//  check in NdefSwitch , scale etc...
// merge in from sitar_versions.scd

Ndef(\Ph_sitar1).clear.clearHalo;
Ndef(\Ph_sitar1).ar(q.numResons);
Ndef(\Ph_sitar1).parentGroup_(q.grpList[2]);

Ndef(\Ph_sitar1).vol = 0.25;
Ndef(\Ph_sitar1).fadeTime = 3;


MFdef(\ndef_setNet).value(Ndef(\Ph_sitar1), 0);

Ndef(\Ph_sitar1).addSpec(\decaycomp, [0, 1]);
Ndef(\Ph_sitar1).addSpec(\decaytime, [1, 25, \exp]);
Ndef(\Ph_sitar1).addSpec(\transpose, [-24, 24, 0.01]);


///// simple favorite
Ndef(\Ph_sitar1, { |amp = 0.5, transpose = -12,
	decaytime = 8, decaycomp = 0.5, rq = 0.34,
	pmod = 0.5s|
	var thisNdef = Ndef(\Ph_sitar1);
	var netNames = thisNdef.getHalo(\myNetNames);
	var indices = thisNdef.getHalo(\myNet);
	var numRopes = indices.size;
	var pitches = Ndef(\scale).kr[indices] + transpose;

	var myPost = "% has: \n - indices: % \n - chord: %\n\n".postf(thisNdef, indices,
		Ndef(\scale).bus.getnSynchronous[indices].round(0.001));

	var tick = Ndef(\Pa_micsAll).ar[indices] * amp.lag(0.1);
	var freqs = pitches.midicps;
	var amps = Ndef(\Ph_ropeTrigs).kr[indices];
	var decaytimes = (260 / freqs) ** decaycomp * decaytime;

	// filterfreqs should go with freqs maybe
	var ffreq = (60 + transpose).midicps;

	var slotick = amps.lag2ud(0.3, 4);
	// var slotick = tick.abs.lag2ud(0.3, 4);
	var pick = tick * (WhiteNoise.ar(2) + PinkNoise.ar(0.3) + 0.2); // orig
	// too flat, too little direct influence
	// var pick = tick * 0.2 + (WhiteNoise.ar(1) + PinkNoise.ar(0.3) * amps);
	var penv = LFDNoise0.kr(8 ! numRopes,
		slotick.lag(0.4) * 0.05 * pmod, 1).lag(0.1);
	var snd = CombL.ar(
		LeakDC.ar(pick, 0.998),
		0.03, 1/freqs * penv,
		decaytimes).softclip;

	snd = RLPF.ar((OnePole.ar(snd * 3.5, 0.5)).tanh, ffreq * (7.2 + (slotick * 24)), rq);

	// DelayL.ar(snd, 0.02, LFDNoise3.kr(0.1, 0.01, 0.01));
});



// // /// 4 octaves down, sound good, bass should get help from subwoofer
// // MFdef('ndef2net').value(Ndef(\Ph_sitar1), [0,1,2]);
//
// Ndef(\Ph_sitar1, { |amp= 0.1, freq=200|
// 	// var tick = Decay2.ar(Impulse.ar(0.2), 0.001, 0.1);
// 	var tick = Ndef(\Pa_micsAll).ar(32);
// 	var freqs = ([0, 2, 3, 6, 7, 8, 11, 12] + 60).midicps.wrapExtend(tick.size) * [1, 0.5, 0.25, 0.125 ].stutter(8).size;
// 	var slotick = tick.lag2ud(0.3, 4);
// 	var pick = tick * PinkNoise.ar(0.3, 0.2);
// 	var penv = LFDNoise0.kr(8, slotick.lag(0.4) * 0.05 + 0.001, 1).round(0.001).lag(0.1);
// 	var snd = CombL.ar(pick, 0.03, 1/freqs * penv, 5).fold2(0.2);
//
// 	RLPF.ar((snd * 5).tanh, freq * (3 + (slotick * 10) * 3), 0.04).tanh * 0.5;
//
// });
//
