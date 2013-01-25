# Documentation
# ==============================================================================
# This script is used to execute remote commands on different servers generating
# a report
# ==============================================================================
# Tested/Supported Platforms (Where this script is executed)
# ==============================================================================
# AIX 6.1
# SLES 5.6
# SLES 5.7
# ==============================================================================
# Usage
# ==============================================================================
# - Filling out the servers to remotely execute the commands:
#   Create a file called Servers.List in the same directory as the script and fill
#   out the server names (one by line)
#	Example: # cat Servers.list
#	eis0stl0
#	eis0stl1
#	eis0stl2
#
# - Start the script execution using your id as an argument
#   ./Remote_Comand_v1.0.1.sh $userid
#
# - Inputting commands
#	Commands must be separated by a semicolon ';' more than one can be executed,
#	including spaces an simple regular expressions.
#	On AIX backspace can generates control characters, use Ctrl + H instead.
#	Example:
#	Enter Command(s):uname -a; ls /var/tmp;ifconfig eth0 | head -1 | cut -d: -f3;
#	
# - Verifying Output
#	This script automatically generates a report of all the commands executed
#	It is stored into /tmp as /tmp/UTS-RemoteCommand_$user_$date.output
# ==============================================================================
# Version Control
# ==============================================================================
#	Ver 1.0.1 - Created by Franco Bontorin
