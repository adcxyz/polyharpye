q.scenes = ();

q.scenes.fadeTime = 3;

q.scenes.load = {
	q.scenes.all = (q.dir.poly.dirname +/+ "/SCENES/scene*.scd").pathMatch.collect(_.load);
	"q.scenes.all has % scenes loaded now.\n".postf(q.scenes.all.size);
};
q.scenes.load;

MFdef(\sceneSwitch).add(\perms, { |newdict|
	if (newdict.notNil) {
		"\n\n*** SCENE switching to : %  ***\n\n".postf(newdict.name ? newdict);
		q.wakePerms;
	};
});

MFdef(\sceneSwitch).add(\scale, { |newdict|
	var fadetime = newdict.fadeTime ? q.scenes.fadeTime;

	if (newdict[\scaleName].notNil) {

		forkIfNeeded {
			"new scale: ".postln;
			~scaleSeed = newdict[\scaleSeed] ? ~scaleSeed;
			~scaleName = newdict[\scaleName];
			Ndef(\scale).nodeMap.set(\scale, nil);
			Ndef(\scale).fadeTime = fadetime;
			Ndef(\scale).rebuild;
			q.getScale;
			s.sync;
		};
	} {
		// "sceneSwitch: no scaleName given.".postln;
	};
});

MFdef(\sceneSwitch).add(\name, { |newdict|
	var allScenesNames = q.scenes.all.collect(_.name);
	var currName = newdict.name;
	var currIndex = allScenesNames.indexOf(currName);

	if (currIndex.isNil) {
		"*** NO SCENE found with name %!\n\n".postf(currName);
	} {
		q.scenes.currName = currName;
		q.scenePop !? {
			q.scenePop.items_(allScenesNames);
			q.scenePop.valueAction_(currIndex);
		}
	}
});


/*
MFdef(\sceneSwitch).value( (scaleName: \minor, scaleSeed: 412, name: \scaleTester));
MFdef(\sceneSwitch).value( (scaleName: \diminished, scaleSeed: 4711));

MFdef(\sceneSwitch).value( q.scenes.all[0]);
MFdef(\sceneSwitch).value( q.scenes.all[9]);

MFdef(\sceneSwitch).value( (scaleName: \major, scaleSeed: 4711, fadeTime: 5));
MFdef(\sceneSwitch).value( (scaleName: \minor, scaleSeed: 4711, fadeTime: 1));
MFdef(\sceneSwitch).value( (scaleName: \minor, scaleSeed: 1234.rand, fadeTime: 1));
*/

MFdef(\sceneSwitch).add(\ons, { |newdict|
	var offNdefs = q.ndef.groups[\Sounds].copy;
	forkIfNeeded {
		newdict[\onNdefs].do { |ndefdict|
			offNdefs.remove(ndefdict.ndef);
			// ndefdict.postcs;

			/// ndef, netIndex, fadeTime = 3, vol, settings|
			MFdef(\ndef2net).value(
				ndefdict.ndef,
				ndefdict.netIndex ? q.pos.micGroups.size,
				q.scenes.fadeTime,
				ndefdict.vol,
				ndefdict.settings,
			);
		};
		offNdefs.do(_.end(q.scenes.fadeTime));
	};
});



/*
q.scenes.fadeTime = 0.3;

MFdef(\sceneSwitch).value( (name: \testinger));

MFdef(\sceneSwitch).value( ());

MFdef(\sceneSwitch).(q.scenes.all.choose.postln);

MFdef(\sceneSwitch).value(
(onNdefs:  [
(ndef: Ndef(\ropesRingz), vol: 0.1)
])
);

MFdef(\sceneSwitch).value(
(onNdefs:  [
(ndef: Ndef(\tabloid),
vol: 0.2,
settings: [\detune, 7],
netIndex: [3, 4] // two single mic nodes
)
])
);


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

*/