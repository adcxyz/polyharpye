// make real mic ins
// scale up to numResons
// add filtering
// add simulator sounds for pluck and rub

var q = PH.q;
// q = q ? ();

q.rope = q.rope ? ();
// these shd maybe go in a more global place
q.numIns = q.numResons;
q.inNums = (0..q.numIns-1);
q.numOuts = q.numResons;
q.numSpks = q.numSpks ? q.numOuts;


// number of inputs depends on sound device:
case { q.sndDevice == \MIO } {
	q.numMics = q.numMics ? 8;
	q.micChans = (0..q.numMics - 1);
} { q.sndDevice == \1248 } {
	q.numMics = q.numMics ? 8;
	q.micChans = (0..q.numMics - 1);
} {
	// default sound device is stereo mic in,
	// stereo speakers out
	q.micChans = [0];
	q.numOuts = 2;
};

/////// OBSOLETE - first pass at PanAzing mics to virtual mics
////// How to scale up from a few mics to many pseudo mics
// // expand number of inputs to a PanAz x panAz product
// // that can be .wrapExtend-ed to q.numResons (65)
// (1..8).collect { |numch|
// 	var numpans = (q.numResons / numch).sqrt;
// 	var numx = (numpans * 1.618).round.asInteger;
// 	var numy = (numpans / 1.618).round.asInteger;
// 	[numch, numx, numy, numch * numx * numy ];
// 	(numch : [numx, numy]);
// };
// // better compose by hand:
// // and set which one to use:
///////// these are for 65:
// q.xyNumPans = (
// 	1: [ 13, 5 ],
// 	2: [ 8, 4 ],
// 	3: [ 7, 3 ],
// 	4: [ 5, 3 ],
// 	5: [ 4, 3 ],
// 	6: [ 5, 2 ],
// 	7: [ 3, 3 ],
// 	8: [ 4, 2 ]
// )[q.numMics];
//
// ///// these for 46
// q.xyNumPans = (
// 	1: [ 8, 6 ],
// 	2: [ 6, 4 ],
// 	3: [ 5, 3 ],
// 	4: [ 4, 3 ],
// 	5: [ 3, 3 ],
// 	6: [ 4, 2 ],
// 	7: [ 3, 2 ],
// 	8: [ 3, 2 ]
// )[q.numMics];


//// some general audio specs
Spec.add(\lag, [0.01, 10, \exp]);
Spec.add(\limit, [0, 1.0]);
// mic filtering - MidEQ
Spec.add(\db,[-24,24,\lin]);
Spec.add(\rq, [1, 0.04,\exp]);
Spec.add(\in, [0, q.numIns,\lin,1]);
Spec.add(\midFQ, \freq);
//
Spec.add(\loCutFreq, [20, 1000, \exp]);
Spec.add(\decaytime, [0.01, 100, \exp]);
Spec.add(\decayslope, [0, 1]);

// Spec.add(\noisy, [0, 1]);
// Spec.add(\detune, [0, 0.5]);

/// make global XY control for center of micgroup moves,
// e.g. from mouse
Ndef(\xy).addSpec(\x, \pan);
Ndef(\xy).addSpec(\y, \pan);
Ndef(\xy).addSpec(\width, [1, 10, \exp]);
Ndef(\xy).addSpec(\rand, \unipolar);
Ndef(\xy).addSpec(\rate, [0.03, 3, \exp]);

Ndef(\xy, { |x = 0, y = 0, width = 2, lag = 0.5, rand = 0.38, rate = 0.3|
	var fixed = [x, y, width].lag(lag);
	var rands = [
		LFDNoise3.kr(1.618 * rate),
		LFDNoise3.kr(rate),
		LFDNoise3.kr(0.618 * rate).exprange(1, 10)
	];
	var movingxys = blend(fixed, rands, rand);
	var fixedMoving = (fixed ++ movingxys);
	SendReply.kr(Impulse.kr(20), '/xybase', fixedMoving);
	movingxys;
});

