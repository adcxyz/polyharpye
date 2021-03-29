/*** namesplit
q.scenes.buts[7].states_(
[ [ "Ph_rhythmicon", Color(1.0, 1.0, 0.8), Color(0.5, 0.5, 0.5) ] ])
***/
WinBounds.addMake('SCENES', {
	var w, v, a, t;
	var bigfont = Font("Futura", 36), fontCol = Color.yellow.blend(Color.white, 0.8);
	var font =  Font("Futura", 25);
	var font2 =  Font("Futura", 16);

	q.scenes = q.scenes ? ();
	q.scenes.volatility = 25;


	w = Window("SCENES", Rect(1.0, 270, 740, 430)).front;
	q.scenes.guiWin = w;
	w.background = Color.grey(0.1, 0.9);
	v = w.addFlowLayout;
	v.gap_(15@15);

	Button(w, Rect(0, 0, 130, 60)).font_(font).states_([
		["manual"],
		["auto", fontCol, Color.grey]
	]).action_({|b|
		[   { MFdef(\autoScene).disable; "manual mode activated" },
			{ MFdef(\autoScene).enable; "auto mode activated"}
		][b.value].value.postln;
	});

	t = StaticText(w, w.bounds.width_(430).height_(60)).string_("NOW: \tsilence").align_(\center).stringColor_(fontCol).font_(bigfont);

	Button(w, Rect(0, 0, 130, 60)).font_(font2).states_([["reload\nscenes"]]).action_({ q.scenes.load; q.scenes.load2Buts });

	EZSlider(w, Rect(0, 0, 350, 40), \vola, [1000, 10, \exp, 1], {|s| q.scenes.volatility = s.value}, 25, layout: \horz).font_(font2).labelView.stringColor_(fontCol);

	EZSlider(w, Rect(0, 0, 350, 40), \fade, [0, 42, 4.005], {|s| q.scenes.fadeTime = s.value}, 3, layout: \horz ).font_(font2).labelView.stringColor_(fontCol);

	v.nextLine;

	q.scenes.buts = { Button(w, Rect(0, 0, 170, 40)).states_([["", nil, Color.black]]) } ! 24;

	q.scenes.load2Buts = {
		q.scenes.buts.do { |but, i|
			var dict = q.scenes.all @ i;
			if (dict.notNil) {
				but
				.states_([
					[dict.name ? i.asString, fontCol, Color.grey(0.38)],
					[dict.name ? i.asString, fontCol, Color.grey(0.62)]
				])
				.font_(font)
				.action_({ |bt|
					q.scenes.buts.do(_.value_(0));
					bt.value_(1);
					t.string_( "NOW: " ++ dict.name );
					MFdef(\sceneSwitch).value(dict);
				})
			}
		};
	};
	q.scenes.load2Buts;
	w;
});

WinBounds.showOrMake('SCENES');
