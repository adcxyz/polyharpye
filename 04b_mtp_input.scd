(
// a dict for all mtp things
q.mtp = q.mtp ? ();

// make sure MTP will find its tongsengmod binary
MTP.progpath = q.projdir +/+ "binaries";

// a synthdef to play intos the e.g. 6 micIns
SynthDef(\noyzMicIns, { |out, amp = 0.1, pan, gate = 1, freq = 261, reso = 10|
	var freq2 = (freq * (5 ** LFDNoise3.kr(ExpRand(1, 30), amp * 0.3))).clip(50, 15000);
	var snd = BPF.ar(GrayNoise.ar + Dust.ar(30, 20), freq2 * [1, 1.9], 1/reso);
	var env = EnvGen.ar(Env.asr(0.001, 1, 0.1), gate, doneAction: 2);

	Out.ar(out,
		PanAz.ar(
			q.numMics,
			((snd * (env * amp.min(100) * reso.sqrt)).softclip).sum
			* AmpComp.kr(freq, exp: 0.2).min(2),
			pan; // + (LFNoise2.kr(10 * amp) * Line.kr(0, 1, 1));
		)
	);
}).add;

// same synthdef to play into the reson inputs
SynthDef(\noyzResons, { |out, amp = 0.0, panx, pany, gate = 1, freq = 261, reso = 10|
	var env = EnvGen.ar(Env.asr(0.001, 1, 0.1), gate, doneAction: 2);
	var amps = q.pos.xy2distAmps(panx @ pany, q.pos.mics)[1];

	// var freq2 = (freq * (5 ** LFDNoise3.kr(ExpRand(1, 30), amp * 0.3))).clip(50, 15000);
	// var snd = BPF.ar(GrayNoise.ar + Dust.ar(30, 20), freq2 * [1, 1.9], 1/reso);
	// var snd2 = ((snd * (env * amp.min(1) * reso.sqrt)).softclip).sum
	// * AmpComp.kr(freq, exp: 0.2).min(2);

	var snd2 = PinkNoise.ar * (env * amp);

	Out.ar(out, snd2 * amps);

}).add;

/*    // tests for the synthdefs

z = Synth(\noyzMicIns, [\freq, exprand(300, 5000), \pan, 1.0.rand2].postln);

z = Synth(\noyzMicIns, [\freq, exprand(300, 5000), \pan, 1.0.rand2].postln);
z.release;

z = Synth(\noyzResons, [
\freq, exprand(300, 5000), \panx, 1.0.rand2, \pany, 1.0.rand2, ].postln);
z.release;


Ndef(\Pa_micsMax).scope
*/

/*
z = Synth(\noyzResons, [
	\freq, exprand(300, 5000),
	\panx, 1.0.rand2,
	\pany, 1.0.rand2,
	\amp, 0.2
].postln);
z.set(\panx, 5);
z.release;
*/
);

(
// MTP.fingerCol = Color(1.0);
MTP.gui.view.alpha_(0.6);
MFdef(\MTP_draw).add(\draw, { |uv|
	var bounds = uv.bounds;
	var width = bounds.width;
	var height = bounds.height;
	var widscale = width / 525; // basewidth;
	var fingerSize = MTP.fingerSize * widscale;
	var halfFing = fingerSize * 0.5;
	var textCol = Color.white;

	var status = ["OFF", "ON"][MTP.isRunning.binaryValue];
	var bigFont = Font("Futura", bounds.width / 10);
	var halfFont = Font("Futura", bounds.width / 30);

	// halfFing.postln;
	// on or off background color
	uv.background_(Color.grey(MTP.isRunning.binaryValue * 0.24 + 0.38));

	// draw on/off and default key commands
	Pen.stringAtPoint(status, 4@4, bigFont, textCol);

	(MTP.infoText ++ MTP.extraText).do { |line, i|
		Pen.stringAtPoint(line, (bigFont.size * 2) @ (i * halfFont.size * 1.2),
			halfFont, textCol)
	};

	Pen.width_(2 * widscale);
	// draw finger touchpoints and info for them
	MTP.fingersDict.keysValuesDo { |key, fItem|
		var x = width  - halfFing * fItem[0];
		var y = height - halfFing * fItem[1];
		var fingSize = fingerSize * fItem[2] * 0.5;

		Pen.color = MTP.fingerCol;
		Pen.strokeOval( Rect.aboutPoint(x@y, fingSize, fingSize));

		Pen.stringCenteredIn(
			MTP.fingerStrings[key] ? key.asString,
			Rect.aboutPoint(x@y, 60, 30),
			halfFont,
			textCol
		);
	};

	// q.xy.xxyys.postln.pairsDo { |panx, pany|
	// 	var x = (panx - 1 * 2 * width);
	// 	var y = (pany- 1 * 2 * width);
	// 	Pen.strokeOval(Rect.aboutPoint(x@y, 30, 30));
	// };
});
);

////// prepare a voicer for micIns synths:
Ndef(\noyzMicIns).clear.ar(q.numMics);
q.mtp.vcMic = q.mtp.vcMic ?? { NPVoicer(Ndef(\noyzMicIns)) };
q.mtp.vcMic.prime(\noyzMicIns); // tell the voicer which synthdef

q.mtp.verbose = false;

////// prepare another one for resons synths:
Ndef(\noyzResons).clear.ar(q.numResons);
q.mtp.vcRes = q.mtp.vcRes ?? { NPVoicer(Ndef(\noyzResons)) };
q.mtp.vcRes.prime(\noyzResons); // tell the voicer which synthdef

