# Reset SUMPAC position to starting threshhold at EGHL Lasham
# Wayne Bragg 2019

var reset_sumpac = func () {

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

}
