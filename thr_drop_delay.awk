BEGIN {
#	参数初始化
	flag[7]=0;	# 标志以记录开始时间
	flag0=0;					
	line=0;
	p=0;
	size0[0]=0;	# 节点0发送数据封包大小
	sent=0;		# 发送封包数
	receive=0;	# 接收封包数
      }

{
#	读取数据行 	       
        event = $1 	# 事件 
        time = $2 	# 时间
        node = $3	# 节点
	level = $4 	# 所在分层 
	pktque = $6 	# 封包序列
	traffic = $7 	# 数据流 
        pktsize = $8	# 封包大小

#	转换（也可改变trace.cc）
	if (node=="_0_")	
		node=0;
	else if (node=="_1_")
		node=1;
	else if (node=="_2_")
		node=2;
	else if (node=="_3_")
		node=3;
	else if (node=="_4_")
		node=4;
	else if (node=="_5_")
		node=5;
	else if (node=="_6_")
		node=6;
	else if (node=="_7_")
		node=7;
	else if (node=="_8_")
		node=8;
	else if (node=="_9_")
		node=9;
	else if (node=="_10_")
		node=10;
	else if (node=="_11_")
		node=11;
	else if (node=="_12_")
		node=12;
	else if (node=="_13_")
		node=13;
	else if (node=="_14_")
		node=14;
	else if (node=="_15_")
		node=15;
	else if (node=="_16_")
		node=16;
	else if (node=="_17_")
		node=17;
	else if (node=="_18_")
		node=18;
	else if (node=="_19_")
		node=19;
	else if (node=="_20_")
		node=20;
	else if (node=="_21_")
		node=21;
	else if (node=="_22_")
		node=22;
	else if (node=="_23_")
		node=23;
	else if (node=="_24_")
		node=24;
	else if (node=="_25_")
		node=25;
	else if (node=="_26_")
		node=26;
	else if (node=="_27_")
		node=27;
	else if (node=="_28_")
		node=28;
	else if (node=="_29_")
		node=29;
	else if (node=="_30_")
		node=30;
	else if (node=="_31_")
		node=31;
	else if (node=="_32_")
		node=32;
	else if (node=="_33_")
		node=33;
	else if (node=="_34_")
		node=34;
	else if (node=="_35_")
		node=35;
	else if (node=="_36_")
		node=36;
	else if (node=="_37_")
		node=37;
	else if (node=="_38_")
		node=38;
	else if (node=="_39_")
		node=39;
	else if (node=="_40_")
		node=40;
	else if (node=="_41_")
		node=41;
	else if (node=="_42_")
		node=42;
	else if (node=="_43_")
		node=43;
	else if (node=="_44_")
		node=44;
	else if (node=="_45_")
		node=45;
	else if (node=="_46_")
		node=46;
	else if (node=="_47_")
		node=47;
	else if (node=="_48_")
		node=48;
	else if (node=="_49_")
		node=49;
	else if (node=="_50_")
		node=50;
	else if (node=="_51_")
		node=51;
	else if (node=="_52_")
		node=52;
	else if (node=="_53_")
		node=53;
	else if (node=="_54_")
		node=54;
	else if (node=="_55_")
		node=55;
	  	
	nodes[node]=node;		# 节点序号
	pktques[pktque]=pktque;		# 封包序号

	if (pack<pktque)
		pack=pktque;		#  记录最高封包序号
	

# 吞吐量
	if (level=="MAC"&&traffic=="cbr")
	   {
		if (event=="r")
		{
	  	  size[node]=size[node]+pktsize;	# 接收封包大小

	  	  if (flag[node]==0)
			{
			  nodestart[node]=time;		# 节点开始时间
			  flag[node]=1;
			}
	  	  if (nodeend[node]<time) 
			  nodeend[node]=time;		# 节点结束时间

		  packend[pktque]=time;			# 封包接收时间
		  receive =receive+1;
		}

# 时延

		else if (event=="s")
	 	  {
	   	  if (packstart[pktque]==0)
			{
	       	      	packstart[pktque]=time;		# 封包发送时间
			}

		  if (node == 0)
			{
		    if (line == 0)
			  {			
			  line=1;
			  end0[0]=time;			# 主节点发送开始时间
			  }			
	  	    else  
			  {
		          p=p+1;			
			  end0[p]=time;			# 主节点发送时间序列
			  }

		    size0[p]=size0[p-1]+pktsize;	# 主节点发送数据量
			}
	
		  sent = sent+1;			# 发送数据封包数目	
	 	  }
# 封包遗失

		else if (event == "D")
	   	  {	
		    cbrdrop[pktque]=1;	    		# 不计重复丢包时丢包数
	   	  }

	}

}



END {
# 初始化
	n=0;		
	delay_last=0;	# 上次时延
	que_last=0;	# 上次封包序号
	drop=0;		# 封包遗失数目
	delta=2;	# 计算吞吐量的时间间隔

#  平均吞吐量
	for (i=1;i<56;i++)
   	{
           endnode = nodeend[i];
           startnode = nodestart[i];
           runtime = endnode - startnode;
           if (runtime > 0) 
  		{
            	    throughput[i] = size[i]*8/runtime;
   		  #  printf("%d\t%f\n",i, throughput[i]) > "nodethr.dat";
		    q++;
       		}
	 #   printf ("node=%d\treceivesize=%d\n",i,size[i]) > "size.dat";
    	}
		  #  printf("number of nodes = %d\n",q) >> "nodethr.dat";

# 主节点实时吞吐量
	for (j=1;j<p;j++)
	{
	    for (k=j+1;k<=p;k++)
		{
		  if ((end0[k]-end0[j])>delta)
			{	
			  thr0 = (size0[k]-size0[j])*8/(end0[k]-end0[j])/1000;
			  j=k;
			  if (thr0 > 0)
				{
				  printf ("%f\t%f\n",end0[k],thr0) > "thr0.dat";	# >>gnuplot	
				}

			}
		}
	}
# 主节点平均吞吐量
	avethr0=size0[p]*8/1000/(end0[p]-end0[0]);
	#printf ("avethrough=%fkbps\n",avethr0) > "avethr.dat";


	for (m=1;m<=pack;m++)
	{
	    startpack = packstart[m];
	    endpack = packend[m];
	    delay = endpack-startpack;

	    if ( delay>0 )
		{
# 时延
	    	printf ("%f\t%f\n",startpack,delay) > "delay.dat";	# >>gnuplot
# 抖动率		
		que_diff=pktques[m]-que_last;
		delay_diff=delay-delay_last;

		if (delay_diff == 0)
			{
			jitter=0;
			}
		else 
			{
			jitter = delay_diff/que_diff;
			}
		
		delay_last = delay;
		que_last = pktques[m];

		printf ("%f\t%f\n",startpack,jitter) > "jitter.dat";	# >>gnuplot

		}
# 遗失封包数
	    drop=drop+cbrdrop[m];

	}
# 封包遗失率
	pktloss = drop*100/sent;
	printf ("sent=%d\tdrop=%d\tpktlossrate=%f%\navethr=%fkbps\nsum of nodes=%d\n\n",sent,drop,pktloss,avethr0,q) >> "data.dat";
	printf ("Well Done!\n");
}
