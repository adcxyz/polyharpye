/******** server config ******

ServerOptions.devices.cs;

******************************/
//   just options

// which server program?
// Server.scsynth;
Server.supernova;
"*** polypharpye sets server to: %\n\n".postf(Server.program.basename);

// Safety(s).disable;

// make it respond fast - for adc_mb18
s.latency = nil;

// tweak for performance optimization
s.options.sampleRate = s.options.sampleRate ? 44100;
// better at 256 if cpu manages, 128 is usually too high
s.options.hardwareBufferSize = s.options.hardwareBufferSize ? 256;
s.options.blockSize = 128; // default is 64

///////// figure out present audio devices to set numIns and numOuts?
// s.options.device = "Soundcraft Ui24";
// s.options.numOutputBusChannels = 10;

// case {
// 	ServerOptions.devices.any(_.contains("2882"))
// } {
// 	q.sndDevice = \MIO; // MobileIO
// 	s.options.device = "2882 [3712]";
// 	s.options.numInputBusChannels = 8;
// 	s.options.numOutputBusChannels = 8;
// } {
// 	ServerOptions.devices.any(_.contains("1248"))
// } {
// 	q.sndDevice = \1248; // MobileIO
// 	s.options.device = "2882 [3712]";
// 	s.options.numInputBusChannels = 16;
// 	s.options.numOutputBusChannels = 16;
// } {
// 	// stereo only
// 	s.options.numOutputBusChannels = 2;
// };

/// keep if already set
s.options.numInputBusChannels = q.numMics ? 2;
s.options.numOutputBusChannels = q.numSpks ? 2;

// 2GB realtime memory - this is the max for scsynth
s.options.memSize = max (s.options.memSize, 8192 * 16 * 16);

// server synth/bus setup - lots of everything
s.options.numAudioBusChannels = max(s.options.numAudioBusChannels, 8192);
s.options.numControlBusChannels = max(s.options.numControlBusChannels, 16384);
s.options.numBuffers = max(s.options.numBuffers, 8192);
s.options.maxNodes = max(s.options.maxNodes, 8192);
s.options.maxSynthDefs = max(8192, s.options.maxSynthDefs);
s.options.numWireBufs = max(1024, s.options.numWireBufs);

q = q ? ();

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

// always remake them on boot, cmdPeriod etc
ServerTree.add( MFdef(\grpListSend), s);

///// if (s.serverRunning) { forkIfNeeded { MFdef(\grpListSend).value } };
