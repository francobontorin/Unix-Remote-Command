#!/bin/ksh
################################################################################
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
# 	Create a file called Servers.List in the same directory as the script and fill
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
#	Ver 1.0.1 - Created by Franco Bontorin / Unix Technical Services 
################################################################################


##########################
# VARIABLE DECLARATION   #
##########################

HOSTS_LIST=Servers.list
USER=$1
LOG_FILE=/tmp/UTS-RemoteCommand_$1_$(date +'%d.%b.%Y-%H.%M%p').output
export OLD_IFS=$IFS
export IFS='
'

#############
# FUNCTIONS
#############

		
	function progressBar {
		
		# Creates a Progress Bar
		
		i=1
		echo ""
		until [ $i -eq 4 ]
		do
			printf "========"
			i=`expr $i + 1`
			sleep 1
		done
		printf " [ $1 ] \n"
		echo ""

	}

	
	function printLog {
	
		# Send the input to the screen an log file
		
		printf "$@" 2>&1 | tee -a $LOG_FILE
		return 0
	}

	
	function checkEnv {
	
		# Verify if the pre requisites are OK
		
		if [[ ! -s $HOSTS_LIST ]]
		then
			printf "$(tput bold)ERROR: Servers.list file not found or null$(tput sgr0)\n\n"
			return 1
		fi
		
		if [[ -z $USER ]]
		then
			printf "$(tput bold)ERROR: User id must be specified as an argument$(tput sgr0)\n\n"
			return 1
		fi
	}
	
	
	function getCommands {

		# Read and prepare the commands inputed
		printf "Command(s) to be remoted executed (Separated by semicolon ';')\n"
		printf "Enter Command(s): "
		read COMMANDS
		sleep 1
		while [[ $(echo "$COMMANDS" | tail -2c) != ";" || -z "$COMMANDS" ]]
		do
			printf "Command(s) cannot be null and must be separated by a semicolon ';'\n"
			printf "Enter Command(s): "
			read COMMANDS
			sleep 1
		done

		echo $COMMANDS | perl -pe 's/;/\n/g' > /tmp/UTS_Remote_Commands.temp
		perl -e 's/^\s+//' -p -i /tmp/UTS_Remote_Commands.temp
		sleep 1
		
		# Removing Control Charaters
		col -b < /tmp/UTS_Remote_Commands.temp > /tmp/UTS_Remote_Commands.temp2
		mv /tmp/UTS_Remote_Commands.temp2 /tmp/UTS_Remote_Commands.temp

	}

	
	function verifyCommands {
	
		# Waiting for users confirmation
		printf "\n\nThese commands will be executed in all the following servers: \n"
		printf "----------------------------------------------------------------\n"
		cat /tmp/UTS_Remote_Commands.temp
		printf "\nServers: \n"
		printf "---------------\n"
		cat $HOSTS_LIST
		printf "$(tput bold)\nPress [Enter] key to continue...$(tput sgr0)\n"
		read enterKey
			
	}

	
	function prepareEnv {

		# Preparing the configuration files 
		for commds in $(cat /tmp/UTS_Remote_Commands.temp)
		do
			cat /tmp/UTS_Remote_Commands.temp | sed "s,$commds,printf \"\\\n\-\-\-\-\-\-\-\-\-\-\-\\\n$commds\\\n\-\-\-\-\-\-\-\-\-\-\-\\\n\\\n\"\n$commds," > /tmp/UTS_Remote_Commands.temp2
			mv /tmp/UTS_Remote_Commands.temp2 /tmp/UTS_Remote_Commands.temp
		done
		
	}

	
	function executeCommands {
	
		# Executing commands remotely
		printf "\nExecuting remote command(s)\n"
		printf "----------------------------------------------------------------\n"
		for servers in $(cat $HOSTS_LIST)
		do
			printLog "\n\n#########\n"
			printLog "$servers\n"
			printLog "#########\n"
			ssh -p 2222 -q $USER@$servers 'ksh' < /tmp/UTS_Remote_Commands.temp >> $LOG_FILE 2>&1
			if [ $? -ne 255 ]
			then
				progressBar Done
			else
				printLog "$(tput bold)ERROR: Unable to connect on Server $servers $(tput sgr0)\n\n"
			fi	
		done
		
		rm -f /tmp/UTS_Remote_Commands.temp
		
		printLog "\n----------------------------------------------------------------------\n"
		printLog "$(tput bold)Output File:$(tput sgr0) $LOG_FILE \n"
		printLog "----------------------------------------------------------------------\n\n\n"
		
	}
	
	
##########
#  MAIN  #
##########


		clear
		printLog "\n\n================================================================\n"
		printLog "\tUNIX TECHNICAL SERVICES - REMOTE COMMAND\t\n"
		printLog "================================================================\n"
		printLog "Created by: $USER\t DATE: $(date "+%a %d %B %Y - %r")\n"
		printLog "================================================================\n\n"

		checkEnv
		[ $? -ne 0 ] && exit 1
		
		getCommands
		[ $? -ne 0 ] && exit 1		

		verifyCommands
		[ $? -ne 0 ] && exit 1
		
		prepareEnv
		[ $? -ne 0 ] && exit 1
		
		executeCommands
		[ $? -ne 0 ] && exit 1

IFS=$OLD_IFS		
exit 0
