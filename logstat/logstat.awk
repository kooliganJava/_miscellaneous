BEGIN {
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
	#print "stamp="mktime("2008 "month" "date" "hh" "mm" "ss)
	#print "mktime is "mktime("2008 "month" "date" "hh" "mm" "ss)
	return mktime("2008 "month" "date" "hh" "mm" "ss)
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

#/Sep 15 06:45:48 bgep01 mcpd[1876]: 01070638:5: Pool member 192.168.226.65:443 monitor status down./ {
/mcpd.+Pool member.+monitor status [ud]|gtmd.+ Monitor instance / {
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
	if (match($0,/mcpd.+Pool member.+monitor status [ud]/)) {
		instance_key=$7" "$8" "$9
	} else {
			if (match($0,/gtmd.+ Monitor instance /)) {
				instance_key=$9" "$10
			}
		}
	
	if (!(instance_key in instance)) {
		instance[instance_key]++
		#print "INSTANCE="instance_key
	}
	#printf "%i %s\n",time,$0
}
	
END {
	entries=asort(log_time)
	print "ENTRIES="entries
	#for (i=1;i<=entries;i++) {
	#	printf "ENTRY #%i %i,%s\n",i,log_time[i],log_entry[log_time[i]]
	#	#tempstr=log_entry[log_time[i]]
	#	#delete log_entry[log_time[i]]
	#	#log_time[i]=substr(log_time[i],1,length(log_time[i])-2)
	#	#log_entry[log_time[i]]=tempstr
	#	#printf "NEW %u,%s\n",log_time[i],log_entry[log_time[i]]
	#}
	
	for (this_instance in instance) {
		printf "\nINSTANCE: "this_instance"\n"
		up_events=0
		down_events=0
		last_up=0
		last_down=0
		up_duration=0
		down_duration=0
		total_up_duration=0
		total_down_duration=0
		x1=0
		x2=0
		instance_entry=0
		for (i=1;i<=entries;i++) {
			time_str=log_time[i]
			this_entry=log_entry[time_str]
			time=strtonum(substr(time_str,1,length(time_str)-2))
			

			#print "this_entry="this_entry
			#print "this_instance="this_instance
			if (this_entry !~ this_instance) {continue}
			
#			if (++instance_entry==1) {
#
#			}
			if (this_entry~/DOWN from|monitor status down/) {
				if (last_status=="up") {
					up_duration=(time-last_up)*(!((time-last_up)>=82900))
					up_duration=int(up_duration/30)*30
					#up_duration=(time-last_up)*(last_up!=0)
					total_up_duration+=up_duration
				}
				printf "%i %10i%10i %s\n",time,up_duration,down_duration,this_entry
				#printf "%20s%20s%20s%20s\n","Time UP","Time DOWN","Total Time UP","Total Time DOWN"
				#printf "%20i%20i%20i%20i\n",up_duration,down_duration,total_up_duration,total_down_duration
				up_duration=0
				down_events++
				last_down=time
				last_status="down"
  	
			}
			
			if (this_entry~/UP from|monitor status up/) {
				if (last_status=="down") {
					down_duration=(time-last_down)*(!((time-last_down)>=82900))
					down_duration=int(down_duration/30)*30
					#down_duration=(time-last_down)*(last_down!=0)
					total_down_duration+=down_duration
				}
				printf "%i %10i%10i %s\n",time,up_duration,down_duration,this_entry
				#printf "%20s%20s%20s%20s\n","Time UP","Time DOWN","Total Time UP","Total Time DOWN"
				#printf "%20i%20i%20i%20i\n",up_duration,down_duration,total_up_duration,total_down_duration
				down_duration=0
				up_events++
				last_up=time
				last_status="up"
			}
			
			x1+=total_up_duration
			x2+=total_up_duration*total_up_duration
			
		}
		print "Ups:       "up_events
		print "Downs:     "down_events
		print "Time Up  : "normalize_time(total_up_duration)
		print "Time Down: "normalize_time(total_down_duration)
		
		#if ((up_events+down_events)>1) {
		#	x1=x1/up_events
		#	x2=x2/up_events
		#	sigma = sqrt(x2 - x1*x1)
		#	std_err = sigma/sqrt(up_events - 1)
		#	printf ("%s%d%s\n","Outage occurs every ",total_up_duration/up_events," seconds.")
		#}
  	#print "Number of points = " up_events
  	#print "Mean = " x1
  	#print "Standard Deviation = " sigma
  	#print "Standard Error = " std_err
	}

}
