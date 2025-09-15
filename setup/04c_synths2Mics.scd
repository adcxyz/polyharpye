SynthDef( \mrid, { arg out, freq = (60.midicps), amp = 0.1, panL = -1;
	var sig = Resonz.ar(
		WhiteNoise.ar(100 * amp)
		* Decay2.kr( Impulse.kr(0), 0.002, 0.1 ),
		freq, 0.02, 4
	).distort;

	DetectSilence.ar( sig,  doneAction: 2 );
	OffsetOut.ar(out, Pan2.ar( sig, panL));
}).add;

/*
// straight to outs
(instrument: \mrid, out: 0, amp: 0.1).play;
*/

Pdef(\mrid1Spk,
	Pbind(
		\out, Pseq((0..PH.numSpks-1), inf),
		\degree, Pseq((0..5) - 7, inf),
		\instrument, \mrid,
	)
);
/*
(instrument: \mrid, amp: 0.02, out: Ndef(\Pa_micIns).index + 1).play;
*/



///// play into the real mic ins, xy-spread spatial
Pdef(\mrid2Mics,
	Pbind(
		\out, Pn(Pseries(Ndef(\Pa_micIns).index, 1, PH.numMics), inf),
		\instrument, \mrid,
		\amp, 0.1,
		\degree, Pseq((0..5) - 7, inf),
		\dur, 0.5
	)
);

///// play all virtual micIns
Pdef(\mrid3Resons,
	Pbind(
		\instrument, \mrid,
		\amp, 0.1,
		\out, Ndef(\Pa_micsMax).index + Pn(Pseries(0, 1, PH.numResons)),
		\degree, Pseq((0..5) - 7, inf),
		\dur, 0.25
	)
);
