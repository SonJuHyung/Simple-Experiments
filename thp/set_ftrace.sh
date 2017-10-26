#!/bin/bash 
OP=$1 
DIR_FTRACE=/sys/kernel/debug/tracing

if [ ${OP} == "start" ]
then 
    PID=$(pgrep thp_test)
    echo $PID > ${DIR_FTRACE}/set_ftrace_pid 
##    echo __alloc_pages_nodemask > ${DIR_FTRACE}/set_ftrace_filter 
##    echo function_graph > ${DIR_FTRACE}/current_tracer  

##    echo __handle_mm_fault > ${DIR_FTRACE}/set_ftrace_filter 
##    echo do_huge_pmd_anonymous_page >> ${DIR_FTRACE}/set_ftrace_filter 

#    echo do_huge_pmd_wp_page >> ${DIR_FTRACE}/set_ftrace_filter 
    echo do_huge_pmd_anonymous_page > ${DIR_FTRACE}/set_graph_function
    echo function_graph > ${DIR_FTRACE}/current_tracer  

#    cat ${DIR_FTRACE}/trace_pipe
    watch -n 0.1 "cat ${DIR_FTRACE}/trace"
elif [ ${OP} == "end" ]
then 
    echo nop > ${DIR_FTRACE}/current_tracer 
    echo > ${DIR_FTRACE}/set_graph_function
##    echo !__alloc_pages_nodemask > ${DIR_FTRACE}/set_ftrace_filter 
    echo > ${DIR_FTRACE}/set_ftrace_filter 
    echo > ${DIR_FTRACE}/set_ftrace_pid  
else
    echo "error"
fi
