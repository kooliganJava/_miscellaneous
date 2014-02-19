BEGIN {
	section_num=1
	section_title="header"
}

(FNR==1) {
	output_dir=sprintf("%s_sections\\",FILENAME)
	system ("if not exist "output_dir" mkdir "output_dir)
	#print "output_dir="output_dir
}	
// {
	output_file=sprintf("%s%s.tech-out",output_dir,section_title)
	do {
		#printf "%%s %s\n",section_num,section_title,$0
		
		#print "Output File = "output_file
		#print $0" > "outputfile
		print > output_file
		if (!(getline)) break
	} while ($0!~/^\*--\*/)
	getline
	#print "NEW SEC "$0
	gsub(/^[\ |\(]+|[\ \)]+$/,"")
	gsub(/[\-\/\\\* ]/,"_")
	section_title=$0
	section_num++
	getline
	#print "NEW SEC "$0
	getline
}
	
		