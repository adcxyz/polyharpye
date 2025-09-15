(
Ndef(\Ph_sawAM).clear.clearHalo;
Ndef(\Ph_sawAM).ar(PH.numResons);

Ndef(\Ph_sawAM).parentGroup_(PH.grpList[2]);
Ndef(\Ph_sawAM).vol = 0.25;
Ndef(\Ph_sawAM).fadeTime = 5;

MFdef(\ndef_setNet).value(Ndef(\Ph_sawAM), 12);

Ndef('Ph_sawAM').addSpec('transpose', [ -24, 24, \lin, 0.01]);

Ndef(\Ph_sawAM, {|transpose = -12, amp = 1.0, rq = 0.4|
	var thisNdef = Ndef(\Ph_sawAM);
	var netNames = thisNdef.getHalo(\myNetNames);
	var indices = thisNdef.getHalo(\myNet);
	var numRopes = indices.size;
	var pitches = Ndef(\scale).kr[indices];

	var myPost = "% has: \n - indices: % \n - chord: %\n\n".postf(thisNdef, indices,
		Ndef(\scale).bus.getnSynchronous[indices].round(0.001));

	var amps = (Ndef(\Ph_ropeTrigs).kr()[indices].lag2ud(0.1, 1) * 6 - 0.01).clip(0, 0.5);
	var freqs = (Ndef(\scale).kr[indices] + transpose).midicps.collect { |val|
		val * SinOsc.kr(rrand(2.0, 12.0), 0, rrand(0, 0.003), 1)
	};
	var micModSigs = Ndef(\Pa_micsAll).ar[indices];
	RLPF.ar(
		LFSaw.ar(freqs) * (1 + micModSigs) * amps * SinOsc.ar(freqs / 24, 0, 0.5,0.5) * amp,
		LFDNoise3.kr({ exprand(0.1, 1) }.dup(indices.size), 12, 96).midicps,
		rq
	);
});
try { s.sync };

);