///////// GUI for globalXY
q.xy = q.xy ? ();
q.xy.xybase = [0,0,2,0,0,2];

WinBounds.addMake(\globalXY, {
	if (q.xy.win.notNil and: { q.xy.win.isClosed.not }) {
		q.xy.win.front;
	} {
		q.xy.win = Window("globalXY", Rect(100, 100, 560, 180)).front;
		q.xy.win.addFlowLayout;
		q.xy.guy = NdefGui(Ndef(\xy), 7, q.xy.win);
		q.xy.guy.skipjack.dt = 0.03;

		q.xy.uv = UserView(q.xy.win, Rect(0,0,160, 160));
		q.xy.uv.background_(Color.grey(0.5));
		q.xy.uv.animate_(true);
		q.xy.uv.frameRate_(20);

		(
			q.xy.uv.drawFunc = { |uv|
				var extent  = uv.bounds.extent;
				var baseXYW = q.xy.xybase.keep(3);
				var softXYW = q.xy.xybase.keep(-3);
				var basePt  = (baseXYW.keep(2).biuni * extent).asPoint;
				var softPt  = (softXYW.keep(2).biuni * extent).asPoint;
				var baseWid = baseXYW[2] * 10;
				var softWid = softXYW[2] * 10;

				Pen.color = Color.white.alpha_(0.8);
				Pen.addArc(basePt, baseWid, 0, 2pi).stroke;
				Pen.addArc(softPt, softWid, 0, 2pi).stroke;
				Pen.color = Color.white.alpha_(0.5);
				q.xy.xxyys.pairsDo { |x, y|
					Pen.addArc([x, y].biuni * extent, softWid, 0, 2pi).stroke;
				};
			};
			q.xy.uv.mouseMoveAction = { |uv, x, y|
				var ext = uv.bounds.extent;
				Ndef(\xy).set(*[\x, (x / ext.x).unibi, \y, (y / ext.y).unibi])
			};
		);
	}
});

Butz(\poly).add(\globalXY, { WinBounds.showOrMake(\globalXY) });
Butz(\poly).run(\globalXY);

//////// now the few-to-many mic scaleup:
//// catch pan values to show them
OSCdef(\xxyys, { |msg|
	// msg.postln;
	q.xy.xxyys = msg.drop(3);
},'/xxyys').permanent_(true);
OSCdef(\xybase, { |msg|
	// msg.postln;
	q.xy.xybase = msg.drop(3);
},'/xybase').permanent_(true);

Spec.add(\gain, [0, 4, \amp]);
Ndef(\Pa_micIns).clear;
Ndef(\Pa_micsMax).clear;
Ndef(\Pa_micIns).addSpec(\gain, \gain);
Ndef(\Pa_micIns, { |gain=1| SoundIn.ar((0.. q.numMics-1)) * gain.lag(0.3) });

Ndef(\Pa_micsMax).addSpec(\gain, [0, 4, \amp]);

//////////////// micsMax with PanAz hack-panning
// Ndef(\Pa_micsMax, { |gain = 1|
// 	var ins = Ndef(\Pa_micIns).ar * gain.lag(1);
// 	var numins = ins.size;
// 	var numPanAzXYs = q.xyNumPans;
//
// 	var xyw = Ndef(\xy).kr;
// 	var width = xyw[2];
// 	var xdrift = LFDNoise3.kr(0.1).sqrt;
// 	var ydrift = LFDNoise3.kr(0.1).sqrt;
// 	var scalers = ((0..numins-1) - (numins - 1 / 2) / numins * 2);
// 	var xypans = numins.collect { |i|
// 		[ xyw[0] + (xdrift * scalers[i]),
// 			xyw[1] + (ydrift * scalers[i])
// 		]
// 	};
//
// 	SendReply.kr(Impulse.kr(10), '/xxyys', xypans.flat);
//
// 	ins.collect { |chan, i|
// 		PanAz.ar(numPanAzXYs[1],
// 			PanAz.ar(numPanAzXYs[1],
// 				chan,
// 				xypans[i][0],
// 				width: width
// 			),
// 			xypans[i][1],
// 			width: width
// 		)
// 	}.flat.wrapExtend(q.numResons);
// });

