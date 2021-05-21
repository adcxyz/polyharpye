/////// nanoKontrol!

MKtl.find(\midi);
MKtl(\nanoK2, "*trol2");
/*
MKtl(\nanoK2).gui;
*/
///// scenes are:
// S 1 2 3 4,
// M 1 2 3 4,
// S 5 6 7 8,
// M 5 6 7 8,

Butz.add(\nanoK2, { WinBounds.showOrMake(\nanoK2) });
WinBounds.addMake(\nanoK2, { MKtl(\nanoK2).gui.parent });

// Butz.add('END', { q.ndef[\Sounds].do(_.end(5)); });

MKtl(\nanoK2).elAt(\bt, [\S, \M]).collect(_.clump(4)).flatten[[0, 2, 1, 3]].flat.do { |el, sceneIndex|
	el.action = { |el|
		if (el.isOn) {
			defer {
				q.scenes.buts[sceneIndex].valueAction_(1);
			};
		};
	};
};

// transport buttons switch scales
MKtl(\nanoK2).elAt(\tr).flat.keep(4).do { |el, scaleIndex|
	el.action = { |el|
		if (el.isOn) {
			defer {
				Butz.run([ \scaleGM, \scaleGMRev, \scaleHung23, \scaleHun42][scaleIndex].postcs);
			};
		};
	};
};




// leave last knob at direct volume control for emergency OFF
MKtl(\nanoK2).elAt(\kn, 7).action = { |el|
	MainFX(s).set(\mainVol, (el.value * 2).squared)
};

// three buttons to read for number of nets to activate
MKtl(\nanoK2).elAt(\tr, \mset);


// top 8 sounds to toggle directly:
q.ndef.top8.do { |ndf, i|
	// slider softsets vol and pauses when 0
	MKtl(\nanoK2).elAt(\sl, i).action = { |sl|
		ndf.softVol_(sl.value, lastVal: sl.prevValue);
	};
	// button R toggles on/off
	// ? hold down modifier to get full chans?
	MKtl(\nanoK2).elAt(\bt, \R, i).action = { |bt|
		var numNodes;
		if (bt.isOn) {
			if (ndf.monitor.isPlaying) {
				ndf.stop
			} {
				// if mset, mright or mleft buttons are down, reset nodes in 3 sizes:
				case { bt.source.elAt(\tr, \mright).isOn } {
					"many nodes".postln;
					numNodes = 4;
				} { bt.source.elAt(\tr, \mleft).isOn } {
					"half nodes".postln;
					numNodes = 2;
				} { bt.source.elAt(\tr, \mset).isOn } {
					"few nodes".postln;
					numNodes = 1;
				} {
					"keep nodes".postln;
				};
				if (numNodes.isNil) {
					// just play with previous nodes
					ndf.play;
				} {
					MFdef(\playRandGroups).value(ndf, numNodes);
				};
			}
		}
	}
};
//
