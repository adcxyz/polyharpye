///// Listen to the chords with a simple Ndef
/*
TODO:
- better instrument sound
- better hi-lo balance
- hold notes with keys
- could also play noise bursts directly into micsMax!
*/

// set a current chord to explore:
q.chords.base = 60;
q.chords.curr = q.chords.chords.gmspiral2;

// post all available chords:
"*** all available q.chords.chords: \n%\n\n".postf(q.chords.chords.keys(SortedList).cs);

// play its notes from a KeyPlayer
// 46 fits exactly!
Butz.add(\ChordPlayer, { WinBounds.showOrMake(\chordPlayer) });
WinBounds.addMake(\chordPlayer, { k.gui.parent.name_(\chordPlayer) });

(
k = KeyPlayer('kord');

"`zxcvbnm,./asdfghjkl;'qwertyuiop[]1234567890-=".do { |char, i|
	k.putDown(char, {
		var key = q.chords.chords.findKeyForValue(q.chords.curr);
		var pitch = (q.chords.curr.wrapAt(i) + q.chords.base);
		"char: % chord % i: %, pitch: %\n"
		.postf(char.cs, key.cs, i, pitch.round(0.001));
		(instrument: \saw, midinote: pitch, pan: 0.8.rand2).play;
	}, noRep: true);

};
);
(
// arpeggio of all its notes in
Pdef(\z_kord, Pbind(
	\midinote, Pseq(q.chords.curr + q.chords.base, inf),
	//	\instrument, \default,
	\pan, Pwhite(-0.8, 0.8),
	\sustain, 2,
	\dur, 0.25
));
);

// random melody and bass
(
Pdef(\z_kord2v,
	Ppar([
		Pbind(
			\midinote, Pindex(
				q.chords.chords.gmspiral2 + q.chords.base,
				Pbrown(0, 45, 5),
			),
			\pan, -0.7,
			\sustain, 0.5,
			\dur, 0.25
		),
		Pbind(
			\midinote, Pindex(
				q.chords.chords.gmspiral2 + q.chords.base,
				Pbrown(0, 45, 2),
			),
			\pan, 0.7,
			\sustain, 0.5,
			\dur, 1/6
		)
	])
);
);

// (
// // xfade between chords
// q.chords.xfade = { |ch, key, base, fadeTime|
// 	key = if (q.chords.chords[key].notNil, key, q.chords.chords.keys.choose);
// 	q.chords.nextKey = key.postcs;
// 	base = base ?? { rrand(24, 48) };
// 	q.chords.base = base.postln;
// 	q.chords.curr = q.chords.chords[key].round(0.001).postln.scramble;
// 	Ndef(\z_kord).fadeTime = fadeTime ? exprand(0.1, 10);
// 	Ndef(\z_kord).rebuild;
// };
// //
// // // init once
// // q.chords.xfade(\golden, nil, 5);
// // q.chords.xfade( 'gmspiral', 60, 5);
// /*
// q.chords.xfade(nil, nil, 5); // random
// q.chords.xfade(nil, nil, 5); // random
//
// (q.chords.chords.gmspiral2 + 60).midicps[[0, 45]];
// q.chords.chords.gmspiral2.plot("gmspiral", nil, true);
// q.chords.chords.gmspiral2.differentiate.drop(1).plot;
//
// // Random pling plong sounds, mouse left-right strums, up makes it loud
//
// Ndef(\z_kord, { |decay = 8, width = 2|
// var numOuts = 2; // 6;
// var chord = q.chords.curr;
// var freqs = (chord + q.chords.base).midicps;
// var numSnds = freqs.size;
//
// var mx = MouseX.kr(0, 4), my = MouseY.kr(0, 1).squared;
// var micSim = PanAz.ar(chord.size,
// Decay2.ar(Dust2.ar(10, GrayNoise.ar(0.25, 0.25)), 0.001, 0.01),
// mx + LFSaw.kr(0.1) * 2,
// my, width);
//
// var detune = LFDNoise3.kr(0.2 ! numSnds, 0.003, 1);
// var strings = Ringz.ar(micSim,
// freqs + detune,
// (1000 / freqs ** 0.5).min(1) * decay
// ).tanh;
//
// var out = strings.tanh;
// var rev = AdCVerb2.ar(out.sum * 0.03, hfDamping: 0.3, nOuts: numOuts);
// "*** numSnds: % freqs: \n%\n".postf(numSnds, freqs.round(0.01));
//
// if (numOuts > 2) {
// out = SplayAz.ar(numOuts, out)
// } {
// out = Splay.ar(out);
// };
// out + rev
// }).play(0, vol: 0.5);
// )
//
// )