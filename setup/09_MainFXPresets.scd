Butz.add(\mainFX, { WinBounds.showOrMake(\mainFX) });

WinBounds.addMake(\mainFX, {

	q.mfx.font = Font("Optima", 18);

	q.mfx.highKeys = [];
	q.mfx.srcKeys = q.mFX.slotNames;

	try { q.mfx.win.close };
	q.mfx.win = Window('mainFX', Rect(0,0, 520, 800)).front;
	q.mfx.win.addFlowLayout;

	q.mfx.prepop = EZPopUpMenu(q.mfx.win, Rect(0,0, 320, 30), \mainPresetz, q.mfx.preNames, { |ezp|
		MFdef(\mainPre).(ezp.item);
	}, labelWidth: 120);
	q.mfx.prepop.font_(q.mfx.font);

	[ "¿x?", "prev", "next" ].collect { |label, i|
		Button(q.mfx.win, Rect(0,0,50,30))
		.states_([[label]]).font_(q.mfx.font)
		.action_({
			MFdef(\mainPreStep).([nil, -1, 1]@i)
		});
	};

	q.mfx.mgui = q.mfx.chain.gui(50, parent: q.mfx.win);
	q.mfx.win.bounds_(q.mfx.win.bounds.moveTo(790, 1200));
	q.mfx.win.alpha_(0.85);

	g.tuneNameView(q.mfx.mgui.editGui);


	// paint wets once when starting
	q.mfx.paintWets = {
		var paramgui = q.mfx.mgui.editGui.paramGui;
		paramgui.paintWetParams(paramgui.editKeys);
	};
	defer ({ q.mfx.paintWets }, 0.1);


	q.mfx.skippa = SkipJack({
		if (q.mfx.prepop.item != q.mfx.currDomain) {
			q.mfx.prepop.value = q.mfx.domainIndex
		};
		q.mFX.proxyChain.proxy.cleanNodeMap;
	}, 0.5, { q.mfx.win.isClosed });

	q.mfx.win;
});
