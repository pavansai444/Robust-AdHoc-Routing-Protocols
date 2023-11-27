set val(chan) Channel/WirelessChannel
set val(prop) Propagation/TwoRayGround
set val(netif) Phy/WirelessPhy
set val(mac) Mac/802_11
set val(ifq) Queue/DropTail/PriQueue
set val(ll) LL
set val(ant) Antenna/OmniAntenna
set val(ifqlen) 20
set val(rp) DYMOUM
set val(nn) 31
set val(x) 500
set val(y) 400
set val(stop) 21


set val(energymodel) EnergyModel
set val(initialenergy) 1000

set ns [new Simulator]

set tf [open dymo31.tr w]
$ns trace-all $tf

set nf [open dymo31.nam w]
$ns namtrace-all-wireless $nf $val(x) $val(y)

set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

set chan_1_ [new $val(chan)]

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

expr { srand(45) }

for {set i 0} {$i < $val(nn)} {incr i} {
    set node_($i) [$ns node]
    $node_($i) set X_ [expr 10+round(rand()*480)]
    $node_($i) set Y_ [expr 10+round(rand()*380)]
    $node_($i) set Z_ 0.0
}

for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at [expr 0.2+round(rand())] "$node_($i) setdest [expr 10+round(rand()*480)] [expr 10+round(rand()*380)] [expr 60+round(rand()*30)]"
}

# TCP section
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
$ns attach-agent $node_(9) $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $node_(2) $sink
$ns connect $tcp $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 1 "$ftp start"

for {set i 0} {$i < $val(nn)} {incr i} {
    $ns initial_node_pos $node_($i) 30
}

for {set i 0} {$i < $val(nn)} {incr i} {
    $ns at $val(stop) "$node_($i) reset"
}

$ns at 19 "finish"
$ns at 18 "$ftp stop"
$ns at 20 "puts \"end simulation\"; $ns halt"

proc finish {} {
    global ns tf nf
    $ns flush-trace
    close $tf
    close $nf
    exec nam dymo31.nam &
    exit 0
}


$ns run


