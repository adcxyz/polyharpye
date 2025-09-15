///////// make ndefmixer flexible:
q.ndef = q.ndef ? ();
q.ndef.groups = q.ndef.groups ? ();
q.ndef.mixspace = q.ndef.mixspace ?? { ProxySpace.new };
q.ndef.groupNames = q.ndef.groupNames ? [\NTMI, \Sounds, \top8, \Mics, \All, \Outs, \Perms ];

// each button adds or removes Ndefs for that group:
MFdef('mixBut').add(\mixBut, { |bt, mod = 0|
	var name = bt.states[0][0].asSymbol;
	var group = q.ndef.groups[name];
	// hold alt key to show only that group that  function
	case { mod.isAlt } {
		"*** ndefmix shows only: %\n".postf(name.cs);
		q.ndef.mixspace.envir.clear;
		group.do { |ndef| q.ndef.mixspace.envir.put(ndef.key, ndef) };
		q.mixbuts.do(_.value_(0));
		bt.value = 1;
	} { bt.value > 0 } {
		"ndefmix adding: %\n".postf(name.cs);
		group.do { |ndef| q.ndef.mixspace.envir.put(ndef.key, ndef) };
	} {
		"ndefmix removing: %\n".postf(name.cs);
		group.do { |ndef| q.ndef.mixspace.envir.removeAt(ndef.key) };
	}
});

Butz.add(\ndefmix, { WinBounds.showOrMake('ndefmix') });
Butz(\poly).add(\ndefmix, { WinBounds.showOrMake('ndefmix') });

WinBounds.addMake(\ndefmix, {
	try { q.mixwin.close };
	q.mixwin = Window(\ndefmix, Rect(700, 94.0, 806.0, 491.0)).front;
	q.mixwin.addFlowLayout;

	q.mixbuts = q.ndef.groupNames.collect { |name, i|
		Button(q.mixwin, 60@24).font_(Butz.style.midfont)
		.states_([[ name, Color.white, Color.grey ], [ name, Color.white, Color.red(0.8) ]])
		.action_(MFdef('mixBut'));
	};
	q.mixer = ProxyMixer.small(q.ndef.mixspace, 24, q.mixwin);
	ProxyMeter.addMixer(q.mixer);

	// defer { q.mixer.switchSize(2) };

	q.ndef.groups .putAll(PH.ndef.groups);
	q.mixbuts[0].valueAction_(1);
	q.mixbuts[1].valueAction_(1);

	q.mixwin;
});
