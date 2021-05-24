# polyharpye

The Polyharye is an Xstrument, i.e. a complex performance setup, 
designed for playing sound sources through resonator networks.
It is written in SuperCollider. 

The sound sources can be microphones, piezos attached to physical objects, or electronic sound generators, or sound generators running in SuperCollider itself. 
On macOS, one can also create sound sources by playing on a MultiTouchPad. 

The sound sources are playing onto a 2D map of virtual sound inputs, and mapped based on proximity: a sound scource will play into virtual inputs near its location. 

The resonator patches are Ndefs (sound generators in SuperCollider), and can be told which subsets of the virtual inputs to listen to. E.g., all inputs could go into sitar-string-like resonators, or 10 inputs go to the sitar, 20 go to a modeled tabla, and 20 others to a glassharp sound. These combinations can be stored in scenes. 

