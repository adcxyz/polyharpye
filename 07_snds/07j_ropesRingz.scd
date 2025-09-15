/*****
orig by Dominik Hildebrand for STS@PdT
finetuned by adc for polyharpye

*****/

Ndef(\Ph_ropesRingz).clear.clearHalo;
Ndef(\Ph_ropesRingz).ar(PH.numResons);
Ndef(\Ph_ropesRingz).parentGroup_(PH.grpList[2]);

Ndef(\Ph_ropesRingz).vol = 0.25;
Ndef(\Ph_ropesRingz).fadeTime = 5;

MFdef(\ndef_setNet).value(Ndef(\Ph_ropesRingz), 9);

Ndef(\Ph_ropesRingz).addSpec(\decTime, [0.01,2.0,\lin]);
Ndef(\Ph_ropesRingz).addSpec(\decTime, [0.1, 10, \exp]);
Ndef(\Ph_ropesRingz).addSpec(\white, [0, 4, \amp]);
Ndef(\Ph_ropesRingz).addSpec(\amp2pitch, [-0.1, 0.1]);
Ndef(\Ph_ropesRingz).addSpec(\decTime, [0.25, 16, \exp]);
Ndef(\Ph_ropesRingz).addSpec(\whiten, [0, 4, \amp]);
Ndef('Ph_ropesRingz').addSpec('transpose', [ -24 , 24, \lin, 0.01]);

(
Ndef(\Ph_ropesRingz, {|amp = 0.5, decTime = 3.5, transpose = 0, whiten = 1, amp2pitch = 0.03|
	var thisNdef = Ndef(\Ph_ropesRingz);
	var netNames = thisNdef.getHalo(\myNetNames);
	var indices = thisNdef.getHalo(\myNet);
	var numRopes = indices.size;
	var pitches = Ndef(\scale).kr[indices] + transpose;

	var myPost = "% has: \n - indices: % \n - chord: %\n\n".postf(thisNdef, indices,
	Ndef(\scale).bus.getnSynchronous[indices].round(0.001));

	var inputs = RHPF.ar(Ndef(\Pa_micsAll).ar()[indices], 100, 0.7) * (0.1 * amp.lag(1));
	var amps = (Ndef(\Ph_ropeTrigs).kr[indices].lag2ud(0, 0.2) - 0.01).clip(0, 0.5);
	var freqs =  (Ndef(\scale).kr[indices] + transpose.lag(3)).midicps;
	var basefreqScalers  = (freqs < 100 + 1);  // 2 for low freqs, 1 for above 100
	var freqs2 =  freqs * (amps * amp2pitch + 1);

	// whiten the inputs:
	var inputs2 = inputs * WhiteNoise.ar(whiten, 1);

	var filterA = Ringz.ar(inputs * 0.7, freqs2 * basefreqScalers, decTime)
	* SinOsc.kr( {6 + 2.0.rand}.dup(numRopes), 0, 0.2, 0.8);
	var filterB = Ringz.ar(inputs, freqs2 * 3.03, decTime * 1.4)
	* SinOsc.kr( {6 + 3.0.rand}.dup(numRopes), 0, 0.2, 0.8);
	var filterC = Ringz.ar(inputs * 0.8, freqs2 * 5.07, decTime * 0.7)
	* SinOsc.kr( {6 + 5.0.rand}.dup(numRopes), 0, 0.2, 0.8);
	var snd = (filterA + filterB + filterC );
	snd = snd.tanh;
	snd
});
);