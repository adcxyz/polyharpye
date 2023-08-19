// turiangl
(
Ndef(\Ph_triangul).clear.clearHalo.ar(q.numResons);
Ndef(\Ph_triangul).parentGroup_(q.grpList[2]);
Ndef(\Ph_triangul).fadeTime = 2;

Ndef(\Ph_triangul).addSpec(\maxring, [0.0625, 16, \exp]);

MFdef(\ndef_setNet).value(Ndef(\Ph_triangul), 2);

(
Ndef(\Ph_triangul, { |maxring = 16|
	var thisNdef = Ndef(\Ph_triangul);
	var indices = thisNdef.getHalo(\myNet);
	var numRopes = indices.size;
	var pitches = Ndef(\scale).kr[indices].fold(60, 100) + 25;

	var myPost = "% has: \n - indices: % \n - chord: %\n\n".postf(thisNdef, indices,
		Ndef(\scale).bus.getnSynchronous[indices].round(0.001));

	var snds = Ndef(\Pa_micsAll).ar()[indices];
	var trix = Ndef(\Ph_ropeTrixReals).kr()[indices]; // kr !
	var ovt = 6;
	var noize = PinkNoise.ar;
	var dlys;
	var intvs = q.chords.golden.gmpitch * [ 0.382, 0.618, 1];

	snds = snds.collect { |snd, i|
		var freqs, decays;
		var trig = trix[i];
		var env = EnvGen.ar(Env.perc(1/10000, 3/1000, 1, -1), trig);
		Silent.ar;


		freqs = (pitches[i] + [ 0, intvs.choose, intvs.choose.neg ]).collect { |pitch|
			[ pitch, pitch + 0.03.bilinrand ].midicps
		}.flat;

		// freqs = { exprand(2000, 10000) * 1.5 }.dup(ovt div: 2).sort;
		decays = { exprand(0.1, 1) }.dup(freqs.size).sort(_ > _) * maxring;


		snd = DynKlank.ar(`[
			freqs,
			([1, 1, -1, -1 ] * 0.01).wrapExtend(freqs.size),
			decays
			],
			noize*env + RHPF.ar(snd, 85.midicps)
		);
	};

});
);
);

