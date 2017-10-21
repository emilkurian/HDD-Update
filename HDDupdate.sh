#!/bin/bash

echo 'HDD Update Script'
##### Constants

DRIVEFWPATH="$(pwd)"
FILEPATH="$(pwd)"

##### Functions

helper(){
echo "this is where the help description goes"
exit 0
}

update_all(){
lsscsi -g | grep "disk" > disk.txt
awk '{print $4" "$5"\t"$6"\t"$7"\t"$8}' disk.txt > data.txt
column -t data.txt > dataparse.txt
echo "pop"
}

update_model(){
lsscsi -g | grep "${DRIVEMODEL}" > disk.txt
awk '{print $4" "$5"\t"$6"\t"$7"\t"$8}' disk.txt > data.txt
column -t data.txt > dataparse.txt
echo "push"
}

update_drive(){
lsscsi -g | grep "${SPECIFICDRIVE}" > disk.txt
awk '{print $4" "$5"\t"$6"\t"$7"\t"$8}' disk.txt > data.txt
column -t data.txt > dataparse.txt
echo "fizz"
}

drive_sort(){
file="${FILEPATH}"/"dataparse.txt"
while IFS="  " read -r f1 f2 f3 f4 f5  
do 
	echo "$f2" "$f3" "$f5" | grep "/dev/sg" >> output.txt
    
done <"$file"


file="${FILEPATH}"/"dataparse.txt"
while IFS="  " read -r f1 f2 f3 f4 f5  
do 
	echo "$f1" "$f2" "$f4" | grep "/dev/sg" >> output.txt
    
done <"$file"
column -t output.txt > updater.txt

rm output.txt
rm dataparse.txt
rm data.txt
rm disk.txt
}


drive_update(){
file="${FILEPATH}"/"updater.txt"
while IFS=" " read -r f1 f2 f3  
do 
	
	cat fwlist.txt | grep "$f1" > fwtoload.txt
	if [ "${FIRMWARE}" != "" ]; then 
	COMPARE="${FIRMWARE}"
	else
	COMPARE="$(awk '{print $2 }' fwtoload.txt)"
	fi
	if [ "${COMPARE}" != "$f2" ]; then
		OUTPUT="$(awk '{print $3 }' fwtoload.txt)"
		FILESIZE="$(ls -l | grep "${OUTPUT}" | awk '{print $5}')"
		sg_write_buffer -v --in="${DRIVEFWPATH}"/"${OUTPUT}" --length="${FILESIZE}" --mode=5 "$f3" 
		STATUS="$(echo $?)"
		if [ "${STATUS}" != "0" ]; then
			sg_write_buffer -v --in="${DRIVEFWPATH}"/"${OUTPUT}" --length="${FILESIZE}" --mode=7 --offset=0 "$f3"
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
rm fwtoload.txt
rm updater.txt
}


##### Main 

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -a|--all)
    UPDATEALL="YES"
    shift
    ;;    
    -m|--model)
    DRIVEMODEL="$2"
    SPECIFICMODEL="YES"
    shift # past argument
    shift # past value
    ;;
    -f|--firmware)
    FIRMWARE="$2"
    shift # past argument
    shift # past value
    ;;
    -d|--drive)
    DRIVELOCATION="$2"
    SPECIFICDRIVE="YES"
    shift # past argument
    shift
    ;;
    -h|--help)
    OPENHELP="YES"
    shift
    ;;
    *)    # unknown option
    NOARGUMENT="YES"
    shift # past argument
    ;;
    
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if [ "${SPECIFICDRIVE}" = "YES" ]; then
	update_drive
	echo " updating drive "
	drive_sort
	drive_update
fi
if [ "${SPECIFICMODEL}" = "YES" ]; then
	update_model
	echo " updating drive model "
	drive_sort
	drive_update
fi
if [ "${UPDATEALL}" = "YES" ]; then
	update_all
	echo " updating all drives"
	drive_sort
	drive_update
fi
if [ "${OPENHELP}" = "YES" ]; then
	helper

fi
if [ "${NOARGUMENT}" = "YES" ]; then
	helper
fi


helper

echo "Task completed"



