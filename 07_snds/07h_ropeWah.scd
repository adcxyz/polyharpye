////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////
// wah wah . wah wah //
(
Ndef(\Ph_ropeWah).clear.clearHalo.ar(PH.numResons);
Ndef(\Ph_ropeWah).parentGroup_(PH.grpList[2]);
Ndef(\Ph_ropeWah).fadeTime = 2;

Ndef(\Ph_ropeWah).addSpec(\attT, [0, 2, 5]);
Ndef(\Ph_ropeWah).addSpec(\dcyT, [0, 2, 5]);
Ndef(\Ph_ropeWah).addSpec(\octSpan, [-6, 6, \lin, 0.1]);
Ndef(\Ph_ropeWah).addSpec(\freqLo, \freq);
Ndef(\Ph_ropeWah).addSpec(\freqHi, \freq);

MFdef(\ndef_setNet).value(Ndef(\Ph_ropeWah), 7);

Ndef(\Ph_ropeWah, { |amp=1, attT= 0.02, dcyT= 0.5, freqLo= 2000, freqHi = 150, rq=0.2|
	var thisNdef = Ndef(\Ph_ropeWah);
	var netNames = thisNdef.getHalo(\myNetNames);
	var indices = thisNdef.getHalo(\myNet);
	var numRopes = indices.size;
	var pitches = Ndef(\scale).kr[indices];

	var myPost = "% has: \n - indices: % \n - chord: %\n\n".postf(thisNdef, indices,
		Ndef(\scale).bus.getnSynchronous[indices].round(0.001));

	var inSounds = Ndef(\Pa_micsAll).ar()[indices];

	var peax = Ndef(\Ph_ropeTrigs).kr()[indices].lag2ud(attT,dcyT);
	var noiz = PinkNoise.ar * peax;
	Limiter.ar(
		RHPF.ar(
			inSounds + noiz * amp,
			peax.linexp(0, 0.6, freqLo, freqHi, \inMin).clip(50, 12000),
			rq
		).tanh
	)
});
);
/* home testin'
Ndef(\Ph_ropeWah).playN([0,1], [1], vol: 1);
*/