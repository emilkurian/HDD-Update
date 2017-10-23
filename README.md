# HDD-Update
HDD-Update project

This script is designed to update Hard Drive FW for any drive in a server that needs to be updated.

Options ->   [--all] [--drive] [--firmware] [--help] [--model]

where: 
--all|-a        Will update all drives (cannot use with -f/-m/-d)
--drive|-d      Will update a specific drive (/dev/sg*)
--firmware|-f   Will update to a specific FW revision
--help|-h       Script usage information
--model|-m      Will update a specific drive model
Usage Examples:

HDDupdate.sh -m 'Drive Model' -f 'Drive FW' 
-Updates specific Drive Model to specific FW"

HDDupdate.sh -d 'Drive Location'
-Updates specific Drive to latest FW

HDDupdate.sh -a
-Updates all drives in the system with latest FW

