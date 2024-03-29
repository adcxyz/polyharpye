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

Butz(\poly).add(\scaleGM, {
	// default:
	q.setScale(
		// (q.chords.chords.gmspiral2 ++ q.chords.chords.gmspiral2.keep(-19)).scramble
		q.chords.golden.orderedChord;
	);
});

Butz(\poly).add(\scaleGMRev, {
	// same goldenMean tuning, but reversed
	q.setScale(
		// (q.chords.chords.gmspiral2 ++ q.chords.chords.gmspiral2.keep(-19)).scramble
		q.chords.golden.orderedChord.reverse;
	);
});


Butz(\poly).add(\scaleHung23, {
	q.setScale(q.makeScale(23, \hungarianMinor));
});

Butz(\poly).add(\scaleHung42, {
	q.setScale(q.makeScale(42, \hungarianMinor));
});

