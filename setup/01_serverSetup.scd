/******** server config ******

ServerOptions.devices.cs;

******************************/
//   just options

// which server program?
///// Server.scsynth;
///// Server.supernova;
"*** polypharpye sets server to: %\n\n".postf(Server.program.basename);

// Safety(s).disable;

// make it respond fast - for adc_mb18
s.latency = nil;

// tweak for performance optimization
s.options.sampleRate = s.options.sampleRate ? 44100;
// better at 256 if cpu manages, 128 is usually too high
s.options.hardwareBufferSize = s.options.hardwareBufferSize ? 256;
s.options.blockSize = s.options.blockSize ? 128; // default is 64

/// keep if already set
s.options.numInputBusChannels = PH.numMics ? 2;
s.options.numOutputBusChannels = PH.numSpks ? 2;

// 2GB realtime memory - this is the max for scsynth
s.options.memSize = max (s.options.memSize, 8192 * 16 * 16);

// server synth/bus setup - lots of everything
s.options.numAudioBusChannels = max(s.options.numAudioBusChannels, 8192);
s.options.numControlBusChannels = max(s.options.numControlBusChannels, 16384);
s.options.numBuffers = max(s.options.numBuffers, 8192);
s.options.maxNodes = max(s.options.maxNodes, 8192);
s.options.maxSynthDefs = max(8192, s.options.maxSynthDefs);
s.options.numWireBufs = max(1024, s.options.numWireBufs);

///// if (s.serverRunning) { forkIfNeeded { MFdef(\grpListSend).value } };
