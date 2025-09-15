/////////// glass harmonica
(
Ndef(\Ph_glassy).clear.clearHalo;
Ndef(\Ph_glassy).ar(PH.numResons);

MFdef(\ndef_setNet).value(Ndef(\Ph_glassy), 3);

Ndef(\Ph_glassy).parentGroup_(PH.grpList[2]);
Ndef(\Ph_glassy).vol = 0.25;
Ndef(\Ph_glassy).fadeTime = 5;

Ndef(\Ph_glassy).addSpec(\modDepth, [0, 0.1, 2]);
Ndef(\Ph_glassy).addSpec(\modRate, [0.5, 16, \exp]);
Ndef(\Ph_glassy).addSpec(\micMod, [0, 1]);
Ndef(\Ph_glassy).addSpec(\transpose, [-24, 24,\lin, 0.01]);


Ndef(\Ph_glassy, { |modDepth = 0.003, modRate = 6, micMod = 0.2, transpose = 0|
	var thisNdef = Ndef(\Ph_glassy);
	var netNames = thisNdef.getHalo(\myNetNames);
	var indices = thisNdef.getHalo(\myNet);
	var numRopes = indices.size;

	var myPost = "% has % indices: \n - % \n - chord: %\n\n"
	.postf(thisNdef, numRopes, indices,
		Ndef(\scale).bus.getnSynchronous[indices].round(0.001)
	);

	var micModSigs = Ndef(\Pa_micsAll).ar[indices];
	var ropeamps = Ndef(\Ph_ropeTrigs).kr[indices].lag2ud(0.1, 1);

	var amps = (ropeamps.lag2ud(0.02, 4) * 6 - 0.02).clip(0, 0.5);

	var  mychord = Ndef(\scale).kr[indices];
	var pitches = mychord + transpose.lag(1);
	var freqs = pitches.midicps.collect { |val|
		var vib = SinOsc.kr(
			modRate * exprand(0.67, 1.5), 0,
			modDepth.max(0.001)
			* exprand(0.33, 0.75)
		);
		val * (1 + vib);
	};

	var ampcomps = AmpComp.kr(freqs);

	(
		SinOsc.ar(freqs)
		* (1 + (micModSigs * (micMod * 2)))
		* (ropeamps * 5 * ampcomps)
	)
	.tanh;
});
);
