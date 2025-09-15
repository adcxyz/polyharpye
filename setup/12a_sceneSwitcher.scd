PH.scenes = ();

PH.scenes.fadeTime = 3;

PH.scenes.load = {
	PH.scenes.all = (PH.dir.poly.dirname +/+ "/SCENES/scene*.scd").pathMatch.collect(_.load);
	"PH.scenes.all has % scenes loaded now.\n".postf(PH.scenes.all.size);
};
PH.scenes.load;

MFdef(\sceneSwitch).add(\perms, { |newdict|
	if (newdict.notNil) {
		"\n\n*** SCENE switching to : %  ***\n\n".postf(newdict.name ? newdict);
		PH.wakePerms;
	};
});

MFdef(\sceneSwitch).add(\scale, { |newdict|
	var fadetime = newdict.fadeTime ? PH.scenes.fadeTime;

	if (newdict[\scaleName].notNil) {

		forkIfNeeded {
			"new scale: ".postln;
			~scaleSeed = newdict[\scaleSeed] ? ~scaleSeed;
			~scaleName = newdict[\scaleName];
			Ndef(\scale).nodeMap.set(\scale, nil);
			Ndef(\scale).fadeTime = fadetime;
			Ndef(\scale).rebuild;
			PH.getScale;
			s.sync;
		};
	} {
		// "sceneSwitch: no scaleName given.".postln;
	};
});

MFdef(\sceneSwitch).add(\name, { |newdict|
	var allScenesNames = PH.scenes.all.collect(_.name);
	var currName = newdict.name;
	var currIndex = allScenesNames.indexOf(currName);

	if (currIndex.isNil) {
		"*** NO SCENE found with name %!\n\n".postf(currName);
	} {
		PH.scenes.currName = currName;
		PH.scenePop !? {
			PH.scenePop.items_(allScenesNames);
			PH.scenePop.valueAction_(currIndex);
		}
	}
});


/*
MFdef(\sceneSwitch).value( (scaleName: \minor, scaleSeed: 412, name: \scaleTester));
MFdef(\sceneSwitch).value( (scaleName: \diminished, scaleSeed: 4711));

MFdef(\sceneSwitch).value( PH.scenes.all[0]);
MFdef(\sceneSwitch).value( PH.scenes.all[9]);

MFdef(\sceneSwitch).value( (scaleName: \major, scaleSeed: 4711, fadeTime: 5));
MFdef(\sceneSwitch).value( (scaleName: \minor, scaleSeed: 4711, fadeTime: 1));
MFdef(\sceneSwitch).value( (scaleName: \minor, scaleSeed: 1234.rand, fadeTime: 1));
*/

MFdef(\sceneSwitch).add(\ons, { |newdict|
	var offNdefs = PH.ndef.groups[\Sounds].copy;
	forkIfNeeded {
		newdict[\onNdefs].do { |ndefdict|
			offNdefs.remove(ndefdict.ndef);
			// ndefdict.postcs;

			/// ndef, netIndex, fadeTime = 3, vol, settings|
			MFdef(\ndef2net).value(
				ndefdict.ndef,
				ndefdict.netIndex ? PH.pos.micGroups.size,
				PH.scenes.fadeTime,
				ndefdict.vol,
				ndefdict.settings,
			);
		};
		offNdefs.do(_.end(PH.scenes.fadeTime));
	};
});




PH.scenes.fadeTime = 0.3;

MFdef(\sceneSwitch).value( (name: \testinger) );

MFdef(\sceneSwitch).value( () );

MFdef(\sceneSwitch).(PH.scenes.all.choose.postln);

/*
(
MFdef(\sceneSwitch).value(
	(onNdefs:  [
		(ndef: Ndef(\ropesRingz), vol: 0.1)
	])
);
)

(
MFdef(\sceneSwitch).value(
	(onNdefs:  [
		(ndef: Ndef(\tabloid),
			vol: 0.2,
			settings: [\detune, 7],
			netIndex: [3, 4] // two single mic nodes
		)
	])
);
)

(
MFdef(\sceneSwitch).value(
	(
		scaleSeed: 23,
		scaleName: \hungarianMinor,
		onNdefs:  [
			(ndef: Ndef(\tabloid),
				vol: 0.2,
				settings: [\detune, -7],
				netIndex: [3, 4]
			)
	])
);
)

*/