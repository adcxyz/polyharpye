// all spatial geometry data:
// microphone locations
// microphone groups/networks
// speaker locations

q = q ? ();
q.pos = q.pos ? ();
q.numResons = q.numResons ? 46;
q.lastReson = q.numResons - 1;

//////////// VIRTUAL MIC LOCATIONS /////////
// space is centered in middle and ca. 10x10
(
// SPIRAL: a spiral of 13x5 arms, 65 locations
q.pos.spiral = q.numResons.collect { |i|
	////// exponentially growing radius?
	// var radius = 1.618 ** (i / 21) * 2;
	////// better linear radius
	var radius = (i / q.numResons) + 0.2 * 8;
	var maxrad = 1.618 ** (63 / 13); // 10.3
	var angle = i * 0.4pi;
	var angshift = 1 + (0.382 / 5);
	Polar(radius, angle * angshift).asPoint;
};
q.pos.spiral.last; // radius just below 1;
q.pos.spiralRings = (0..q.lastReson).clumps([6, 10, 10, 10, 10]);
q.pos.spiralRings.last;

// topology of various nets:
// which mics are in which object groups?
// each mic can be in several if ropes are connected that way

q.pos.spiralGroups = NamedList([
	/////// radial rotating spokes
	\ring1, q.pos.spiralRings[0],
	\ring2, q.pos.spiralRings[1],
	\ring3, q.pos.spiralRings[2],
	\ring4, q.pos.spiralRings[3],
	\ring5, q.pos.spiralRings[4],
	/////// radial sectors
	\r13_1, ([0,5,10] + 0).collect { |n| (n,n+14 .. q.lastReson) }.flat,
	\r13_2, ([0,5,10] + 1).collect { |n| (n,n+14 .. q.lastReson) }.flat,
	\r13_3, ([0,5,10] + 2).collect { |n| (n,n+14 .. q.lastReson) }.flat,
	\r13_4, ([0,5,10] + 3).collect { |n| (n,n+14 .. q.lastReson) }.flat,
	\r13_5, ([0,5,10] + 4).collect { |n| (n,n+14 .. q.lastReson) }.flat,
	/////// reverse-rotating spokes
	\r09_1, ([0,5] + 0).collect { |n| (n,n+9 .. q.lastReson) }.lace,
	\r09_2, ([0,5] + 1).collect { |n| (n,n+9 .. q.lastReson) }.lace,
	\r09_3, ([0,5] + 2).collect { |n| (n,n+9 .. q.lastReson) }.lace,
	\r09_4, ([0,5] + 3).collect { |n| (n,n+9 .. q.lastReson) }.lace,
	// some duplicates with r09_1
	\r09_5, ([0,5] + 4).collect { |n| (n,n+9 .. q.lastReson) }.lace,
]);

// next to buttons on the left:
q.pos.groupCenters = q.pos.spiralGroups.collect { |name, val, i|
	(-0.96 @ (-5.1 + i * 0.1))
};

////// HARPYES ARE twaeked for 65, likely fails for 46 !!!!!
// harpyes : based on hole patterns in concentric pentagons:
// 1, 2, 3, 5, 8 holes from smallest to largest pentagon
// 1.618 ** 4
q.pos.harpyeRings = [
	// [ 0 ],
	[ 0, 0.382 ],
	[ 0, 0.333, 0.666 ],
	// [ 0, 0.2, 0.4, 0.6, 0.8 ],
	[ 0, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8 ]
].collect { |holedists, i|
	var radius = 1.618 ** i * 3;
	var segAngle =  0.4pi;
	5.collect { |j|
		holedists.collect { |dist|
			var angle = (i % 2 * 0.5) + (j + dist) * segAngle;
			Polar(radius, angle).asPoint;
		};
	};
};
q.pos.harpyes = q.pos.harpyeRings.flat;


q.pos.harpyes.copy.sort { |p1, p2| p1.theta < p2.theta }.separate { |pt1, pt2|
	(pt1.theta / 0.4pi).trunc != (pt2.theta / 0.4pi).trunc
}.collect(_.size) { |list, i|
	list.collect { |point, j| q.pos.harpyes.indexOf(point) }
};

q.pos.harpyeGroups = NamedList([
	////// the firsts of each ring
	\pn1, (0,2..8),
	\pn2, (10,13..22),
	\pn3, (25,33..64),

	/// the full rings
	\rng1, (0..9),
	\rng2, (10..24),
	\rng3, (25..64),

	////// all within one directional cone - hmmm
	\rad1, [0, 1, [24, 10, 11]+0,  (25..32)+0].flat,
	\rad2, [2, 3, [9, 10, 11 ]+3,  (25..32)+8].flat,
	\rad3, [4, 5, [9, 10, 11 ]+6,  (25..32)+16].flat,
	\rad4, [6, 7, [9, 10, 11 ]+9,  (25..32)+24].flat,
	\rad5, [8, 9, [9, 10, 11 ]+12, (25..32)+32].flat,
]);

q.pos.harpyeGroups.last;

////////// the full harpye holle pattern:
// q.pos.harpyeGroups = NamedList([
// 	////// the firsts of each ring
// 	\pen1, (0..4),
// 	\pen2, (5,7..13),
// 	\pen3, (15,18..29),
// 	\pen4, (30,35..54),
// 	\pen5, (55,63..94),
//
// 	/// the full rings
// 	\rng1, (0..4),
// 	\rng2, (5..13),
// 	\rng3, (15..29),
// 	\rng4, (30..54),
// 	\rng5, (55..94),
//
// 	////// all within one directional cone - hmmm
// 	\rad1, q.pos.harpyes.selectIndices { |pt|
// 		(0.4pi * 1 > pt.theta) and: (pt.theta > (0.4pi * 0))
// 	};
// ]);

////////////// SET WHICH ONES TO USE HERE:
q.pos.mics = q.pos.spiral;
q.pos.micGroups = q.pos.spiralGroups;
/*
q.pos.mics = q.pos.harpyes;
q.pos.micGroups = q.pos.harpyeGroups;
*/

// for easy lookup
q.pos.allNetNames = q.pos.micGroups.names;
q.pos.numNets = q.pos.micGroups.size;
q.pos.lastNet = q.pos.numNets - 1;
q.pos.allNets = (0..q.pos.lastNet);

"*** q.pos.micGroups sizes: ".postln;
q.pos.micGroups.collect(_.size).do { |size, name|
	"%: %\n".postf(name, size);
};

);

