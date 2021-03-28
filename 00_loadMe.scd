

"*** Startup file for Polyharpye.".postln;

// global storage
q = q ? ();
q.projdir = thisProcess.nowExecutingPath.dirname;

////////////////////////////////////////////////////////////
"***** GLOBAL SETUP things first: ******".postln;

// could already be set in startup file:
q.numMics = q.numMics ? 6;
q.numSpks = q.numSpks ? 2;
q.randSeed = q.randSeed ? 666;

q.numResons = 46; // same as numNotes, numPseudoMics
q.lastReson = q.numResons - 1;

Ndef.defaultReshaping = nil;


s.latency = 0.05; // fast response for MTP

///////// LOAD ALL CODE FILES IN TASKS, with posting:

//////// loads local or absolute filenames or paths,
// embeds into with wait time and posted load time info:
q.load = { |q, filename, here, wait = 0.05, dirsup = 0, preText = "", postText = ""|
	var paths, path;
	if (filename.isNil) { warn("q.load: path was nil!") } {

		path = filename.standardizePath;
		if (path[0].isPathSeparator.not) {
			here = here ? q.projdir; // q.dir.base;
			dirsup.do { here = here.dirname };
			path = (here +/+ path);
		};

		paths = path.pathMatch;

		forkIfNeeded ({
			var loadDur, t0 = Main.elapsedTime;

			if (paths.size == 0) { "*** no files found for % :\n".postf(path.cs) };

			if (paths.size > 1) { "****** % matching files for % :\n".postf(paths.size, path.cs) };

			paths.do { |path|
				"*** loading % : %".postf(path.basename, preText);
				path.load;
				if (s.serverRunning) { try { s.sync } };
				loadDur = (Main.elapsedTime - t0).round(0.001);
				" % secs. %\n".postf(loadDur, postText);
				wait.wait;
			};

			"";
		}, AppClock)
	};
};
// measure startup load time
q.startedTime = Main.elapsedTime;

Task({
	// the number of the beast
	thisThread.randSeed = q.randSeed;

	s.volume = -12;

	if (s.serverRunning.not) {
		q.load("01_serverSetup.scd");
		// Server.scsynth;
		"*** server uses %.\n".postf(Server.program.basename);
	};

	"*** q.numMics: %\n".postf(q.numMics);

	q.load("allFX.scd");

	q.load("01a_synthdefs.scd");
	q.load("01b_positions.scd");
	q.load("01c_butz.scd");
	q.load("01d_ndefmix.scd");


	////// SET SPEAKER POSITIONS - must be one of:
	// [ 'head', 'caeiros', 'aula', 'mumuth'  ]
	// q.pos.spks = q.pos.aula * 0.8;
	// q.pos.spks = q.pos.caeiros * 2;
	q.pos.spks = q.pos.caeiros * 2;
	// q.pos.spks = q.pos.head * 2;

	////// supernova: set max numOutputBusChannels correctly pe interface!
	q.pos.spks = q.pos.spks.keep(s.options.numOutputBusChannels);
	q.numSpks = q.pos.spks.size;
	"q.numSpks: %.\n".postf(q.numSpks);


	if (s.serverRunning.not) {
		"booting server ...\n\n".postln;
		// s.quit;
		// unixCmd("killall scsynth supernova".postcs);
		// 1.wait;
		s.boot;
		fork ({
			while { s.serverRunning.not } { ".".postln; 1.wait }
		}, AppClock);
	};

}, AppClock).play;

// load full setup when booted:
s.doWhenBooted {
	var t0 = Main.elapsedTime;

	"... server booted after % seconds.\nStarting Setup:\n\n".postf(t0 - q.startedTime);

	// wait for server interface to finish
	0.1.wait;

	q.pos.omnibus = Bus.audio(s, q.numResons);

	// set a latency for loading only
	s.latency = 0.1;
	s.sync; 0.1.wait;

	(q.projdir +/+ "02*.scd").pathMatch.collect(_.basename);

	q.load("02a_chords.scd");
	q.load("02b_explore_chords.scd");
	q.load("02c_testSounds.scd");

	s.sync; 0.1.wait;

	q.load("03_omnibus.scd");
	q.load("04_micsAll.scd");
	q.load("04b_mtp_input.scd");
	q.load("04c_synths2Mics.scd");

	q.load("06_ndefSwitch.scd");
	q.load("06a_ropeTrigs.scd");

	s.sync; 0.1.wait;

	// all sounds:
	q.load("07_snds/07*.scd");
	"... snds loaded. /n/n".postln;

	s.sync; 0.2.wait;



	q.load("08a_ndefGroups.scd");
	s.sync; 0.1.wait;

	q.load("08b_Spatio.scd");

	s.sync; 0.1.wait;

	q.load("09*.scd");

	s.sync; 0.1.wait;

	q.load("11_makePresets.scd");

	q.load("12a_sceneSwitcher.scd");

	Butz.run(\ndefmix);

	q.load("12b_sceneGui.scd");
	s.sync; 0.1.wait;

	0.25.wait;

	q.load("15_scaleButz.scd");
	0.05.wait;

	q.load("16_cleanupLayout.scd");

	// // sitar, tabla, tringulz
	q.scenes.buts[0].doAction;

	s.sync; 0.1.wait;

	Ndef(\Pz_grid).play(vol: 0.25, fadeTime: 3);

	// /// tweax
	// MasterFX(s).add('9stereofy', 1);
	// q.load("scaleButz.scd");
	//
	// s.volume = -2;
	// s.scope(2);


	"\n*** SETUP DONE in % seconds.\n\n\n".postf((Main.elapsedTime - t0).round(0.001));
};
