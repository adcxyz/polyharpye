var q = PH.q;

"*** Polyharpye loadMe file.\n".postln;

// global storage
q.dir = q.dir ? ();
q.dir.poly = thisProcess.nowExecutingPath.dirname;

Task({
	0.1.wait;
	LoadMe.start;

	////////////////////////////////////////////////////////////
	"***** GLOBAL SETUP things first: ******".postln;

	// could already be set in startup file:
	q.numMics = q.numMics ? 6;
	q.numSpks = q.numSpks ? 2;
	q.randSeed = q.randSeed ? 666;

	q.numResons = q.numResons ? 46; // same as numNotes, numPseudoMics
	q.lastReson = q.numResons - 1;

	Ndef.defaultReshaping = nil;

	// these are for the proxymixer?
	q.ndefGroups = q.ndefGroups ? ();

	////// soft check for present quarks
	LoadMe("007_checkQuarks.scd");

	// the number of the beast
	thisThread.randSeed = q.randSeed;

	if (s.serverRunning.not) {
		LoadMe("01_serverSetup.scd");
		// Server.scsynth;
		"*** server uses %.\n".postf(Server.program.basename);
	};

	"*** q.numMics: %\n".postf(q.numMics);

	// copied from NTMI a long time ago;
	// better load current version from there
	LoadMe("allFX.scd");

	LoadMe("01a_synthdefs.scd");
	LoadMe("01b_positions.scd");
	LoadMe("01c_butz.scd");
	LoadMe("01d_ndefmix.scd");

	////// SET SPEAKER POSITIONS - must be one of:
	// [ 'head', 'caeiros', 'aula', 'mumuth', 'tuBig'  ]
	q.pos.aula = q.pos.aula * 0.8;
	q.pos.caeiros = q.pos.caeiros * 2;
	q.pos.spks = q.pos.tuBig * 2;
	q.pos.head = q.pos.head * 2;

	PH.spksName = PH.spksName ? \head;
	q.pos.spks = q.pos[PH.spksName];

	////// supernova: set max numOutputBusChannels correctly per interface.
	q.pos.spks = q.pos.spks.keep(s.options.numOutputBusChannels);
	q.numSpks = q.pos.spks.size;
	"PH.spksName: %, numSpks: %.\n".postf(PH.spksName, q.numSpks);


	if (s.serverRunning.not) {
		"booting server ...\n\n".postln;
		// s.quit;
		// unixCmd("killall scsynth supernova".postcs);
		// 1.wait;
		s.boot;
		fork ({
			while { s.serverRunning.not } { ".".postln; 1.wait }
		}, AppClock);
	} {
		"server already running, not booting ...\n\n".postln;
	};

	// load full setup when booted:
	s.doWhenBooted {
		var t0 = Main.elapsedTime;
		if (s.serverRunning.not) {
			"\n... server booted after % seconds.\n"
			"Starting Setup:\n\n".postf(t0 - q.startedTime);
		};

		// wait for server interface to finish
		0.1.wait;

		PH.pos.omnibus = Bus.audio(s, q.numResons);

		// set a latency for loading only
		s.latency = 0.1;
		s.sync; 0.1.wait;

		// make 8 parallel groups for ins, processing chains, outs
		q.grp = q.grp ? ();
		q.grpList = 8.collect { ParGroup.basicNew(s, s.nextPermNodeID) };

		MFdef(\grpListSend).add(\send, {
			s.sync;
			q.grpList.do { |grp|
				s.sendMsg(*grp.newMsg(s, \addToTail));
			};
			s.sync;
			q.grpList.do(_.isPlaying_(true));
			"*** q.grpList sent. ***".postln;
		});
		// do it once
		MFdef(\grpListSend).value;

		// and always remake them on boot, cmdPeriod etc
		ServerTree.add( MFdef(\grpListSend), s);


		(q.dir.poly +/+ "02*.scd").pathMatch.collect(_.basename);

		LoadMe("02a_chords.scd");
		LoadMe("02b_explore_chords.scd");
		LoadMe("02c_testSounds.scd");

		s.sync; 0.1.wait;

		LoadMe("03_omnibus.scd");
		LoadMe("04_micsAll.scd");

		Platform.case(
			// MultiTouchPad only runs on macOS, so we load MTP patch:
			\osx, { LoadMe("04b_mtp_input.scd") }, {
				// load single mousexy on window instead?
				"MultiTouchPad - cannot run on %.".postf(thisProcess.platform.name)
			}
		);

		LoadMe("04c_synths2Mics.scd");

		LoadMe("06_ndefSwitch.scd");
		LoadMe("06a_ropeTrigs.scd");

		s.sync; 0.1.wait;

		// all sounds are up one level:
		LoadMe("07_snds/07*.scd", q.dir.poly.dirname);
		"... snds loaded. \n\n".postln;

		s.sync; 0.2.wait;



		LoadMe("08a_ndefGroups.scd");
		s.sync; 0.1.wait;

		LoadMe("08b_Spatio.scd");

		s.sync; 0.1.wait;

		if (PH.usesMainFX == true) {
			LoadMe("09*.scd");
		} {
			"PH: no mainFX.".postln;
		};

		s.sync; 0.1.wait;

		LoadMe("11_makePresets.scd");

		LoadMe("12a_sceneSwitcher.scd");

		LoadMe("12b_sceneGui.scd");
		s.sync; 0.1.wait;

		LoadMe("13_nanoKontrol2.scd");
		0.1.wait;

		LoadMe("15_scaleButz.scd");
		0.05.wait;

		LoadMe("16_cleanupLayout.scd");

		// // sitar, tabla, tringulz
		q.scenes.buts[0].doAction;


		"*** GETS HERE???".postln;

		s.sync; 0.1.wait;

		Butz.run(\poly).showButs;

		Ndef(\Pz_grid).play(vol: 0.25, fadeTime: 3);

		// fast response for MTP
		s.latency = PH.latency ? 0.06;
		s.volume = PH.volume ? -6;


		Ndef('Ph_sitar1').set(\rq, 0.62);
		Ndef(\Pz_grid).vol_(1);

		PH.finalSetup;

		defer {
			Window.find("PRESETS").close;
			try { q.mixer.switchSize(2) };
			MFdef(\showScaleNotes).value;
		};


		"\n*** Polyharpye: SETUP DONE in % seconds.\n\n"
		.postf((Main.elapsedTime - t0).round(0.001));
		LoadMe.end;

	};

}, AppClock).play;
