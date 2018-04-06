#!/bin/bash 

#This script uses Linux's ent command to compute entropy for forensics analyses

if [ "$1" == "--help" ]
then
	echo "Usage: cent.sh [--filter value] input_dir output_fileName"
else 
	
	if [ "$#" -eq 4 ]
	then 
		echo "Start parsing dir: $3"
		lines=$(find $3 -type f)
		for line in $lines
		do
			entropy=$(ent $line)
			if [ "$1" == "--filter" ]
			then
				firstLine=`echo "$entropy" | head -1`
				value=$(echo "$firstLine" | egrep -e '[0-8]{1}\.[0-9]+' -o)
				good=`echo $value'>'$2 | bc -l` 
				if [ "$good" == "1" ]
				then
					echo "$value $line" >> "$4"
				fi
			else
				echo "Illegal argument! Use --help to see options."
			fi
		done
	elif [ $# -eq 2 ]
	then
		echo "Start parsing dir: $1"
		lines=$(find $1 -type f)
		for line in $lines
		do
			entropy=$(ent $line)
			firstLine=`echo "$entropy" | head -1`       
			value=$(echo "$firstLine" | egrep -e '[0-8]{1}\.[0-9]+' -o)
			echo "$value $line" >> "$2"
		done
	else 
		echo "Illegal arguments! Usage: cent.sh [--filter value] input_dir output_fileName" 
	fi
fi
