BEGIN {
#	参数初始化
	sent=0;		# 发送封包数
	receive=0;	# 接收封包数
	liner=0;
	q=0;
	dropd=0;
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
	  	
	pktques[pktque]=pktque;		# 封包序号

	if (pack<pktque)
		pack=pktque;		#  记录最高封包序号
	

# 吞吐量
	if (level=="MAC"&&traffic=="cbr")
	   {
		if (event=="r")
		{
		  packend[pktque]=time;			# 封包接收时间
		  receive =receive+1;
		  
		  if (node == "_0_")
			{
		    if (liner == 0)
			  {			
			  liner=1;
			  endr[0]=time;			# 主节点接收开始时间
			  }			
	  	    else  
			  {
		          q=q+1;			
			  endr[q]=time;			# 主节点接收时间序列
			  }

		    sizer[q]=sizer[q-1]+pktsize;	# 主节点接收数据量
			}

		}

# 时延

		else if (event=="s")
	 	  {

	   	  if (packstart[pktque]==0)
			{
	       	      	packstart[pktque]=time;		# 封包发送时间
			}

	 	  }

		else if (event=="D")
		  {
			dropd++;
		  }

	}

}



END {
# 初始化
	n=0;		
	delay_last=0;	# 上次时延
	que_last=0;	# 上次封包序号
	delta=2;

# 主节点实时吞吐量
	for (j=1;j<q;j++)
	{
	    for (k=j+1;k<=q;k++)
		{
		  if ((endr[k]-endr[j])>delta)
			{	
			  thrr = (sizer[k]-sizer[j])*8/(endr[k]-endr[j])/1000;
			  j=k;
			  if (thrr > 0)
				{
				  printf ("%f\t%f\n",endr[k],thrr) > "thrr.dat";	
				}

			}
		}
	}

	for (m=1;m<=pack;m++)
	{
	    startpack = packstart[m];
	    endpack = packend[m];
	    delay = endpack-startpack;

	    if ( delay>0 )
		{
		delays[n]=delay;
# 时延
	    	printf ("%f\t%f\n",packstart[m],delay) > "delay.dat";	# >>gnuplot
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
		
		n++;

		}

	}

	for (p=0;p<n;p++)
	{
		sum_delay+=delays[p];
	}
	ave_delay=sum_delay/n;
	printf ("ave delay = %f\n\n",ave_delay)>>"avedelay.dat";

	printf ("dropd=%d\n",dropd);

	printf ("Well Done!\n");
}
