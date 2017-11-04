#!/bin/bash 
#perf stat -e dTLB ./bin/ycsb run redis -P ../workloads/workload -P ../conf/redis.prop -s -threads `nproc` > ../run_result/test.dat 

# redis or mongodb
SZ=""
# redis or mongodb
DB=""
# nhp or thp
HP_TYPE=""
# f or nf
M_FRG=""
# workload 
TYPE_WR=""

usage()
{
    echo ""
    echo "  usage : # ./exp_ycsb.sh -d redis -w wa -h nhp -f nf -s 28"   
    echo "        : # ./exp_ycsb.sh -d monogodb -w wb -h thp -f f -s 32"
    echo ""
}

if [ $# -eq 0 ]
then 
    usage 
    exit 
fi

while getopts d:h:f:w:s: opt 
do
    case $opt in
        d)
            if [ $OPTARG == "redis" ] || [ $OPTARG == "mongodb" ]
            then
                DB=$OPTARG
            else  
                echo "  error : db must be redis of mongodb" 
                usage 
                exit 0
            fi           
            ;;
        h)
            HP_TYPE=$OPTARG
            ;;        
        f)
            M_FRG=$OPTARG

            ;;
        w)
            TYPE_WR=$OPTARG
            ;;
        s)
            SZ=$OPTARG
            ;;

        *)
            usage 
            exit 0
            ;;
    esac
done

if [ -z $DB ] || [ -z $HP_TYPE ] || [ -z $M_FRG ] || [ -z $SZ ] 
then 
    usage
    exit 0
fi
# db configuration file 
DIR_YCSB=$(pwd)/../
PERF_LIST=${DIR_YCSB}/../perf.sh
DIR_DB_CONF=${DIR_YCSB}/conf
DIR_WORKLOAD=${DIR_YCSB}/workloads

DIR_OUTPUT_OPT=${DIR_YCSB}/db/${DB}/run/${HP_TYPE}
DIR_OUTPUT_PERF=${DIR_YCSB}/db/${DB}/perf/${HP_TYPE}
DIR_OUTPUT_SYS=${DIR_YCSB}/db/${DB}/sys/${HP_TYPE}

source ${PERF_LIST}

echo ""
echo "PWD : ${DIR_YCSB}"
echo "PERF_LIST : ${PMU_S}"
echo ""
echo ""

source ./_check.sh > ${DIR_OUTPUT_SYS}/${DB}-${HP_TYPE}-${M_FRG}_${SZ}_before.dat 

./bin/ycsb load ${DB} -P ${DIR_DB_CONF}/${DB}.prop -P ${DIR_WORKLOAD}/${TYPE_WR} -threads `nproc` -s > ${DIR_OUTPUT_OPT}/${DB}-${HP_TYPE}-${M_FRG}_${SZ}.dat 
perf stat -e ${PMU_S} -o ${DIR_OUTPUT_PERF}/${DB}-${HP_TYPE}-${M_FRG}_${SZ}.dat -a ./bin/ycsb run ${DB} -P ${DIR_DB_CONF}/${DB}.prop -P ${DIR_WORKLOAD}/${TYPE_WR} -threads `nproc` -s > ${DIR_OUTPUT_OPT}/${DB}-${HP_TYPE}-${M_FRG}_${SZ}.dat 

source ./_check.sh > ${DIR_OUTPUT_SYS}/${DB}-${HP_TYPE}-${M_FRG}_${SZ}_after.dat 

PERF="perf"
PERF_PID=$(pgrep ${PERF})
kill -TERM ${PERF_PID}

