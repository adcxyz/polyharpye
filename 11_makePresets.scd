/*
// its getting better and better ...


/// LOAD ONE OF TE old saved settings:
q.loadSetup(\stopped);

q.loadSetup(\started);
q.loadSetup("batuque");

// to save a setup, give it a name:
q.saveSetup(\worldmusic);
CmdPeriod.run;
q.saveSetup(\stopped);

q.loadSetup(\started);
q.loadSetup("batuque");

*/

q.pre = ();

// 'micsAll' are broken
// // fix mystery broken Ph_micsAll values
// Ndef(\Ph_micsAll).supplementNodeMap;
// Ndef(\Ph_micsAll).nodeMap.keys.do { |key|
// 	if (key.isKindOf(Symbol).not) { Ndef(\Ph_micsAll).put(key, nil) }
// };

q.pre.names = Ndef.all.localhost.arProxyNames.reject(_  == \Ph_micsAll);

q.pre.win = Window("PRESETS", Rect(0,0,500, 500)).front;
q.pre.win.addFlowLayout;

// // separate buttons?
// q.pre.butZone = CompositeView(q.pre.win, 100@600);
// // update when needed!
// q.pre.butZone.addFlowLayout;
// q.pre.names.do { |name|
// 	Button(q.pre.butZone, 90@30).states_([[name]]);
// };

q.pre.names.do { |name|
	try { NdefPreset(Ndef(name)).postcs } { "preset failed for: %!\n".postf(name) };
};

/*** proxies are saved like this:
[ Ndef(\x),
	[\settings, getKeysVals],
	// [\playState, \stop],
	[\playState, \playN, \vol, \outs, \amps],
	[\playState, \play, \out, \amp]
	[\myNet, (\blabla -> [1, 2, 3]) ]
]
***/

q.proxySaveList = { |q, proxy, withPlay = true, withSettings = true, withNet = true|
	var list = List[proxy];
	var monitor = proxy.monitor;
	var playing = monitor.isPlaying;
	var myNet = proxy.getHalo(\myNet);
	if (withSettings) { list.add([\settings, proxy.getKeysValues ]) };
	if (withPlay) {
		if (playing.not) {
			list.add([\playState, \stop])
		} {
			// monitor is playing:
			if (monitor.usedPlayN) {
				list.add([\playState, \playN, monitor.outs, monitor.vol, monitor.fadeTime ]);
			} {
				list.add([\playState, \play, monitor.out, monitor.vol, monitor.fadeTime ]);
			}
		}
	};
	if (withNet and: myNet.notNil) {
		list.add([\myNet, myNet]);
	};
	list
};

q.proxySaveList(Ndef(\verb)).cs.replace("], [", "],\n\t[").replace("), [", "),\n [").replace("[ [", "[\n\t[");

q.proxySaveList(Ndef(\ropesRingz)).cs.replace("], [", "],\n\t[").replace("), [", "),\n [").replace("[ [", "[\n\t[");

q.proxySaveList(Ndef(\batucada)).cs.replace("], [", "],\n\t[").replace("), [", "),\n [").replace("[ [", "[\n\t[");


/*
q.proxySaveStr(Ndef(\time16), true, true);
q.proxySaveStr(Ndef(\time16), true, Ndef(\time16).monitor.isPlaying);
q.proxySaveStr(Ndef(\batucada));
q.proxySaveStr(Ndef(\scale));

*/

(
q.saveSetup = { |q, savename, includeNodeMaps = true|
	var stamp = Date.getDate.stamp;
	var basename = "SETUP_%.scd".format(savename ? stamp);
	var filepath = q.projdir +/+ basename;
	var bkName = "setups_BK/SETUP_%_%_BK.scd".format(savename, stamp);
	var bkfilepath = q.projdir +/+ bkName;

	var title = "/*** % - saved at date % . ***/\n\n".format(basename, stamp);

	var prettify = { |list|
		list.cs.replace("], [", "],\n\t[").replace("), [", "),\n [").replace("[ [", "[\n\t[") ++ ",\n"
	};

	fork {
		var cond = Condition();
		if (filepath.pathMatch.notNil) {
			// moving previous version to backup folder
			File.mkdir(bkfilepath.dirname);
			unixCmd("mv % %".format( filepath.quote, (q.projdir +/+ bkName).quote).postcs, { cond.unhang });
			cond.hang;
		};

		File.use(filepath.postcs, "w", { |file|

			file.write(title);

			file.write("\n\n//////////// SOUNDS: All active q.ndefSounds param and playback settings:\n");

			file.write("[\n");

			q.ndef[\Sounds].do { |proxy|
				var postSettings = proxy.monitor.isPlaying;
				file.write(prettify.(q.proxySaveList(proxy, true, postSettings)))
			};


			file.write("\n\n//////////// OUTPUTS: q.ndefOuts param and playbackplayback settings:\n");
			q.ndefOuts.do { |proxy|
				file.write(prettify.(q.proxySaveList(proxy)))
			};

			file.write("\n\n//////////// PERMANENT sources: q.ndefPerms param settings:\n");
			q.ndefPerms.do { |proxy|
				file.write(prettify.(q.proxySaveList(proxy)))
			};

			// file.write("//////////// All MFdef states:\n");
			// MFdef.all.do { |mf|
			// 	var str = "MFdef(%).enable( % )\n.disable( % );\n\n".format(
			// 		mf.key.cs, mf.activeNames.cs, mf.orderedNames.difference(mf.activeNames).cs
			// 	);
			// 	file.write(str);
			// };
			file.write("\n]\n");

		});
		filepath.openOS;
	};
};
// q.saveSetup("sitarTest");
);

q.loadSetup = { |q, setupName="blablbal"|
	var path = q.projdir +/+ "SETUP_%.scd".format(setupName);
	path.pathMatch.postcs;
	path.loadPaths;
};


/*

q.saveSetup(\sitarbla);
CmdPeriod.run;
q.saveSetup(\stopped);

q.loadSetup(\started);
q.loadSetup("batuque");


Ndef.all.localhost.do(_.fadeTime = 0.02);
q.loadSetup("stopped");

q.loadSetup("batuqueBOESE");
q.loadSetup(\started);

OSCdef(\micTrig).disable;
MFdef(\micTrig).disable(\post);

*/

q.pre.presetNames = NdefPreset.all.keys(Array).sort;
q.pre.popup = EZPopUpMenu(q.pre.win, 200@30, \show, q.pre.names, { |pop| q.pre.pregui.object = NdefPreset(pop.item) });
q.pre.pregui = NdefPresetGui(nil, 20, q.pre.win.view);

q.pre.pregui;