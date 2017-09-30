#!/bin/bash 
#perf stat -e dTLB ./bin/ycsb run redis -P ../workloads/workload -P ../conf/redis.prop -s -threads `nproc` > ../run_result/test.dat 

# redis or mongodb
SZ=0
# redis or mongodb
DB=""
# load or run
OPT=""
# nhp or thp
HP_TYPE=""
# f or nf
M_FRG=""
# workload 
TYPE_WR=""

usage()
{
    echo ""
    echo "  usage : # ./exp_ycsb.sh -d redis -o load -w wa -h nhp -f nf -s 28"   
    echo "        : # ./exp_ycsb.sh -d monogodb -o run -w wb -h thp -f f -s 32"
    echo ""
}

if [ $# -eq 0 ]
then 
    usage 
    exit 
fi

while getopts d:o:h:f:w:s: opt 
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
        o)
            if [ $OPTARG == "load" ] || [ $OPTARG == "run" ]
            then
                OPT=$OPTARG
            else 
                echo "  error : opt must be load of run"
                usage 
                exit 0
            fi
            ;;
        h)
            HP_TYPE=$OPTARG
            ;;        
        f)
            if [ $OPTARG == "nf" ] || [ $OPTARG == "f" ]
            then
                M_FRG=$OPTARG
            else

                echo "  error : mfrage must be nr of f"
                usage 
                exit 0
            fi
            ;;
        w)
            if [ $OPTARG == "wmongo" ] || [ $OPTARG == "wredis" ]
            then
                TYPE_WR=$OPTARG
            else
                echo "  error : workload must be wredis of wmongo"
                usage 
                exit 0
            fi
            ;;
        s)
            if [ $OPTARG -ne 0 ]
            then
                SZ=$OPTARG
            else
                echo "  error : size"
                usage 
                exit 0
            fi
            ;;

        *)
            usage 
            exit 0
            ;;
    esac
done

if [ -z $DB ] || [ -z $OPT ] || [ -z $HP_TYPE ] || [ -z $M_FRG ] || [ -z $SZ ] 
then 
    usage
    exit 0
fi
# db configuration file 
DIR_YCSB=$(pwd)/../
PERF_LIST=${DIR_YCSB}/../perf.sh
DIR_DB_CONF=${DIR_YCSB}/conf
DIR_WORKLOAD=${DIR_YCSB}/workloads

DIR_OUTPUT_OPT=${DIR_YCSB}/db/${DB}/${OPT}
DIR_OUTPUT_PERF=${DIR_YCSB}/db/${DB}/perf

source ${PERF_LIST}

echo ""
echo "PWD : ${DIR_YCSB}"
echo "PERF_LIST : ${PMU_D}"
echo ""
echo "perf stat -e ${PMU_D} -o ${DIR_OUTPUT_PERF}/${DB}-${OPT}-${HP_TYPE}-${M_FRG}_${SZ}.txt -a ./bin/ycsb ${OPT} ${DB} -P ${DIR_DB_CONF}/${DB}.prop -P ${DIR_WORKLOAD}/${TYPE_WR} -threads `nproc` -s > ${DIR_OUTPUT_OPT}/${DB}-${OPT}-${HP_TYPE}-${M_FRG}_${SZ}.dat "
echo ""

perf stat -e ${PMU_D} -o ${DIR_OUTPUT_PERF}/${DB}-${OPT}-${HP_TYPE}-${M_FRG}_${SZ}.txt -a ./bin/ycsb ${OPT} ${DB} -P ${DIR_DB_CONF}/${DB}.prop -P ${DIR_WORKLOAD}/${TYPE_WR} -threads `nproc` -s > ${DIR_OUTPUT_OPT}/${DB}-${OPT}-${HP_TYPE}-${M_FRG}_${SZ}.dat 

