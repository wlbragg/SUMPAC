# Reset SUMPAC position to starting threshhold at EGHL Lasham
# Wayne Bragg 2019

##############################################
# Kremer Prize Course
##############################################

var height_marker_one_pos = geo.Coord.new();
var height_marker_two_pos = geo.Coord.new();
height_marker_one_pos.set_latlon(51.18832335, -1.028179628);
height_marker_two_pos.set_latlon(51.18585610, -1.027836159);
var dist_to_height_marker = 0;
var end_flag_set = 0;
var message = "";

var kremer_course_loop = func () {

    var current_height = getprop("/position/altitude-agl-ft")-2;

    if (!getprop("/sim/course/running")) {
        dist_to_height_marker = geo.aircraft_position().distance_to(height_marker_one_pos);
        if (dist_to_height_marker < 40) {
            if (current_height > 10) {
                setprop("/sim/course/running", 1);
                gui.popupTip("Kremer Course Attempt Now Running!", 5);
            }
        }
    } else {
        var height_failure = 0;
        var touch_failure = 0;

        dist_to_height_marker = geo.aircraft_position().distance_to(height_marker_two_pos);

        if (dist_to_height_marker < 40)
            end_flag_set = 1;

        if (end_flag_set) {
            if (dist_to_height_marker > 40 and current_height > 10) {
                gui.popupTip("Kremer Course Attempt Successful!", 5);
                setprop("/sim/course/running", 0);
                kremer_course_timer.stop();
            } else
                if (current_height < 10) height_failure = 1;
        }

        if (getprop("/fdm/jsbsim/gear/unit[0]/WOW")) touch_failure = 1;
        if (getprop("/fdm/jsbsim/gear/unit[1]/WOW")) touch_failure = 1;
        if (getprop("/fdm/jsbsim/gear/unit[2]/WOW")) touch_failure = 1;
        if (getprop("/fdm/jsbsim/gear/unit[3]/WOW")) touch_failure = 1;
        if (getprop("/fdm/jsbsim/gear/unit[4]/WOW")) touch_failure = 1;
        if (getprop("/fdm/jsbsim/contact/unit[5]/WOW")) touch_failure = 1;
        if (getprop("/fdm/jsbsim/contact/unit[6]/WOW")) touch_failure = 1;

        var course_failure = height_failure + touch_failure;

gui.popupTip("dist_to_height_marker="~dist_to_height_marker~" end_flag_set="~end_flag_set, 2);

        if (course_failure) {
            if (height_failure) message = "you failed to maintain height over height markers";
            if (touch_failure) message = "a portion of the aircraft touched the ground";

            gui.popupTip("Course failed, "~ message ~ "!", 5);

            settimer(func {
                setprop("/sim/course/failed", 1);
                kremer_course_timer.stop();
                gui.popupTip("Press the [r] key to reset and try again!", 5);
                #reset_course();
            }, 5);
        }
    }
}

var kremer_course_timer = maketimer(.25, kremer_course_loop);

var reset_course = func () {

    gui.popupTip("Kremer Course Attempt Reset!", 5);
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

        dist_to_height_marker = 0;
        end_flag_set = 0;

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
