//// set up left hand button shortcuts:
//// remake butz window
Task({
	1.wait;
	Butz.numButz = 20;
	Butz.style.winExtent.x = 100;
	Butz.style.font = Font("Futura", 16);
	Butz.style.midfont = Font("Futura", 20);
	Butz.style.bigfont = Font("Futura", 25);

	Window.allWindows.do { |w| if ((w.name == "Butz")) { w.close } };
	0.5.wait;
	Butz.show;
	Butz.w.layout.margins_(1);
	Butz.w.layout.spacing_(0@0);
}).play(AppClock);


// put this func on all Windows,
/// so you can navigate everywhere by shortcuts
MFdef(\masterKeyDown).add(\mtp, { |view, key|
	MTP.keydownDict[key].value(view, key);
});

View.globalKeyDownAction = MFdef(\masterKeyDown);

(
g = g ? (); // gui dict

/// make nameViews/nameButs more prominent:
g.tuneNameView = { |q, obj|
	var but, states;
	case {
		obj.respondsTo(\nameView)
		and: { obj.nameView.notNil }
	}
	{	// "nameview ...".postln;
		obj.nameView.font_(Font("Helvetica", 16))
		.stringColor_(Color.white)
		.background_(Color.blue)
	} { obj.respondsTo(\nameBut) }
	{
		but = obj.nameBut;
		states = but.states;
		// "namebut ...".postln;
		but.font_(Font("Helvetica", 16));
		states[0].put(1, Color.white)
		.put(2, Color.blue);
		but.states_(states);
	} { obj.isKindOf(TaskProxyAllGui) } {

		"XdefAllGui ...".postln;
		obj.edits.do { |tpgui| g.tuneNameView(tpgui) };
	} { obj.isKindOf(ProxyMixer) } {

		"mixer ...".postln;
		(obj.arGuis ++ obj.krGuis ++ obj.editGui).do { |ndgui|
			g.tuneNameView(ndgui);
		};
	} {
		// default
		"*** g.tuneNameView: obj % has no nameView.\n".postf(obj.cs)
	};
	obj
};

/*
Ndef(\x).ar; g.tuneNameView(q.mixer); Ndef(\y).ar;
Pdef(\y); g.tuneNameView(PdefGui(Pdef(\y)));
g.tuneNameView(PdefAllGui(4));
*/
);


Butz.addMiniMax;
Butz.add(\StartupDial, { StartupFile.dialog });
Butz.add(\poly, { Butz.curr_(\poly) });

Butz(\poly).addMiniMax;

[

	\ndefmix,
	'MainFX',
	\tdefall,
	\pdefall,
	'TESTS',
	\meter,
	\scope
].do (Butz.add(_));

[
	\StartupDial,
	\SCENES,
	'spatio',
	\globalXY,
	\MTP_MicIns, // collapse into single MTP button
	\MTP_Resons,
	\ndefmix,
	'MainFX',
	'restoreAll',
	'TESTS',
	\save_scene,
	\drawMap,
	\ChordPlayer,
	\chord_explo,
].do (Butz(\poly).add(_));




Butz.add(\meter, { WinBounds.showOrMake(\meter) });
WinBounds.addMake(\meter, {
	var meterwin;
	s.meter;
	meterwin = Window.find("localhost");
	meterwin.moveTo(20, 20);
	meterwin.name = \meter;
});
Butz.add(\scope, { WinBounds.showOrMake(\scope) });
WinBounds.addMake(\scope, {
	var scopewin;
	s.scope;
	scopewin = Window.find("Stetho");
	scopewin.moveTo(280, 20);
	scopewin.name = \scope;
});


Butz.add(\tdefall, { WinBounds.showOrMake('Tdef.all') });
WinBounds.addMake('Tdef.all', {
	q.tdagui = TdefAllGui(16);
	g.tuneNameView(q.tdagui);
	q.tdagui.parent
});

Butz.add(\MainFX, { WinBounds.showOrMake('MainFX') });
Butz(\poly).add(\MainFX, { Butz.run('MainFX') });

Butz.add(\pdefall, { WinBounds.showOrMake('Pdef.all') });
WinBounds.addMake('Pdef.all', {
	q.pdagui = PdefAllGui(16);
	g.tuneNameView(q.pdagui);
	q.pdagui.parent
});

Butz(\poly).add(\SCENES, { WinBounds.showOrMake('SCENES') });
// WinBounds.addMake(\SCENES) is defined later

// MTP_... added later
// globalXY added later
// ndefmix added later



Butz(\poly).add(\drawMap, { WinBounds.showOrMake('drawMap') });
WinBounds.addMake(\drawMap, { q.pos.drawMap(true) });

Butz(\poly).add(\chord_explo, { (q.dir.poly +/+ "02b_explore_chords.scd").resolveRelative.openOS });

Butz(\poly).add(\save_scene, { MFdef(\saveStr).value });

MFdef(\saveStr).add(\save, {
	var date = Date.getDate.stamp;
	var name = "Polyharpye_on_%".format(date);
	var header = "/*** % ****/\n\n".format(name);
	var comments = "/*/n ... add comments here, and resave! ****/\n\n".format(name);
	var folder = q.dir.poly +/+ "saves";
	var filepath = folder +/+ "%.scd".format(name);

	var ndefStr = Ndef.dictFor(s).playingProxies.collect { |name|
		var ndef = Ndef(name);
		var myNetNames = ndef.getHalo(\myNetNames);
		var netStr = if (myNetNames.notNil) {
			"MFdef('ndef2net').value(%, %);\n\n".format(ndef, myNetNames.cs);
		} { "\n" };
		[
			ndef.nodeMap.asCode(ndef.cs, true),
			"%.vol = %;".format(ndef.cs, ndef.vol.round(0.0001)),
			netStr
		].join("");
	}.join("\n");
	var fullStr = header ++ ndefStr;
	File.mkdir(folder);
	File.use(filepath, "w", { |file| file.write(fullStr) });
	Document.open(filepath);
});
