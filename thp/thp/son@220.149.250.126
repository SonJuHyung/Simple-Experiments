#!/bin/bash 

THP_TYPE=$1
ACCESS_TYPE=$2
ACCESS_RANGE=$3
VERSION=$4 

OUT_FILE=ftrace/ftrace_${THP_TYPE}_${ACCESS_TYPE}_${ACCESS_RANGE}_${VERSION}.txt

cat /sys/kernel/debug/tracing/trace > ${OUT_FILE}
cat ${OUT_FILE} | sed -e '1,4d' |  awk '{ n=split($0,arr,"us"); printf("%s\n",arr[1]);}' > a.txt
cat a.txt | awk '{ n=split($0,arr,")"); printf("%s\n",arr[2]);}' | sed "s/ + /   /g" > b.txt 
cat b.txt | awk 'BEGIN {sum=0} {for(i=1; i<=NF; i++) sum+=$i } END {print sum}' >> ${OUT_FILE}

rm -rf a.txt b.txt
#cat b.txt | awk '{ n=split($0,arr," "); for(i=1; i < n; i++) printf("%s\n",arr[1]);}' 
#echo ${ARRAY}



