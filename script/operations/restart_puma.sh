#!/bin/bash
PUMA_PID=`ps aux | egrep [p]uma | awk 'NR==3{print $2}'`
echo "Sending SIGUSR2 to $PUMA_PID"
kill -SIGUSR2 $PUMA_PID
echo "Done"
