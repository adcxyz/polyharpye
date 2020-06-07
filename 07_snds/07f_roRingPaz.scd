///// dominik style ringz in overtones 1, 3, 5 tuning
(
Ndef(\Ph_roRingPaz).clear.clearHalo;
Ndef(\Ph_roRingPaz).ar(q.numResons);

Ndef(\Ph_roRingPaz).parentGroup_(q.grpList[2]);
Ndef(\Ph_roRingPaz).vol = 0.25;
Ndef(\Ph_roRingPaz).fadeTime = 5;
Ndef(\Ph_roRingPaz).addSpec(\decTime, [0.01,2.0,\lin]);

MFdef(\ndef_setNet).value(Ndef(\Ph_roRingPaz), 5);

Ndef(\Ph_roRingPaz, {|amp = 1.0, decTime = 0.9, detune = 0|
	var thisNdef = Ndef(\Ph_roRingPaz);
	var netNames = thisNdef.getHalo(\myNetNames);
	var indices = thisNdef.getHalo(\myNet);
	var numRopes = indices.size;
	var pitches = Ndef(\scale).kr[indices];

	var myPost = "% has % indices: \n - % \n - chord: %\n\n"
	.postf(thisNdef, numRopes, indices,
		Ndef(\scale).bus.getnSynchronous[indices].round(0.001)
	);

	var snds = RHPF.ar(Ndef(\Pa_micsAll).ar()[indices], 200, 0.7) * (0.075 * amp);
	var trix =  Ndef(\Ph_ropeTrixReals).kr[indices];

	snds = snds.collect { |snd, i|
		var scaleIndex = indices[i] + Stepper.kr(trix[i], 0,0, rrand(3, 13)) % numRopes;
		var freq = (Ndef(\scale).kr(1, scaleIndex) + detune).midicps.lag(0.0001);
		var filterA = Ringz.ar(snd * 0.5, freq * 1, decTime * 1  ) * SinOsc.ar( 6 + 2.0.rand, 0, 0.2, 0.8);
		var filterB = Ringz.ar(snd * 0.8, freq * 3, decTime * 0.9) * SinOsc.ar( 6 + 3.0.rand, 0, 0.2,0.8);
		var filterC = Ringz.ar(snd * 0.6, freq * 5, decTime * 0.8) * SinOsc.ar( 6 + 3.0.rand, 0, 0.2,0.8);
		snd = (filterA + filterB + filterC );
		snd
	};

	snds
});
);


