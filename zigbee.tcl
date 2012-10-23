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


# 选项定义
set val(chan)           Channel/WirelessChannel    ;# 信道类型：无线信道
set val(prop)           Propagation/Shadowing      ;# 广播模型：Shadowing（Shadowing/TwoRayGround/FreeSpace） 
set val(netif)          Phy/WirelessPhy/802_15_4
set val(mac)            Mac/802_15_4
set val(ifq)            Queue/DropTail/PriQueue    ;# 接口队列类型：队尾丢弃
set val(ll)             LL                         ;# 逻辑链路类型
set val(ant)            Antenna/OmniAntenna        ;# 天线模型：
set val(ifqlen)         100                        ;# 队列允许最大封包数
set val(nn)             56                         ;# 节点数
set val(rp)             AODV                       ;# 路由协议：AODV（DSR/ZBR/AOMDV/AODV）
set val(x)		100			   ;# nam中显示的中心位置
set val(y)		100
        
set val(tr)		zigbee.tr		   ;# 跟踪文件
set val(nam)		zigbee0.nam		   ;# nam文件
set val(traffic)	cbr                        ;# 数据流：cbr（cbr/poisson/ftp）

set val(trInterval)	0.01			   ;# 数据发送间隔
set val(startInterval)  0.5			   ;# 设备开启时间系数

set stopTime            100			   ;# 仿真结束时间

# 读取命令行
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

# 设置时间参量

# 初始化全局变量
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


# 建立拓扑对象
set topo       [new Topography]
$topo load_flatgrid $val(x) $val(y)

set god_ [create-god $val(nn)]

set chan_1_ [new $val(chan)]

# 配置节点
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

# 读取节点位置配置文件
source ./zigbee.scn

# 开启协调点与从节点
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

# 设置nam运行速率
Mac/802_15_4 wpanNam PlaybackRate 5ms
$ns_ at 30.0 "Mac/802_15_4 wpanNam PlaybackRate 10.0ms"
$ns_ at 40.0 "Mac/802_15_4 wpanNam PlaybackRate 100.0ms"

$ns_ at 50.0 "puts \"\nTransmitting data ...\n\""

# 建立节点间UDP与cbr
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

# 回复机制设定
if {$val(rp) == "ZBR"} {
	Mac/802_15_4 wpanCmd callBack 2	;# 0=无回复; 1=仅失败回复 (默认值); 2=失败与成功都回复
}
if { ("$val(traffic)" == "cbr") } {
   puts "\nTraffic: $val(traffic)"
   puts [format "Acknowledgement for data: %s" [Mac/802_15_4 wpanCmd ack4data off]]

# 调用函数，启动cbr数据流

   for {set i 1} {$i < 56} {incr i} {
   $val(traffic)traffic 0 $i $val(trInterval) [expr 30+$i]) 
   }
  
# 设置各层显示颜色
   Mac/802_15_4 wpanNam FlowClr -p AODV -c green
   Mac/802_15_4 wpanNam FlowClr -p ARP -c tomato
   Mac/802_15_4 wpanNam FlowClr -p MAC -c navy
}


# 定义节点在nam中大小
for {set i 0} {$i < $val(nn)} {incr i} {
	$ns_ initial_node_pos $node_($i) 8
}

# 节点复位
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $stopTime "$node_($i) reset";
}

# 仿真结束
$ns_ at $stopTime "stop"
$ns_ at $stopTime "puts \"\nNS EXITING...\n\""
$ns_ at $stopTime "$ns_ halt"

# 结束程序定义
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

# 启动仿真
puts "\nStarting Simulation..."
$ns_ run
