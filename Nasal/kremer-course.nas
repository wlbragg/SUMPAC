# Reset SUMPAC position to starting threshhold at EGHL Lasham
# Wayne Bragg 2019

##############################################
# Kremer Prize Course
##############################################
var kremer_course_loop = func () {

    var current_height = getprop("/position/altitude-agl-ft")-2;
    var course_running = getprop("/sim/course/running");

    if (!course_running) {
        if (current_height > 10) {
            setprop("/sim/course/running", 1);
            gui.popupTip("Kremer Course Now Running!", 5);
        
        }
    } else {
        if (current_height < 10 or getprop("/fdm/jsbsim/contact[5]/WOW") or getprop("/fdm/jsbsim/contact[6]/WOW")) {
            gui.popupTip("Kremer Course Failed!", 5);
            settimer(func {
                if (!getprop("/engines/active-engine/running")) {
                    setprop("/sim/course/failed", 1);
                    kremer_course_timer.stop();
                    reset_course();
                }
            }, 5);
        }
    }
}

var kremer_course_timer = maketimer(.25, kremer_course_loop);

var reset_course = func () {
    gui.popupTip("Kremer Course Re-Starting!", 5);
    settimer(func {
        var elev_m = geo.elevation(getprop("/sim/presets/latitude-deg"), getprop("/sim/presets/longitude-deg"));
        var lat_init = getprop("/sim/presets/latitude-deg");
        var lon_init = getprop("/sim/presets/longitude-deg");
        var heading_init = getprop("/sim/presets/heading-deg");

        setprop("/controls/engines/engine[0]/throttle", 0);
		    setprop("/controls/flight/aileron", 0);
        setprop("/controls/flight/elevator", 0);
        setprop("/controls/flight/rudder", 0);
		    setprop("/position/altitude-ft", (elev_m * 3.2808)+1);
		    setprop("/position/latitude-deg", lat_init); 
		    setprop("/position/longitude-deg", lon_init);
        setprop("/orientation/pitch-deg", 0.0);
		    setprop("/orientation/roll-deg", 0.0);
		    setprop("orientation/heading-deg", heading_init); 
		    setprop("/velocities/uBody-fps",0.0);
		    setprop("/velocities/wBody-fps",0.0);

        setprop("/sim/course/failed", 0);
        setprop("/sim/course/running", 0);

        setprop("/sim/flyerflagone/enable", 1);
        setprop("/sim/flyerflagtwo/enable", 1);
        if (getprop("/sim/rendering/course-pole-type")){
            setprop("/sim/heightpoleone/enable", 0);
            setprop("/sim/heightpoletwo/enable", 0);
            setprop("/sim/tpoleone/enable", 1);
            setprop("/sim/tpoletwo/enable", 1);
        } else {
            setprop("/sim/tpoleone/enable", 0);
            setprop("/sim/tpoletwo/enable", 0);
            setprop("/sim/heightpoleone/enable", 1);
            setprop("/sim/heightpoletwo/enable", 1);
        }

        if (!kremer_course_timer.isRunning)
            kremer_course_timer.start();
    }, 5);
}

var stop_course = func () {

    setprop("/sim/flyerflagone/enable", 0);
    setprop("/sim/flyerflagtwo/enable", 0);
    setprop("/sim/heightpoleone/enable", 0);
    setprop("/sim/heightpoletwo/enable", 0);
    setprop("/sim/tpoleone/enable", 0);
    setprop("/sim/tpoletwo/enable", 0);

    setprop("/sim/course/running", 0);

    kremer_course_timer.stop();
}
