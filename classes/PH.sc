/*
Quarks.install("/Users/adc/Seafile/polyharpye/public/polyharpye/");
Quarks.uninstall("StartupFile");
Quarks.uninstall("Modality-toolkit");
Quarks.install("StartupFile");
Quarks.install("Modality-toolkit");

// add a method: dict refers to NTI.q, then args
PH.boing = { |dict, a, b, c, d|
"boing: ".post; [a, b, c, d].postln;
};

// test
PH.boing(1, 2, 3, 4);
PH.run
*/

// a flexible project class that redirects everything to internal dict:
PH {  // polyharpye
	classvar <q;
	*initClass {
		q = (
			dir: (),
			// init necessary dicts
			defaults: (),
			pos: (),    // all spatial data
			g: (),      // all gui things
			chords: (), // the chords and funcs
			scenes: (), // the switchable scenes
			mtp: (),    // multitouchpad
			mfx: (),    // mainfx

			run: {|self, path|
				path = (path ? self.dir.polyLoadPath);
				path.loadPaths
			},
		);
		q.dir.poly = (PH.filenameSymbol.asString.dirname.dirname +/+ "setup/");
		q.dir.polyLoadFile = "00_loadMe.scd";
		q.dir.polyLoadPath = q.dir.poly +/+ q.dir.polyLoadFile;

		// prepare to find defaults automatically when settings are nil:
		q.parent = q.defaults;
	}

	// redirect everything to NTMI.q:
	*doesNotUnderstand { |selector ... args|
		^q.performList(selector, args)
	}
}
