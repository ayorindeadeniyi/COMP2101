		#!/bin/bash
#
# This script produces a dynamic welcome message
# it should look like
#   Welcome to planet hostname, title name!

# Task 1: Use the variable $USER instead of the myname variable to get your name
# Task 2: Dynamically generate the value for your hostname variable using the hostname command - e.g. $(hostname)
# Task 3: Add the time and day of the week to the welcome message using the format shown below
#   Use a format like this:
#   It is weekday at HH:MM AM.
# Task 4: Set the title using the day of the week
#   e.g. On Monday it might be Optimist, Tuesday might be Realist, Wednesday might be Pessimist, etc.
#   You will need multiple tests to set a title
#   Invent your own titles, do not use the ones from this example

###############
# Variables   #
###############
#title="Overlord"
#myname="dennis"
#hostname="myhostname"

###############
# Main        #
###############
cat <<EOF

Welcome to planet $hostname, "$title $myname!"

EOF

																							# Task 1 Solution
USER="ayorindeadeniyi"

# Task 2 Solution
hostname=$(hostname)

# Task 3 Solution
date=$(date +'%a, %b %d, %Y %r')
cat <<EOF

Welcome to planet $hostname, "$title $myname!"
It is weekday at $date

EOF

# Task 4 Solution
day=$(date +'%a, %b %d, %Y %r' | awk '{print $1}' | cut -d ',' -f1)
if [ $day == "Mon" ]; then
echo "Mondays is start of working day"
fi
if [ $day == "Tue" ]; then
echo "Tuesday is a boring working day"
fi
if [ $day == "Wed" ]; then
echo "Wednesdays bring good feelings"
fi
if [ $day == "Thu" ]; then
echo "Mondays is start of working day"
fi
if [ $day == "Fri" ]; then
echo "Friday is meeting deadline"
fi
if [ $day == "Sat" ]; then
echo "Saturday is a refresher"
fi
if [ $day == "Sun" ]; then
echo "Sundays are fun days"
fi
