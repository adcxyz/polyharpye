/// check that all required quarks for polyharpye  are present:

var requiredNames = [ "JITLibExtensions", "adclib",
	"SafetyNet",  "StartupFile",
	"Influx", "Modality-toolkit",
	// "KtlLoop", "KeyPlayer",
	"MultiTouchPad", "SpeakersCorner" ].collect(_.asSymbol);

var installedNames = Quarks.installed.collect(_.name).collect(_.asSymbol);

var missing = requiredNames.difference(installedNames);

if (missing.size > 0) {
	"*** MISSING QUARKS - please install: ***".postln;
	missing.do("Quarks.install(\"%\");\n".postf(_));
	"*** STOPPING polyharpye load HERE! ***".postln;
	this.halt;
};