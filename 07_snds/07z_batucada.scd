// rubbed and plucked sounds open windows on rhythmic loops
/////// WORKS only WITH MICS 1-6 ////////
// check in ndefSwitch ing !!

Ndef(\Ph_batucada).clear.clearHalo.ar(q.numResons);

Ndef(\Ph_batucada).addSpec(\minamp, [0, 0.2, \amp]);
Ndef(\Ph_batucada).addSpec(\guideAmp, [0, 0.2, \amp]);

(
MFdef(\ndef_setNet).value(Ndef(\Ph_batucada), 11);

Ndef(\Ph_batucada, { |minamp = 0.0, guideAmp = 0.0|
	var thisNdef = Ndef(\Ph_batucada);
	var indices = thisNdef.getHalo(\myNet);
	var numRopes = indices.size;
	var pitches = Ndef(\scale).kr[indices];
	var freqs = pitches.midicps;
	var poster = "- % \n- : %\n".postf(thisNdef, indices);

	var numIndices6 = numRopes.round(6);
	var indices6 = indices.wrapExtend(numIndices6).keep(42);
	var numLayers = (numIndices6 div: 6);

	/// do one 6part group for every group of 6 chans:
	/// 12, 16, 8, 6, 4, 3, 2 // ( up to 42 ;-)
	var timeLayers = [12, 16, 8, 10, 14, 9, 6].keep(numLayers);

	var ropetrigs = Ndef(\Ph_ropeTrigs).kr;

	var layers = indices6.clump(6).collect { |indexGroup, i|

		var post = [indexGroup, i];
		var subdiv = timeLayers[i];
		var subdivRatio = subdiv / 12;
		var subdivIndex = subdiv - 1;
		var tic12 = Ndef(\time16).ar(1, subdivIndex);

		var ampsMic = (ropetrigs[indexGroup]).lag2ud(0.0, 0.5).max(minamp);
		var amps = max(ampsMic, [guideAmp, 0, guideAmp, 0, 0, 0]) * 8;

		///// konkolo timeline rhythm
		var rhy1 = Demand.ar(tic12, 0, Dseq([1,0,0.8,1,0,1,0,1,0,0.8,1,0], inf));
		var snd1 = Ringz.ar(tic12 * rhy1 * amps[0], 999 * subdivRatio, 0.1);

		///// konkolo counter rhythm
		var rhy2 = Demand.ar(tic12, 0, Dseq([0,1,0  ,0,1,0,1,0,1,0,  0,1], inf));
		var snd2 = Ringz.ar(tic12 * rhy2 * amps[1], 666 * subdivRatio, 0.1);

		///// bassdrums 3 : 4
		var rhy3 = Demand.ar(tic12, 0, Dseq([1, 0, 0, 0.8, 0, 0.5], inf));
		var snd3 = Ringz.ar(tic12 * rhy3 * amps[2], 66.6  * subdivRatio * (1 + Decay.ar(rhy3 * tic12, 0.2)), 1) * 2;

		var rhy4 = Demand.ar(tic12, 0, Dseq([1, 0, 0, 0], inf));
		var snd4 = Ringz.ar(tic12 * rhy4 * amps[3], 44.4  * subdivRatio * (1 + Decay.ar(rhy4 * tic12, 0.2)), 1)  * 2;

		///// tambourin1
		var rhy5 = Demand.ar(tic12, 0, Dseq([0, 0.6, 1, 0.8], inf));
		var snd5 = Ringz.ar(
			Decay.ar(tic12 * rhy5 * amps[4], 0.3) * WhiteNoise.ar(0.5),
			[1200, 5000, 12000]  * subdivRatio,
			0.001
		).sum;

		//// // triangle -> guide
		var rhy6 = Demand.ar(tic12, 0, Dseq([0, 0.6, 0.8, 0, 0.8, 1, 0, 0.4, 0.6, 0.2, 0.6, 0.8 ].squared, inf));

		var snd6 = Ringz.ar(
			Decay.ar(tic12 * rhy6 * amps[5], 0.3) * WhiteNoise.ar(0.02),
			[ 3500, 4000, 4080, 7000, 7200, 12000] * subdivRatio,
			[ 0.8,  0.6,  0.4,  0.25, 0.1, 0.4 ]
		).sum;

		// six-sound layer
		[snd1, snd2, snd3, snd4, snd5, snd6];
	};
	layers.flat;
});
)

/*
// all on
Ndef(\Ph_batucada).set(\minamp, 0.2);
// alloff when noone plays
Ndef(\Ph_batucada).set(\minamp, 0.0);
Ndef(\Pa_micsAll).pause;

Ndef(\Ph_batucada).set(\minamp, 0.002);
Ndef(\Pa_micsAll).resume;
*/