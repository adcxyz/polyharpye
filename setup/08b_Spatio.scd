/*
Butz.run(\spatio);
Window.find(\spatio).view.onResize = {
"resizing...".postln;
};
*/


(
Butz(\poly).add(\spatio, { WinBounds.showOrMake(\spatio) });

PH.pos.colors = PH.pos.micGroups.size.collect { |i| Color.hsv(i/PH.pos.micGroups.size, 0.7, 0.8) };

PH.pos.showNet = { |qpos, netName, col, colOff|
	var black = Color.black;
	var nets = netName.asArray.collect { |key| PH.pos.micGroups[key] }.select(_.notNil);
	var indices = nets.flat.asSet.asArray.sort;
	PH.pos.showIndices(indices, col, colOff);
};

PH.pos.selectedGroupIndices = Set[];

PH.pos.showIndices = { |qpos, indices, col, colOff|
	var ampVs = PH.spat.ampViews;
	col = col ? Color(1, 0.5);
	colOff = colOff ? Color.black;
	indices.postln;
	ampVs.do { |v, i|
		if (indices.includes(i)) {
			v.background_(col);
		} {
			v.background_(colOff)
		}
	};
	nil
};

PH.micLevels = 0.1.dup(Ndef(\Pa_micIns).numChannels);

(
// PH.spatUV.drawFunc = ...
MFdef('drawSpat').add(\drawGroups, { |uv|

	var font = Butz.style.font.copy.size_(36);
	var cols = PH.pos.colors;
	var spati = PH.spat;

	////// dynamic size -but views are not scaling!
	// "PH.spatUV selectedGroupIndices: %\n\n".postf(PH.pos.selectedGroupIndices);
	PH.pos.selectedGroupIndices.do { |i|
		var triple = PH.pos.micLocsCenters[i];
		var name = triple[0];
		var cent = (triple[1] + [1, 1]) * PH.pos.spatScaler + [-8, 8];
		var pnts = triple[2] + [1, 1] * PH.pos.spatScaler;
		var rect = Rect.aboutPoint(cent, 20, 20);

		Pen.color_(cols[i]);
		Pen.addOval(rect).stroke;

		///// or the group as one shape
		pnts.doAdjacentPairs { |pta, ptb| Pen.line(pta, ptb) };

		Pen.stroke;
		///// then the name first
		Pen.stringCenteredIn(name, rect, font, Color.white);
	};
	Pen.color = Color.grey(1);
	Pen.width = 1.5;
	// PH.xy.xybase = fixed + drifting mouse xyw
	// PH.xy.xybase.clump(3).do { |xys, i|
	// 	var name = ["fix", "drift"][i];
	// 	var center = (xys.keep(2) + [1, 1] * PH.pos.spatScaler).asPoint;
	// 	var width = xys[2] * PH.pos.spatScaler * 0.1;
	// 	var rect = Rect.aboutPoint(center, width, width);
	// 	Pen.strokeOval(rect);
	// 	Pen.stringCenteredIn(name, rect, font)
	// };

	// PH.xy.xxyys is drifting xys for all mics:
	PH.xy.xxyys.clump(3).do { |xys, i|
		var center = (xys.keep(2) + [1, 1] * PH.pos.spatScaler).asPoint;
		var width = xys[2] * PH.pos.spatScaler * 0.3;
		var levelrad = width * PH.micLevels.sqrt[i];
		var rect = Rect.aboutPoint(center, width, width);
		var levelrect = Rect.aboutPoint(center, levelrad, levelrad);
		Pen.fillColor_(Color.grey(1, 0.4));
		Pen.fillOval(rect);
		Pen.fillColor_(Color.green(1, 0.5));
		Pen.fillOval(levelrect);

		Pen.stringCenteredIn((i + 1).asString, rect, font, Color.white)
	};
});
);

MFdef(\showScaleNotes).add(\calcAndShow, {
	var midinotes = (PH.getScale.round + Ndef(\scale).get(\base));
	var notenames = midinotes.collect { |midinote, i| PH.toNote(midinote) };

	// [ midinotes, notenames ].flop.printAll;
	notenames.do { |notename, i| PH.spat.ampViews[i].string = notename };
});


WinBounds.addMake(\spatio, {
	var name = \spatio;
	var w = Window(name, Rect(100, 100, 800, 800)).front
	.background_(Color.blue(0.3));
	var size = 700;
	var extentMics = 26@26;
	var extentSpks = 42@42;
	var stringColMics = Color(0.4, 1.0, 1.0);
	var stringColSpks = Color(1.0, 0.8);

	// Butz.style.bigfont;

	var baseFont = Butz.style.font;
	var midFont = Butz.style.midfont;

	var updateButs = {
		// "updateButs".postln;
		topbuts.do { |but, name, i|
			but.value = PH.pos.selectedGroupIndices.includes(i).binaryValue;
		};
	};

	var scenePop = EZPopUpMenu(w, Rect(5, 5, 100, 50),
		"Scenes:", [\SiTriTab, \Silence, \Sitar, \Tabloid], { |pop|
			MFdef(\selectScene).value(pop.item.postln);
	}, labelHeight: 20, layout: \vert);
	var soundPop = EZPopUpMenu(w, Rect(5, 55, 100, 50),
		"Sounds:", PH.ndef.groups[\Sounds].collect(_.key), { |pop|
			MFdef(\selectNdef).value(pop.item.postln);
	}, labelHeight: 20, layout: \vert);

	var goBut = Button(w, Rect(5, 110, 100, 22)).states_([["GO!"]])
	.action_({
		MFdef(\ndef2net).(Ndef(soundPop.item.postln), PH.pos.selectedGroupIndices.postln);
	});
	var onBut = Button(w, Rect(5, 132, 50, 22)).states_([["on"]])
	.action_({
		PH.pos.selectedGroupIndices.addAll((0..PH.pos.micGroups.size-1));
		MFdef('updateSpat').value;
	});
	var offBut = Button(w, Rect(55, 132, 50, 22)).states_([["off"]])
	.action_({
		PH.pos.selectedGroupIndices.clear;
		MFdef('updateSpat').value;
	});

	var topbuts = PH.pos.micGroups.collect { |grp, name, i|
		Button(w, Rect(5, i * 35 + 160, 90, 30))
		.font_(midFont)
		.states_([[name, PH.pos.colors[i], Color.blue(0.1)],
			[name, Color.grey(0.9), PH.pos.colors[i] ]])
		.action_({ |bt|
			if (bt.value > 0) {
				PH.pos.selectedGroupIndices.add(i)
			} {
				PH.pos.selectedGroupIndices.remove(i)
			};
			MFdef('updateSpat').value;
		});
	};
	var posMics = PH.pos.mics.collect { |list|
		(list * [1, -1] * 0.1 + [0.03, 0.04]).asPoint
	};
	var posSpks = PH.pos.spks.keep(PH.numSpks).collect { |list|
		(list * [1, -1] * 0.1 + [0.03, 0.04]).asPoint
	};

	var spatHome = CompositeView(w, Rect(100, 0, size, size));
	var spat = SpatioScope(posMics ++ posSpks, s, spatHome, bounds: Rect(10, 10, size, size));

	spatHome.background_(Color.clear);
	spat.parent.name_(name);

	PH.scenePop = scenePop;
	PH.soundPop = soundPop;

	[ PH.scenePop, PH.soundPop].do { |pop, i|
		var popbnds = pop.widget.bounds;
		var colors = [Color.grey(0.8), Color(0.1, 1.0, 0.1) ];
		pop.widget.bounds_(popbnds.width = popbnds.width + 20);
		pop.font_(Butz.style.font);
		pop.widget.background_(colors[i]);
		pop.labelView.align_(\center).stringColor_(Color.white);
	};

	MFdef('updateSpat').add(\buts, { updateButs.value });
	MFdef('updateSpat').add(\nets, { PH.spatUV.refresh; });

	MFdef(\selectScene).add(\byName, { |name|
		var allScenesNames = PH.scenes.all.collect(_.name);
		var scene = PH.scenes.all.detect { |dict| dict.name == name };
		var layers, layerNames, firstLayer, ndefIndex;

		case { scene.isNil } {
			"*** scene % not found.".postf(name)
		} { scene.onNdefs.isNil } {
			PH.pos.selectedGroupIndices.clear;
			PH.scenePop.widget.background_(Color.green(0.8));
			PH.soundPop.widget.background_(Color.grey(0.8));
			"*** scene % has no active layers.".postf(name)
		} {
			// scene has layers
			layers = scene.onNdefs.collect(_.ndef);
			layerNames = layers.collect(_.key);
			firstLayer = scene.onNdefs[0];
			PH.pos.selectedGroupIndices.clear;

			scene.onNdefs.do { |ndefdict|
				var indices = ndefdict.netIndex;
				PH.pos.selectedGroupIndices.addAll(indices);
			};
			// PH.pos.selectedGroupIndices.postln;

			// update popups
			defer {
				PH.scenePop.items = allScenesNames;
				PH.scenePop.value = allScenesNames.indexOf(name);
				PH.scenePop.widget.background_(Color.green(0.8));
				PH.soundPop.widget.background_(Color.grey(0.8));

				firstLayer !? {
					ndefIndex = PH.ndef.groups[\Sounds].indexOf(firstLayer.ndef);
					ndefIndex !? { PH.soundPop.value = ndefIndex }
			} };

		};
		MFdef('updateSpat').value;
	});

	MFdef(\selectNdef).add(\byName, { |name|
		var ndef = Ndef.dictFor(s).at(name);
		var names = ndef.getHalo(\netNames);
		var indices = names.collect { |name|
			PH.pos.micGroups.names.indexOf(name)
		}.postln;
		PH.pos.selectedGroupIndices.clear.addAll(indices);
		PH.pos.selectedGroupIndices.postln;
		PH.scenePop.widget.background_(Color.grey(0.8));
		PH.soundPop.widget.background_(Color.green(0.8));
		MFdef('updateSpat').value;
	});

	// mics views:
	spat.ampViews.keep(PH.numResons).do { |av, i|
		av.bounds_(av.bounds.extent_(extentMics));
		av.stringColor_(stringColMics)
		.font_(baseFont);
		// transparent for nets drawing
		av.background_(Color.grey(0, 0.2));
	};
	// speaker views:
	spat.ampViews.drop(PH.numResons).do { |av, i|
		av.bounds_(av.bounds.extent_(extentSpks));
		av.string_("Sp" ++ (i + 1))
		.stringColor_(stringColSpks).font_(midFont);
		// transparent for nets drawing
		av.background_(Color.grey(0, 0.2));
	};
	spat.skipjack.dt = 0.05;
	spat.magnify = 4;
	spat.busOffset = Ndef(\Pa_micsAll).index ? 0;

	spat.clickAction = { |indices, x, y, mod|
		"clicked in ampView index: %, xy: %, mod key: %\n"
		.postf(indices, [x, y], mod)
	};
	PH.spat = spat;

	MFdef(\showScaleNotes).value;

	PH.spat.clickAction = { |indices, x, y, mod|
		var pitches;
		var index = indices.unbubble;
		// "clicked in ampView index: %, xy: %, mod key: %\n"
		// .postf(indices, [x, y], mod)
		if (index.notNil) {
			pitches = Ndef(\scale).bus.getnSynchronous;
			"scale pitch at index % is % -> % Hz.\n".postf(
				index, pitches[index], pitches[index].midicps
			);
		} {
			"click on a node to see its pitch...".postln;
		};
	};

	PH.spatUV = UserView(w, spatHome.bounds)
	.background_(Color.clear);
	PH.spatUV.acceptsMouse = false;

	PH.spatUV.frameRate = 20;
	PH.spatUV.animate_(true);

	// prep drawFunc data here:
	PH.pos.micLocsCenters = PH.pos.micGroups.collect { |grp, name, i|
		var centerPoint = PH.pos.groupCenters[i];
		[name, centerPoint, PH.spat.locations[grp]];
	};
	PH.pos.initBounds = PH.spatUV.bounds;
	PH.pos.spatScaler = PH.pos.initBounds.extent.asArray.minItem * 0.5;

	PH.pos.selectedGroupIndices = (0..PH.pos.micGroups.size-1).asSet;
	PH.spatUV.drawFunc = MFdef('drawSpat');

	MFdef(\selectNdef).(soundPop.item);
	// PH.spatUV.refresh;
	w;
});
);



