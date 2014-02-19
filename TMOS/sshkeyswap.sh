#Tested on a version 4.5.14 configuration

function enum_vs(foo) {
	for (vs_n=1;vs_n<=vs_c;vs_n++) {
		print vs[vs_n]
	}
}

function va_descendants(VA_n,HOW) {
	HOW=tolower(HOW)
	#HOW is a string.  value of "all" prints all
	#Anything else only prints the root ancestor.
	delete NODE_printed
	print "Virtual Address " va[VA_n]
	for (va_ch_n=1;va_ch_n<=va_ch_c[VA_n];va_ch_n++) {
		delete NODE_printed
		if (HOW=="all") {
			printf "\t%s\n","Virtual Server "va_ch[VA_n,va_ch_n]
		}
		vs_n=vs_index[va_ch[VA_n,va_ch_n]]
		for (vs_ch_n=1;vs_ch_n<=vs_ch_c[vs_n];vs_ch_n++) {
			if (HOW=="all") {
				printf "\t\t%s\n",vs_ch[vs_n,vs_ch_n]
			}
			split(vs_ch[vs_n,vs_ch_n],ch_part," ")
			ch_type=ch_part[1]
			ch_name=ch_part[2]
			if (ch_type=="pool") {
				pool_n=pool_index[ch_name]
				if (HOW!="all") {
					delete NODE_printed
				}
				for (pool_ch_n=1;pool_ch_n<=pool_ch_c[pool_n];pool_ch_n++) {
						NODE=gensub(/:.*$/,"","g",pool_ch[pool_n,pool_ch_n])
						if (HOW=="all") {
							printf "\t\t\t\t%s\n","Member "pool_ch[pool_n,pool_ch_n]
						}
						if (!(NODE in NODE_printed)) {
							printf "\t\t\t\t\t%s\n","Node "NODE
							NODE_printed[NODE]=NODE
						}
				}
			}
			if (ch_type=="rule") {
				rule_n=rule_index[ch_name]
				for (rule_ch_n=1;rule_ch_n<=rule_ch_c[rule_n];rule_ch_n++) {
					if (HOW=="all") {
						printf "\t\t\t%s\n",rule_ch[rule_n,rule_ch_n]
					}
					split(rule_ch[rule_n,rule_ch_n],ch_part," ")
					pool_n=pool_index[ch_part[2]]
					for (pool_ch_n=1;pool_ch_n<=pool_ch_c[pool_n];pool_ch_n++) {
						NODE=gensub(/:.*$/,"","g",pool_ch[pool_n,pool_ch_n])
						if (HOW=="all") {
							printf "\t\t\t\t%s\n","Member "pool_ch[pool_n,pool_ch_n]
						}
						if (!(NODE in NODE_printed)) {
							printf "\t\t\t\t\t%s\n","Node "NODE
							NODE_printed[NODE]=NODE
						}
					}
				}
			}
		}
		printf "\n"
	}
	printf "\n"
}

function va_descendants_va(VA_n,HOW) {
	HOW=tolower(HOW)
	#HOW is a string.  value of "all" prints all
	#Anything else only prints the root ancestor.
	print "Virtual Address " va[VA_n]
	for (va_ch_n=1;va_ch_n<=va_ch_c[VA_n];va_ch_n++) {

		if (HOW=="all") {
			printf "\t%s\n","Virtual Server "va_ch[VA_n,va_ch_n]
		}
		vs_n=vs_index[va_ch[VA_n,va_ch_n]]
		for (vs_ch_n=1;vs_ch_n<=vs_ch_c[vs_n];vs_ch_n++) {
			if (HOW=="all") {
				printf "\t\t%s\n",vs_ch[vs_n,vs_ch_n]
			}
			split(vs_ch[vs_n,vs_ch_n],ch_part," ")
			ch_type=ch_part[1]
			ch_name=ch_part[2]
			if (ch_type=="pool") {
				pool_n=pool_index[ch_name]
				for (pool_ch_n=1;pool_ch_n<=pool_ch_c[pool_n];pool_ch_n++) {
						NODE=gensub(/:.*$/,"","g",pool_ch[pool_n,pool_ch_n])
						if (HOW=="all") {
							printf "\t\t\t\t%s\n","Member "pool_ch[pool_n,pool_ch_n]
						}
						if (!(NODE in NODE_printed)) {
							printf "\t\t\t\t\t%s\n","Node "NODE
							node_ancestors(NODE,"all")
							NODE_printed[NODE]=NODE
						}
				}
			}
			if (ch_type=="rule") {
				rule_n=rule_index[ch_name]
				for (rule_ch_n=1;rule_ch_n<=rule_ch_c[rule_n];rule_ch_n++) {
					if (HOW=="all") {
						printf "\t\t\t%s\n",rule_ch[rule_n,rule_ch_n]
					}
					split(rule_ch[rule_n,rule_ch_n],ch_part," ")
					pool_n=pool_index[ch_part[2]]
					for (pool_ch_n=1;pool_ch_n<=pool_ch_c[pool_n];pool_ch_n++) {
						NODE=gensub(/:.*$/,"","g",pool_ch[pool_n,pool_ch_n])
						if (HOW=="all") {
							printf "\t\t\t\t%s\n","Member "pool_ch[pool_n,pool_ch_n]
						}
						if (!(NODE in NODE_printed)) {
							printf "\t\t\t\t\t%s\n","Node "NODE
							node_ancestors(NODE,"all")
							NODE_printed[NODE]=NODE
						}
					}
				}
			}
		}
		printf "\n"
	}
	printf "\n"
}


