#!/bin/bash 

THP_TYPE=$1
ACCESS_TYPE=$2
ACCESS_RANGE=$3
VERSION=$4 
OP=$5

OUT_FILE=perf_data/perf_data_${THP_TYPE}_${ACCESS_TYPE}_${ACCESS_RANGE}_${VERSION}

if [ $OP == "record" ]
then
    PGM="thp_test"
    PID=$(pgrep $PGM) 
    perf record -p $PID -o ${OUT_FILE}
elif [ $OP == "report" ]      
then
    perf report -i ${OUT_FILE}
else
    echo "error"
fi

