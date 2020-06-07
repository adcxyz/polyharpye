/******** GENERAL SHOW SETUP

* make groups of all proxies
* stop all sound proxies
* keep all permanent proxies alive
* open all outs to low amp

**** call current setup file!

MFdef(\hideNdefs).(q.ndef[\Mics]);
MFdef(\showNdefs).(q.ndef[\Mics]);
*/

NdefPreset.all.do(_.loadSettings);
Ndef.all.localhost.do(_.fadeTime = 1);

q.ndef = q.ndef ? ();

q.ndef[\All] = Ndef.dictFor(s);

// all real, expanded and simulated mic inputs
q.ndef[\Mics] = [
	Ndef('Pa_micIns'),
	Ndef('Pa_micsAll'),
	Ndef('Pa_micsMax'),
	Ndef('noyzResons'),
	Ndef('noyzMicIns'),
	Ndef('time16'),
];

// all outputs are always playing
q.ndef[\Outs] = [
	Ndef('Pz_ins2Spk'),
	Ndef('Pz_grid'),
	// Ndef(\Pz_sub),
];

////// ALL THE SOUND THAT CAN PLAY:
q.ndef[\Sounds] = [
	Ndef('Ph_sitar1'),
	Ndef('Ph_tabloid'),
	Ndef('Ph_triangul'),
	Ndef('Ph_ropesRingz'),
	Ndef('Ph_glassy'),
	Ndef('Ph_roRingPaz'),
	Ndef('Ph_ropesClicks'),
	Ndef('Ph_ropeWah'),
	Ndef('Ph_ropesPure'),
	Ndef('Ph_sawAM'),
	Ndef('Ph_rhythmicon'),
	Ndef('Ph_batucada'),
	// Ndef('Ph_verb'),

	// Ndef('Ph_perky'),
	// Ndef('Ph_ropesSmpls'),
	// Ndef('Ph_spiral'),
	// Ndef('Ph_trgDelJump'),
	// Ndef('Pz_rope2Sub2'),
	// Ndef('Pz_rope2Sub')
	// Ndef('testDust'),
];

// necessary running but non-playing silent ndefs:
q.ndef[\Perms] = [
	Ndef('Pa_micIns'),
	Ndef('Pa_micsAll'),
	Ndef('Pa_micsMax'),

	Ndef('Pz_ins2Spk'),
	Ndef('time16'),
	Ndef('Pa_time16'),
	// Ndef('Pa_spiralIn'),
	// ProxySubmix('Pa_verbin'),
	// Ndef('zz_gridDelay'),

	Ndef('xy'),
	Ndef('scale'),
	Ndef('Ph_ropeTrigs'),
	Ndef('Ph_ropePeaks'),
	Ndef('Ph_ropeTrixReals'),
	Ndef(\Pz_mainCopy)
];

q.ndef[\Sounds].do(_.end(0));
try { s.sync };

q.ndef[\Sounds].do(_.vol_(0.25));

q.ndef[\Outs].do(_.vol_(0.2));

q.ndef.unknown = Ndef.all[s.name].as(Array).removeAll([
	q.ndef[\Mics],
	q.ndef[\Sounds],
	q.ndef[\Outs],
	q.ndef[\Perms],
].flat);

if (q.ndef.unknown.size > 0) {
	"*** UNKNOWN NDEFS ? \n// q.ndef.unknown has: ".post;
	q.ndef.unknown.postln
} {
	"all Ndefs are known in groups.".postln
};

ServerTree.add(MFdef(\wakeUp), s);

MFdef(\wakeUp).add(\perms, {
	"wakeUp perms".postln;
	q.ndef[\Perms].do { |ndef|
		ndef.stop.resume.wakeUp;
		// wait works, sync does not ???
		0.08.wait;
		// s.sync;
	};
	s.sync;
});

MFdef(\wakeUp).add(\outs, {
	q.ndef[\Outs].do { |ndef|
		ndef.resume.play;
		0.05.wait;
	};
	s.sync;
});


// // default reverb mix settings, overwritten later
// ProxySubmix('verbin').set(
// 	'snd_Pa_micsAll', 0.03,
// 	'snd_ropesRingz', 0.1,
// 	'snd_tabloid', 0.03,
// 	'snd_perky', 0.03,
// 	'snd_sawAM', 0.03,
// 	'snd_glassy', 0.03,
// 	'snd_trgDelJump', 0.25,
// );

// other funcs
// leave the oscdef always on, switch only the MFdef
OSCdef(\micTrig).disable;
MFdef(\micTrig).disable(MFdef(\micTrig).activeNames.copy);
MFdef(\micTrig).disable(MFdef(\micTrig).orderedNames);


