#!/bin/bash
# this script displays system information

# TASK: This script produces a report. It does not communicate errors or deal with the user pressing ^C
#       Create the 4 functions described in the comments for
#         help display
#         error message display (2 of these)
#         temporary files cleanup to be used with interrupts
#       Create a trap command to attach your interrupt handling function to the signal that will be received if the user presses ^C while the script is running

# Start of section to be done for TASK
# This is where your changes will go for this TASK

# This function will send an error message to stderr
# Usage:
#   error-message ["some text to print to stderr"]
function error-message {
echo "Invalid input"
echo "$@" 1>&2
exit
}

# This function will send a message to stderr and exit with a failure status
# Usage:
#   error-exit ["some text to print to stderr" [exit-status]]
function error-exit {
echo "$@" 1>&2
exit
}
#This function displays help information if the user asks for it on the command line or gives us a bad command line
function displayhelp {
echo "Usage:"
echo "./sysconfig.sh	[-h,--help]"
echo "		[--host]"
echo "		[--domain]"
echo "		[--ipconfig]"
echo "		[--os]"
echo "		[--cpu]"
echo "		[--memory]"
echo "		[--disk]"
echo "		[--printer]"
}

# This function will remove all the temp files created by the script
# The temp files are all named similarly, "/tmp/somethinginfo.$$"