// used in q.util.drawMap:
(
q.pos.drawMap = { |pos, remake = false|
	var white = Color.white, black = Color.black;
	if (remake) { try { q.pos.win.close; } };
	if ( (remake or: { q.pos.win.isNil or: { q.pos.win.isClosed } }).not) {
		// "keep q.pos.win ..".postln;
		q.pos.win.front;
	} {
		q.pos.grpIndicesToShow = Set[];
		// "make new q.pos.win ..".postln;
		q.pos.win = Window("Mics and Speaker Layout", Window.flipY(Rect(0,0,500,400)));
		q.pos.win.background_(Color.red(0.3)).front;
		q.pos.butz = q.pos.micGroups.collect { |arr, name, i|
			Button(q.pos.win, Rect(0,i*22,100,20))
			.states_([[name, white, black], [name, black, white]])
			.action_({ |bt|
				if (bt.value > 0) {
					q.pos.grpIndicesToShow.add(i).postln;
					q.pos.uv.refresh;
				} {
					q.pos.grpIndicesToShow.remove(i).postln;
					q.pos.uv.refresh;
				}
			});
		};
		q.pos.uv = UserView(q.pos.win, Rect(100,0,400,400)).front;
		q.pos.uv.resize_(5);

		q.pos.uv.drawFunc = { |u|
			var bounds = u.bounds;
			var center = bounds.extent * 0.5;
			var scaler = center.asArray.minItem;
			Pen.translate(center.x, center.y);

			Pen.stringCenteredIn("X", Rect.aboutPoint(0@0, 10, 10), nil, Color.white);

			// also draw speakers ...
			q.pos.spks.do { |pair, i|
				var rect = Rect.aboutPoint((pair / 10 * scaler).asPoint, 12, 12);
				Pen.color = Color(0.5, 1);
				Pen.addRect(rect);
				Pen.fill;
				Pen.color = Color.grey(0.1);
				Pen.stringCenteredIn((i+1).asString, rect);
			};

			// draw all points
			q.pos.mics.do { |xy, i|
				var pt = (xy / 10 * scaler);
				Pen.color = Color(1.0, 0.75);
				Pen.addArc(pt, 10, 0, 2pi);
				Pen.fill;
				Pen.color = Color.grey(0.1);
				Pen.stringCenteredIn(
					i.asString,
					Rect.aboutPoint(pt, 20, 20)
				);
			};

			Pen.color = Color.grey(0.7);
			// draw the selected groups
			q.pos.grpIndicesToShow.asArray.sort.do { |index|
				var group = q.pos.micGroups[index];
				group.value.doAdjacentPairs { |ai, bi|
					var pta = q.pos.mics[ai];
					var ptb = q.pos.mics[bi];
					Pen.line(pta / 10 * scaler, ptb / 10 * scaler);
				};
				Pen.stroke;
			}
		}
	};
	q.pos.uv.refresh;
};
// q.pos.drawMap;
);


/********* SPEAKER / LISTENER POSITIONS START HERE *********/

// headphone or stereo monitors
q.pos.head = [ [1, -0.5 ], [-1, -0.5] ];

// speakers in caeiros studio (guess)
q.pos.caeiros = [
	[ -1.5,  2.0 ],
	[  1.5,  2.0 ],
	[  2.5,  0.0 ],
	[  2.0, -2.0 ],
	[ -2.0, -2.0 ],
	[ -2.5,  0.0 ]
];

// speakers in UdK aula - 10 meyers
q.pos.aula = [
	[ -4, -6.88],  // front pair
	[  4, -6.88],
	[  8, 0],     // right side
	[ -4, 6.88], // back pair
	[  4, 6.88],
	[ -8, 0],     // left side
	[ 0, 0 ],     // center
	[ -4, -2.88 ], // above, front pair
	[  4, -2.88 ], // above, front pair
	[  0, 4 ],    // above, center back
];

