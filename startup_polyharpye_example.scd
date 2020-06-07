/********** example startup file ***
Recommended:
// install and use StartupFile:
Quarks.install("StartupFile");
thisProcess.recompile;
// * copy this file to here:
StartupFile.openDir;
// or for plain vanilla SC, to here:
Platform.userAppSupportDir.openOS;
///////// in both cases:
// * rename to "startup.scd",
// * and modify it as needed!

StartupFile.choose;
**********/

"*** loading SuperCollider startup file. \n\n".postln;
//// open this file in SC if desired:
// thisProcess.nowExecutingPath.openOS;

/*
// some useful debugging things:
Server.killAll;
s.reboot;
NetAddr.langPort;
NetAddr.broadcastFlag == true;
OSCdef.trace;
OSCdef.trace(false);
*/
// make a global dict for everything
q = q ? ();

/////// unify sound in/out here
ServerOptions.devices.postcs;
s.options.sampleRate = 44100;


//////////// PUT YOUR PREFS FOR AUDIO DEVICE
//////////// and number of mic-chans and speaker chans here:
// look for my three sound devices, and use the one currently connected:
q.foundDevice = ServerOptions.devices.detect { |str|
	[ "2882 [3712]", "1248", "Fireface 400 (297)" ].includesEqual(str)
}.postcs;

if (q.foundDevice.notNil) {
	"*** using found sound device : % \n\n".postf(q.foundDevice);
	s.options.device = q.foundDevice;
} {
	"*** using system default sound i/o devices.\n".postln;
};

// set number of mics and speakers here,
// maybe dependent on which device
q.numMics = 1; // mono mic on mac laptop
q.numSpks = 2; // stereo speakers or headphones

// ////// run Polyharpye setup file
"~/Seafile/polyharpye/src/_main.scd".loadPaths;
/*
"~/Seafile/polyharpye/src/_main.scd".openOS;
*/
