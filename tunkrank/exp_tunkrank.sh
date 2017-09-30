#!/bin/bash 
#perf stat -e dTLB ./bin/ycsb run redis -P ../workloads/workload -P ../conf/redis.prop -s -threads `nproc` > ../run_result/test.dat 

OP=TUNKRANK
# data set path
DATA_PATH=""
# number of cpu
NCPUS=0
# engine 
ENGINE=""
# nhp or thp
HP_TYPE=""
DATA_SET=""

usage()
{
    echo ""
    echo "  usage : # ./exp_tunkrank.sh -p data_set/twitter_small_data_graplab.in -n 8 -e asynchronous -h thp -d small"   
    echo "        : # ./exp_tunkrank.sh -p data_set/twitter_data_graplab. -n 8 -e synchronous -n thp -d large"
    echo ""
}

if [ $# -eq 0 ]
then 
    usage 
    exit 
fi

while getopts p:n:e:h:d: opt 
do
    case $opt in
        d)
            DATA_SET=$OPTARG
            ;;
        p)
            DATA_PATH=$OPTARG
            ;;
        n)
            NCPUS=$OPTARG
            ;;
        e)
            ENGINE=$OPTARG
            ;;        
        h)
            HP_TYPE=$OPTARG
            ;;
        *)
            usage 
            exit 0
            ;;
    esac
done

if [ -z $DATA_PATH ] || [ $NCPUS -eq 0 ] || [ -z $ENGINE ] || [ -z $HP_TYPE ]
then 
    usage
    exit 0
fi

# db configuration file
DIR_TKRK=$(pwd) 
PERF_LIST=${DIR_TKRK}/../perf.sh
DIR_OUTPUT_OPT=${DIR_TKRK}/run
DIR_OUTPUT_PERF=${DIR_TKRK}/perf

source $PERF_LIST

echo ""
echo "PWD : ${DIR_TKRK}"
echo ""
echo "perf stat -e ${PMU_D} -o ${DIR_OUTPUT_PERF}/${OP}-${HP_TYPE}-${DATA_SET}-${ENGINE}-${NCPUS}.dat -a ./tunkrank --graph=${DATA_PATH} --format=tsv --ncpus=${NCPUS} --engine=${ENGINE} > ${DIR_OUTPUT_OPT}/${OP}-${HP_TYPE}-${DATA_SET}-${ENGINE}-${NCPUS}.dat"
echo ""

perf stat -e ${PMU_D} -o ${DIR_OUTPUT_PERF}/${OP}-${HP_TYPE}-${DATA_SET}-${ENGINE}-${NCPUS}.dat -a ./tunkrank --graph=${DATA_PATH} --format=tsv --ncpus=${NCPUS} --engine=${ENGINE} > ${DIR_OUTPUT_OPT}/${OP}-${HP_TYPE}-${DATA_SET}-${ENGINE}-${NCPUS}.dat 