// in ligeti hall graz
q.pos.mumuth = [
	0, 0,
	2.664, -0.352,
	1.864,  2.902,
	-1.256,  3.060,
	-2.664,  0.23,
	-1.886, -2.901,
	1.256, -3.051,
	6.277, -3.232,
	6.558,  1.75,
	5.235,  6.71,
	0.83,   6.795,
	-3.352,  6.71,
	-6.222,  3.222,
	-6.564, -1.749,
	-5.251, -6.528,
	-0.824, -6.816,
	3.358, -6.529,
	6.665, -4.726,
	6.665, -0.395,
	6.665,  3.371,
	5.235, 10.092,
	0,     11.361,
	-5.251, 10.10,
	-6.66,  4.726,
	-6.66,  0.384,
	-6.639, -3.371,
	-5.24, -10.102,
	-0.013, -11.361,
	5.235, -10.102,
	-6.928, 8.961, // 2x4 subs
	-6.928, 1.803,
	-6.928, -5.384,
	-6.928, -12.563,
	7.001, 8.961,
	7.001, 1.803,
	7.001, -5.384,
	7.001, -12.563
].clump(2).keep(30) * 0.8;

/// set speaker output mode to one of these ...
q.pos.spks = q.pos.mumuth;
q.pos.spks = q.pos.aula;
q.pos.spks = q.pos.caeiros;
q.pos.spks = q.pos.head;

////// here:
q.pos.spks = q.pos.head;


///////////// FUNCTION TO CALCULATE DIstance-based amplitudes:
(
q.pos.xy2distAmps = { |dict, point1, points, powerExp = 0.7, mindist = 1, floor = 0.45|
	// calc minimum floor level so we always get valid amps
	// points are more sparse further outside, so make focus wider there
	// offline, this could also be done by finding 4th-highest amp and flooring there.
	var pt1Radius = point1.rho;
	var baseFloor = pt1Radius.linlin(0, 10, 0.45, 0.12) ;
	var minFloor = min(baseFloor, floor);

	// mindist 1 means dist is always > 1
	var min2ed = mindist.squared;
	var dists = points.collect { |point2|
		var sumSquared =
		point1.x.absdif(point2.x).squared
		+ point1.y.absdif(point2.y).squared
		+ min2ed
		;
		sumSquared.sqrt;
	};
	// amps based on xy dist minus florr level to increase focus
	var amps = dists.collect { |d| (d.reciprocal - minFloor).max(0) };
	// use sum to normalize
	var ampscale = amps.sum.max(0.01).reciprocal;
	// // could optimize a little for lang side only;
	///// amps.collectInPlace { |amp| if (amp > 0) { amp * ampscale ** powerExp } { amp } };
	////// this works for lang and server:
	amps = amps.collectInPlace { |amp| amp * ampscale ** powerExp };
	[dists, amps];
};

/////// alternative: calculate bell func with given radius in meters:

q.pos.xyBellDist = { |dict, point1, points, radius = 1.4|

	// distances expand with distance from center,
	// maybe compensate for that?
	var distFromCenter = point1.rho.max(1.6);

	var dists = points.collect (_ dist: point1);
	var amps = dists.collect { |dist|
		dist.linlin(0, radius * distFromCenter, 0, 0.5pi).cos.round(0.000001);
	};
	[dists, amps];
};

// q.pos.xy2distAmps = q.pos[\xyBellDist];


/*
//// test usage in an Ndef:
Ndef(\testXY, { // |x, y|
	var mx = MouseX.kr(-10, 10).poll(1, \x);
	var my = MouseY.kr(-10, 10).poll(1, \y);
	var snd = SinOsc.ar(500) * Dust2.ar(2000, 0.62, 0.38);
	var amps = q.pos.xy2distAmps(mx@my, q.pos.mics)[1];
	snd * amps;
}).play(Ndef(\Pa_micsAll).index);

// Ndef(\testXY).scope;

bench { 1000.do {
	q.pos.xy2distAmps(q.pos.mics[0], q.pos.mics, 1, 0.2);
} };

//////// xy range for mics is ca. +- 9
q.pos.mics.collect(_.x).minItem
q.pos.mics.collect(_.x).maxItem
q.pos.mics.collect(_.y).minItem
q.pos.mics.collect(_.y).maxItem

/// test some points for correctness, esp adjusting floor value
q.pos.xy2distAmps(  q.pos.mics[0], q.pos.mics)[1];
q.pos.xy2distAmps(  0 @ 0, q.pos.mics)[1];
q.pos.xy2distAmps(-10 @ 10, q.pos.mics)[1];
q.pos.xy2distAmps( 10 @ 10, q.pos.mics)[1];
q.pos.xy2distAmps( 10 @ -10, q.pos.mics)[1];
q.pos.xy2distAmps(-10 @ -10, q.pos.mics)[1];

*/
);

