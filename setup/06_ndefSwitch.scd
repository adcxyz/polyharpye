///////////// // support keys also? //

/****** SWITCH AN Ndef's mics and outputs:

// ///////just set the next net or nets to prepare
MFdef(\ndef_setNet).value(Ndef(\x), 0);
MFdef(\ndef_setNet).value(Ndef(\x), 1);

/// support polyphony - indices from multiple micGroups are merged
MFdef(\ndef_setNet).value(Ndef(\x), [0, 1]);
MFdef(\ndef_setNet).value(Ndef(\x), [1, 1]);
Ndef(\x).getHalo;
MFdef(\ndef_setNet).value(Ndef(\x), PH.pos.allNets);

MFdef(\ndef_setNet).value(Ndef(\x), (0, 4 .. PH.pos.lastNet));

PH.pos.allNets
PH.pos.numNets
PH.pos.lastNet

//////// SET NET NUMBER directly by hand:
Ndef(\Ph_sitar1).addHalo(\myNet, (0..31));
// then rebuild Ndef using these
MFdef(\ndef_playNet).value(Ndef(\Ph_sitar1));

///////// rebuild and play the ndef

MFdef(\ndef_playNet).(Ndef(\Ph_sitar1), 3, 0.1, [\detune, 6.5] );
MFdef(\ndef_playNet).(Ndef(\Ph_sitar1), 1, 0.5, [\detune, 4.5] );

////// \ndef2net does both together :
MFdef(\ndef2net).value(Ndef(\Ph_sitar1), [0, 1, 2], 2, 0.2, [\amp, 0.1]);

// further args when switching: fadeTime, vol, parameters
MFdef(\ndef2net).value(Ndef('tabloid'), PH.pos.allNets, 5, 0.15, [\detune, -7]);

Ndef('tabloid').end(5);
*/

MFdef(\ndef_setNet).add(\set, { |ndef, netIndex|
	var namedPosList = PH.pos.micGroups;
	var netNames = netIndex.asArray.collect { |nameOrIndex|
		if (nameOrIndex.isKindOf(Symbol)) { nameOrIndex } {
			namedPosList.names[nameOrIndex]
		}
	}.select(_.notNil);

	var netIndices = namedPosList[netNames].flat;
	var mergedIndices = netIndices.asSet.asArray.sort;
	"% -> groups % \n - merged % indices to % \n"
	.postf(ndef, netNames.cs, netIndices.size, mergedIndices.size);

	ndef.addHalo(\netNames, netNames);
	ndef.addHalo(\myNet, mergedIndices);
});

// just remake it based on myNet only
// - in case no named nets were used
MFdef(\ndef_playNet).add(\redo, { |ndef, fadeTime = 3, vol, settings|
	var oldVol = if (ndef.monitor.isNil, 0.0, { ndef.vol });
	var netIndices = ndef.getHalo(\myNet);
	vol =  vol ? oldVol;

	if (netIndices.notNil) {
		forkIfNeeded {
			settings !? { ndef.nodeMap.set(*settings.flat) };
			ndef.fadeTime = fadeTime;
			ndef.rebuild;
			s.sync;
			"%.playN\n".postf(ndef);
			ndef.playN(PH.pos.omnibus.index + netIndices, vol: vol, fadeTime: fadeTime);
		};
		ndef
	} {
		"MFdef('ndef_redo') / % - no netIndices found\n".postf(ndef);
		nil
	};

});

MFdef(\ndef2net).add(\switch, { |ndef, netIndex, fadeTime = 3, vol, settings|
	forkIfNeeded {
		MFdef(\ndef_setNet).value(ndef, netIndex);
		MFdef(\ndef_playNet).value(ndef, fadeTime, vol, settings);
		try { s.sync };
	};
});

// rebuild one Ndef with a random choice of groups, just give it a size:
MFdef(\playRandGroups).add(\groups, { |ndef, numGroups = 2, fadeTime = 3 |
	fork {
		var netGroups = (0..PH.pos.micGroups.lastIndex).scramble.keep(numGroups).postln;
		MFdef(\ndef2net).value(
			ndef,
			netGroups,
			fadeTime
		);
	}
});

/*
MFdef(\playRandGroups).value(Ndef('Ph_sitar1'), 1); // few notes, usually 10
MFdef(\playRandGroups).value(Ndef('Ph_tabloid'), 2); // usually 18-20
MFdef(\playRandGroups).value(Ndef('Ph_glassy'), 4);  // around 30
MFdef(\playRandGroups).value(Ndef('Ph_sitar1'), 8); // usually all 46
*/
