(FNR==1) {
	THIS_HOSTNAME=$0
}

function chomp(STRING) {
	sub (/^ +/,"",STRING)
	sub (/ +$/,"",STRING)
	return STRING
}

function compress_string(STRING) {
	gsub(" +","_",STRING)
	return STRING
}

/^\(  b .+stats.+\)/ {
	#printf "\n\nNew level 1 stats.\n"
	NUMVARLEVELS=0
	CURVARLEVEL=0
	delete CHARPOS
	delete VARPART
	delete VARLEVEL
	getline
	do  {
		getline
		match($0,/(^[^(]+)\(*/,PART)
		LEFTPART=PART[1]
		#print "LEFTPART "LEFTPART
		LLEN=length(LEFTPART)
		for (CHAR_POSITION=1;(CHAR_POSITION<=LLEN);CHAR_POSITION++) {
			#print substr(LEFTPART,CHAR_POSITION,(LLEN-CHAR_POSITION))
			#print LLEN,CHAR_POSITION,match(substr(LEFTPART,CHAR_POSITION,(LLEN-CHAR_POSITION)),/^([A-Za-z][A-Za-z0-9\-\_ ]+).+/,PART)
			#print "matching on __"substr(LEFTPART,CHAR_POSITION,(LLEN-CHAR_POSITION))"__"
			if (match(substr(LEFTPART,CHAR_POSITION,(LLEN-CHAR_POSITION)),/^([A-Za-z][A-Za-z0-9\-\_\ ]+[A-Za-z0-9]).*/,PART)) {
				#print "WHAT MATCHED __"PART[1]"__"
				#PART[1]=chomp(PART[1])
				#print "WHAT WERE USING __"PART[1]"__"
				MATCHLEN=length(PART[1])
				
				

				if (PART[1]=="") {print "NULL STRING" ; continue}

				if (!(CHAR_POSITION in VARLEVEL)) {
					NUMVARLEVELS+=1
					CURVARLEVEL+=1
					#print "CHARPOS="CHAR_POSITION" NUMVARLEVELS="NUMVARLEVELS" CURVARLEVEL="CURVARLEVEL
					CHARPOS[CURVARLEVEL]=CHAR_POSITION
					VARPART[CHARPOS[CURVARLEVEL]]=compress_string(chomp(PART[1]))
					VARLEVEL[CHARPOS[CURVARLEVEL]]=CURVARLEVEL
					#for (ii=1;ii<=NUMVARLEVELS;ii++) {	printf "%s%s",	VARPART[CHARPOS[ii]],((ii==NUMVARLEVELS)?"\n":"\.")}
					#print "___"VARLEVEL[CHARPOS[CHAR_POSITION]]" "CHAR_POSITION" "VARPART[CHARPOS[CHAR_POSITION]]
					CHAR_POSITION+=MATCHLEN
				} else {
					#print "else CHARPOS="CHAR_POSITION" NUMVARLEVELS="NUMVARLEVELS" CURVARLEVEL="CURVARLEVEL
					#print "VARPART[]="CHARPOS[CHAR_POSITION]"]="PART[1]
					#print "VARLEVEL["CHARPOS[CHAR_POSITION]"]="CHAR_POSITION
					# Wipe out everything at this higher VARLEVELs
					#print "CURVARLEVEL="CURVARLEVEL
					VARPART[CHAR_POSITION]=compress_string(chomp(PART[1]))
					CURVARLEVEL=VARLEVEL[CHAR_POSITION]
					CHARPOS[CURVARLEVEL]=CHAR_POSITION
					VARLEVEL[CHAR_POSITION]=CURVARLEVEL
					for (LEVEL=CURVARLEVEL+1;LEVEL<=NUMVARLEVELS;++LEVEL) {
						#print "DELETING on LEVEL "LEVEL
						delete VARLEVEL[CHARPOS[LEVEL]]
						delete VARPART[CHARPOS[LEVEL]]
						delete CHARPOS[LEVEL]
					}
					
					
					
					#for (ii=1;ii<=NUMVARLEVELS;ii++) {	printf "%s%s",	VARPART[CHARPOS[ii]],((ii==NUMVARLEVELS)?"\n":"\.")}
					#print "___"VARLEVEL[CHARPOS[CHAR_POSITION]]" "CHAR_POSITION" "VARPART[CHARPOS[CHAR_POSITION]]
					CHAR_POSITION+=MATCHLEN
				}

			}
		}

			VARSTRING=""
			for (LEVEL=0;LEVEL<=CURVARLEVEL;LEVEL++) {
				VARSTRING=VARSTRING ((LEVEL)?VARPART[CHARPOS[LEVEL]]((LEVEL==CURVARLEVEL)?"":".")	:"")
				}
				#print "VARSTRING=="VARSTRING
				
		

		# Handler for this .. "|   |     server (pkts,bits) in = (130.8G, 314.0T), out = (130.2G, 913.6T)"
		if (match($0,/(\([^,]+,[^\)]+\)) ([a-zA-Z]+) = (\([^,]+,[^\)]+\)), ([a-zA-Z]+) = (\([^,]+,[^\)]+\))/,PART_ARRAY1)) {
			#print "__SPECIAL__CASE__"
			#for (THISPART=1;THISPART<=5;THISPART++) {
			#	print THISPART" "PART_ARRAY1[THISPART]
			#}
			for (ELEMENT1=1;ELEMENT1<=5;ELEMENT1++) {
				#print "ELEMENT1="ELEMENT1
				gsub(", +",",",PART_ARRAY1[ELEMENT1])
				PARTS=split(PART_ARRAY1[ELEMENT1],PART_ARRAY2,/[,\(\) ]/)
				for (ELEMENT2=1;ELEMENT2<=PARTS;ELEMENT2++) {
					PART_ARRAY3[ELEMENT1,ELEMENT2]=PART_ARRAY2[ELEMENT2]
					#print ELEMENT1,ELEMENT2,PART_ARRAY2[ELEMENT2]
				}
				ELEMENT1++
			}
			printf THIS_HOSTNAME"::"VARSTRING"."PART_ARRAY3[1,2]"."PART_ARRAY1[2]"="PART_ARRAY3[3,2]"\n"
			printf THIS_HOSTNAME"::"VARSTRING"."PART_ARRAY3[1,2]"."PART_ARRAY1[4]"="PART_ARRAY3[5,2]"\n"
			printf THIS_HOSTNAME"::"VARSTRING"."PART_ARRAY3[1,3]"."PART_ARRAY1[2]"="PART_ARRAY3[3,3]"\n"
			printf THIS_HOSTNAME"::"VARSTRING"."PART_ARRAY3[1,3]"."PART_ARRAY1[4]"="PART_ARRAY3[5,3]"\n"	
			#printf VARSTRING"."
			
		} else if ($0~/\([^\)]+\)\ +=\ +\([^\)]+\)/) {
			#print "A-V Pairs here"
			match ($0,/\([^\)]+\)\ +=\ +\([^\)]+\)/)
			avps=substr($0,RSTART,RLENGTH)
			#print avps
			split(avps,PART,"=")
			#print "LHS="PART[1]
			#print "RHS="PART[2]
			
			gsub(/[\)\( ]/,"",PART[1])
			gsub(/[\)\( ]/,"",PART[2])
			#print "rhs with only numerics and commas "PART[1]
			#print "lhs with only numerics and commas "PART[2]
			lhs=PART[1]
			rhs=PART[2]
			#print "LHS="lhs
			#print "RHS="rhs
			l_elements=split(lhs,LHS_ELEMENT,/[, \(]/)
			r_elements=split(rhs,RHS_ELEMENT,/[, \(]/)
			
			for (i=1;i<=l_elements;i++) {
				printf THIS_HOSTNAME"::"VARSTRING"."LHS_ELEMENT[i]"="RHS_ELEMENT[i]"\n"
			}
		}
	} while ($0 !~ /\*--\*--\*--\*--\*--\*--\*--\*--\*/)



}
