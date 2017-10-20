#!/bin/bash

echo 'HDD Update Script'


rm report.txt

lsscsi -g | grep "disk" > disk.txt
awk '{print $4" "$5"\t"$6"\t"$7"\t"$8}' disk.txt > data.txt
column -t data.txt > dataparse.txt

file="/home/joshua/Desktop/HDDupdate/dataparse.txt"
while IFS="  " read -r f1 f2 f3 f4 f5  
do 
	echo "$f2" "$f3" "$f5" | grep "/dev/sg" >> output.txt
    
done <"$file"


file="/home/joshua/Desktop/HDDupdate/dataparse.txt"
while IFS="  " read -r f1 f2 f3 f4 f5  
do 
	echo "$f1" "$f2" "$f4" | grep "/dev/sg" >> output.txt
    
done <"$file"
column -t output.txt > updater.txt

file="/home/joshua/Desktop/HDDupdate/updater.txt"
while IFS=" " read -r f1 f2 f3  
do 
	
	cat fwlist.txt | grep "$f1" > fwtoload.txt
	COMPARE="$(awk '{print $2 }' fwtoload.txt)"
	if [ "${COMPARE}" != "$f2" ]; then
		OUTPUT="$(awk '{print $3 }' fwtoload.txt)"
		FILESIZE="$(ls -l | grep "${OUTPUT}" | awk '{print $5}')"
		FILEPATH="$(pwd)"
		sg_write_buffer -v --in="${FILEPATH}"/"${OUTPUT}" --length="${FILESIZE}" --mode=5 "$f3" 
		STATUS="$(echo $?)"
		if [ "${STATUS}" != "0" ]; then
			sg_write_buffer -v --in="${FILEPATH}"/"${OUTPUT}" --length="${FILESIZE}" --mode=7 --offset=0 "$f3"
			STATUS="$(echo $?)"
			if [ "${STATUS}" != "0" ]; then
				echo "$f1 $f2 $f3 FW not updated." >> report.txt
			else
				echo "$f1 $f2 $f3 updated" >> report.txt
			fi
			
		else
			sleep 10		
			echo "$f1 $f2 $f3 updated" >> report.txt

		fi
	
	else
		echo "$f1 $f2 $f3 updated." >> report.txt
	fi

done <"$file"

rm output.txt
rm dataparse.txt
rm data.txt
rm disk.txt
rm fwtoload.txt
rm updater.txt

echo "Task completed"



