(
name: \siTriTab,
// scaleSeed: 42,
// scaleName: \major,
onNdefs:  [
	(ndef: Ndef(\Ph_sitar1),
		vol: 0.25,
		netIndex: [0, 5, 9],
		// netIndex: (0, 2..16)+1,
		settings: [\detune, -12]
	),
	(ndef: Ndef(\Ph_triangul),
		vol: 0.25,
		netIndex: [6]
	),
	(ndef: Ndef(\Ph_tabloid),
		vol: 0.25,
		netIndex: [7, 8]
	),
	// (ndef: Ndef(\Ph_verb),
	// 	vol: 0.1,
	// 	netIndex: q.pos.allNets
	// ),
])