function cleanup {
rm -rf /tmp/sysinfo.$$
rm -rf /tmp/memoryinfo.$$
rm -rf /tmp/businfo.$$
rm -rf /tmp/*.$$
}


# A trap command is used after the function definition to specify this function is to be run if we get a ^C while running
trap ctrl_c INT

function ctrl_c() {
	echo "** Trapped CTRL-C"
}

# End of section to be done for TASK
# Remainder of script does not require any modification, but may need to be examined in order to create the functions for TASK

# DO NOT MODIFY ANYTHING BELOW THIS LINE

#This function produces the network configuration for our report
function getipinfo {
  # reuse our netid.sh script from lab 4
  # Once per host report
#####
[ "$verbose" = "yes" ] && echo "Gathering host information"
# we use the hostname command to get our system name
my_hostname=$(hostname)

[ "$verbose" = "yes" ] && echo "Identifying default route"
# the default route can be found in the route table normally
# the router name is obtained with getent
default_router_address=$(ip r s default| cut -d ' ' -f 3)
default_router_name=$(getent hosts $default_router_address|awk '{print $2}')

[ "$verbose" = "yes" ] && echo "Checking for external IP address and hostname"
# finding external information relies on curl being installed and relies on live internet connection
external_address=$(curl -s icanhazip.com)
external_name=$(getent hosts $external_address | awk '{print $2}')

cat <<EOF

System Identification Summary
=============================
Hostname      : $my_hostname
Default Router: $default_router_address
Router Name   : $default_router_name
External IP   : $external_address
External Name : $external_name

EOF

#####
# End of Once per host report
#####

# the second part of the output generates a per-interface report
# the task is to change this from something that runs once using a fixed value for the interface name to
#   a dynamic list obtained by parsing the interface names out of a network info command like "ip"
#   and using a loop to run this info gathering section for every interface found

# the default version uses a fixed name and puts it in a variable
#####
# Per-interface report
#####

# define the interface being summarized
interface="eno1"
[ "$verbose" = "yes" ] && echo "Reporting on interface(s): $interface"

[ "$verbose" = "yes" ] && echo "Getting IPV4 address and name for interface $interface"
# Find an address and hostname for the interface being summarized
# we are assuming there is only one IPV4 address assigned to this interface
ipv4_address=$(ip a s $interface|awk -F '[/ ]+' '/inet /{print $3}')
ipv4_hostname=$(getent hosts $ipv4_address | awk '{print $2}')

[ "$verbose" = "yes" ] && echo "Getting IPV4 network block info and name for interface $interface"
# Identify the network number for this interface and its name if it has one
# Some organizations have enough networks that it makes sense to name them just like how we name hosts
# To ensure your network numbers have names, add them to your /etc/networks file, one network to a line, as   networkname networknumber
#   e.g. grep -q mynetworknumber /etc/networks || (echo 'mynetworkname mynetworknumber' |sudo tee -a /etc/networks)
network_address=$(ip route list dev $interface scope link|cut -d ' ' -f 1)
network_number=$(cut -d / -f 1 <<<"$network_address")
network_name=$(getent networks $network_number|awk '{print $1}')

cat <<EOF

Interface $interface:
===============
Address         : $ipv4_address
Name            : $ipv4_hostname
Network Address : $network_address
Network Name    : $network_name

EOF
#####
# End of per-interface report
#####
}

# process command line options
partialreport=
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      displayhelp
      error-exit
      ;;
    --host)
      hostnamewanted=true
      partialreport=true
      ;;
    --domain)
      domainnamewanted=true
      partialreport=true
      ;;
    --ipconfig)
      ipinfowanted=true
      partialreport=true
      ;;
    --os)
      osinfowanted=true
      partialreport=true
      ;;
    --cpu)
      cpuinfowanted=true
      partialreport=true
      ;;
    --memory)
      memoryinfowanted=true
      partialreport=true
      ;;
    --disk)
      diskinfowanted=true
      partialreport=true
      ;;
    --printer)
      printerinfowanted=true
      partialreport=true
      ;;
    *)
      error-exit "$1 is invalid"
      ;;
  esac
  shift
done

# gather data into temporary files to reduce time spent running lshw
sudo lshw -class system >/tmp/sysinfo.$$ 2>/dev/null
sudo lshw -class memory >/tmp/memoryinfo.$$ 2>/dev/null
sudo lshw -class bus >/tmp/businfo.$$ 2>/dev/null
sudo lshw -class cpu >/tmp/cpuinfo.$$ 2>/dev/null

# extract the specific data items into variables
systemproduct=`sed -n '/product:/s/ *product: //p' /tmp/sysinfo.$$`
systemwidth=`sed -n '/width:/s/ *width: //p' /tmp/sysinfo.$$`
systemmotherboard=`sed -n '/product:/s/ *product: //p' /tmp/businfo.$$|head -1`
systembiosvendor=`sed -n '/vendor:/s/ *vendor: //p' /tmp/memoryinfo.$$|head -1`
systembiosversion=`sed -n '/version:/s/ *version: //p' /tmp/memoryinfo.$$|head -1`
systemcpuvendor=`sed -n '/vendor:/s/ *vendor: //p' /tmp/cpuinfo.$$|head -1`
systemcpuproduct=`sed -n '/product:/s/ *product: //p' /tmp/cpuinfo.$$|head -1`
systemcpuspeed=`sed -n '/size:/s/ *size: //p' /tmp/cpuinfo.$$|head -1`
systemcpucores=`sed -n '/configuration:/s/ *configuration:.*cores=//p' /tmp/cpuinfo.$$|head -1`

# gather the remaining data needed
sysname=`hostname`
domainname=`hostname -d`
osname=`sed -n -e '/^NAME=/s/^NAME="\(.*\)"$/\1/p' /etc/os-release`
osversion=`sed -n -e '/^VERSION=/s/^VERSION="\(.*\)"$/\1/p' /etc/os-release`
memoryinfo=`sudo lshw -class memory|sed -e 1,/bank/d -e '/cache/,$d' |egrep 'size|description'|grep -v empty`
ipinfo=`getipinfo`
diskusage=`df -h -t ext4`
printerlist="`lpstat -e`
Default printer: `lpstat -d|cut -d : -f 2`"

# create output

[[ (! "$partialreport" || "$hostnamewanted") && "$sysname" ]] &&
  echo "Hostname:     $sysname" >/tmp/sysreport.$$
[[ (! "$partialreport" || "$domainnamewanted") && "$domainname" ]] &&
  echo "Domainname:   $domainname" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$osinfowanted") && "$osname" && "$osversion" ]] &&
  echo "OS:           $osname $osversion" >>/tmp/sysreport.$$
[[ ! "$partialreport" || "$cpuinfowanted" ]] &&
  echo "System:       $systemproduct ($systemwidth)
Motherboard:  $systemmotherboard
BIOS:         $systembiosvendor $systembiosversion
CPU:          $systemcpuproduct from $systemcpuvendor
CPU config:   $systemcpuspeed with $systemcpucores core(s) enabled" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$memoryinfowanted") && "$memoryinfo" ]] &&
  echo "RAM installed:
$memoryinfo" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$diskinfowanted") && "$diskusage" ]] &&
  echo "Disk Usage:
$diskusage" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$printerinfowanted") && "$printerlist" ]] &&
  echo "Printer(s):
$printerlist" >>/tmp/sysreport.$$
[[ (! "$partialreport" || "$ipinfowanted") && "$ipinfo" ]] &&
  echo "IP Configuration:" >>/tmp/sysreport.$$ &&
  echo "$ipinfo" >> /tmp/sysreport.$$

cat /tmp/sysreport.$$

# cleanup temporary files
cleanup