function node_ancestors(NODE,HOW) {
	HOW=tolower(HOW)
	#HOW is a string.  value of "all" prints all ancestors.
	#Anything else only prints the root ancestor.
	print "Node "NODE
	#Members that are parents of this node.
	memberprint=0
	for (pool_n=1;pool_n<=pool_c;pool_n++) {
		delete VA_printed
		for (pool_ch_n=1;pool_ch_n<=pool_ch_c[pool_n];pool_ch_n++) {
			if (pool_ch[pool_n,pool_ch_n]~NODE":") {
				if (HOW=="all") {
					if (!(memberprint)) {
						printf "\t%s%s\n","Member ",pool_ch[pool_n,pool_ch_n]
						memberprint=1
					}
				}
				if (HOW=="all") {
					printf "\t\t%s%s\n","Pool ",pool[pool_n]
				}

				# Rules that are referenced by this pool.
				for (rule_n=1;rule_n<=rule_c;rule_n++) {
					for (rule_ch_n=1;rule_ch_n<=rule_ch_c[rule_n];rule_ch_n++) {
						if (rule_ch[rule_n,rule_ch_n]~pool[pool_n]) {
							if (HOW=="all") {
								printf "\t\t\t%s%s\n","Rule ",rule[rule_n]
							}

							#Virtual Servers that are referenced by this rule.
							for (vs_n=1;vs_n<=vs_c;vs_n++) {
								for (vs_ch_n=1;vs_ch_n<=vs_ch_c[vs_n];vs_ch_n++) {
									split(vs_ch[vs_n,vs_ch_n],ch_part," ")
									ch_type=ch_part[1]
									ch_name=ch_part[2]
									if (ch_type=="rule") {
										#print "Checking "vs_ch[vs_n,vs_ch_n]" against rule "rule[rule_n]
										if (vs_ch[vs_n,vs_ch_n]~"rule "rule[rule_n]) {
												if (HOW=="all") {
													printf "\t\t\t\t%s%s\n","Virtual Server ",vs[vs_n]
												}
												split(vs[vs_n],element,":")
												VA=element[1]
												if (!(VA in VA_printed)) {
													VA_printed[VA]=VA
													printf "\t\t\t\t\t%s%s\n","Virtual Address ",VA
												}
										}
									}
								}
							}
						}
					}
				}

				#Virtual servers that are referenced by this pool.
				for (vs_n=1;vs_n<=vs_c;vs_n++) {
					for (vs_ch_n=1;vs_ch_n<=vs_ch_c[vs_n];vs_ch_n++) {
						#print "Checking "vs_ch[vs_n,vs_ch_n]" against pool "pool[pool_n]
						if (vs_ch[vs_n,vs_ch_n]~"pool "pool[pool_n]) {
							if (HOW=="all") {
								printf "\t\t\t%s%s\n","Virtual Server ",vs[vs_n]
								split(vs[vs_n],element,":")
								VA=element[1]
								if (!(VA in VA_printed)) {
									VA_printed[VA]=VA
									printf "\t\t\t\t\t%s%s\n","Virtual Address ",VA
								}
							}
						}
					}
				}
			}
		}
	}
	printf "\n"
}

#####################################LINE PROCESSING SECTION ########################################

