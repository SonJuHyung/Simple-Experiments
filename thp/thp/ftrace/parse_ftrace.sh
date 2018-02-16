#!/bin/bash 

THP_TYPE=$1
ACCESS_TYPE=$2
ACCESS_RANGE=$3
VERSION=$4 

IN_FILE=ftrace_${THP_TYPE}_${ACCESS_TYPE}_${ACCESS_RANGE}_${VERSION}.txt
OUT_FILE=data/ftrace_data_${THP_TYPE}_${ACCESS_TYPE}_${ACCESS_RANGE}_${VERSION}.txt

cat ${IN_FILE} | sed -e '1,4d' |  awk '{ n=split($0,arr,"us"); printf("%s\n",arr[1]);}' > a.txt
cat a.txt | awk '{ n=split($0,arr,")"); printf("%s\n",arr[2]);}' | sed "s/ + /   /g" > ${OUT_FILE}
#cat b.txt | awk 'BEGIN {sum=0} {for(i=1; i<=NF; i++) sum+=$i } END {print sum}' >> ${OUT_FILE}

rm -rf a.txt 
#cat b.txt | awk '{ n=split($0,arr," "); for(i=1; i < n; i++) printf("%s\n",arr[1]);}' 
#echo ${ARRAY}



