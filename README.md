Unix-Remote-Command
-

This script is used to execute remote commands on different servers generating a report

<b> Tested/Supported Platforms (Where this script is executed) <b/>

  * AIX 6.1
  * SLES 5.6
  * SLES 5.7

<b> Usage <b/>

Filling out the servers to remotely execute the commands:
Create a file called Servers.List in the same directory as the script and fill out the server names (one by line)
Example: # cat Servers.list
<br>
linux0brl1
<br>
linux0brl2
<br>
linux0brl3
<br>

- Start the script execution using your id as an argument
<br>
./Remote_Comand_v1.0.1.sh $userid

<b> Inputting commands <b/>

Commands must be separated by a semicolon ';' more than one can be executed, including spaces an simple regular expressions.
On AIX backspace can generates control characters, use Ctrl + H instead.
<br>
Example:
<br>
Enter Command(s):uname -a; ls /var/tmp;ifconfig eth0 | head -1 | cut -d: -f3;

<b> Verifying Output <b/>

This script automatically generates a report of all the commands executed
It is stored into /tmp as /tmp/UTS-RemoteCommand_$user_$date.output

<b>Version Control <b/>
  *	Ver 1.0.1

<b>Author<b/>

  * Franco Bontorin (francobontorin at gmail.com)
  * Senior Unix Architect

<b>License<b/>

  * This is under GNU GPL v2

<b>Date<b/>

  * July 2012


