/*   /
- derive amps, loudnesses and triggers from raw HPFiltered mic inputs.
- osc func therefore

*** TODO - build switching interface for trig sounds > see 15_sentience.scd for more analysis. gui viz, ...

PH.util.spat_MicIns.proxy.scope
PH.micTrigAmp = 1;

OSCdef(\micTrig).enable;
OSCdef(\micTrig).disable;

MFdef(\micTrig).enable(\post);
MFdef(\micTrig).disable(\post);

MFdef(\micTrig).enable(\sinFB);
MFdef(\micTrig).disable(\sinFB);

MFdef(\micTrig).enable(\varSaw);
MFdef(\micTrig).disable(\varSaw);
MFdef(\micTrig);

MFdef(\micTrig).disable(\band);
MFdef(\micTrig).enable(\band);

// test single sound by hand
(
var chanID = 1;
MFdef(\micTrig).at(\band).value(
(
chanID: chanID,
ampBus: Ndef(\Ph_ropeTrigs).bus.index + chanID,
inGroups: PH.pos.micGroups.select { |assoc| assoc.value.includes(chanID) }.collect(_.key);
);
);
)

*/
PH.rope= PH.rope ? ();
// global rope data
PH.rope.scale = Scale.major;
PH.rope.trigGroupSounds = (
	\netA: \trigSinFB,
	\netB: \trigNoise,
	\netC: \trigBD
);

Spec.add(\decTime, [0.01, 4.0,\lin]);
Spec.add(\peakFCoeff, [0.99, 0.99999, \lin, 1]);
Spec.add(\thresh, [0.01, 1, \exp]);

// indiv. triggers from all rope mics
// hipass-filter to detect hf energy which is always strongest in most direct mic

// \ropeTrigs are a bit wrong: they SendTrig the Trigs, but utput just the EnvFollower!
// \ropeTrixReals outpuz the EnvFollower!
Ndef(\Ph_ropeTrigs).clear;
Ndef(\Ph_ropeTrigs).parentGroup_(PH.grpList.first);
Ndef(\Ph_ropeTrigs).addSpec(\threshRatio, [1,25,\exp, 0.1]);

Ndef(\Ph_ropeTrixReals).parentGroup_(PH.grpList.first);
Ndef(\Ph_ropeTrixReals).kr( PH.inNums.size );

Ndef(\Ph_ropeTrigs, {|thresh =0.05, loCutFreq = 500, peakFCoeff = 0.9995|
	var peax = PeakFollower.ar(RHPF.ar(Ndef(\Pa_micsAll).ar, loCutFreq), peakFCoeff );
	var trix = Trig.ar(peax > thresh, 0.15);
	Out.kr( Ndef(\Ph_ropeTrixReals).index, trix);
	SendTrig.ar(trix, PH.inNums, peax);
	A2K.kr(peax)
});


// improve transient triggering to get less triggers from just loud playing?
// peak of the PeakFollower!-) - used for Sentience
Ndef(\Ph_ropePeaks, {|t_trig=1|
	var in = Ndef(\Ph_ropeTrigs).kr();
	Peak.kr(in, t_trig)
});


// listen to trigs and use MFdef
OSCdef(\micTrig, { arg msg;
	var chanID = msg[2];
	var inGroups = [];
	var trigEvent = (
		chanID: chanID,
		ampBusIndex: Ndef(\Ph_ropeTrigs).bus.index + chanID,
	);
	PH.pos.micGroups.do { |indices, name, i|
		if (indices.includes(chanID)) {
			inGroups = inGroups.add(name)
		};
	};
	trigEvent.put(\inGroups, inGroups);

	MFdef(\micTrig).value(trigEvent);
},'/tr', s.addr);

OSCdef(\micTrig).permanent_(true);
OSCdef(\micTrig).enable;
OSCdef(\micTrig).disable;

PH.micTrigAmp = 0.5;

MFdef(\micTrig).add(\post, { |event| event.postcs });

MFdef(\micTrig).add(\sinFB, { |event|
	(
		instrument: \trigSinFB,
		scale: PH.rope.scale,
		degree: event.chanID,
		amp: PH.micTrigAmp,
		\ampBus: event.ampBusIndex,
		\pitchMod: -2,
		group: PH.grpList[1],
		\out: PH.pos.omnibus.index + event.chanID
	).postln.play;
}, false );

MFdef(\micTrig).add(\varSaw, { |event|
	(
		instrument: \trigVarSaw,
		scale: PH.rope.scale,
		degree: event.chanID,
		amp: PH.micTrigAmp,
		\ampBus: event.ampBusIndex,
		\pitchMod: 2,
		group: PH.grpList[1],
		\out: PH.pos.omnibus.index + event.chanID
	).postln.play;
}, false );

