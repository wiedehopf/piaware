# -*- mode: tcl; tab-width: 4; indent-tabs-mode: t -*-
#
# piaware - aviation data exchange protocol ADS-B client
#
# Copyright (C) 2014 FlightAware LLC, All Rights Reserved
#

package require fa_sudo
package require fa_services

#
# setup_faup1090_vars - setup vars but don't start faup1090
#
proc setup_faup1090_vars {} {
	# receiver config
	set ::receiverType [piawareConfig get receiver-type]
	lassign [receiver_host_and_port piawareConfig] ::receiverHost ::receiverPort
	set ::receiverDataFormat [receiver_data_format piawareConfig]
	set ::adsbLocalPort [receiver_local_port piawareConfig]
	set ::adsbDataService [receiver_local_service piawareConfig]
	set ::adsbDataProgram [receiver_description piawareConfig]

	# path to faup1090
	set path "/usr/lib/piaware/helpers/faup1090"
	if {[set ::faup1090Path [auto_execok $path]] eq ""} {
		logger "No faup1090 found at $path, cannot continue"
		exit 1
	}
}

#
# connect_adsb_via_faup1090 - connect to the receiver using faup1090 as an intermediary;
# if it fails, schedule another attempt later
#
proc connect_adsb_via_faup1090 {} {
	# stop faup1090 connection just in case...
	if {[info exists ::faup1090]} {
		$::faup1090 faup_disconnect
	}

	# Create faup connection object with receiver config
	set ::faup1090 [FaupConnection faup1090 \
		-adsbDataProgram $::adsbDataProgram \
		-receiverType $::receiverType \
		-receiverHost $::receiverHost \
		-receiverPort $::receiverPort \
		-receiverLat $::receiverLat \
		-receiverLon $::receiverLon \
		-receiverDataFormat $::receiverDataFormat \
		-adsbLocalPort $::adsbLocalPort \
		-adsbDataService $::adsbDataService \
		-faupProgramPath $::faup1090Path]

	$::faup1090 faup_connect
}

#
# stop_faup1090 - clean up faup1090 pipe, don't schedule a reconnect
#
proc stop_faup1090 {} {
	if {![info exists ::faup1090]} {
		# Nothing to do
		return
	}

	$::faup1090 faup_disconnect
}

#
# restart_faup1090 - pretty self-explanatory
#
proc restart_faup1090 {{delay 30}} {
	if {![info exists ::faup1090]} {
		# Nothing to do
		return
	}

	$::faup1090 faup_restart $delay
}

#
# periodically_check_adsb_traffic - periodically perform checks to see if
# we are receiving data and possibly start/restart faup1090
#
# also issue a traffic report
#
proc periodically_check_adsb_traffic {} {
	if {![info exists ::faup1090]} {
		return
	}

	after [expr {$::adsbTrafficCheckIntervalSeconds * 1000}] periodically_check_adsb_traffic

	$::faup1090 check_traffic

	after 30000 $::faup1090 traffic_report
}

# when adept tells us the receiver location,
# record it and maybe restart dump1090 / faup1090
proc update_location {lat lon} {
	if {![info exists ::faup1090]} {
		return
	}

	$::faup1090 update_location $lat $lon
}

# vim: set ts=4 sw=4 sts=4 noet :
