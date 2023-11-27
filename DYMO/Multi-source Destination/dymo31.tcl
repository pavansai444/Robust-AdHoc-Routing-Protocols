
# Define options
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             30                         ;# number of mobilenodes
set val(rp)             DYMOUM                    ;# routing protocol
set val(x)              500   			   ;# X dimension of topography
set val(y)              400   			   ;# Y dimension of topography  
set val(stop)		150			   ;# time of simulation end
set val(energymodel) EnergyModel
set val(initialenergy) 1000

set ns		  [new Simulator]
set tracefd       [open dymo31.tr w]
set windowVsTime2 [open dymo31.tr w] 
set namtrace      [open dymo31.nam w]    
expr { srand(999) }
$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)
set chan_1_ [new $val(chan)]
create-god $val(nn)

#
#  Create nn mobilenodes [$val(nn)] and attach them to the channel. 
#

# configure the nodes
$ns node-config -adhocRouting $val(rp) \
    -llType $val(ll) \
    -macType $val(mac) \
    -ifqType $val(ifq) \
    -ifqLen $val(ifqlen) \
    -antType $val(ant) \
    -propType $val(prop) \
    -phyType $val(netif) \
    -channel $chan_1_ \
    -topoInstance $topo \
    -agentTrace ON \
    -routerTrace ON \
    -macTrace OFF \
    -movementTrace ON \
    -energyModel $val(energymodel) \
    -initialEnergy $val(initialenergy) \
    -rxPower 0.4 \
    -txPower 1.0 \
    -idlePower 0.6 \
    -sleepPower 0.1 \
    -transitionPower 0.4 \
    -transitionTime 0.1

# Provide initial location of mobilenodes


set j 0
set node_($j) [$ns node]
	$node_($j) set X_ [expr 10 ]
	$node_($j) set Y_ [expr 10 ]
	$node_($j) set Z_ 0.0
	
	incr j
	
set node_($j) [$ns node]
	$node_($j) set X_ [expr 300]
	$node_($j) set Y_ [expr 300]
	$node_($j) set Z_ 0.0
	incr j
set node_($j) [$ns node]
	$node_($j) set X_ [expr 10]
	$node_($j) set Y_ [expr 300]
	$node_($j) set Z_ 0.0
	incr j
	
set node_($j) [$ns node]
	$node_($j) set X_ [expr 300]
	$node_($j) set Y_ [expr 10 ]
	$node_($j) set Z_ 0.0
         
for {set j 4} {$j < $val(nn)} {incr j} {
	set node_($j) [$ns node]
	$node_($j) set X_ [expr 10 + round(rand() * 480)]
	$node_($j) set Y_ [expr 10 + round(rand() * 380)]
	$node_($j) set Z_ 0.0
}


for {set i 0} {$i < $val(nn)} {incr i} {
	$ns at [ expr 0.2+round(rand()*125) ] "$node_($i) setdest [ expr 10+round(rand()*480) ] [expr 10+round(rand()*380) ] [expr 60+round(rand()*30) ]"
}
# Generation of movements
#$ns at 0.5 "$node_(0) setdest 250.0 250.0 3.0"
#$ns at 1.5 "$node_(1) setdest 45.0 285.0 5.0"
#$ns at 110.0 "$node_(0) setdest 480.0 300.0 5.0" 

# Set a TCP connection between node_(0) and node_(1)
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
set sink [new Agent/TCPSink]
$ns attach-agent $node_(0) $tcp
$ns attach-agent $node_(1) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 0.5 "$ftp start" 


set tcp2 [new Agent/TCP/Newreno]
$tcp2 set class_ 3
set sink2 [new Agent/TCPSink]
$ns attach-agent $node_(2) $tcp2
$ns attach-agent $node_(3) $sink2
$ns connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ns at 0.6 "$ftp2 start" 

set tcp3 [new Agent/TCP/Newreno]
$tcp3 set class_ 4
set sink3 [new Agent/TCPSink]
$ns attach-agent $node_(16) $tcp3
$ns attach-agent $node_(13) $sink3
$ns connect $tcp3 $sink3
set ftp3 [new Application/FTP]
$ftp3 attach-agent $tcp3
$ns at 0.7 "$ftp3 start" 

set tcp4 [new Agent/TCP/Newreno]
$tcp4 set class_ 5
set sink4 [new Agent/TCPSink]
$ns attach-agent $node_(8) $tcp4
$ns attach-agent $node_(14) $sink4
$ns connect $tcp4 $sink4
set ftp4 [new Application/FTP]
$ftp4 attach-agent $tcp4
$ns at 0.8 "$ftp4 start" 

set tcp5 [new Agent/TCP/Newreno]
$tcp5 set class_ 6
set sink5 [new Agent/TCPSink]
$ns attach-agent $node_(5) $tcp5
$ns attach-agent $node_(6) $sink5
$ns connect $tcp5 $sink5
set ftp5 [new Application/FTP]
$ftp5 attach-agent $tcp5
$ns at 0.9 "$ftp5 start" 

set tcp6 [new Agent/TCP/Newreno]
$tcp6 set class_ 7
set sink6 [new Agent/TCPSink]
$ns attach-agent $node_(29) $tcp6
$ns attach-agent $node_(28) $sink6
$ns connect $tcp6 $sink6
set ftp6 [new Application/FTP]
$ftp6 attach-agent $tcp6
$ns at 0.9 "$ftp6 start"

set tcp7 [new Agent/TCP/Newreno]
$tcp7 set class_ 8
set sink7 [new Agent/TCPSink]
$ns attach-agent $node_(19) $tcp7
$ns attach-agent $node_(29) $sink7
$ns connect $tcp7 $sink7
set ftp7 [new Application/FTP]
$ftp7 attach-agent $tcp7
$ns at 0.9 "$ftp7 start"

# Printing the window size
proc plotWindow {tcpSource file} {
global ns
set time 0.01
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file" }
$ns at 10.1 "plotWindow $tcp $windowVsTime2"  

# Define node initial position in nam
for {set i 0} {$i < $val(nn)} { incr i } {
 #30 defines the node size for nam
$ns initial_node_pos $node_($i) 30
}

# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
    $ns at $val(stop) "$node_($i) reset";
}

# ending nam and the simulation 
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 150.01 "puts \"end simulation\" ; $ns halt"
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
    exec nam dymo31.nam &
    exit 0
}

$ns run


