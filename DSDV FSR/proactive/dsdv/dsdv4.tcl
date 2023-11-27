set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             100                         ;# number of mobilenodes
set val(rp)             DSDV                    ;# routing protocol
set val(x)              1500   			   ;# X dimension of topography
set val(y)              1000  			   ;# Y dimension of topography  
set val(stop)		150			   ;# time of simulation end

set val(energymodel) EnergyModel
set val(initialenergy) 1000

set ns		  [new Simulator]
set tracefd       [open DSDV.tr w]
set windowVsTime2 [open DSDV.tr w] 
set namtrace      [open DSDV.nam w]    
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
	$node_($j) set X_ [expr 10 + round(rand() * 1480)]
	$node_($j) set Y_ [expr 10 + round(rand() * 980)]
	$node_($j) set Z_ 0.0
}


for {set i 0} {$i < $val(nn)} {incr i} {
	$ns at [ expr 0.2+round(rand()*125) ] "$node_($i) setdest [ expr 10+round(rand()*1480) ] [expr 10+round(rand()*980) ] [expr 60+round(rand()*30) ]"
}
# Generation of movements
#$ns at 0.5 "$node_(0) setdest 250.0 250.0 3.0"
#$ns at 1.5 "$node_(1) setdest 45.0 285.0 5.0"
#$ns at 110.0 "$node_(0) setdest 480.0 300.0 5.0" 

# Set a TCP connection between node_(0) and node_(1)

for {set i 2} {$i < 78 } {incr i} {
	set tcp_($i) [new Agent/TCP/Newreno]
    $tcp_($i) set class_ $i
    set j [ expr $i + 1 ]
    set sink_($i) [new Agent/TCPSink]
    $ns attach-agent $node_($i) $tcp_($i)
    $ns attach-agent $node_($j) $sink_($i)
    $ns connect $tcp_($i) $sink_($i)
    set ftp_($i) [new Application/FTP]
    $ftp_($i) attach-agent $tcp_($i)
    $ns at 1 "$ftp_($i) start" 
}

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
    exec nam DSDV.nam &
    exit 0
}

$ns run
