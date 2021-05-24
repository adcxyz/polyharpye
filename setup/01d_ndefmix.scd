///////// ndefmixer:
q.ndef = q.ndef ? ();
q.ndef.mixspace = q.ndef.mixspace ?? { ProxySpace.new };

Butz.add(\ndefmix, { WinBounds.showOrMake('ndefmix') });
WinBounds.addMake(\ndefmix, {
	try { q.mixwin.close };

	q.mixwin = Window(\ndefmix, Rect(103.0, 146.0, 680.0, 440)).front;
	q.mixwin.addFlowLayout;
	q.mixbuts = [\Sounds, \top8, \Mics, \All, \Outs, \Perms ].collect { |name, i|
		Button(q.mixwin, 100@24).font_(Butz.style.midfont)
		.states_([[ name, Color.white, Color.grey ], [ name, Color.white, Color.red(0.8) ]])
		.action_(MFdef('mixBut'));
	};
	q.mixer = ProxyMixer(q.ndef.mixspace, 24, q.mixwin);
	ProxyMeter.addMixer(q.mixer);

	MFdef('mixBut').add(\mixBut, { |bt, mod = 0|
		var name = bt.states[0][0].asSymbol;
		var group = q.ndef[name];
		case { mod.isAlt } {
			"ndefmix solo: %\n".postf(name.cs);
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
	q.mixbuts[0].valueAction_(1);
	q.mixwin;
});

Butz.run(\ndefmix);

