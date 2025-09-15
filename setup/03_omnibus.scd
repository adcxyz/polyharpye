/*
omnibus plays the omnibus out to the existing speakers.
*/

/*
//OUTPUTS CONNECT TO:
mumuth: 0-28 go to speakers
29 goes to all subs (mono)

*/

var q = PH.q;

q.pos.omnibus = q.pos.omnibus ?? { Bus.audio(s, q.numResons) }; //rename to power pan??

Spec.add(\hpfreq, [20, 200, \exp]);
Spec.add(\width, [0.2, 20, \exp]);

Spec.add(\driftRate, [0.03, 3, \exp]);
Spec.add(\driftdepth, [0, 1, \amp]);

ServerTree.objects;
Server.program;

/////////// Make sure we have Pa_micsAll and Pz_grid
// on adajacent buses, so Spatio gets them together!
Ndef(\Pa_micsAll).ar(q.numResons);
Ndef(\Pz_grid).ar(q.numResons);
Ndef(\Pz_mainCopy).ar(q.numSpks);
Ndef(\Pz_mainCopy, { InFeedback.ar(0, q.numSpks) });

{
	var nextChanAfterMics = Ndef(\Pa_micsAll).index + Ndef(\Pa_micsAll).numChannels;
	var firstChanOfGrid = Ndef(\Pz_grid).index;
	if (nextChanAfterMics != firstChanOfGrid) {
		"*** SpatioScope will not show correctly".warn;
	} {
		"OK, SpatioScope channels adjacent".postln;
	};
}.value;


Ndef(\Pz_grid).parentGroup_(q.grpList[6]);

Ndef('Pz_ins2Spk', {

	var inBus = q.pos.omnibus;
	var numIns = inBus.numChannels;
	var numSpkOuts = q.pos.spks.size;
	var allIns = InFeedback.ar(inBus.index, numIns);

	// works for caeiros, not generally:
	// pan every reson chan to speaker ring by angle
	if (q.numSpks > 2) {
		allIns.sum { |chan, i|
			var angle = q.pos.mics[i].theta;
			PanAz.ar(q.numSpks, chan, angle / pi)
		};
	} {
		"stereo".postln;
		// stereo: just use Pan2 with pos-x to +-1
		allIns.sum { |chan, i|
			var panpos = q.pos.mics[i].x * 0.125;
			Pan2.ar(chan, panpos)
		};
	};

	// // quick and dirty hack low-cpu hack:
	// // just roll around and add them somewhere
	// var numSums = (numIns / numSpkOuts).roundUp(1);
	// numSpkOuts.collect { |i|
	// 	var sum = 0;
	// 	numSums.do { |j|
	// 		var index = j * numSpkOuts + i;
	// 		if (index < numIns) {
	// 			sum = sum + allIns[index]
	// 		};
	// 	};
	// 	sum;
	// };

});

try { s.sync };

// delaytime drift on outputs shifts acoustic feedback
// common delaytime for all chans keeps panning image,
// individual delaytimes make acoustic feedback more lively

Ndef('Pz_grid', { |hpfreq = 20, amp = 1.0, limit = 0.5, driftRate = 0.1, driftdepth = 0.1|
	var gridIns = Ndef('Pz_ins2Spk').ar; // q.numSpks
	var gridOuts = gridIns * (q.numSpks * 2 / q.numResons * amp.lag(1.0));
	var maxDelay = 0.01; // 10 msec
	var commonDelayTime;

	gridOuts = RHPF.ar(gridOuts, hpfreq.lag(1), 0.7);
	// gridOuts = Lim-iter.ar(gridOuts, limit, 0.005);
	gridOuts = (gridOuts).tanh;

	//// antifeedback phase shift -
	driftRate = driftRate.lag(1);
	driftdepth = driftdepth.lag(1) * maxDelay * 0.5;


	commonDelayTime = LFDNoise3.kr(driftRate, driftdepth, driftdepth);

	gridOuts = gridOuts.collect { |chan|
		///// share same delaytime to avoid headphone panning drift
		var delaytime = commonDelayTime;
		///// use individual delaytimes in multichan settings?
		// var delaytime = LFDNoise3.kr(driftRate, driftdepth, driftdepth);
		DelayL.ar(chan, maxDelay, delaytime);
	};
});
try { s.sync };

Ndef('Pz_grid').set('hpfreq', 20, 'amp', 1.0, 'width', 2.0);
Ndef('Pz_grid').play(
	vol: 0.5
);

try { s.sync };

///////////
// // mono sub Ndef on SC chan 29 == hardware out 30
// Ndef(\Pz_sub).parentGroup_(q.grpList[6]);
// Spec.add(\hicut, [80, 150]);
// Spec.add(\locut, [20, 40]);
//
// // play out to chans
// Ndef(\Pz_sub, {|locut =25, hicut = 120, amp = 1.0, limit = 0.99|
// 	var ins = InFeedback.ar(q.pos.omnibus.index, q.pos.omnibus.numChannels).sum;
// 	var subsnd = RLPF.ar(ins, hicut.lag(1), 0.7);
// 	subsnd = RHPF.ar(subsnd, locut.lag(1), 0.7) * (amp * (q.numResons ** -0.5));
// 	// PeakFollower.ar(subsnd).poll;
// 	Limiter.ar(subsnd, limit);
// }).play(7, vol: 0);
//
// fork { 0.5.wait; Ndef(\Pz_sub).end };

// // instead of a subBus, play onto subs directly with:
// Ndef(\Pz_sub).bus;
// //
