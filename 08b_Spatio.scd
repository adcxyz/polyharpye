/*
Butz.run(\spatio);
Window.find(\spatio).view.onResize = {
"resizing...".postln;
};
*/


(
Butz.add(\spatio, { WinBounds.showOrMake(\spatio) });

q.pos.colors = q.pos.micGroups.size.collect { |i| Color.hsv(i/q.pos.micGroups.size, 0.7, 0.8) };

q.pos.showNet = { |qpos, netName, col, colOff|
	var black = Color.black;
	var nets = netName.asArray.collect { |key| q.pos.micGroups[key] }.select(_.notNil);
	var indices = nets.flat.asSet.asArray.sort;
	q.pos.showIndices(indices, col, colOff);
};

q.pos.selectedGroupIndices = Set[];

q.pos.showIndices = { |qpos, indices, col, colOff|
	var ampVs = q.spat.ampViews;
	col = col ? Color(1, 0.5);
	colOff = colOff ? Color.black;
	indices.postln;
	ampVs.do { |v, i|
		if (indices.includes(i)) {
			i.postln;
			v.background_(col);
		} {
			v.background_(colOff)
		}
	};
	nil
};

(
// q.spatUV.drawFunc = ...
MFdef('drawSpat').add(\drawGroups, { |uv|

	var font = Butz.style.font.copy.size_(24);
	var cols = q.pos.colors;
	var spati = q.spat;

	////// dynamic size -but views are not scaling!
	// "q.spatUV selectedGroupIndices: %\n\n".postf(q.pos.selectedGroupIndices);

	q.pos.selectedGroupIndices.do { |i|
		var triple = q.pos.micLocsCenters[i];
		var name = triple[0];
		var cent = (triple[1] + [1, 1]) * q.pos.spatScaler + [-8, 8];
		var pnts = triple[2] + [1, 1] * q.pos.spatScaler;
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
	// q.xy.xybase = fixed + drifting mouse xyw
	q.xy.xybase.clump(3).do { |xys, i|
		var name = ["fix", "drift"][i];
		var center = (xys.keep(2) + [1, 1] * q.pos.spatScaler).asPoint;
		var width = xys[2] * q.pos.spatScaler * 0.1;
		var rect = Rect.aboutPoint(center, width, width);
		Pen.strokeOval(rect);
		Pen.stringCenteredIn(name, rect, font)
	};

	// q.xy.xxyys is drifting xys for all mics:
	q.xy.xxyys.clump(3).do { |xys, i|
		var center = (xys.keep(2) + [1, 1] * q.pos.spatScaler).asPoint;
		var width = xys[2] * q.pos.spatScaler * 0.1;
		var rect = Rect.aboutPoint(center, width, width);
		Pen.strokeOval(rect);
		Pen.stringCenteredIn((i + 1).asString, rect, font)
	};
});
);


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
			but.value = q.pos.selectedGroupIndices.includes(i).binaryValue;
		};
	};

	var scenePop = EZPopUpMenu(w, Rect(5, 5, 100, 50),
		"Scenes:", [\SiTriTab, \Silence, \Sitar, \Tabloid], { |pop|
			MFdef(\selectScene).value(pop.item.postln);
	}, labelHeight: 20, layout: \vert);
	var soundPop = EZPopUpMenu(w, Rect(5, 55, 100, 50),
		"Sounds:", q.ndef[\Sounds].collect(_.key), { |pop|
			MFdef(\selectNdef).value(pop.item.postln);
	}, labelHeight: 20, layout: \vert);

	var goBut = Button(w, Rect(5, 110, 100, 22)).states_([["GO!"]])
	.action_({
		MFdef(\ndef2net).(Ndef(soundPop.item.postln), q.pos.selectedGroupIndices.postln);
	});
	var onBut = Button(w, Rect(5, 132, 50, 22)).states_([["on"]])
	.action_({
		q.pos.selectedGroupIndices.addAll((0..q.pos.micGroups.size-1));
		MFdef('updateSpat').value;
	});
	var offBut = Button(w, Rect(55, 132, 50, 22)).states_([["off"]])
	.action_({
		q.pos.selectedGroupIndices.clear;
		MFdef('updateSpat').value;
	});

	var topbuts = q.pos.micGroups.collect { |grp, name, i|
		Button(w, Rect(5, i * 35 + 160, 90, 30))
		.font_(midFont)
		.states_([[name, q.pos.colors[i], Color.blue(0.1)],
			[name, Color.grey(0.9), q.pos.colors[i] ]])
		.action_({ |bt|
			if (bt.value > 0) {
				q.pos.selectedGroupIndices.add(i)
			} {
				q.pos.selectedGroupIndices.remove(i)
			};
			MFdef('updateSpat').value;
		});
	};
	var posMics = q.pos.mics.collect { |list|
		(list * [1, -1] * 0.1 + [0.03, 0.04]).asPoint
	};
	var posSpks = q.pos.spks.keep(q.numOuts).collect { |list|
		(list * [1, -1] * 0.1 + [0.03, 0.04]).asPoint
	};

	var spatHome = CompositeView(w, Rect(100, 0, size, size));
	var spat = SpatioScope(posMics ++ posSpks, s, spatHome, bounds: Rect(10, 10, size, size));

	spatHome.background_(Color.clear);
	spat.parent.name_(name);

	q.scenePop = scenePop;
	q.soundPop = soundPop;

	[ q.scenePop, q.soundPop].do { |pop, i|
		var popbnds = pop.widget.bounds;
		var colors = [Color.grey(0.8), Color(0.1, 1.0, 0.1) ];
		pop.widget.bounds_(popbnds.width = popbnds.width + 20);
		pop.font_(Butz.style.font);
		pop.widget.background_(colors[i]);
		pop.labelView.align_(\center).stringColor_(Color.white);
	};

	MFdef('updateSpat').add(\buts, { updateButs.value });
	MFdef('updateSpat').add(\nets, { q.spatUV.refresh; });

	MFdef(\selectScene).add(\byName, { |name|
		var allScenesNames = q.scenes.all.collect(_.name);
		var scene = q.scenes.all.detect { |dict| dict.name == name };
		case { scene.isNil } {
			"*** scene % not found.".postf(name)
		} { scene.onNdefs.isNil } {
			q.pos.selectedGroupIndices.clear;
			q.scenePop.widget.background_(Color.green(0.8));
			q.soundPop.widget.background_(Color.grey(0.8));
			"*** scene % has no active layers.".postf(name)
		} {
			// scene has layers
			var layers = scene.onNdefs.collect(_.ndef);
			var layerNames = layers.collect(_.key);
			var firstLayer = scene.onNdefs[0];
			q.pos.selectedGroupIndices.clear;

			scene.onNdefs.do { |ndefdict|
				var indices = ndefdict.netIndex;
				q.pos.selectedGroupIndices.addAll(indices);
			};
			q.pos.selectedGroupIndices.postln;

			// update popups
			defer {
				q.scenePop.items = allScenesNames;
				q.scenePop.value = allScenesNames.indexOf(name);
				q.scenePop.widget.background_(Color.green(0.8));
				q.soundPop.widget.background_(Color.grey(0.8));

				firstLayer !? {
					var ndefIndex = q.ndef[\Sounds].indexOf(firstLayer.ndef);
					ndefIndex !? { q.soundPop.value = ndefIndex }
			} };

		};
		MFdef('updateSpat').value;
	});

	MFdef(\selectNdef).add(\byName, { |name|
		var ndef = Ndef.dictFor(s).at(name);
		var names = ndef.getHalo(\netNames);
		var indices = names.collect { |name|
			q.pos.micGroups.names.indexOf(name)
		}.postln;
		q.pos.selectedGroupIndices.clear.addAll(indices);
		q.pos.selectedGroupIndices.postln;
		q.scenePop.widget.background_(Color.grey(0.8));
		q.soundPop.widget.background_(Color.green(0.8));
		MFdef('updateSpat').value;
	});

	// mics views:
	spat.ampViews.keep(q.numResons).do { |av, i|
		av.bounds_(av.bounds.extent_(extentMics));
		av.stringColor_(stringColMics)
		.font_(baseFont);
		// transparent for nets drawing
		av.background_(Color.grey(0, 0.2));
	};
	// speaker views:
	spat.ampViews.drop(q.numResons).do { |av, i|
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
	q.spat = spat;

	q.spat.clickAction = { |indices, x, y, mod|
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

	q.spatUV = UserView(w, spatHome.bounds)
	.background_(Color.clear);
	q.spatUV.acceptsMouse = false;

	q.spatUV.frameRate = 20;
	q.spatUV.animate_(true);

	// prep drawFunc data here:
	q.pos.micLocsCenters = q.pos.micGroups.collect { |grp, name, i|
		var centerPoint = q.pos.groupCenters[i];
		[name, centerPoint, q.spat.locations[grp]];
	};
	q.pos.initBounds = q.spatUV.bounds;
	q.pos.spatScaler = q.pos.initBounds.extent.asArray.minItem * 0.5;

	q.pos.selectedGroupIndices = (0..q.pos.micGroups.size-1).asSet;
	q.spatUV.drawFunc = MFdef('drawSpat');

	MFdef(\selectNdef).(soundPop.item);
	// q.spatUV.refresh;
	w;
});
);



