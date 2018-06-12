// Stop playback in harmo modes: does it work?
// Make option to stop loops in the order they appeared.
// Find a way to make inheritance.

// Pops did not stop with sponge zebra.
(
{
	~scJackName="SuperCollider:out_"; //for Jack connections
	// ~scJackName="supernova:output_"; //for Jack connections
	~reaperInJackName="REAPER:in";

	~rppFilePath = "../signumMix/signumMix.RPP".resolveRelative;

	"killall reaper5".unixCmd; //kill reaper.
	// "nmcli con up sponger".unixCmd; // Make this computer a hotspot.
	"nmcli con up sudafed".unixCmd; // Connect to sudafedn

	// ~cond = Condition.new;
	("reaper5" + ~rppFilePath).unixCmd;
	"killall jconvolver;".unixCmd;
	0.1.wait;
	"jconvolver -N rvb ~/docs/soundBank/ir/True\\ M7/Halls/amsterdamHall.conf".unixCmd;
	s.bootSync;
	"/home/marierm/scripts/jackDisconnectEverything.py".unixCmd;
	"prep/cSponge.scd".loadRelative;
	"prep/cLooper.scd".loadRelative;
	"prep/cFm.scd".loadRelative;
	// "prep/cPopperRzn.scd".loadRelative;
	// "prep/cPopper.scd".loadRelative;
	// "prep/cPlayer.scd".loadRelative;
	s.sync;
	1.wait;
	// ~ipsPrefix = "192.168.109.";
	// ~ips = (14..18);
	// ~ipsPrefix = "192.168.109.";
	// ~ips = [191];
	// ~ips = (97..98);
	// ~ipsPrefix = "10.42.0.";
	~ipsPrefix = "192.168.0."; // for sudafed
	// ~ips = [140]; // stripes
	// ~ips = [123]; // ana
	// ~ips = [190]; // brown
	// ~ips = [140]; // flowers
	// ~ips = [140, 141]; // stripes + flowers
	// ~ips = [123, 141]; // ana + flowers
	// ~ips = [123, 140, 141]; // ana + stripes + flowers
	// ~ips = [140, 141, 123, 191]; // stripes + flowers + ana + zebra
	~ips = [195,126,177,174];
	~spongeNames = ["stripes", "flowers", "ana", "zebra"];
	~transpose = 0;
	~sponges = IdentityDictionary.new();
	~voices = IdentityDictionary.new();

	// x = ~cSponge.value( ~ipsPrefix ++ 97, \sponge, Server.default );
	// x.prep;
	// x.sponge.hold_(true);
	~ips.do({ |i, j|
		// var sym = ("sponge_" ++ i.asAscii).asSymbol;
		var sym = (~spongeNames[j] ++ "_" ++ i).asSymbol;
		~sponges.put( sym, ~cSponge.value( ~ipsPrefix ++ i, sym, Server.default ) );
		~sponges[sym].prep;
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
				server: s
			)
		);
		///////////////
		s.sync;
		1.wait;
		~voices.at(sym).do({|i| i.prep});
		s.sync;
		1.wait;
		
		sym.post; " ready.".postln;
	});
	s.sync;

	// Make Jack connections.
	8.do({ |i|
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
	
	"jack_connect REAPER:out7 rvb:inL
     jack_connect REAPER:out8 rvb:inR
     jack_connect rvb:outL REAPER:in31
     jack_connect rvb:outR REAPER:in32".unixCmd;

	~ips.do({ |i,j|
		var sym = (~spongeNames[j] ++ "_" ++ i).asSymbol;
		~sponges[sym].sponge.hold_(false);
	});
	"prep/gui.scd".loadRelative;
	{
		// a = ~quintetGui.value([100,98,97,101,99]);
		// order is francis, ana, martin, emilie, preston
		a = ~quintetGui.value(~ips, ~spongeNames);
		a.window.front;
	}.defer;
}.fork
)


