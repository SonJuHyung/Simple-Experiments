#!/bin/bash 

echo ""
cat $1 | awk '{ split($0,arr," "); printf("%s : %s\n",arr[2],arr[1]);  }'
echo ""

if [ $# -ne 1 ]
then
    echo "input file missing."
    exit 0
fi

cat $1 | awk '{ split($0,arr," "); printf("%s\n",arr[1]);  }'
