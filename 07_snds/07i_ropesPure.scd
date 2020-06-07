
Ndef(\Ph_ropesPure).clear;
Ndef(\Ph_ropesPure).clearHalo;
Ndef(\Ph_ropesPure).ar(q.numResons);

Ndef(\Ph_ropesPure).vol = 0.25;
Ndef(\Ph_ropesPure).fadeTime = 5;

MFdef(\ndef_setNet).value(Ndef(\Ph_ropesPure), 8);

Ndef(\Ph_ropesPure).getHalo;

Ndef(\Ph_ropesPure).addSpec(\treble, [-12, 12]);

Ndef(\Ph_ropesPure, {|hpfreq = 20, tiltfreq = 1000, treble = 12|
	var thisNdef = Ndef(\Ph_ropesPure);
	var netNames = thisNdef.getHalo(\myNetNames);
	var indices = thisNdef.getHalo(\myNet);
	var numRopes = indices.size;
	var pitches = Ndef(\scale).kr[indices];

	var myPost = "% has % indices:\n - % \n\n"
	.postf(thisNdef, numRopes, indices);


	var inputs = HPF.ar(Ndef(\Pa_micsAll).ar()[indices], hpfreq.lag(1));

	var lows = RLPF.ar(inputs, tiltfreq, 0.7);
	var highs = inputs - lows;

	var snd = lows + (highs * treble.dbamp);

	snd
});
