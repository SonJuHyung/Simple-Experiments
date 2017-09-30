#bin/bash 
echo ""
cat $1 | grep RunTime 
cat $1 | grep Throughput 
cat $1 | grep AverageLatency 
echo ""
if [ $# -ne 1 ]
then 
    echo $#
    echo "input file missing"
    exit 0
fi

cat $1 | grep RunTime | awk '{ split($0,arr,","); printf("%s\n",arr[3]);  }'
cat $1 | grep Throughput | awk '{ split($0,arr,","); printf("%s\n",arr[3]);  }'
cat $1 | grep AverageLatency | awk '{ split($0,arr,","); printf("%s\n",arr[3]);  }'
echo ""