MFdef(\micTrig).add(\band, { |event|
	var groups = event.inGroups;

	groups.do { |grName|
		(
			instrument: PH.rope.trigGroupSounds[grName].postcs ? \trigVarSaw,
			scale: PH.rope.scale,
			degree: event.chanID,
			amp: PH.micTrigAmp,
			\ampBus: event.ampBusIndex,
			\pitchMod: 1,
			group: PH.grpList[1],
			\out: PH.pos.omnibus.index + event.chanID
		).postln.play;
	}
}, false);


// MFdef(\micTrig).add(\fluxChange, {
//
// });

// off on startup
OSCdef(\micTrig).disable;
MFdef(\micTrig).disable(\post);
MFdef(\micTrig).disable([ 'sinFB', 'varSaw', \band ]);

//MFdef(\micTrig).enable('varSaw');
// two different sounds that get amp from a mod signal on a bus:
// Ndef(\Pa_micsAll) for the raw sound with LF,
// Ndef(\Ph_ropeTrigs) for HPfed amps, ...
// var micIn = Ndef(\Pa_micsAll).ar(chanID, 1);
// make sounds trigger off when low again?
// var gate = inamp > thresh;

SynthDef(\trigSinFB, { |freq = 261, amp = 0.1, pan, out, decay = 3, ampBus, pitchMod = -12|
	var inamp = In.kr(ampBus).lag(0.2);
	var freqSig = freq * ((inamp * pitchMod).clip(0,1) * pitchMod).midiratio;
	var ampComp = AmpComp.kr(freq.max(200));

	var snd = SinOscFB.ar(freqSig, (inamp * 3).clip(0.5, 1.5)) ;
	var env = Line.kr(1, 0.1, decay, doneAction: 2) * amp * ampComp;
	OffsetOut.ar(out, snd * (inamp).max(0.0003) * env)

}).add;

SynthDef(\trigVarSaw, { |freq = 261, amp = 0.1, pan, out, decay = 3, ampBus, pitchMod = -12|
	var inamp = In.kr(ampBus).lag(0.2);
	var freqSig = freq * ((inamp * pitchMod).clip(0,1) * pitchMod).midiratio;
	var ampComp = AmpComp.kr(freq.max(200));

	var snd = VarSaw.ar(freqSig, 0.5 + (inamp * 3).clip(0, 0.5)) ;
	var env = Line.kr(1, 0.1, decay, doneAction: 2) * amp * ampComp;
	OffsetOut.ar(out, snd * (inamp).max(0.0003) * env)

}).add;

SynthDef(\trigNoise, {|freq = 261, amp = 0.1, out, decay = 0.5, ampBus|

	var noize = PinkNoise.ar();
	var inamp = In.kr(ampBus).lag(0.2);
	var env = EnvGen.ar(Env.perc(0.01,decay), 1, doneAction:2);
	var snd = noize * env * amp;
	OffsetOut.ar(out, snd * (inamp).max(0.0003));

}).add;

SynthDef(\trigBD, {|freq = 261, amp = 0.1, out, decay = 1.5, ampBus|

	var osc = SinOsc.ar([50, 82, 120],0,[0.8,1,0.4]).sum;
	var inamp = In.kr(ampBus).lag(0.2);
	var env = EnvGen.ar(Env.perc(0.001,decay), 1, doneAction:2);
	var snd = osc * env * amp;
	OffsetOut.ar(out, snd * (inamp).max(0.0003));

}).add;

/*

SynthDef(\ampMod, {|freq = 400, dur = 3.0, amp = 0.1, out = 0, ampBus|

var modFreq = freq / 24;
var mod = SinOsc.ar(modFreq, 0, 0.5, 0.5);
var osc = SinOsc.ar(freq);
var inamp = In.kr(ampBus).lag(0.2);
var env = EnvGen.kr(Env.perc(0.01, dur, 1, 0),1, doneAction:2);
var snd = (osc * env * mod).distort(0.4);
OffsetOut.ar(out, snd );

}).add;

MFdef(\micTrig).add(\ampMod, { |event|
(
instrument: \ampMod,
scale: PH.rope.scale,
degree: event.chanID -12,
amp: PH.micTrigAmp,
\ampBus: event.ampBusIndex,
\pitchMod: -12,
group: PH.grpList[1],
\out: PH.pos.omnibus.index + event.chanID
).postln.play;
}, false );
*/
/*
MFdef(\micTrig).enable(\ampMod);
MFdef(\micTrig).disable(\ampMod);
*/
/*
MFdef(\micTrig).enable(\band);
*/