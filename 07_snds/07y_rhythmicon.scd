// check out TempoBusClock ...
Spec.add(\tempo, [0.25, 8, \exp]);

Ndef(\time16, { |tempo = 1|
	Impulse.ar(tempo * ((1..16) * 0.5), { -0.001.rand } );
});
try { s.sync };
/*
Ndef(\time16).play(vol: 0.25);
*/

Ndef(\Ph_rhythmicon).clear;
Ndef(\Ph_rhythmicon).clearHalo;
Ndef(\Ph_rhythmicon).ar(q.numResons);
Ndef(\Ph_rhythmicon).parentGroup_(q.grpList[2]);
Ndef(\Ph_rhythmicon).fadeTime = 2;

MFdef(\ndef_setNet).value(Ndef(\Ph_rhythmicon), 10);

Ndef(\Ph_rhythmicon).addSpec(\minamp,  [0, 0.1]);
Ndef(\Ph_rhythmicon).addSpec(\baserate,  [0.618, 11.09, \exp]);

Ndef(\Ph_rhythmicon, { |minamp = 0.0, baserate = 2.618|
	var thisNdef = Ndef(\Ph_rhythmicon);
	var indices = thisNdef.getHalo(\myNet);
	var numRopes = indices.size;
	var pitches = Ndef(\scale).kr[indices];
	var freqs = pitches.midicps;
	var rates = q.getScale[indices].midiratio * baserate;
	var poster = "- % \n- : %\n".postf(indices);

	var tix = Impulse.ar(rates, 0, [1, -1].wrapExtend(numRopes)).lag2ud(0, 0.0003);
	var amps = (Ndef(\Ph_ropeTrigs).kr[indices] * 3).lag2ud(0.0, 0.5);
	var snd = Ringz.ar(
		(tix * (max(amps, minamp)).clip2(1)),
		freqs * (1 + (amps.collect (_ * rrand(0.02, 0.1)))),
		1/rates;
	).tanh;

	snd;
});