// now set up MTP: so it can play them
(

MTP.keydownDict[$.] = MFdef(\MTP_OFF);
MTP.keydownDict[$ ] = MFdef(\MTP_toFront);
MTP.keydownDict[$ ] = MFdef(\MTP_toFront);

MTP.keydownDict[$b] = { WinBounds.showOrMake(\Butz) };
MTP.keydownDict[$c] = { WinBounds.showOrMake(\SCENES) };

MTP.keydownDict[$s] = { WinBounds.showOrMake(\spatio) };
MTP.keydownDict[$g] = { WinBounds.showOrMake(\globalXY) };

MTP.keydownDict[$i] = MFdef(\noyzMicIns);
MTP.keydownDict[$r] = MFdef(\noyzResons);

MTP.keydownDict[$m] = { WinBounds.showOrMake(\ndefmix) };
MTP.keydownDict[$M] = { WinBounds.showOrMake(\MasterFX) };

MTP.keydownDict[$t] = { WinBounds.showOrMake('Tdef.all') };
MTP.keydownDict[$p] = { WinBounds.showOrMake('Pdef.all') };

MTP.keydownDict[$T] = { WinBounds.showOrMake('TESTS') };
MTP.keydownDict[$C] = { Butz.run('ChordPlayer') };

MTP.infoText.clear.addAll([
	"space: play, dot: stop",
	"b: Butz,   c: for SCENES",
	"s: spatio, g: globalXY",
	"i: MTPMic, r: MTPRes",
	"m: ndefmix, M: MasterFX",
	"p: pdefall, t: tdefall",
	"T: tests, C: ChordPlayer",

]);


MFdef(\MTP_toFront).add(\show, {
	// bring all guis to front,
	// then put MTP window on top
	Window.allWindows.do(_.front);
	WinBounds.showOrMake(\spatio);
	MTP.start.gui.front;
	MTP.uview.resize_(1);
	MTP.uview.drawFunc = MFdef(\MTP_draw);

	fork({
		MTP.maximize;
		0.02.wait;
		MTP.gui.front;
		// MTP.gui.alwaysOnTop_(true);
		MTP.uview.bounds_(q.spatUV.absoluteBounds.moveBy(0, -46));
		MTP.uview.refresh;
	}, AppClock);
});

MFdef(\MTP_OFF).add(\off, {
	Ndef(\noyzResons).end;
	Ndef(\noyzMicIns).end;
	MTP.stop;

	MTP.minimize;
	// MTP.gui.alwaysOnTop_(false);
	fork({

		0.05.wait;
		MTP.uview.bounds_(MTP.gui.bounds.extent.asRect);
		MTP.uview.refresh;
	}, AppClock);
});

// clear the current actions:
MFdef(\noyzMicIns).add('switch', {
	"*** MTP: switching to 'noyzMicIns'".postln;
	Ndef(\Pa_micIns).put(10, Ndef(\noyzMicIns));
	MTP.extraText = ["NOW: noyzMicIns".toUpper];
	MFdef(\MTP_toFront).value;

	// now set them
	MTP.touchAction = {|curID, xys|
		if (q.mtp.verbose) {
			"MTP noyzMicIns starts w/ curID: % xys: %. \n    ".postf(curID, xys.round(0.001));
		};
		q.mtp.vcMic.put(curID, [
			\freq, (xys[0]).linexp(0, 1, 30, 3000),
			\reso, xys[1].linexp(0, 1, 5, 100),
			\amp, xys[2].squared,
			\pan, xys[0] * 2 - 1,
		]);
	};
	MTP.untouchAction = {|curID| q.mtp.vcMic.release(curID) };
	MTP.setAction = { |curID, xys|
		//    "   set curID: % xys: % \n    ".postf(curID, xys.round(0.001));
		q.mtp.vcMic.setAt(curID, *[
			\freq, (xys[0]).linexp(0, 1, 100, 10000),
			\reso, xys[1].linexp(0, 1, 5, 100),
			\amp, xys[2].squared * 0.1,
			\pan, xys[0] * 2 - 1
		]);
	};
});


MFdef(\noyzResons).add('switch', {
	"*** MTP: switching to 'noyzResons'".postln;
	Ndef(\Pa_micsMax).put(10, Ndef(\noyzResons));
	MTP.extraText = ["NOW: noyzResons".toUpper];
	MFdef(\MTP_toFront).value;

	// now set them
	MTP.touchAction = {|curID, xys|
		if (q.mtp.verbose) {
			"MTP noyzResons starts w/ curID: % xys: %. \n    ".postf(curID, xys.round(0.001));
		};
		q.mtp.vcRes.put(curID, [
			\freq, exprand(100, 3000), // (xys[0]).linexp(0, 1, 30, 3000),
			\reso, 3, // xys[1].linexp(0, 1, 5, 100),
			\amp, xys[2].squared * 2,
			\panx, xys[0] * 2 - 1 * 10,
			\pany, xys[1] * 2 - 1 * -10
		]);
	};
	MTP.untouchAction = {|curID|
		// "MTP noyzResons curID: % ends.\n".postf(curID);
		q.mtp.vcRes.release(curID);
	};
	MTP.setAction = { |curID, xys|
		//    "   set curID: % xys: % \n    ".postf(curID, xys.round(0.001));
		q.mtp.vcRes.setAt(curID, *[
			// \freq, (xys[0]).linexp(0, 1, 100, 10000),
			\reso, 3, // xys[1].linexp(0, 1, 5, 100),
			\amp, xys[2].squared * 0.5,
			\panx, xys[0] * 2 - 1 * 10,
			\pany, xys[1] * 2 - 1 * -10
		]);
	};
});

Butz.add(\MTP_MicIns, MFdef(\noyzMicIns));
Butz.add(\MTP_Resons, MFdef(\noyzResons));

);
