#!/bin/bash 

THP_TYPE=$1
WORKLOAD=$2
VERSION=$3
OP=$4

OUT_FILE=perf_record/perf_record_${THP_TYPE}_${WORKLOAD}_${VERSION}

if [ $# -ne 4 ]
then 
    echo "wrong usage"
    exit
fi
    
if [ $OP == "record" ]
then
    PGM="thp_test"
    PID=$(pgrep $PGM) 
#    perf record -p $PID -o ${OUT_FILE} 
    perf record -a -o ${OUT_FILE}
elif [ $OP == "report" ]      
then
    perf report -i ${OUT_FILE}
else
    echo "error"
fi

