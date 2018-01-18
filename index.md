## Performance evaluation of Zigbee based on NS2

### This repository includes the following documents. 
1. `zigbee.scn`: network topology in 3D
2. `zigbee.tcl`: network script written in tcl
3. `thr_drop_delay.awk`: eualuation script written in awk
4. **data**: results of delay, throughput, jitter, and packet loss rate
5. **out**: figures of results
6. **demo**: demos of nam
7. [thesis.pdf](https://raw.github.com/yongsen/ns2_zigbee/master/thesis.pdf) (in Chinese)

### How to
1. Please make sure zigbee.scn and zibee.tcl are in the same folder. The simulation script is written for NS-2.34 with tcl8.4.
2. `cd` to the folder by terminal
3. run `ns zigbee.tcl`. This will generate the simulation results stored in the output file named "zigbee.tr".
4. run `awk -f thr_drop_delay.awk zigbee.tr` to get the performance results.
5. run `gnuplot` and `plot xxx.dat` to get the figures of simulation results.

### Some Results
![Throughput](https://raw.github.com/yongsen/ns2_zigbee/master/out/throughput_02_05_1.png)

![Throughput with beacon (dis)enabled](https://raw.github.com/yongsen/ns2_zigbee/master/out/thr_beacon.png)