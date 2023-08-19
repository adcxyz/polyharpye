/////// nanoKontrol!

MKtlGUI.showLabels = true;
MKtl.find(\midi);
MKtl(\nanoK2, "*trol2");
/*
MKtl(\nanoK2).gui;
*/
///// scenes are:
// S 1 2 3 4,
// M 1 2 3 4,
// S 5 6 7 8,
// M 5 6 7 8,

Butz(\poly).add(\nanoK2, { WinBounds.showOrMake(\nanoK2) });
WinBounds.addMake(\nanoK2, {
	MKtl(\nanoK2).gui.parent;
});

// Butz(\poly).add('END', { q.ndef.groups[\Sounds].do(_.end(5)); });

MKtl(\nanoK2).elAt(\bt, \S, 0).elemDesc;

MKtl(\nanoK2).elAt(\bt, [\S, \M]).flat.do { |el, sceneIndex|
	el.elemDesc.label = q.scenes.buts[sceneIndex].states[0][0];
	el.action = { |el|
		if (el.isOn) {
			defer {
				q.scenes.buts[sceneIndex].valueAction_(1);
			};
		};
	};
};

// transport buttons switch scales
MKtl(\nanoK2).elAt(\tr).flat.keep(4).do { |el, scaleIndex|
	var scaleNames = [ \scaleGM, \scaleGMRev, \scaleHung23, \scaleHung42];
	el.elemDesc.label = scaleNames[scaleIndex].asString.drop(5);
	el.action = { |el|
		if (el.isOn) {
			defer {
				Butz(\poly).run(scaleNames[scaleIndex].postcs);
			};
		};
	};
};




// leave last knob at direct volume control for emergency OFF
MKtl(\nanoK2).elAt(\kn, 7).elemDesc.label = "VOL";
MKtl(\nanoK2).elAt(\kn, 7).action = { |el|
	el.elemDesc.label = "VOL";
	MainFX(s).set(\mainVol, (el.value * 2).squared)
};


MKtl(\nanoK2).elAt(\tr, \tleft).action = { |bt|
	if (bt.isOn.not) {
		MFdef(\mainPreStep).(1);
	};
};
MKtl(\nanoK2).elAt(\tr, \tright).action = { |bt|
	if (bt.isOn.not) {
		MFdef(\mainPreStep).(-1);
	}
};

// three buttons to read for number of nets to activate
MKtl(\nanoK2).elAt(\tr, \mset).elemDesc.label = "RDN1";
MKtl(\nanoK2).elAt(\tr, \mleft).elemDesc.label = "RDN2";
MKtl(\nanoK2).elAt(\tr, \mright).elemDesc.label = "RDN4";

MKtl(\nanoK2).elAt(\tr, \cycle).elemDesc.label = "swap";
MKtl(\nanoK2).elAt(\tr, \cycle).action = { |bt|
	var numPairs2Swap = 3;
	// if mset, mright or mleft buttons are down, reset nodes in 3 sizes:
	case { bt.source.elAt(\tr, \mright).isOn } {
		"swap ALL".postln;
		numPairs2Swap = 24;
	} { bt.source.elAt(\tr, \mleft).isOn } {
		"swap 1/2".postln;
		numPairs2Swap = 12;
	} { bt.source.elAt(\tr, \mset).isOn } {
		"swap 1/4".postln;
		numPairs2Swap = 6;
	} {
		"swap 1/8".postln;
	};
	q.modScale(numPairs2Swap);
};


// top 8 sounds to toggle directly:
q.ndef.groups.top8.do { |ndf, i|
	var ndefname = ndf.key.asString.drop(3).keep(4);
	// slider softsets vol and pauses when 0
	MKtl(\nanoK2).elAt(\sl, i).elemDesc.label = ndefname ++ " vol";
	MKtl(\nanoK2).elAt(\sl, i).action = { |sl|
		ndf.softVol_(sl.value, lastVal: sl.prevValue);
	};
	// button R toggles on/off
	// ? hold down modifier to get full chans?

	MKtl(\nanoK2).elAt(\bt, \R, i).elemDesc.label = ndefname ++ " play";
	MKtl(\nanoK2).elAt(\bt, \R, i).action = { |bt|
		var numNodes;
		if (bt.isOn) {
			if (ndf.monitor.isPlaying) {
				ndf.stop
			} {
				// if mset, mright or mleft buttons are down, reset nodes in 3 sizes:
				case { bt.source.elAt(\tr, \mright).isOn } {
					"many nodes".postln;
					numNodes = 4;
				} { bt.source.elAt(\tr, \mleft).isOn } {
					"half nodes".postln;
					numNodes = 2;
				} { bt.source.elAt(\tr, \mset).isOn } {
					"few nodes".postln;
					numNodes = 1;
				} {
					"keep nodes".postln;
				};
				if (numNodes.isNil) {
					// just play with previous nodes
					ndf.play;
				} {
					MFdef(\playRandGroups).value(ndf, numNodes);
				};
			}
		}
	}
};
//