// used in q.util.drawMap:
(
q.pos.drawMap = { |pos, remake = false|
	var white = Color.white, black = Color.black;
	if (remake) { try { q.pos.win.close; } };
	if ( (remake or: { q.pos.win.isNil or: { q.pos.win.isClosed } }).not) {
		// "keep q.pos.win ..".postln;
		q.pos.win.front;
	} {
		q.pos.grpIndicesToShow = Set[];
		// "make new q.pos.win ..".postln;
		q.pos.win = Window("Mics and Speaker Layout", Window.flipY(Rect(0,0,500,400)));
		q.pos.win.background_(Color.red(0.3)).front;
		q.pos.butz = q.pos.micGroups.collect { |arr, name, i|
			Button(q.pos.win, Rect(0,i*22,100,20))
			.states_([[name, white, black], [name, black, white]])
			.action_({ |bt|
				if (bt.value > 0) {
					q.pos.selectedGroupIndices.add(i).postln;
					q.pos.uv.refresh;
				} {
					q.pos.selectedGroupIndices.remove(i).postln;
					q.pos.uv.refresh;
				}
			});
		};
		q.pos.uv = UserView(q.pos.win, Rect(100,0,400,400)).front;
		q.pos.uv.resize_(5);

		q.pos.uv.drawFunc = { |u|
			var bounds = u.bounds;
			var center = bounds.extent * 0.5;
			var scaler = center.asArray.minItem;
			Pen.translate(center.x, center.y);

			Pen.stringCenteredIn("X", Rect.aboutPoint(0@0, 10, 10), nil, Color.white);

			// also draw speakers ...
			q.pos.spks.do { |pair, i|
				var rect = Rect.aboutPoint((pair / 10 * scaler).asPoint, 12, 12);
				Pen.color = Color(0.5, 1);
				Pen.addRect(rect);
				Pen.fill;
				Pen.color = Color.grey(0.1);
				Pen.stringCenteredIn((i+1).asString, rect);
			};

			// draw all points
			q.pos.mics.do { |xy, i|
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
			q.pos.grpIndicesToShow.asArray.sort.do { |index|
				var group = q.pos.micGroups[index];
				group.value.doAdjacentPairs { |ai, bi|
					var pta = q.pos.mics[ai];
					var ptb = q.pos.mics[bi];
					Pen.line(pta / 10 * scaler, ptb / 10 * scaler);
				};
				Pen.stroke;
			}
		}
	};
	q.pos.uv.refresh;
};

Butz.run(\spatio);

////// draw maps on spatioScope:
/*
.xn
// turn spatio off first
q.spat.stop;
q.pos.showIndices((13..21));
q.pos.showIndices((0..4));
q.pos.showIndices((0..4) + 5);
q.pos.showNet(\ring1);
q.pos.showNet([\ring1, \ring3]);
*/
)
