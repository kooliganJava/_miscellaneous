BEGIN {
	print strtonum("." "80")
	verbose=0
	month_num["Jan"]=1
	month_num["Feb"]=2
	month_num["Mar"]=3
	month_num["Apr"]=4
	month_num["May"]=5
	month_num["Jun"]=6
	month_num["Jul"]=7
	month_num["Aug"]=8
	month_num["Sep"]=9
	month_num["Oct"]=10
	month_num["Nov"]=12
	month_num["Dec"]=13
	states[0]="down"
	states[1]="up"
	events["down"]=0
	events["up"]=0
	ostatus["down"]="up"
	ostatus["up"]="down"
	state_duration["down"]=0
	state_duration["up"]=0
	state_percent["down"]=0  
	state_percent["up"]=0
	total_state_duration["down"]=0
	total_state_duration["up"]=0
	rgx_mstatus["down"]="DOWN from|monitor status down"
	rgx_mstatus["up"]="UP from|monitor status up"
	rgx_sstatus["down"]="session status (forced )*down"
	rgx_sstatus["up"]="session status up"
	resolution=1
	maximum_state_time=2592000	# 30 days
	
}
function ip_part(str_ipaddr) {
	match(str_ipaddr,/[12]{0,1}[0-9]{1,2}\.[12]{0,1}[0-9]{1,2}\.[12]{0,1}[0-9]{1,2}\.[12]{0,1}[0-9]{1,2}/)
	return substr(str_ipaddr,RSTART,RLENGTH)
}

function port_part(str_ipaddr) {
	match(str_ipaddr,/:[0-9]{1,5}/)
	return substr(str_ipaddr,RSTART+1,RLENGTH-1)
}

function ip_to_int(str_ipaddr) {
	split(str_ipaddr,octet,"\.")
	return octet[4]+octet[3]*256+octet[2]*65536+octet[1]*16777216
}


function ip_port_to_int(str_ipaddr) {
	delete octet
	match(str_ipaddr,/([12]{0,1}[0-9]{1,2}\.){3}[12]{0,1}[0-9]{1,2}:*[0-9]{0,5}/)
	str_ipaddr=substr(str_ipaddr,RSTART,RLENGTH)
	split(str_ipaddr,octet,"[\:\.]")
	if (octet[5]=="0") octet[5]=1
	return octet[5]+octet[4]*256+octet[3]*65536+octet[2]*16777216+octet[1]*4294967296
}

function round_to_resolution(intDUR) {
	return int(intDUR/resolution)*resolution
}

function calc_duration(intTIME,intLAST) {
						return round_to_resolution((intTIME-intLAST)*(!((intTIME-intLAST)>=maximum_state_time)))
					}
					
function line_out() {
				#printf "%i %10i%10i %s\n",time,up_duration,down_duration,this_entry
				#printf "%20s%20s%20s%20s\n","Time UP","Time DOWN","Total Time UP","Total Time DOWN"
				#printf "%20i%20i%20i%20i\n",up_duration,down_duration,total_up_duration,total_down_duration
}

function time_from_entry(month,date,time) {

	split(time,PART,":")
	hh=PART[1]
	mm=PART[2]
	ss=PART[3]
	month=month_num[month]
	#print "month="month
	#print "date="date
	#print "time="time
	#print "hours="hh
	#print "minutes="mm
	#print "seconds="ss
	#print "stamp="mktime("2009 "month" "date" "hh" "mm" "ss)
	#print "mktime is "mktime("2009 "month" "date" "hh" "mm" "ss)
	return mktime("2009 "month" "date" "hh" "mm" "ss)
}	

function normalize_time(seconds) {
	if (!seconds) {return}
	if (seconds<60) {
		return sprintf(" %i %s%s",seconds,"Second",(seconds==1)?"":"s")
	}
	if (seconds<3600) {
		return sprintf(" %i %s%s%s",int(seconds/60),"Minute",(int(seconds/60)==1)?"":"s",","normalize_time(seconds%60))
	}
	if (seconds<86400) {
		return sprintf(" %i %s%s%s",int(seconds/3600),"Hour",(int(seconds/3600)==1)?"":"s",","normalize_time(seconds%3600))
	}
	
	if (seconds>=86400) {
		return sprintf(" %i %s%s%s",int(seconds/86400),"Day",(int(seconds/86400)==1)?"":"s",","normalize_time(seconds%86400))
	}
}

		
# produce log statistics per gtm node

#/tcp_half_open 170.135.128.149:20021/ {
#/gtmd.+ Monitor instance / {
#	time=time_from_entry($1,$2,$3)*100
#
#	#if (time in log_entry) printf "%s\n%i %s\n",$0,time,"DUPLICATE ENTRY"
#	#while (time in log_entry) {
#	#	printf "%s,%i","increasing time to ",time++
#	#}
#	log_time[$0]=time
#	log_entry[time]=$0          
#	if (!($9" "$10 in instance)) {
#		instance[$9" "$10]=time
#		print "INSTANCE="$9" "$10
#	}
#	printf "%i %s\n",time,$0
#	}
		
	
#/tcp_half_open 170.135.128.149:20021/ {
#/gtmd.+ Monitor instance / {
#	#log_time[$0]=sprintf("%i",strtonum(time_from_entry($1,$2,$3)))
#	time=sprintf("%i",strtonum(time_from_entry($1,$2,$3)*100))
#	#print "time is "time
#	#time=sprintf("%s",time)
#
#	#printf "%i %s\n",time,$0
#	if (($0 in log_time)&& (log_time[$0]==time)) {
#		#print "Bail out on DUPLICATE"
#		next
#	}
#	while (time in log_entry) {
#		#print (time in log_entry)
#		a=strtonum(time)+1
#		time=sprintf("%i",a)
#		#printf "%s %i\n","increasing time TO ",time" "(time in log_entry)
#	} 
#	log_time[$0]=time
#	log_entry[time]=$0
#	instance_key=$9" "$10
#	if (!(instance_key in instance)) {
#		instance[instance_key]=time
#		#print "INSTANCE="instance_key
#	}
#	#printf "%i %s\n",time,$0
#}

