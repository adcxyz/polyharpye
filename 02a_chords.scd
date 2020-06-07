// possible chords for the specific subnets:
/*
(
q.getScale.round(0.001);
q.getScaleAbs.round(0.001);

// fade to random next chord:
q.chords.xfade;
// specifics
q.chords.xfade(\mystic, 48);
q.chords.xfade(\sacre, 48, 1);
q.chords.xfade(\jimi, 52, 1);

q.chords.xfade(\whole);
q.chords.chords.keys.postcs.size;
Tdef(\chords).stop;
Ndef(\chords).end(20);

Tdef(\chords, {
	loop {
		q.chords.chords.keys.do { |key|
			q.chords.xfade(key, rrand(40, 60), 20);
			60.wait;
		}
	}
}).play;
)
*/
(
q.scale = q.scale ? ();

q.chords = ();
q.chords.chords = ();

// pythagoras, pure fifths, no cycle, 500 BC
q.chords.pythag = (0..11) * 1.5.ratiomidi;

// prime numbers as overtones - since invention of strings
q.chords.chords.prime = ([1] ++ (0..9).collect(_.nthPrime)).ratiomidi;

// basic tonal chords
q.chords.chords.major = [0, 7, 12, 16, 19, 24, 28, 31, 36];
q.chords.chords.minor = [0, 7, 12, 15, 19, 24, 27, 31, 36];

// diminished chord (17th century, baroque max dramatic tension)
q.chords.chords.dim = [0, 9, 9, 6, 3, 3, 3, 3, 6, 9, 9, 9].integrate;

// Alexandre Scriabin, early 20th, mystic chord in many late pieces
q.chords.chords.mystic = [0, 6, 10, 16, 21, 26];

// Stravinsky, Sacre du printemps, polytonality
q.chords.chords.sacre = [0, 4, 7, 12, 15, 18, 21, 23];

// prime numbers as undertones (Harry Partch, Subharchord, 20th)
q.chords.chords.subprime = q.chords.chords.prime.reverse.neg + q.chords.chords.prime.maxItem;

// a symmetrical 12tone chord by AdC, a la Schoenberg, Webern (1900-1950)
q.chords.chords.sym12 = [0, 8, 7, 3, 4, 4, 3].mirror.drop(-1).integrate;

// golden ratio as interval structure - James Tenney
q.chords.chords.golden = (0..9) * 1.618024.ratiomidi;

// whole tone scale chord by adc - a la debussy
q.chords.chords.whole = [0, 8, 8, 6, 4, 4, 2, 4, 4, 6, 8, 8].integrate;

// hendrix power chord - E7#9
q.chords.chords.jimi = [0, 12, 16, 22, 27, 31];

q.chords.golden = ();
q.chords.golden.use {
	~gmratio = 5.sqrt + 1 / 2;
	~gmratiorec = 1/~gmratio;
	~gmpitch = ~gmratio.ratiomidi;
	// symmetric intervals from center - [21, 13, 8, 13, 21], expanding from note 0
	~frameIntervals =  ~gmpitch * [ 0.5, ~gmratio, ~gmratio.squared ].integrate;
	~framePitches =  ~frameIntervals.neg.reverse ++ ~frameIntervals;

	~interpolate = { |pitches|
		var pairs = [pitches.drop(-1), pitches.drop(1) ].flop;
		var newpitches = pairs.collect { |pair, i|
			var lo = pair[0], hi = pair[1];
			var diff = hi - lo;
			var interpolLo = lo + (diff * ~gmratiorec.squared);
			var interpolHi = lo + (diff * ~gmratiorec);
			// pair.postln;
			[ lo, interpolLo, interpolHi ];
		}.flat ++ ~framePitches.last;
		newpitches;
	};


	// ~framePitches.differentiate.drop(1).plot;
	// ~interpolate.value(~framePitches).differentiate.drop(1).plot("pitches");
	~chord1 = ~interpolate.value(~framePitches);
	~chord2 = ~interpolate.value(~interpolate.value(~framePitches));

	~orderIndices = [
		4, 42, 43, 14, 38, 39, 12, 34, 35,
		2, 30, 31, 10, 26, 27,  8, 22, 23,
		0, 18, 19,  6, 16, 17,  7, 20, 21,
		1, 24, 25,  9, 28, 29, 11, 32, 33,
		3, 36, 37, 13, 40, 41, 15, 44, 45,
		5
	];
	~orderedChord = Array.newClear(~orderIndices.size);
	~orderIndices.do { |spatIndex, i|
		~orderedChord.put(spatIndex, ~chord2[i]);
	};
	~orderedChord
};

q.chords.golden.chord2.size;
q.chords.golden.orderIndices;
q.chords.golden.orderedChord;

q.chords.chords.gmspiral1 = q.chords.golden.chord1;
q.chords.chords.gmspiral2 = q.chords.golden.chord2;

/*
q.chords.golden.chord1.round(0.001).postln;
q.chords.golden.chord2.round(0.001).postln;

*/

// SCALES:
// function to make a repeatable random major scale distribution
// q.makeScale = { |q, seed|
// 	{ ((Scale.major.degrees +.t [-12, -12, 0, 0, 0, 12, 12, 24, 24]).flat ++ 36).scramble }.valueSeed(seed);
// };
// can now pass in scale name - distro is still by randSeed
q.makeScale = { |q, seed, scaleName = \major, lowest = -2, highest = 2|
	var numNotes = q.numResons;
	///////  good balanced set of octaves, for sitar, tabla etc
	// var octaves = [-2, -1, 0, 0, 0, 1, 1, 2, 2].clip(lowest, highest);
	///////  toy piano range for opening night and TS default
	var octaves = [0, 0, 0, 0, 0, 1, 1, 1, 2].clip(lowest, highest);
	var octShifts = octaves * 12;
	// [-12, -12, 0, 0, 0, 12, 12, 24, 24]
	{
		(
			Scale.at(scaleName).degrees.wrapExtend(numNotes).scramble
			+ octShifts.wrapExtend(numNotes).scramble
		)
	}.valueSeed(seed);
};

q.getScale = { Ndef(\scale).get(\scale) };
q.getScaleAbs = { Ndef(\scale).get(\scale) + Ndef(\scale).get(\base) };
q.setScale = { |q, scale|
	if (scale.size != q.numResons) {
		"not a valid scale.".warn;
	} {
		"*** SCALE is now:".postln;
		scale.round(0.001).postln;
		Ndef(\scale).set(\scale, scale)
	}
};

q.scale.name = \hungarianMinor; q.scale.seed = 4711;
q.scale.allIntervals = q.makeScale(q.scale.seed, q.scale.name);

q.scale.allIntervals = q.scale.allIntervals.collect { |intv|
	if (intv < 0) { intv.wrap(0, 11) } { intv };
};

Ndef(\scale).fadeTime = 10;
Ndef(\scale).addSpec(\base, [36, 84, \lin, 0.5]);
Ndef(\scale).addSpec(\lag, [0, 10, \amp ]);

// THE BOMB for openingn night and TS default
// q.scale.allIntervals[26] = 4;
//  q.scale.allIntervals[12] = -31 ; - 12;
q.scale.allIntervals[36] = -36 ; - 12;
q.scale.allIntervals[38] = -29; - 12;
// fix of too high note
q.scale.allIntervals[39] = 7; - 12;

Ndef(\scale, { |base = 60, lag = 10|
	var scaleKr = \scale.kr(q.scale.allIntervals);
	(base + scaleKr).clip(12, 120).lag(lag);
});

/////// set to gmchord for now
q.setScale(
	// (q.chords.chords.gmspiral2 ++ q.chords.chords.gmspiral2.keep(-19)).scramble
	q.chords.golden.orderedChord;
);
)


// make one for cologneliness
// q.makeScale(4711, \major);
// // the current scale
// "\n\n*** q.getScale is: %\n\n".postf(q.getScale);

/*
Ndef(\scaletest, {
(Splay.ar(Ringz.ar(Impulse.ar(0.2!q.numResons, (0..q.numResons - 1) / 100, 1) + PinkNoise.ar(0.002), Ndef(\scale).kr.midicps, 0.1)) * 0.1).clip2(0.5, 0.5)
}).play(0);
*/

/*
// reeeally boring
q.setScale(q.makeScale(0815));
// and the meaning of life
q.setScale(q.makeScale(42));

q.setScale(q.makeScale(10.rand.postln));
Ndef(\scale).gui

*/

/*
// build a fat chord network from adc chords:
q.chords.chords.collect(_.size).sum; // 106 chord notes
q.pos.micGroups.collect(_.value).collect(_.size).sum; // 102 connected ropes

q.setScale(q.chords.chords.asArray.flat.round(0.01).asSet.asArray - 30);
*/