/^pool .+\{$/ {
	pool[++pool_c]=$2
	pool_index[$2]=pool_c
	print "Found Pool #"pool_c", "pool[pool_c]
	do {
		getline
		if (match($0,/member ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9a-zA-Z]+)/,element)) {

			#Add a new member
			pool_ch[pool_c,++pool_ch_c[pool_c]]=element[1]

			#Add a new node.
			split (pool_ch[pool_c,pool_ch_c[pool_c]],ch_part,":")
			if (!(ch_part[1] in rawnode)) {
				rawnode[ch_part[1]]=ch_part[1]
				node[++node_c]=ch_part[1]

				#Add member to this node as its child.
				node_ch[node_n,++node_ch_c[node_c]]=pool_ch[pool_c,pool_ch_c[pool_c]]
			}
		}
	} while ($0 !~ "}$")
	nextline
}

/^rule .+\{$/ {
	rule[++rule_c]=$2
	rule_index[$2]=rule_c
	print "Found Rule #"rule_c", "rule[rule_c]
	do {
		getline
		if (match($0,/pool ([a-zA-Z0-0\.\-\_]+)/)) {

			#Add this pool as child of this rule.
			rule_ch[rule_c,++rule_ch_c[rule_c]]=substr($0,RSTART,RLENGTH)
			printf "\t%s\n","Rule "rule[rule_c]" has "rule_ch[rule_c,rule_ch_c[rule_c]]" as a child."
		}

	} while ($0 !~ "}$")
	nextline
}

/^virtual .+\{$/ {
	vs[++vs_c]=$2
	vs_index[$2]=vs_c
	print "Found Virtual Server #"vs_c," "vs[vs_c]

	#Process the rules and pools that are children of this virtual.
	do {
		getline
		if (match($0,/[pr][ou][ol][le] [a-zA-Z0-0\.\-\_]+/)) {
			vs_ch[vs_c,++vs_ch_c[vs_c]]=substr($0,RSTART,RLENGTH)
			printf "\t%s\n","Found child "substr($0,RSTART,RLENGTH)
		}

	} while ($0 !~ "}$")
	nextline
}

/^proxy .+/ {
	ps[++ps_c]=$2
	print "Found Proxy Server #"ps_c", "ps[ps_c]
	do {
		getline
		if (match($0,/target virtual ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}:[0-9a-zA-Z]+)/,element)) {
			printf "\t%s\n","Proxy Target is "element[1]
			pts[ps_c]=element[1]
			split(pts[ps_c],ch_part,":")
			pta[ps_c]=ch_part[1]
		}

	} while ($0 !~ "}$")

	for (vs_n=1;vs_n<=vs_c;vs_n++) {
		if (vs[vs_n]==pts[ps_c]) {
			printf "\t%-23s%-17s%s\n","Virtual Server #"vs_n", ",vs[vs_n]," renamed to "ps[ps_c]
			delete vs_index[vs[vs_n]]
			vs[vs_n]=ps[ps_c]
			vs_index[vs[vs_n]]=vs_n

		}
	}
	nextline
}

END {
	########################################### ENDBLOCK #############################################################

#	print "############################## function test ##############################"
#	while ( (getline < enum_vs(1)) > 0) {
#		print "FOOBAR__"$0
#	}

	print "############################## CREATE VIRTUAL ADDRESSES ##############################"
	for (vs_n=1;vs_n<=vs_c;vs_n++) {
		if (match(vs[vs_n],/^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}):[0-9a-zA-Z]+/,element)) {
			VA=element[1]
			if (!(VA in va_index)) {
				va_c++
				va_index[VA]=++va_c
				va[va_c]=VA
				#print "Added Virtual Address #"va_c", "va[va_c
			}
		}
	}

	print "############################## CREATE VIRTUAL ADDRESS CHILDREN ##############################"
	for (va_n=1;va_n<=va_c;va_n++) {
		#print "Children of Virtual Address "va[va_n]" are ..."
		for (vs_n=1;vs_n<=vs_c;vs_n++) {
			if (match(vs[vs_n],va[va_n]":")) {
				va_ch[va_n,++va_ch_c[va_n]]=vs[vs_n]
				#printf "\t\t%s\n",va_ch[va_n,va_ch_c[va_n]]
			}
		}
	}

	print "############################## NODES and Ancestors ##############################"
	for (node_n=1;node_n<=node_c;node_n++) {
		node_ancestors(node[node_n],"all")
	}


	print "############################## VIRTUAL ADDRESSES and Descendants ##############################"
	for (va_n=1;va_n<=va_c;va_n++) {
		print "Showing Virtual address #"va_n" and its descendants ___-_"
		va_descendants(va_n,"all")
	}


}


