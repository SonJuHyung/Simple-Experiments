#!/bin/bash 

THP_TYPE=$1
ACCESS_TYPE=$2
ACCESS_RANGE=$3
VERSION=$4

OUT_FILE=perf_data/perf_data_${THP_TYPE}_${ACCESS_TYPE}_${ACCESS_RANGE}_${VERSION}.txt

PGM="thp_test"
PID=$(pgrep $PGM)
#perf record -p $PID -o ${OUT_FILE}
perf record -p ${PID} -e huge_memory:* -o ${OUT_FILE}

