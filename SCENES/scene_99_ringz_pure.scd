/*
Ndef(\Pa_micsAll).getKeysValues.flat.cs

Ndef(\Pa_micsAll).set('simPluck', 0.0, 'simRub', 0.01);
Ndef(\Ph_ropesRingz).getKeysValues.flat.cs
*/
(
name: \START_SOUND,
onNdefs:  [
	(ndef: Ndef(\Ph_ropesRingz),
		vol: 0.25,
		netIndex: PH.pos.allNets, ////// .removeAll([ 10, 17, 18]),
		settings: [ 'amp', 0.5, 'decTime', 0.9, 'detune', 0, 'whiten', 2, 'amp2pitch', 0.02 ]
	),
	(ndef: Ndef(\Ph_ropesPure),
		vol: 0.1,
		netIndex: [6, 8]
	),
	// (ndef: Ndef(\Ph_sitar1),
	// 	vol: 0.08,
	// 	netIndex: [ 10, 17, 18]
	// )
])
