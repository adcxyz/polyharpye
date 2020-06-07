(
Ndef(\Ph_tabloid).clear.clearHalo;
Ndef(\Ph_tabloid).ar(q.numResons);

Ndef(\Ph_tabloid).parentGroup_(q.grpList[2]);
Ndef(\Ph_tabloid).vol = 0.25;
Ndef(\Ph_tabloid).fadeTime = 5;

MFdef(\ndef_setNet).value(Ndef(\Ph_tabloid), 1);

Ndef(\Ph_tabloid).addSpec(\amp2pitch, [-0.1, 0.1]);
Ndef(\Ph_tabloid).addSpec(\whiten, [0, 1]);
Ndef(\Ph_tabloid).addSpec(\decayScale, [0.2, 5, \exp]);

Ndef(\Ph_tabloid, {|amp = 1.0, decayScale = 1.2, transpose = 0, hpfreq = 200, whiten = 0.75, amp2pitch = 0.05|
	var thisNdef = Ndef(\Ph_tabloid);
	var indices = thisNdef.getHalo(\myNet);
	var numRopes = indices.size;

	var myPost = "% has: \n - indices: % \n - chord: %\n\n".postf(thisNdef, indices,
		Ndef(\scale).bus.getnSynchronous[indices].round(0.001));

	var amps = (Ndef(\Ph_ropeTrigs).kr[indices].lag2ud(0, 0.2) - 0.01).clip(0, 0.5);
	var inputs = RHPF.ar(Ndef(\Pa_micsAll).ar()[indices] * 0.1, hpfreq, 0.7);
	var inputs2 = inputs * (0.4 * blend(1, GrayNoise.ar, whiten));
	var freqs =  (Ndef(\scale).kr[indices] + transpose.lag(1)).midicps;
	var freqs2 =  freqs * (amps * amp2pitch + 1);
	var ringfreqs = [ 1.0, 1.5133, 2.0159, 2.54867, 3.0708 ];
	var ringcomp = AmpComp.kr(freqs.max(50));
	var ampcomp = AmpComp.kr(freqs.max(250), exp: 0.3);
	var decayscalers = ([ 2.625, 0.9, 1.2, 0.375, 0.45 ] * decayScale).clip(0.1, 3);
	var snd = (Ringz.ar(
		inputs2,
		freqs2.collect (_ * ringfreqs),
		ringcomp.collect (_ * decayscalers),
	).sum * ampcomp).tanh;
	snd
});
try { s.sync };
);