q.led = ();
q.led.addr = NetAddr("127.0.0.1", 9999); // Python

if(q.hasGui){
	q.led.uv = Window.new.front;
	Tdef(\led).gui;
//	Ndef(\ledKrSamp).scope;
};

Tdef(\led).set(\dt, 1/50);
Tdef(\led).set(\dt, 1/(100/3));
Tdef(\led).set(\num, 8);
Tdef(\led).addSpec(\num, [2, 100, 4, 1] );
Tdef(\led).addSpec(\state, [0, Tdef(\led).get(\num), 0, 1] );
Tdef(\led).set(\state, 0);
Tdef(\led).set(\colOffs, 0);
Tdef(\led).set(\bright, 1);
Tdef(\led).set(\red, 1);
Tdef(\led).set(\green, 1);
Tdef(\led).set(\blue, 0.6 );
Tdef(\led).addSpec(\bright, [0, 1, -2] );
Tdef(\led).addSpec(\blue, [0, 1] );
Tdef(\led).addSpec(\green, [0, 1] );
Tdef(\led).addSpec(\red, [0, 1] );


// now, sample dis slowly....trapeziod wave
// Ndef(\ledKrFade, {	LFTri.kr(1/8).range(-2.5, 2).clip(0, 2).round.lag3(0.8);  });
// Ndef(\ledKrSamp, {	LFPulse.kr(1/2, 0, 0.03, 3).lag3(0.2);  });// lighten additive
// Ndef(\ledKrSamp, {	LFPulse.kr(1/2, 0, 0.06).neg.lag3(0.2);  });// darken additive
//Ndef(\ledKrSamp, {	LFPulse.kr(1/2, 0, 1-0.06).lag3(0.2);  });// darken additive
Ndef(\ledKrSynth, {	LFPulse.kr(1/2, 0, 1-0.05).range(-1,1).lag3(0.15) });// darken additive
Ndef(\ledKrSamp, {	LFPulse.kr(1/2, [0, 0.15], 1-0.05).range(-1,1).lag3([0.1, 0.2]).mean  });// darken additive
//Ndef(\ledKrSamp, {	LFPulse.kr(0.5/[5,3], 0, 1-0.06).lag3([0.3, 0.2]).product  });// darken additive

(
Tdef(\led, {|ev|
	var col, oldCol = Color.black;

	loop{
		var strobeSynth = Ndef(\ledKrSynth).bus.getSynchronous.round(1/360);
		var strobeSamp = Ndef(\ledKrSamp).bus.getSynchronous.round(1/360);
		var cIndex =
		// Ndef(\ledKrFade).bus.getSynchronous.round(1/360) / ev.num;
		(q.mktl.elAt(\xy, \x).value - 0.5 * 2).cubed;

		var state = q.osc.indices[q.osc.mode];
		var hue = (state + cIndex % ev.num) / ev.num;
		var bright = (q.mktl.elAt(\xy, \y).value).sqrt * 0.95 + 0.05;
		if(q.osc.mode == \sample){  bright = bright * strobeSamp }{  bright = bright * strobeSynth };
		col = Color.hsv(hue.frac, 1, bright, 1);

		col = col.asArray.keep(3) * [ev.red, ev.green, ev.blue];
		col = Color.new(*col);

		if(oldCol != col){ // save bandwidth
			MFdef(\led).value(col);
		};
		ev.dt.wait;
		oldCol = col
	}
});
);

Tdef(\led).play;

// change from synth to sampl: add strobe AND change nr of hues / state

(
MFdef(\ledToggler, [
	\test,  { arg col; col.postln },
]);

MFdef(\ledToggler).add(\run, { arg mode;
	var num = if(mode== \synthe){
		q.osc.ndefs.synthe.size;
	}{
		q.bufNums.short.size;
	};
	Tdef(\led).set(\num, num);
});

MFdef(\ledToggler).disable(\test);

);

(
MFdef(\led, [
	\test,  { arg col; col.postln },
]);

MFdef(\led).add(\pythonOSC, { arg col;
	q.led.addr.sendMsg(\rgb_led, *(col.asArray.keep(3)*255 ).asInteger );
});

MFdef(\led).modes.put(\test, (off: \all, on: \test));
MFdef(\led).modes.put(\pythonOSC, (off: \all, on: [\pythonOSC]));

// MFdef(\led).mode_(\all);
// MFdef(\led).mode_(\test);
MFdef(\led).mode_(\pythonOSC);

if(q.hasGui){
	MFdef(\led).add(\gui, { arg col; defer{ q.led.uv.background=(col) }; });
	MFdef(\led).modes.put(\all, (on: [\gui, \pythonOSC]));
	MFdef(\led).modes.put(\gui, (off: \all, on: [\gui]));
	MFdef(\led).mode_(\all);
}{
	MFdef(\led).mode_(\pythonOSC);
};

);

/*
(
// test
Tdef(\test, {
loop{
q.led.addr.sendMsg(\rgb_led, *(Color.red.asArray.keep(3)*255 ).asInteger.postln);
1.wait;
q.led.addr.sendMsg(\rgb_led, *(Color.green.asArray.keep(3)*255 ).asInteger.postln);
1.wait;
q.led.addr.sendMsg(\rgb_led, *(Color.blue.asArray.keep(3)*255 ).asInteger.postln);
1.wait;
q.led.addr.sendMsg(\rgb_led, *(Color.rand.asArray.keep(3)*255 ).asInteger.postln);
1.wait;
}
}).play;
);
Tdef(\test).play;
Tdef(\test).stop;
*/