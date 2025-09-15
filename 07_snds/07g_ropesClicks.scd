(
Ndef(\Ph_ropesClicks).clear.clearHalo.ar(PH.numResons);
Ndef(\Ph_ropesClicks).parentGroup_(PH.grpList[2]);
Ndef(\Ph_ropesClicks).fadeTime = 5;

MFdef(\ndef_setNet).value(Ndef(\Ph_ropesClicks), 6);

Ndef(\Ph_ropesClicks).addSpec(\dur, [0.01, 1, \amp]);

Ndef(\Ph_ropesClicks, {|amp = 1.0, thresh = 0.2, lofreq = 13, dur = 0.3, freq = 400|
	var thisNdef = Ndef(\Ph_ropesClicks);
	var grpAssoc = thisNdef.getHalo(\myNet);
	var netNames = thisNdef.getHalo(\myNetNames);
	var indices = thisNdef.getHalo(\myNet);
	var numRopes = indices.size;
	var pitches = Ndef(\scale).kr[indices];

	var myPost = "% has: \n - indices: % \n - chord: %\n\n".postf(thisNdef, indices,
		Ndef(\scale).bus.getnSynchronous[indices].round(0.001));

	var peax = Ndef(\Ph_ropeTrigs).kr()[indices]; //the ropes that trigger delays
	//var amps = peax.lag2ud(0.01, 1.0) * 10 - 0.005).clip(0, 1.0);
	//create the triggers again to avoid too much messaging
	var trigs = Trig.ar(peax > thresh, 0.1);
	var envs = EnvGen.kr(Env.perc(0.001,dur,1.0), trigs);
	var envs2 = EnvGen.kr(Env.new([freq,freq, freq * 4],[0, dur],\exp), trigs);
	var source = LPF.ar(LFPulse.ar(lofreq), envs2.lag(0.1)) * amp;
	envs.collect{|env, i| env * source[i]} ;
});
try { s.sync };
);