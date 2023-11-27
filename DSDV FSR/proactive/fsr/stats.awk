BEGIN {
       sends=0;
       recvs=0;
       routing_packets=0;
       droppedPackets=0;
       highest_packet_id =0;
       sum=0;
       recvnum=0;
       recv_size=0;
       average_tput=0;
       startt=65535;
       endt=0.00; 
       initialenergy = 1000;
       maxenergy=0;
	  totalenergy=0;
      pacMax=0;
       n=1;
       retransmissions=0;
       pack_size=0;
     }
  {
     
  time = $2;
  packet_id = $6;
  event =$1;
  pkt_size=$8;
   if (event == "r" || event == "D" || event == "s"|| event == "f") {
        	node_id = $3;
        	energy=$14;
        }
        if (event=="N"){
        	node_id = $5;
          if($5 > n )n=$5;
        	energy=$7;
        }
    # Store remaining energy
    finalenergy[node_id]=energy;

  # CALCULATE PACKET DELIVERY FRACTION
  if (( $1 == "s") &&  ( $7 == "tcp" || $7 =="ack" ) && ( $4=="AGT" )) {  
    sends++;
    if(pacMax < packet_id )
      pacMax = packet_id;
    if(time<startt)
      startt=time; 
  }
  if (( $1 == "r") &&  ( $7 == "tcp" || $7 =="ack" ) && ( $4=="AGT" ))   {
      recvs++;
      if($7=="tcp"){
        recv_size++;
        hdr_size = pkt_size % 512;
       	pkt_size -= hdr_size;
        pack_size = pack_size+pkt_size; #$8 is the packet size 
      }
      if(time > endt ){
        endt=time;
      }
  }
  # CALCULATE Retransmissions
  if ($1 == "r" && $4 == "tcp") {
        acks[$6] = 1;
    } else if ($1 == "+" && $4 == "tcp") {
        if ($6 in acks) {
            retransmissions++;
        }
    }
    
  # CALCULATE DELAY
  if ( start_time[packet_id] == 0 )  start_time[packet_id] = time;
  if (( $1 == "r") &&  ( $7 == "tcp" || $7 == "ack" ) && ( $4=="AGT" )) { end_time[packet_id] = time;  }
       else {  end_time[packet_id] = -1;  }
  # CALCULATE TOTAL AODV OVERHEAD
  if (($1 == "s" || $1 == "f" || $1="r") && $4 == "RTR" && ($7 =="undefined" ||$7 =="message")) routing_packets++;
  # DROPPED PACKETS
  if (event == "D") droppedPackets++;
  }
  END {
     n++;
  for ( i in end_time )
  {
  start = start_time[i];
  end = end_time[i];
  packet_duration = end - start;
  if ( packet_duration > 0 )
  {    sum += packet_duration;
       recvnum++;
  }
  }
    for (i=0;i<n;i=i+1) {
        consumenergy[i]=initialenergy-finalenergy[i]
        totalenergy += consumenergy[i]
        if(maxenergy<consumenergy[i]){
       		 maxenergy=consumenergy[i]
        }
    }
    #compute average energy
    averagenergy=totalenergy/n
    #output
    for (i=0; i<n; i++) {
        print("node",i, consumenergy[i])
    }
        print("average",averagenergy)
        print("total energy",totalenergy)
	print("max energy consumed",maxenergy)

     delay=sum/recvnum;
     print("total recieve packet size",pack_size);
     average_tput=(0.512*8*recv_size)/(endt-startt);
     NRL = routing_packets/recvs;  #normalized routing load
     PDF = (recvs/sends)*100;  #packet delivery ratio[fraction]
     print("Start Time: ",startt," End Time: ",endt);
     print("Average Throughput is= ",average_tput,"kbps");
     printf("Send Packets = %.2f\n",sends);
     printf("Received Packets = %.2f\n",recvs);
     printf("Routing Packets = %.2f\n",routing_packets++);
     printf("Packet Delivery Function = %.2f\n",PDF);
     printf("Normalised Routing Load = %.2f\n",NRL);
     printf("Average end to end delay(ms)= %.2f\n",delay*1000);
     print("No. of dropped packets = ",droppedPackets);
     print("packet drop % = ",droppedPackets/sends*100);
     print("Retransmissions =",retransmissions);
     print("Last Packet ID ="pacMax);
     }