# produce log statistics per ltm or gtm member

#Sep 15 06:45:48 bgep01 mcpd[1876]: 01070638:5: Pool member 192.168.226.65:443 monitor status down.
#Jun  2 00:01:36 ltm3400prod-1 mcpd[1079]: 01070640:3: Node 10.111.130.20 monitor status down.
/mcpd.+(Node|Pool member).+(monitor|session) status [udfe]|gtmd.+ Monitor instance / {
	#printf "___________MCPD INSTANCE\n"$0"\n"
	#log_time[$0]=sprintf("%i",strtonum(time_from_entry($1,$2,$3)))
	time=sprintf("%i",strtonum(time_from_entry($1,$2,$3)*100))
	#print "time is "time
	#time=sprintf("%s",time)

	#printf "%i %s\n",time,$0
	#if (($0 in log_time)&& (log_time[$0]==time)) {
	if ($0 in log_time) {
		#print "Bail out on DUPLICATE"
		next
	}
	while (time in log_entry) {
		#print (time in log_entry)
		a=strtonum(time)+1
		time=sprintf("%i",a)
		#printf "%s %i\n","increasing time TO ",time" "(time in log_entry)
	} 
	log_time[$0]=time
	log_entry[time]=$0
	if (match($0,/mcpd.+(Node|Pool member).+(monitor|session) status [udfe]/)) {
		instance_key=$7" "(($7=="Node") ? $8 : $8" "$9)
	} else if (match($0,/gtmd.+ Monitor instance /)) {
				instance_key=$9" "$10
	}

	if (!(instance_key in instance)) {
		instance[instance_key]++
		instance_order[instance_key]=ip_port_to_int(instance_key)
		order_instance[instance_order[instance_key]]=instance_key
		print "INSTANCE="instance_key	
		#print "IP Address="ip_part(instance_key),ip_port_to_int(ip_part(instance_key))
		#print "PORT="port_part(instance_key)
		#printf "%s\t%i\n","Instance Order=",instance_order[instance_key]
	}
	#printf "%i %s\n",time,$0
}
	
END {
	entries=asort(log_time)
	instances=asort(instance_order,i_o)
	print "ENTRIES="entries
		print "Instances="instances
	for (ii=1;ii<=instances;ii++) {
		this_instance=order_instance[i_o[ii]]
		#print "\nInstance="order_instance[i_o[ii]],i_o[ii]
		for (boolState in states) {
			events[states[boolState]]=0
			state_duration[states[boolState]]=0
			state_percent[states[boolState]]=0
			total_state_duration[states[boolState]]=0
			last_time[states[boolState]]=0
		}
		x1=0
		x2=0
		instance_entry=0
		start_time=0
		end_time=0
		last_status=""
		for (i=1;i<=entries;i++) {
			time_str=log_time[i]
			this_entry=log_entry[time_str]
			time=strtonum(substr(time_str,1,length(time_str)-2))
			#print "this_entry="this_entry
			#print "this_instance="this_instance
			if (i==entries) end_time=time

			if (this_entry !~ this_instance) continue
			if (++instance_entry==1) start_time=time
			
			for (boolState in states) {
				if (this_entry~rgx_mstatus[states[boolState]]) {
					status=states[boolState]
					if (last_status=="") {
						last_status=ostatus[status]
						last_time[ostatus[status]]=start_time
						}				
					if (last_status==ostatus[status]) {
							total_state_duration[ostatus[status]]+=calc_duration(time,last_time[ostatus[status]]);
					} else {
						total_state_duration[status]+=calc_duration(time,last_time[status])
					}
				if (verbose==1) line_out()
				state_duration[ostatus[status]]=0
				events[status]++
				last_time[status]=time
				last_status=status
			}
			x1+=total_up_duration
			x2+=total_up_duration*total_up_duration
		}
		}
		total_duration=end_time-start_time
		total_state_duration[status]+=end_time-last_time[status]+(end_time==last_time[status])
		for (boolState in states) {
			state_percent[states[boolState]]=total_state_duration[states[boolState]]/(total_duration+1)*100
		}
		printf "\n"this_instance"\n"
		print "Ups:       "events["up"]
		print "Downs:     "events["down"]
		printf "%s %.3f%%,%s\n","Duration:  ",100,normalize_time(total_duration)
		printf "%s %.3f%%,%s\n","Time Up  : ",state_percent["up"],normalize_time(total_state_duration["up"])
		printf "%s %.3f%%,%s\n","Time Down: ",state_percent["down"],normalize_time(total_state_duration["down"])
		
		
#		if ((events["down"]+events["up"])>1) {
#			x1=x1/events["up"]
#			x2=x2/events["up"]
#			sigma = sqrt(x2 - x1*x1)
#			if(events["up"]>1) {
#				std_err = sigma/sqrt(events["up"] - 1)
#			} else {
#				std_err = 0
#			}
#			printf ("%s%s%s\n","Outage occurs every ",normalize_time(total_state_duration["up"]/events["up"])," on average.")
#		}
		print "Number of points = " events["up"]
#		print "Mean = " x1
#		print "Standard Deviation = " sigma
#		print "Standard Error = " std_err
	}

}
