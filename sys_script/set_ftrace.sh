#!/bin/bash 

echo try_to_compact_pages >> /sys/kernel/debug/tracing/set_ftrace_filter  
echo __alloc_pages_direct_compact >> /sys/kernel/debug/tracing/set_ftrace_filter
echo function > /sys/kernel/debug/tracing/current_tracer

echo always > /sys/kernel/mm/transparent_hugepage/defrag 
echo 1 > /sys/kernel/mm/transparent_hugepage/khugepaged/defrag 

source ./pre.sh 
echo ""
cat /sys/kernel/debug/tracing/set_ftrace_filter
echo ""
cat /sys/kernel/mm/transparent_hugepage/defrag
