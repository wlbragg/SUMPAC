var checkTime = func (curve) {
     if (getprop("fdm/jsbsim/elapsed-time") == 6) {
	     gui.popupTip("Elapsed Time = .1 minute \nPower Output = " ~ int(curve) ~ " watts", 10);
     }
     if (getprop("fdm/jsbsim/elapsed-time") == 30) {
	     gui.popupTip("Elapsed Time = .5 minute \nPower Output = " ~ int(curve) ~ " watts", 10);
     }
     if (getprop("fdm/jsbsim/elapsed-time") == 60) {
	     gui.popupTip("Elapsed Time = 1 minute \nPower Output = " ~ int(curve) ~ " watts", 10);
     }
     if (getprop("fdm/jsbsim/elapsed-time") == 120) {
	     gui.popupTip("Elapsed Time = 2 minutes \nPower Output = " ~ int(curve) ~ " watts", 10);
     }
     if (getprop("fdm/jsbsim/elapsed-time") == 300) {
	     gui.popupTip("Elapsed Time = 5 minutes \nPower Output = " ~ int(curve) ~ " watts", 10);
     }
     if (getprop("fdm/jsbsim/elapsed-time") == 600) {
	     gui.popupTip("Elapsed Time = 10 minutes \nPower Output = " ~ int(curve) ~ " watts", 10);
     }
     if (getprop("fdm/jsbsim/elapsed-time") == 1200) {
	     gui.popupTip("Elapsed Time = 20 minutes \nPower Output = " ~ int(curve) ~ " watts", 10);
     }
     if (getprop("fdm/jsbsim/elapsed-time") == 3000) {
	     gui.popupTip("Elapsed Time = 50 minutes \nPower Output = " ~ int(curve) ~ " watts", 10);
     }
     if (getprop("fdm/jsbsim/elapsed-time") == 3600) {
	     gui.popupTip("Elapsed Time = 1 Hour \nPower Output = " ~ int(curve) ~ " watts", 10);
     }
}

var power_curve = func () {

    setprop("fdm/jsbsim/elapsed-time", getprop("fdm/jsbsim/elapsed-time") + .25);

    if (getprop("fdm/jsbsim/power-curve") == 0) {
         setprop("/controls/engines/engine[0]/throttle", getprop("fdm/jsbsim/human-output/healthy60m")/2378);
         checkTime(getprop("fdm/jsbsim/human-output/healthy60m"));
    } else if (getprop("fdm/jsbsim/power-curve") == 1) {
         setprop("/controls/engines/engine[0]/throttle", getprop("fdm/jsbsim/human-output/athlete60m")/2378);
         checkTime(getprop("fdm/jsbsim/human-output/athlete60m"));
    } else if (getprop("fdm/jsbsim/power-curve") == 2) {
         setprop("/controls/engines/engine[0]/throttle", getprop("fdm/jsbsim/human-output/healthy500m")/2378);
         checkTime(getprop("fdm/jsbsim/human-output/healthy500m"));
    } else if (getprop("fdm/jsbsim/power-curve") == 3) {
         setprop("/controls/engines/engine[0]/throttle", getprop("fdm/jsbsim/human-output/athlete1440m")/2378);
         checkTime(getprop("fdm/jsbsim/human-output/athlete1440m"));
    } else if (getprop("fdm/jsbsim/power-curve") == 4) {
         setprop("/controls/engines/engine[0]/throttle", getprop("fdm/jsbsim/human-output/cyclist60m")/2378);
         checkTime(getprop("fdm/jsbsim/human-output/cyclist60m"));
    } else if (getprop("fdm/jsbsim/power-curve") == 5) {
         setprop("/controls/engines/engine[0]/throttle", getprop("fdm/jsbsim/human-output/cyclist27500m")/2378);
         checkTime(getprop("fdm/jsbsim/human-output/cyclist27500m"));
    } else if (getprop("fdm/jsbsim/power-curve") == 6) {
         setprop("/controls/engines/engine[0]/throttle", getprop("fdm/jsbsim/human-output/cyclist27500mstep")/2378);
         checkTime(getprop("fdm/jsbsim/human-output/cyclist27500mstep"));
    } else if (getprop("fdm/jsbsim/power-curve") == 8) {
         setprop("/controls/engines/engine[0]/throttle", 215/2378);
    } else if (getprop("fdm/jsbsim/power-curve") == 9) {
         setprop("/controls/engines/engine[0]/throttle", 325/2378);
    } else if (getprop("fdm/jsbsim/power-curve") == 10) {
         setprop("/controls/engines/engine[0]/throttle", 450/2378);
    } else if (getprop("fdm/jsbsim/power-curve") == 11) {
         setprop("/controls/engines/engine[0]/throttle", 570/2378);
    } else if (getprop("fdm/jsbsim/power-curve") == 12) {
         setprop("/controls/engines/engine[0]/throttle", getprop("fdm/jsbsim/human-output/user-curve")/2378);
         checkTime(getprop("fdm/jsbsim/human-output/user-curve"));
    }

}

##############################################
#rain
##############################################
var weather_effects_loop = func {
    var airspeed = getprop("/velocities/airspeed-kt");

    # SUMPAC
    var airspeed_max = 60;

    if (airspeed > airspeed_max) {airspeed = airspeed_max;}

    airspeed = math.sqrt(airspeed/airspeed_max);

    # SUMPAC
    var splash_x = -0.1 - 2.0 * airspeed;
    var splash_y = 0.0;
    var splash_z = 1.0 - 1.35 * airspeed;

    setprop("/environment/aircraft-effects/splash-vector-x", splash_x);
    setprop("/environment/aircraft-effects/splash-vector-y", splash_y);
    setprop("/environment/aircraft-effects/splash-vector-z", splash_z);
}

############################################
# Global loop function
# If you need to run nasal as loop, add it in this function
############################################
var global_system_loop = func{
    weather_effects_loop();
    if (!getprop("fdm/jsbsim/electric-power")) 
        power_curve();
}

var sumpac_timer = maketimer(0.25, func{global_system_loop()});

var nasalInit = setlistener("/sim/signals/fdm-initialized", func{
    #aircraft.data.add("fdm/jsbsim/pedal-power");
    #aircraft.data.load();

    if (getprop("/sim/gui/show-power-output")) {
        fgcommand("dialog-show", props.Node.new({"dialog-name": "power-output-dialog"}));
    } else {
        fgcommand("dialog-close", props.Node.new({"dialog-name": "power-output-dialog"}));
    }

    if (getprop("/sim/gui/show-range")) {
        fgcommand("dialog-show", props.Node.new({"dialog-name": "range-dialog"}));
    } else {
        fgcommand("dialog-close", props.Node.new({"dialog-name": "range-dialog"}));
    }

    sumpac_timer.start();
});

setlistener("/sim/gui/show-power-output", func (node) {      
    if (node.getBoolValue()) {
        fgcommand("dialog-show", props.Node.new({"dialog-name": "power-output-dialog"}));
    } else {
        fgcommand("dialog-close", props.Node.new({"dialog-name": "power-output-dialog"}));
    }
}, 0, 0);

setlistener("/sim/gui/show-range", func (node) {      
    if (node.getBoolValue()) {
        fgcommand("dialog-show", props.Node.new({"dialog-name": "range-dialog"}));
    } else {
        fgcommand("dialog-close", props.Node.new({"dialog-name": "range-dialog"}));
    }
}, 0, 0);
