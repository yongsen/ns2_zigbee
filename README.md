ns2_zigbee
==========

Performance evaluation of Zigbee based on NS2

This repositories includes the codes of my undergraduate thesis. 
1. zigbee.scn: network topology in 3D
2. zigbee.tcl: network script written in tcl
3. thr_drop_delay.awk: eualuation script written in awk
4. data: results of delay, throughput, jitter, and packet loss rate
5. out: figures of results
6. demo: demos of nam
7. thesis

How to
1. make sure zigbee.scn and zibee.tcl are in the same folder
2. cd to the folder by terminal
3. run ns zigbee.tcl
4. run awk zigbee.tr
5. run gnuplot xxx.dat