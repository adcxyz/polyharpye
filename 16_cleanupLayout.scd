/***
// to update, run:
WinBounds.storeAll;
WinBounds.saveString
WinBounds.store
**/

// Window.allWindows.do { |w|
// 	if (w.view.keyDownAction.isNil) {
// 		w.view.keyDownAction = MTP. guiWin.view.keyDownAction;
// 	};
// };

WinBounds.stored.putAll( (
	'Butz': Rect(0.0, 149.0, 136.0, 856.0),
	'SCENES': Rect(936.0, 619.0, 736.0, 345.0),
	'spatio': Rect(135.0, 164.0, 800.0, 800.0),
	'globalXY': Rect(698.0, 0.0, 560.0, 180.0),
	'MTP': Rect(137.0, 0.0, 502.0, 172.0),

	'ndefmix': Rect(936.0, 105.0, 682.0, 491.0),
	'Tdef.all': Rect(135.0, 651.0, 274.0, 354.0),
	'Pdef.all': Rect(290.0, 650.0, 274.0, 354.0),
	'MasterFX': Rect(1158.0, 205.0, 520.0, 800.0),

	'TESTS': Rect(137.0, 227.0, 400.0, 400.0),
	'Stethoscope': Rect(423.0, 0.0, 273.0, 230.0),
	'localhost levels (dBFS)': Rect(0.0, 0.0, 362.0, 230.0),
	'localhost Node Tree': Rect(538.0, -1.0, 370.0, 1005.0),

	'chordPlayer': Rect(137.0, 650.0, 434.0, 188.0),
	'Mics and Speaker Layout': Rect(0.0, 605.0, 500.0, 400.0),
) );

MTP.gui.bounds_(WinBounds.at('MTP'));

Butz.add(\restoreAll, { WinBounds.restoreAll });
Butz.run(\restoreAll);

defer { MFdef(\noyzResons).value };

