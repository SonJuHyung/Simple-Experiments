#!/bin/bash 
OP=$1 

if [ ${OP} == "start" ]
then 
    PID=$(pgrep thp_test)
    echo $PID > /sys/kernel/debug/tracing/set_ftrace_pid 
    echo __alloc_pages_nodemask > /sys/kernel/debug/tracing/set_ftrace_filter 
    echo function_graph > /sys/kernel/debug/tracing/current_tracer  

#    cat /sys/kernel/debug/tracing/trace_pipe
    watch -n 0.1 "cat /sys/kernel/debug/tracing/trace"
elif [ ${OP} == "end" ]
then 
    echo > /sys/kernel/debug/tracing/set_ftrace_pid 
    echo !__alloc_pages_nodemask > /sys/kernel/debug/tracing/set_ftrace_filter 
    echo nop > /sys/kernel/debug/tracing/current_tracer 
else
    echo "error"
fi
