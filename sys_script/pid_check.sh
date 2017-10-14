#!/bin/bash 
PID=$(pgrep $1)

watch -n -0.1 "./_pid_check.sh -p $PID"
#watch -n -0.1 "./_pid_check.sh -n thp_test"

##while [ -d /proc/${PID} ]
##do
##    ./_pid_check.sh -n $1
##done


