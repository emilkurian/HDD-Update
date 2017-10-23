#!/bin/bash

##### Constants

DRIVEFWPATH="$(pwd)"
FILEPATH="$(pwd)"

##### Functions

helper(){
echo "Options ->   [--all] [--drive] [--firmware] [--help] [--model]"
echo "" 
echo "where: "
echo "   --all|-a        Will update all Drives (cannot use with -f/-m/-d)
   --drive|-d      Will update a specific drive (/dev/sg*)
   --firmware|-f   Will update to a specific FW revision
   --help|-h       Script usage information
   --model|-m      Will update a specific drive model"
echo "Usage Examples:"
echo ""
echo "HDDupdate.sh -m 'Drive Model' -f 'Drive FW' "
echo "    -Updates specific Drive Model to specific FW"
echo ""
echo "HDDupdate.sh -d 'Drive Location'"
echo "    -Updates specific Drive to latest FW"
echo ""
echo "HDDupdate.sh -a"
echo "    -Updates all drives in the system with latest FW"
echo ""
echo "This script is designed to update any HDD in a system, provided that the drive"
echo "FW is available to the system"
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
		echo "$f1 $f2 $f3 current" >> report.txt
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
	drive_sort
	drive_update
	exit 0
fi
if [ "${SPECIFICMODEL}" = "YES" ]; then
	update_model
	drive_sort
	drive_update
	exit 0
fi
if [ "${UPDATEALL}" = "YES" ]; then
	update_all
	drive_sort
	drive_update
	exit 0
fi
if [ "${OPENHELP}" = "YES" ]; then
	helper
	exit 0
fi
if [ "${NOARGUMENT}" = "YES" ]; then
	helper
	exit 0
fi


helper

echo "Task completed"



