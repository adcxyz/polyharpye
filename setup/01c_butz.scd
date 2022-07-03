//// set up left hand button shortcuts:
Butz.clear;
Butz.numButz = 24;
Butz.style.winExtent.x = 120;
Butz.style.font = Font("Futura", 16);
Butz.style.midfont = Font("Futura", 20);
Butz.style.bigfont = Font("Futura", 25);

Butz.makeWin;
Butz.w.layout.margins_(4);
Butz.w.layout.spacing_(0@0);

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

[
	\StartupDial,
	\SCENES,
	'spatio',
	\globalXY,
	\MTP_MicIns, // collapse into single MTP button
	\MTP_Resons,
	\ndefmix,
	'MainFX',
	\tdefall,
	\pdefall,
	'restoreAll',
	'TESTS',
	\save_scene,
	\drawMap,
	\ChordPlayer,
	\chord_explo,
].do (Butz.add(_));

Butz.show;
Butz.add(\StartupDial, { StartupFile.dialog });
Butz.addMiniMax;

Butz.add(\SCENES, { WinBounds.showOrMake('SCENES') });
// WinBounds.addMake(\SCENES) is defined later

// MTP_... added later
// globalXY added later
// ndefmix added later

Butz.add(\tdefall, { WinBounds.showOrMake('Tdef.all') });
WinBounds.addMake('Tdef.all', {
	q.tdagui = TdefAllGui(16);
	g.tuneNameView(q.tdagui);
	q.tdagui.parent
});

Butz.add(\MainFX, { WinBounds.showOrMake('MainFX') });

Butz.add(\pdefall, { WinBounds.showOrMake('Pdef.all') });
WinBounds.addMake('Pdef.all', {
	q.pdagui = PdefAllGui(16);
	g.tuneNameView(q.pdagui);
	q.pdagui.parent
});

Butz.add(\drawMap, { WinBounds.showOrMake('drawMap') });
WinBounds.addMake(\drawMap, { q.pos.drawMap(true) });

Butz.add(\chord_explo, { (q.dir.poly +/+ "02b_explore_chords.scd").resolveRelative.openOS });

Butz.add(\save_scene, { MFdef(\saveStr).value });

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
