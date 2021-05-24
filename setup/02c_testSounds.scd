// simple speaker testers & in/out displays
(
q.test = q.test ? ();
q.test.dust = NodeProxy(s);
q.test.spk = TaskProxy();

Butz.add(\TESTS, { WinBounds.showOrMake(\TESTS) });

WinBounds.addMake(\scope, { s.scope(q.numSpks).window });
WinBounds.addMake(\meter, {
	var meter = s.meter(q.numMics, q.numSpks);
	meter.window.name_("meter").moveTo(110, 10)
});
WinBounds.addMake(\plotTree, {
	s.plotTree(tabSize: 16);
	Window.find(s.name.asString + "Node Tree");
});

WinBounds.addMake(\TESTS, {
	var tdg, states;
	q.test.win = Window('TESTS').front;
	q.test.win.addFlowLayout;
	StaticText(q.test.win, 400@40).string_("GENERAL TESTS:")
	.align_(\center).font_(Butz.style.midfont);

	g.tuneNameView(NdefGui(q.test.dust, 3, q.test.win).name_('dust'));

	/// g.tuneNameView does not work for TdefGui);
	tdg = TdefGui(q.test.spk, 6, q.test.win, Rect(0,0,390,130));
	tdg.name = \testSpeakers;
	states = tdg.nameBut.states;
	states[0].put(1, Color.white).put(2, Color.blue);
	tdg.nameBut.font_(Butz.style.font);
	tdg.nameBut.states_(states);

	[ \scope, \meter, \plotTree].do { |name|
		Button(q.test.win, Rect(0,0,120,30))
		.font_(Butz.style.font)
		.states_([[ name, Color.white, Color.red(0.4) ]])
		.action_({ WinBounds.showOrMake(name) });
	};
	q.test.win;
});

// dust sound source localizes well
q.test.dust.addSpec(\dens, [10, 1000, \exp]);
q.test.dust.source = { Dust2.ar(\dens.kr(300)) };
q.test.dust.vol_(0.1);

//// drum sound going around
q.test.spk.addSpec(\dur, [0.0625, 1, \exp]);
q.test.spk.addSpec(\range, [0, q.numResons, \lin, 1]);
q.test.spk.addSpec(\out, [0, q.numResons - 1, \lin, 1]);

q.test.spk.envir.clear;
q.test.spk.clear;
q.test.spk.set(\range, [0, s.options.numOutputBusChannels]);
q.test.spk.set(\amp, 0.02);
q.test.spk.set(\pan, -1);
q.test.spk.set(\dur, 0.25);
// SynthDef( "mrid") defined in synthdefs
q.test.spk.set(\instrument, \mrid);

q.test.spk.source = { |e|
	loop {
		(e.range.first .. e.range.last).do { |i|
			i.postln;
			e.copy.putAll((\degree: i, \out: i, octave: 5)).play;
			e.dur.wait;
		};
		0.5.wait;
	}
};
)