# Define options
set val(chan) Channel/WirelessChannel 	;# channel type
set val(prop) Propagation/TwoRayGround 	;# radio-propagation model
set val(netif) Phy/WirelessPhy 		;# network interface type
set val(mac) Mac/802_11 		;# MAC type
set val(ifq) Queue/DropTail/PriQueue 	;# interface queue type
set val(ll) LL 				;# link layer type
set val(ant) Antenna/OmniAntenna 	;# antenna model
set val(ifqlen) 50			;# max packet in ifq
set val(nn) 10	;# number of mobilenodes
set val(rp) AODV	;# routing protocol
set val(x) 300				;# X dimension of topography
set val(y) 160				;# Y dimension of topography 
set val(stop) 75 			;# time of simulation end

#-------Event scheduler object creation--------#
set ns              [new Simulator]

#creating trace file and nam file
set tracefd       [open fsr.tr w]
set windowVsTime2 [open win.tr w]
set namtrace      [open fsr.nam w]

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)

# configure gateway node
        $ns node-config -adhocRouting $val(rp) \
                   -llType $val(ll) \
                   -macType $val(mac) \
                   -ifqType $val(ifq) \
                   -ifqLen $val(ifqlen) \
                   -antType $val(ant) \
                   -propType $val(prop) \
                   -phyType $val(netif) \
                   -channelType $val(chan) \
                   -topoInstance $topo \
                   -agentTrace ON \
                   -routerTrace ON \
                   -macTrace OFF \
                   -movementTrace ON

		
	for {set i 0} {$i < 2 } { incr i } {
	        set node_($i) [$ns node];
	        #$node_($i) color "red";   ;# Set node size here (replace 1.0 with your desired size)
	        $ns at 3.0 "$node_($i) color blue"	        
		}
		

		
	for {set i 2} {$i < $val(nn) } { incr i } {
	        set node_($i) [$ns node];# Set node size here (replace 1.0 with your desired size)
	        $node_($i) color "blue";
	        $ns at 3.0 "$node_($i) color blue"
		}
     

#Change node color based on role
$node_(4) color green
$ns at 7.0 "$node_(2) color green"
$ns at 36.0 "$node_(2) color blue"

$node_(4) color green
$ns at 7.0 "$node_(5) color green"
$ns at 36.0 "$node_(5) color blue"

$node_(5) color green
$ns at 8.0 "$node_(3) color green"
$ns at 39.0 "$node_(3) color blue"

$node_(6) color green
$ns at 44.0 "$node_(4) color green"
$ns at 65.0 "$node_(4) color blue"

$node_(9) color green
$ns at 45.0 "$node_(5) color green"
$ns at 66.0 "$node_(5) color blue"

#Change node label based on role
$ns at 7.0 "$node_(2) label sender1"
$ns at 36.0 "$node_(2) label \"\""

$ns at 6.0 "$node_(5) label sender2"
$ns at 35.0 "$node_(5) label \"\""

$ns at 8.0 "$node_(3) label reciever"
$ns at 39.0 "$node_(3) label \"\""

$ns at 44.0 "$node_(4) label sender"
$ns at 65.0 "$node_(4) label \"\""

$ns at 45.0 "$node_(5) label reciever"
$ns at 66.0 "$node_(5) label \"\""

#Provide location of gateways
	
$node_(0) set X_ 55.0
$node_(0) set Y_ 55.0
$node_(0) set Z_ 0.0
$node_(0) color red

$node_(1) set X_ 120.0
$node_(1) set Y_ 120.0
$node_(1) set Z_ 0.0
$node_(1) color red

$node_(2) set X_ 80.0
$node_(2) set Y_ 20.0
$node_(2) set Z_ 0.0
$node_(2) color red

$node_(3) set X_ 135.0
$node_(3) set Y_ 135.0
$node_(3) set Z_ 0.0
$node_(3) color red

$node_(4) set X_ 25.0
$node_(4) set Y_ 25.0
$node_(4) set Z_ 0.0
$node_(4) color red

$node_(5) set X_ 20.0
$node_(5) set Y_ 80.0
$node_(5) set Z_ 0.0
$node_(5) color red

# Provide random initial position of mobilenodes
for {set i 6} {$i < $val(nn)} {incr i} {
	$node_($i) set X_ [expr rand()*300]
	$node_($i) set Y_ [expr rand()*160]
	$node_($i) set Z_ 0
}


# Generation of random movement and speed
for {set i 0} {$i < 6} {incr i} {
$ns at 0.0 "$node_($i) setdest [expr rand()*300] [expr rand()*160] 1.0"
}

for {set i 6} {$i < $val(nn)} {incr i} {
$ns at 0.0 "$node_($i) setdest [expr rand()*300] [expr rand()*160] [expr rand()*10]"
}


# Set up TCP connections
set tcp1 [new Agent/TCP/Newreno]
$tcp1 set class_ 2
set sink1 [new Agent/TCPSink]
$ns attach-agent $node_(2) $tcp1
$ns attach-agent $node_(0) $sink1
$ns connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns at 9.0 "$ftp1 start"
$ns at 35.0 "$ftp1 stop"

set tcp2 [new Agent/TCP/Newreno]
$tcp2 set class_ 3
set sink2 [new Agent/TCPSink]
$ns attach-agent $node_(5) $tcp2
$ns attach-agent $node_(0) $sink2
$ns connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ns at 9.0 "$ftp2 start"
$ns at 35.0 "$ftp2 stop"


set tcp3 [new Agent/TCP/Newreno]
$tcp3 set class_ 4
set sink3 [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp3
$ns attach-agent $node_(1) $sink3
$ns connect $tcp3 $sink3
set ftp3 [new Application/FTP]
$ftp3 attach-agent $tcp3
$ns at 10.0 "$ftp3 start"
$ns at 36.0 "$ftp3 stop"

set tcp4 [new Agent/TCP/Newreno]
$tcp4 set class_ 5
set sink4 [new Agent/TCPSink]
$ns attach-agent $node_(1) $tcp4
$ns attach-agent $node_(3) $sink4
$ns connect $tcp4 $sink4
set ftp4 [new Application/FTP]
$ftp4 attach-agent $tcp4
$ns at 11.0 "$ftp4 start"
$ns at 37.0 "$ftp4 stop"

set tcp5 [new Agent/TCP/Newreno]
$tcp5 set class_ 6
set sink5 [new Agent/TCPSink]
$ns attach-agent $node_(4) $tcp5
$ns attach-agent $node_(5) $sink5
$ns connect $tcp5 $sink5
set ftp5 [new Application/FTP]
$ftp5 attach-agent $tcp5
$ns at 45.0 "$ftp5 start"
$ns at 65.0 "$ftp5 stop"

# Printing the window size
proc plotWindow {tcpSource file} {
global ns
set time 0.01
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file" }
$ns at 10.0 "plotWindow $tcp1 $windowVsTime2" 
$ns at 10.0 "plotWindow $tcp2 $windowVsTime2" 

# Define node initial position in nam
for {set i 0} {$i < $val(nn)} { incr i } {
$ns initial_node_pos $node_($i) 20
}

# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$node_($i) reset";
}

# ending nam and the simulation 
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 100.01 "puts \"end simulation\" ; $ns halt"
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
exec nam fsr.nam &
}

$ns run
