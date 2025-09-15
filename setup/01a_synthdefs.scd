// used for tests

// simple drummy mridangam sound
SynthDef( \mrid, { arg out, freq = (60.midicps), amp = 0.1, panL = -1, decay = 0.1;
	var amp2 = AmpComp.kr(freq, 260, 0.17) * amp;
	var sig = Resonz.ar(
		WhiteNoise.ar(50 * amp2) + PinkNoise.ar(50 * amp2)
		* Decay2.kr( Impulse.kr(0), 0.001, decay ),
		freq, 0.02, 4
	).distort;

	DetectSilence.ar( sig,  doneAction: 2 );
	OffsetOut.ar(out, Pan2.ar( sig, panL));
}).add;

/// simple sawy keyboardy sound, not so cool, but clear pitch
SynthDef(\saw, { arg out=0, freq=440, amp=0.1, pan=0, gate=1;
	var filtfreq = freq * amp.expexp(0.1, 1, 1.5, 3) * AmpComp.kr(freq, 400, 0.5).max(1);
	var amp2 = amp * AmpComp.kr(freq).min(3);
	var env = EnvGen.ar(Env.adsr(0.01, 0.5, 0.8, 0.2), gate);
	var snd = LPF.ar(
		Saw.ar(freq),
		filtfreq * (0.5 + env)
	);
	OffsetOut.ar(out, Pan2.ar(snd * env, pan, amp2));
}, [\ir]).add;

/*
(instrument: \saw, note: -36).play;
(instrument: \saw, note: -36, amp: 0.5).play;
(instrument: \saw, note: 0).play;
(instrument: \saw, note: 0, amp: 0.1, sustain: 4).play;
(instrument: \saw, note: 0, amp: 0.2).play;
(instrument: \saw, note: 0, amp: 0.3).play;
(instrument: \saw, note: 0, amp: 0.5).play;

(instrument: \saw, note: 48).play;
*/