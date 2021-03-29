/* TODO:
global fadetime on control
global mic volume on control
more overlapping scenes
ways to add/subtract layers / snd+map
add more tunings?
find UC4 ...
*/

/*
MKtl(\nk2).gui;
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

// S 1 2 3 4,
// M 1 2 3 4,
// S 5 6 7 8,
// M 5 6 7 8,

MKtl(\nk2).elAt(\bt, [\S, \M]).collect(_.clump(4)).flatten[[0, 2, 1, 3]].flat.do { |el, sceneIndex|
	el.action = { |el|
		if (el.isOn) {
			defer {
				q.scenes.buts[sceneIndex].valueAction_(1);
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
	MainFX(s).set(\mainVol, (el.value * 2).squared)
};

// top 8 sounds to toggle directly:
q.ndef.top8.do { |ndf, i|
	// slider softsets vol and pauses when 0
	MKtl(\nk2).elAt(\sl, i).action = { |sl|
		ndf.softVol_(sl.value, lastVal: sl.prevValue);
	};
	// button R toggles on/off
	// ? hold down modifier to get full chans?
	MKtl(\nk2).elAt(\bt, \R, i).action = { |bt|
		if (bt.isOn) {
			if (ndf.monitor.isPlaying) { ndf.stop } { ndf.play }
		}
	}
};


// // stereoOut for recording
// Ndef(\stereoOut78, { Splay.ar(InFeedback.ar(0, 6)) * 2 }).play(6);
//
// s.scope(2);

// Ndef.all.localhost.arProxyNames.collect { |name| Ndef(name).index };
// .collect(_.index);