// used in PH.util.drawMap:
(
PH.pos.drawMap = { |pos, remake = false|
	var white = Color.white, black = Color.black;
	if (remake) { try { PH.pos.win.close; } };
	if ( (remake or: { PH.pos.win.isNil or: { PH.pos.win.isClosed } }).not) {
		// "keep PH.pos.win ..".postln;
		PH.pos.win.front;
	} {
		PH.pos.grpIndicesToShow = Set[];
		// "make new PH.pos.win ..".postln;
		PH.pos.win = Window("Mics and Speaker Layout", Window.flipY(Rect(0,0,500,400)));
		PH.pos.win.background_(Color.red(0.3)).front;
		PH.pos.butz = PH.pos.micGroups.collect { |arr, name, i|
			Button(PH.pos.win, Rect(0,i*22,100,20))
			.states_([[name, white, black], [name, black, white]])
			.action_({ |bt|
				if (bt.value > 0) {
					PH.pos.selectedGroupIndices.add(i).postln;
					PH.pos.uv.refresh;
				} {
					PH.pos.selectedGroupIndices.remove(i).postln;
					PH.pos.uv.refresh;
				}
			});
		};
		PH.pos.uv = UserView(PH.pos.win, Rect(100,0,400,400)).front;
		PH.pos.uv.resize_(5);

		PH.pos.uv.drawFunc = { |u|
			var bounds = u.bounds;
			var center = bounds.extent * 0.5;
			var scaler = center.asArray.minItem;
			Pen.translate(center.x, center.y);

			Pen.stringCenteredIn("X", Rect.aboutPoint(0@0, 10, 10), nil, Color.white);

			// also draw speakers ...
			PH.pos.spks.do { |pair, i|
				var rect = Rect.aboutPoint((pair / 10 * scaler).asPoint, 12, 12);
				Pen.color = Color(0.5, 1);
				Pen.addRect(rect);
				Pen.fill;
				Pen.color = Color.grey(0.1);
				Pen.stringCenteredIn((i+1).asString, rect);
			};

			// draw all points
			PH.pos.mics.do { |xy, i|
				var pt = (xy / 10 * scaler);
				Pen.color = Color(1.0, 0.75);
				Pen.addArc(pt, 10, 0, 2pi);
				Pen.fill;
				Pen.color = Color.grey(0.1);
				Pen.stringCenteredIn(
					i.asString,
					Rect.aboutPoint(pt, 20, 20)
				);
			};

			Pen.color = Color.grey(0.7);
			// draw the selected groups
			PH.pos.grpIndicesToShow.asArray.sort.do { |index|
				var group = PH.pos.micGroups[index];
				group.value.doAdjacentPairs { |ai, bi|
					var pta = PH.pos.mics[ai];
					var ptb = PH.pos.mics[bi];
					Pen.line(pta / 10 * scaler, ptb / 10 * scaler);
				};
				Pen.stroke;
			}
		}
	};
	PH.pos.uv.refresh;
};

Butz(\poly).run(\spatio);

////// draw maps on spatioScope:
/*
.xn
// turn spatio off first
PH.spat.stop;
PH.pos.showIndices((13..21));
PH.pos.showIndices((0..4));
PH.pos.showIndices((0..4) + 5);
PH.pos.showNet(\ring1);
PH.pos.showNet([\ring1, \ring3]);
*/
)
