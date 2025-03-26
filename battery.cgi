#!/bin/bash
#
# Simple BASH script placed in /usr/lib/cgi-bin/ to create a web page
# that displays the contents of system calls
#
##
echo "Content-type: text/html"
echo ""
echo "<html><head><title>Bash as CGI"
echo "</title></head><body>"

echo "<h1>System information for host $(hostname -s)</h1>"
echo ""

echo "<h1>Power Stats</h1>"

for i in `seq 1 5`;
do
   echo "<pre> Power status is $(./pwrstat) </pre>"
   sleep 1s
done

echo "<h1>Memory Info</h1>"
echo "<pre> $(free -m) </pre>"

echo "<h1>Disk Info:</h1>"
echo "<pre> $(df -h) </pre>"

echo "<h1>Logged in user</h1>"
echo "<pre> $(w) </pre>"

echo "</body></html>"
