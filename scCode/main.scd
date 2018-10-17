// TEST
x = {SinOsc.ar(([54,56,58,60]+12).midicps, 0, 0.1)}.play; 
x.free;
s.meter;

// Stop playback in harmo modes: does it work?
// Make option to stop loops in the order they appeared.
// Find a way to make inheritance.

// Pops did not stop with sponge zebra.


(
{
	~scJackName="SuperCollider:out_"; //for Jack connections
	~scJackNameIn="SuperCollider:in_"; //for Jack connections
	// ~scJackName="supernova:output_"; //for Jack connections
	~reaperInJackName="REAPER:in";

	~rppFilePath = "../signumMix/signumMix.RPP".resolveRelative;

	"killall reaper5".unixCmd; //kill reaper.
	// "nmcli con up sponger".unixCmd; // Make this computer a hotspot.
	// "nmcli con up sudafed".unixCmd; // Connect to sudafed

	// ~cond = Condition.new;
	("reaper5" + ~rppFilePath).unixCmd;
	// "killall jconvolver;".unixCmd;
	"killall zita-rev1;".unixCmd;
	0.1.wait;
	// "jconvolver -N rvb ~/docs/soundBank/ir/True\\ M7/Halls/amsterdamHall.conf".unixCmd;
	"zita-rev1 -name rvb".unixCmd;
	s.bootSync;
	"/home/marierm/scripts/jackDisconnectEverything.py".unixCmd;
	"prep/cSponge.scd".loadRelative;
	"prep/cSimpleSponge.scd".loadRelative;
	"prep/cLooper.scd".loadRelative;
	"prep/cFm.scd".loadRelative;
	// "prep/triggeredByVideo.scd".loadRelative;
	// "prep/cPopperRzn.scd".loadRelative;
	// "prep/cPopper.scd".loadRelative;
	// "prep/cPlayer.scd".loadRelative;
	"prep/gui.scd".loadRelative;
	
	s.sync;
	1.wait;
	~ipsPrefix = "192.168.109.";
	// ~ips = (14..18);
	// ~ipsPrefix = "192.168.109.";
	// ~ips = [191];
	// ~ips = (97..98);
	// ~ipsPrefix = "10.42.0.";
	// ~ipsPrefix = "192.168.0."; // for sudafed
	// ~ips = [123]; // ana
	// ~ips = [190]; // brown
	// ~ips = [140]; // flowers
	// ~ips = [140, 141]; // stripes + flowers
	// ~ips = [123, 141]; // ana + flowers
	// ~ips = [123, 140, 141]; // ana + stripes + flowers
	// ~ips = [140, 141, 123, 191]; // stripes + flowers + ana + zebra
	// ~ips = [195,126,177,174];
	// ~ips = [194,126,104,174];
	// ~spongeNames = ["stripes", "flowers", "ana", "zebra"];
	~ips = [103, 79]; //, 111, 86, 109];
	~spongeNames = ["stripes", "zebra"]; //, "flowers", "ana", "brown"];
	~classes = [~cSponge, ~cSimpleSponge, ~cSimpleSponge, ~cSimpleSponge];
	// ~spongeNames = ["stripes", "flowers", "brown", "zebra"];
	// ~classes = [~cSponge, ~cSimpleSponge, ~cSimpleSponge, ~cSimpleSponge];
	~transpose = 0;
	~sponges = IdentityDictionary.new();
	~voices = IdentityDictionary.new();

	~numDots = 32;  // For Pat's video.
	~dotArrays = Array.fill2D(~ips.size, ~numDots, {0});
	~patsAddress = NetAddr("224.0.0.1", 8888);
	// x = ~cSponge.value( ~ipsPrefix ++ 97, \sponge, Server.default );
	// x.prep;
	// x.sponge.hold_(true);
	~ips.do({ |i, j|
		// var sym = ("sponge_" ++ i.asAscii).asSymbol;
		var sym = (~spongeNames[j] ++ "_" ++ i).asSymbol;
		~sponges.put( sym, ~classes[j].value( ~ipsPrefix ++ i, sym, Server.default ) );
		~sponges[sym].prep; // The master is the first sponge: stripes
		s.sync;
		1.wait;
		~sponges[sym].sponge.hold_(true);
		~voices.put( sym, List[] );
		~voices[sym].add( // add fm synth to voice 0 of each sponge.
			~cFmManager.value(
				interpolatorPath: ("fm0*").resolveRelative.pathMatch.sort.last.resolveRelative,
				cSponge: ~sponges[sym],
				notes: ([ \en1, \en2, \en3].keynum.mirror2.clump(3)).flat + (0 * 12) + ~transpose,
				chords: [
					[ \en1, \en2, \en3, \en3, \en2, \en1].keynum + ~transpose,
					// [ \fs7, \bn7, \en8, \en7, \bf7, \cn8].keynum - 12,
					[ \en1, \en2, \gn2, \dn3, \fs3, \bn3].keynum + ~transpose,
					[ \en1, \dn2, \fs2, \dn3, \fs3, \bn3].keynum + ~transpose,
					[ \en1, \cn2, \gn2, \dn3, \fs3, \bn3].keynum + ~transpose,
					[ \en1, \bn1, \an2, \dn3, \fs3, \bn3].keynum + ~transpose,
					[ \en1, \en2, \cn3, \dn3, \fs3, \bn3].keynum + ~transpose,
					[ \en1, \dn2, \gn2, \cn3, \fs3, \bn3].keynum + ~transpose,
					[ \en1, \cn2, \gn2, \bn2, \fs3, \bn3].keynum + ~transpose,
					[ \en1, \dn2, \fs2, \bn2, \en3, \an3].keynum + ~transpose,
					[ \fs1, \bn1, \en2, \en1, \bf1, \cn2].keynum + ~transpose,
					[ \fn1, \bf1, \ef2, \en1, \bf1, \cn2].keynum + ~transpose,
					[ \en1, \an1, \cs2, \ef1, \af1, \dn2].keynum + ~transpose,
					[ \gf1, \an1, \cn2, \fn1, \af1, \df2].keynum + ~transpose,
					[ \gf1, \an1, \cn2, \fn1, \bf1, \dn2].keynum + ~transpose,
					[ \gf1, \an1, \cn2, \fn1, \bn1, \dn2].keynum + ~transpose,
					[ \gn1, \an1, \cn2, \fn1, \bn1, \dn2].keynum + ~transpose,
					[ \gn1, \an1, \cn2, \fn1, \fn2, \dn2].keynum + ~transpose
				],
				outBus: j * 2,
				fsrMuteThreshold: 0.85, // larger number = muting is easier
				fmId: j + 20,
				relTime: 0.2,
				server: s,
				withLoop: (~classes[j] == ~cSponge )
			)
		);
		///////////////
		s.sync;
		1.wait;
		~voices.at(sym).do({|i| i.prep});
		s.sync;
		1.wait;
		////////////////////  To send controls to Pat's videos.
		// ~sponges.at(sym).sponge.action_(
		// 	~sponges.at(sym).sponge.action.addFunc({ |msg|
		// 		var val;
		// 		val = msg[0].linlin(0,1023,-1.0,1.0);
		// 		~dotArrays[j] = ~dotArrays[j].rotate(-1);
		// 		~dotArrays[j].put(~numDots - 1, val);
		// 		~dotArrays[j].do({ |value, index|
		// 			~patsAddress.sendMsg("/video_wave" +/+ ~spongeNames[j], index, value);
		// 			~patsAddress.sendMsg("/video_wave_c" +/+ ~spongeNames[j], index, value);
		// 		});
		// 	});
		// );
		// sym.post; " ready.".postln;
	});
	s.sync;

	// Make Jack connections.
	12.do({ |i|
		var string;
		string = "jack_connect" + ~scJackName ++ (i+1) + ~reaperInJackName ++ (i+1);
		string.unixCmd;
	});

	"jack_connect REAPER:out1 system:playback_1
     jack_connect REAPER:out2 system:playback_2
     jack_connect REAPER:out3 system:playback_3
     jack_connect REAPER:out4 system:playback_4
     jack_connect REAPER:out5 system:playback_5
     jack_connect REAPER:out6 system:playback_6".unixCmd;
	
	"jack_connect REAPER:out7 rvb:in.L
     jack_connect REAPER:out8 rvb:in.R
     jack_connect rvb:out.L REAPER:in31
     jack_connect rvb:out.R REAPER:in32".unixCmd;

	2.do({ |i|
		var string =
		"jack_connect system:capture_" ++ (i+1) + ~scJackNameIn ++ (i+1);
		string.unixCmd;
	});

	~ips.do({ |i,j|
		var sym = (~spongeNames[j] ++ "_" ++ i).asSymbol;
		~sponges[sym].sponge.hold_(false);
	});
	{
		~gui = ~quintetGui.value(~ips, ~spongeNames);
		~gui.window.front;
	}.defer;
}.fork;
)




~sponges[\zebra_174].

s.meter

x = Synth.tail(s, \noiseAccu, [\ffreq, 1000]);

p = Pbind(
	\instrument, \noiseAccu,
	\ffreq, Pwhite(800,8000),
	\rq, Pwhite(5, 0.5),
	\dur, Pwhite(0.1, 1.0),
	\db, -20
).play;
p.stop;


s.queryAllNodes
// mapper amplitude à amplitude du sinus.

~sponges[\stripes_195].slaveSponges[0].defName
~sponges[\flowers_126].masterSponge;
~sponges[\zebra_174].isSlave;

slaveSponges[2].

// IP mac mini patrick@192.168.0.150  pw: mozart

~cSponge
~cSimpleSponge