(
name: \tabRiTriSub,
// scaleSeed: 42,
// scaleName: \hungarianMinor,
onNdefs:  [
	(ndef: Ndef(\Ph_tabloid),
		vol: 0.15,
		netIndex: (0, 4 .. q.pos.lastNet),
		// netIndex: (0, 2..16)+1,
		settings: [\detune, 0]
	),
	(ndef: Ndef(\Ph_ropesRingz),
		vol: 0.8,
		netIndex: (1, 5 .. q.pos.lastNet - 1),
		// netIndex: (0, 2..16)+1,
		settings: [\detune, 12]
	),
	(ndef: Ndef(\Ph_triangul),
		vol: 0.06,
		netIndex: (2, 6..q.pos.lastNet)
	),
	// (ndef: Ndef(\Ph_rope2Sub2),
	// 	vol: 0.1,
	// 	netIndex: (0..q.pos.lastNet)
	// ),
	(ndef: Ndef(\Ph_ropesPure),
		vol: 0.1,
		netIndex: (3,7 ..q.pos.lastNet)
	),
])
