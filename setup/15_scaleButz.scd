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
	PH.setScale(
		// (PH.chords.chords.gmspiral2 ++ PH.chords.chords.gmspiral2.keep(-19)).scramble
		PH.chords.golden.orderedChord;
	);
});

Butz(\poly).add(\scaleGMRev, {
	// same goldenMean tuning, but reversed
	PH.setScale(
		// (PH.chords.chords.gmspiral2 ++ PH.chords.chords.gmspiral2.keep(-19)).scramble
		PH.chords.golden.orderedChord.reverse;
	);
});


Butz(\poly).add(\scaleHung23, {
	PH.setScale(PH.makeScale(23, \hungarianMinor));
});

Butz(\poly).add(\scaleHung42, {
	PH.setScale(PH.makeScale(42, \hungarianMinor));
});

