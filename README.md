ns2_zigbee
==========

Performance evaluation of Zigbee based on NS2

This repository includes the codes of the undergraduate thesis.

1. `zigbee_topology.scn`: network topology in 3D

2. `zigbee.tcl`: network script written in tcl

3. `thr_drop_delay.awk`: eualuation script written in awk

4. `data/`: results of delay, throughput, jitter, and packet loss rate

5. `out/`: figures of results

6. `demo/`: demos of nam

7. `thesis_Chinese.pdf`


How to

1. make sure `zigbee_topology.scn` and `zibee.tcl` are in the same folder

2. cd to the folder by terminal

3. run `ns zigbee.tcl`

4. run `awk -f thr_drop_delay.awk zigbee.tr` to get performance results

5. run `gnuplot [xxx].dat` to get performance plots where `[xxx].dat` has the performance results