////////////// micsMax use xywidth panning w belldist
Ndef(\Pa_micsMax, { |gain = 1, driftspeed = 1|
	var ins = Ndef(\Pa_micIns).ar * gain.lag(1);
	var numins = ins.size;

	var xdrift = LFDNoise3.kr(0.1).sqrt;
	var ydrift = LFDNoise3.kr(0.1).sqrt;
	var scalers = ((0..numins-1) - (numins - 1 / 2) / numins * 2);

	// drifting lines of multiple independent XYwidths
	var xypans = numins.collect { |i|
		var x = LFDNoise3.kr(0.1618 * driftspeed);
		var y = LFDNoise3.kr(0.1000 * driftspeed);
		var wid = LFDNoise3.kr(0.0618 * driftspeed).linlin(-1, 1, 0.3, 1);
		var limit = 1; /// (x.abs + y.abs).max(1).reciprocal;
		[ x * limit, y * limit, wid ]
	};
	// not using width for now
	var outsigs = ins.sum { |chan, i|
		var xyschan = xypans[i];
		var amps = q.pos.xyBellDist(
			// scale up to meters
			(xyschan.keep(2) * [ 9.5, -9.5]).asPoint,
			q.pos.mics,
			xyschan[2]
		)[1];
		chan * amps;
	};
	// outsigs.size.postln;
	SendReply.kr(Impulse.kr(20), '/xxyys', xypans.flat);


	outsigs;
});

/*
////////////// micsMax with real xy panning, yay!
Ndef(\Pa_micsMax, { |gain = 1|
var ins = Ndef(\Pa_micIns).ar * gain.lag(1);
var numins = ins.size;

var xyw = Ndef(\xy).kr;
var width = xyw[2];
var xdrift = LFDNoise3.kr(0.1).sqrt;
var ydrift = LFDNoise3.kr(0.1).sqrt;
var scalers = ((0..numins-1) - (numins - 1 / 2) / numins * 2);

// drifting line of multiple XYs
var xypans = numins.collect { |i|
[ xyw[0] + (xdrift * scalers[i]),
xyw[1] + (ydrift * scalers[i]),
width
]
};

// not using width for now
var outsigs = ins.sum { |chan, i|
var amps = q.pos.xy2distAmps(
// scale up to meters
(xypans[i].keep(2) * [10, -10]).asPoint,
q.pos.mics
)[1];
chan * amps;
};
// outsigs.size.postln;
SendReply.kr(Impulse.kr(20), '/xxyys', xypans.flat);


outsigs;
});
*/

try { Ndef(\Pa_micsAll).parentGroup_(q.grpList[0]) };

/////////// + simulator
Ndef(\Pa_micsAll).addSpec(\simPluck, [0, 1, \amp]);
Ndef(\Pa_micsAll).addSpec(\simRub, [0, 1, \amp]);

/// add simulation inputs
Ndef(\Pa_micsAll, {|amp = 0.5, simPluck = 0.0, simRub = 0.0|
	var snd = Ndef(\Pa_micsMax).ar;
	var simPluckSnd = PinkNoise.ar(simPluck) * Decay.ar(Dust2.ar(1!q.numResons), 0.1);
	var simRubSnd = (GrayNoise.ar(simRub) * LFDNoise3.kr(0.3 ! q.numResons).range(1, -5).max(0));

	// no limiting here, just sum:
	var allSnds = (snd + simPluckSnd + simRubSnd);

	// was Lim---iter.ar(allSnds, limit);
	// but tanh adds no latency and makes inputs brighter when very loud
	allSnds.tanh;

});

