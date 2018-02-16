#!/bin/bash 

ALLOC=4 
THP_TYPE=$1
ACCESS_TYPE=$2
ACCESS_RANGE=$3
VERSION=$4

OUT_FILE=run/${THP_TYPE}_${ACCESS_TYPE}_${ACCESS_RANGE}_${VERSION}.txt

if [ $ACCESS_TYPE == "stride" ]
then
    ./thp_test -a 4 -t stride -s $ACCESS_RANGE > ${OUT_FILE}
elif [ $ACCESS_TYPE == "random" ]
then
    ./thp_test -a 4 -t random -s 1 -f data/thp_rand_set_1.txt > ${OUT_FILE}
else 
    echo "error"
fi
