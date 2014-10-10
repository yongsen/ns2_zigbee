###################################################
#              ZigBee over 802.15.4           	  #
#                (beacon enabled)                 #
#        Copyright (c) 2003 Samsung/CUNY          #
# - - - - - - - - - - - - - - - - - - - - - - - - #
#           Prepared by Jianliang Zheng           #
#            (zheng@ee.ccny.cuny.edu)             #
###################################################

###################################################
###########   Modified by Ma Yongsen   ############
###################################################


# Parameters Settings
set val(chan)           Channel/WirelessChannel    ;# Channel Model: Wireless
set val(prop)           Propagation/Shadowing      ;# Propragation Model: Shadowing (Shadowing/TwoRayGround/FreeSpace) 
set val(netif)          Phy/WirelessPhy/802_15_4
set val(mac)            Mac/802_15_4
set val(ifq)            Queue/DropTail/PriQueue    ;# Queue Model: Drop at Tail
set val(ll)             LL                         ;# Link Layer Model
set val(ant)            Antenna/OmniAntenna        ;# Antenna Model
set val(ifqlen)         100                        ;# Max Number of Queue
set val(nn)             56                         ;# Number of Nodes
set val(rp)             AODV                       ;# Routing Protocol: AODV (DSR/ZBR/AOMDV/AODV)
set val(x)		100			   ;# Center Position of nam
set val(y)		100
        
set val(tr)		zigbee.tr		   ;# Tracing File
set val(nam)		zigbee0.nam		   ;# Nam File
set val(traffic)	cbr                        ;# Data Flow: cbr (cbr/poisson/ftp)

set val(trInterval)	0.01			   ;# Time Interval between Packets
set val(startInterval)  0.5			   ;# Start Time
set stopTime            100			   ;# Stop Time

# Input
proc getCmdArgu {argc argv} {
        global val
        for {set i 0} {$i < $argc} {incr i} {
                set arg [lindex $argv $i]
                if {[string range $arg 0 0] != "-"} continue
                set name [string range $arg 1 end]
                set val($name) [lindex $argv [expr $i+1]]
        }
}
getCmdArgu $argc $argv

# Time Settings

# Initial Global Variables
set ns_		[new Simulator]
set tracefd     [open ./$val(tr) w]
$ns_ trace-all $tracefd
if { "$val(nam)" == "zigbee.nam" } {
        set namtrace     [open ./$val(nam) w]
        $ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
}

$ns_ puts-nam-traceall {# ZigBee #
			}		

Mac/802_15_4 wpanCmd verbose on
Mac/802_15_4 wpanNam namStatus on		


# Topology Configuration
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)

set god_ [create-god $val(nn)]

set chan_1_ [new $val(chan)]

# Node Configuration
$ns_ node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-topoInstance $topo \
		-agentTrace OFF \
		-routerTrace OFF \
		-macTrace ON \
		-movementTrace OFF \
                -energyModel "EnergyModel" \
                -initialEnergy 1000 \
                -rxPower 35.28e-3 \
                -txPower 31.32e-3 \
		-idlePower 712e-6 \
		-sleepPower 144e-9 \
		-channel $chan_1_


for {set i 0} {$i < $val(nn) } {incr i} {
	set node_($i) [$ns_ node]
	$node_($i) random-motion 0		
}

# Topology Input
source ./zigbee.scn

# Start Coordinate/Normal Nodes
$ns_ at 0.0	"$node_(0) NodeLabel \"PAN Coor\""
$ns_ at 0.0	"$node_(0) sscs startCTPANCoord"	



#########################################################

for {set i 1} {$i < 52} {incr i} {
	$ns_ at [expr $i*($val(startInterval))] "$node_($i) sscs startCTDevice"
}

for {set i 52} {$i < 56} {incr i} {
	$ns_ at [expr $i*($val(startInterval))] "$node_($i) sscs startCTDevice"
}

#########################################################

# Runing Speed of Nam
Mac/802_15_4 wpanNam PlaybackRate 5ms
$ns_ at 30.0 "Mac/802_15_4 wpanNam PlaybackRate 10.0ms"
$ns_ at 40.0 "Mac/802_15_4 wpanNam PlaybackRate 100.0ms"

$ns_ at 50.0 "puts \"\nTransmitting data ...\n\""

# Setup UDP and CBR
proc cbrtraffic { src dst interval starttime } {
   global ns_ node_
   set udp_($src) [new Agent/UDP]
   eval $ns_ attach-agent \$node_($src) \$udp_($src)
   set null_($dst) [new Agent/Null]
   eval $ns_ attach-agent \$node_($dst) \$null_($dst)
   set cbr_($src) [new Application/Traffic/CBR]
   eval \$cbr_($src) set packetSize_ 100
   eval \$cbr_($src) set interval_ $interval
   eval \$cbr_($src) set random_ 0
   #eval \$cbr_($src) set maxpkts_ 1000
   eval \$cbr_($src) attach-agent \$udp_($src)
   eval $ns_ connect \$udp_($src) \$null_($dst)
   $ns_ at $starttime "$cbr_($src) start"
}

# ACK
if {$val(rp) == "ZBR"} {
# 0=No ACK; 1=ACK at failure (default); 2=ACK at success/failure
	Mac/802_15_4 wpanCmd callBack 2;
}
if { ("$val(traffic)" == "cbr") } {
   puts "\nTraffic: $val(traffic)"
   puts [format "Acknowledgement for data: %s" [Mac/802_15_4 wpanCmd ack4data off]]

# Start CBR
   for {set i 1} {$i < 56} {incr i} {
   $val(traffic)traffic 0 $i $val(trInterval) [expr 30+$i]) 
   }
  
# Color of Nodes in Nam
   Mac/802_15_4 wpanNam FlowClr -p AODV -c green
   Mac/802_15_4 wpanNam FlowClr -p ARP -c tomato
   Mac/802_15_4 wpanNam FlowClr -p MAC -c navy
}


# Size of Nodes in Nam
for {set i 0} {$i < $val(nn)} {incr i} {
	$ns_ initial_node_pos $node_($i) 8
}

# Reset of Nodes
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $stopTime "$node_($i) reset";
}

# Stop Simulation
$ns_ at $stopTime "stop"
$ns_ at $stopTime "puts \"\nNS EXITING...\n\""
$ns_ at $stopTime "$ns_ halt"

# Stop Function
proc stop {} {
    global ns_ tracefd starttime(1) val env
    $ns_ flush-trace
    close $tracefd
    set hasDISPLAY 0
    foreach index [array names env] {
        #puts "$index: $env($index)"
        if { ("$index" == "DISPLAY") && ("$env($index)" != "") } {
                set hasDISPLAY 1
        }
    }
    if { ("$val(nam)" == "zigbee.nam") && ("$hasDISPLAY" == "1") } {
    	exec nam zigbee.nam &
    }
}

# Start Simulation
puts "\nStarting Simulation..."
$ns_ run
