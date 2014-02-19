/Pva.FlowkeySpace.Enforce = / {
	bdb_Pva_FlowkeySpace_Enforce=$3
	if (bdb_Pva_FlowkeySpace_Enforce=="enable") {
		print "This unit is impacted by the issues described in SOL7834."
	}
}
	

/\(  b profile fastL4 show  \)/ {
	getline
	getline
	do {
		if ($0 ~ / virtual servers:/) {
			#print "_"$0"_"
			for (FIELD=4;FIELD<=NF;FIELD++) {
				VIRTUALS_FL4[$FIELD]=$FIELD
				VIRTUALS_FL4_COUNT++
				#printf "Added VS# "VIRTUALS_FL4_COUNT"\t"$FIELD"\n"
			}
		}
		getline
	} while ( $0 != "*--*--*--*--*--*--*--*--*" )
}



/\(  b virtual show  \)/ {
	getline
	getline
	do {
		if ($0~/> VIRTUAL /) {
			virtual=$3
			VIRTUALS_COUNT++
		}

		if ($0~/ POOL MEMBER /) {
			poolmember=$4
			if (virtual in VIRTUALS_FL4) {
				virtuals[poolmember]=virtuals[poolmember]((virtuals[poolmember]=="")?"":" ")virtual
				virtual_count[poolmember]++
			}
		}
		
		getline
		} while ( $0 != "*--*--*--*--*--*--*--*--*" )
}

END {
	printf "There are "VIRTUALS_FL4_COUNT" Performance L4 Virtual Servers out of a total of "VIRTUALS_COUNT" Virtual Servers.\n\n"
	for (poolmember in virtuals) {
		if (virtual_count[poolmember] > 1 ) {
			printf "\nPool Member "poolmember" is shared by these Performance L4 Virtual Servers.\n"
			printf "\t"virtuals[poolmember]"\n"
			if (VIRTUALS_IMPACTED_COUNT_POOL=split(virtuals[poolmember],VIRTUALS_IMPACTED_POOL," ")) {
				for (VSNUM=1;VSNUM<=VIRTUALS_IMPACTED_COUNT_POOL;VSNUM++) {
					if (!(VIRTUALS_IMPACTED_POOL[VSNUM] in VIRTUALS_IMPACTED)) {
						VIRTUALS_IMPACTED_COUNT_TOTAL++
						VIRTUALS_IMPACTED[VIRTUALS_IMPACTED_COUNT_TOTAL]=VIRTUALS_IMPACTED_POOL[VSNUM]
					}
				}
			}
		}
	}
	printf "\n\nThese are the "VIRTUALS_IMPACTED_COUNT_TOTAL" Performance L4 Virtual Servers impacted by the issues described in SOL7834.\n"
	for (VS in VIRTUALS_IMPACTED) {
		printf "\t"VIRTUALS_IMPACTED[VS]"\n"
	}
}