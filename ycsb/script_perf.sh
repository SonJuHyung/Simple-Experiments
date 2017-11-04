#!/bin/bash 


PGM=$1
THP_TYPE=$2
SIZE=$3
COUNT=$4
VERSION=$5
OP=$6

OUT_FILE=perf_record/perf_record_${PGM}_${THP_TYPE}_${SIZE}_${COUNT}_${VERSION}

usage()
{
    echo ""
    echo "  usage : # ./script_perf.sh redis thp 2M 100M v1 record"
    echo ""
}


if [ $# -ne 6 ]
then  
    usage
    exit
fi   


if [ $OP == "record" ]
then
    PID=$(pgrep $PGM) 
    perf record -a -p $PID -o ${OUT_FILE} 
#    perf record -o ${OUT_FILE}
elif [ $OP == "report" ]      
then
    perf report -i ${OUT_FILE}
else
    echo "error"
fi

