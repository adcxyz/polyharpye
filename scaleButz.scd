/* TODO:
global fadetime on control
global mic volume on control
more overlapping scenes
ways to add/subtract layers / snd+map
add more tunings?
find UC4 ...
*/

Butz.add(\scaleGM, {
	// default:
	q.setScale(
		// (q.chords.chords.gmspiral2 ++ q.chords.chords.gmspiral2.keep(-19)).scramble
		q.chords.golden.orderedChord;
	);
});

Butz.add(\scaleGMRev, {
	// same goldenMean tuning, but reversed
	q.setScale(
		// (q.chords.chords.gmspiral2 ++ q.chords.chords.gmspiral2.keep(-19)).scramble
		q.chords.golden.orderedChord.reverse;
	);
});


Butz.add(\scaleHung23, {
	q.setScale(q.makeScale(23, \hungarianMinor));
});

Butz.add(\scaleHung42, {
	q.setScale(q.makeScale(42, \hungarianMinor));
});

MKtl.find(\midi);
MKtl(\nk2, "*trol2");

q.scenes.all[0].name;

MKtl(\nk2).elAt(\bt).flat.clump(8).collect(_.keep(4)).flat.do { |el, sceneIndex|
	el.action = { |el|
		if (el.isOn) {
			defer {
				q.scenes.buts[sceneIndex].valueAction_(1);
				[sceneIndex, el].postln;
			};
		};
	};
};

MKtl(\nk2).elAt(\tr).flat.keep(4).do { |el, scaleIndex|
	el.action = { |el|
		if (el.isOn) {
			defer {
				Butz.run([ \scaleGM, \scaleGMRev, \scaleHung23, \scaleHun42][scaleIndex].postcs);
			};
		};
	};
};

MKtl(\nk2).elAt(\kn, 7).action = { |el|
	MasterFX(s).set(\mastaVol, (el.value * 2).squared)
};

MKtl(\nk2).elAt(\kn, 7).action = { |el|
	MasterFX(s).set(\mastaVol, (el.value * 2).squared)
};


// // stereoOut for recording
// Ndef(\stereoOut78, { Splay.ar(InFeedback.ar(0, 6)) * 2 }).play(6);
//
// s.scope(2);

// Ndef.all.localhost.arProxyNames.collect { |name| Ndef(name).index };
// .collect(_.index);