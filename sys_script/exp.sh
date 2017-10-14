#!/bin/bash 
#perf stat -e dTLB ./bin/ycsb run redis -P ../workloads/workload -P ../conf/redis.prop -s -threads `nproc` > ../run_result/test.dat 

# size
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
    echo "  usage : # ./exp.sh -d redis -o load -w wa -h nhp -f nf -s 28"   
    echo "        : # ./exp.sh -d monogodb -o run -w wb -h thp -f f -s 80"
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
            if [ $OPTARG == "nhp" ] || [ $OPTARG == "thp" ]
            then
                HP_TYPE=$OPTARG
            else  
                echo "  error : hp must be nhp of thp"
                usage 
                exit 0
            fi
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
            if [ $OPTARG == "wa" ] || [ $OPTARG == "wb" ]
            then
                TYPE_WR=$OPTARG
            else
                echo "  error : workload must be wa of wb"
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
DIR_YCSB=$(pwd)/..
DIR_DB_CONF=${DIR_YCSB}/conf
DIR_WORKLOAD=${DIR_YCSB}/workloads
DIR_OUTPUT_OPT=${DIR_YCSB}/${OPT}_result
DIR_OUTPUT_PERF=${DIR_YCSB}/perf

# perf event list
PERF_EVENT_LIST="dTLB-loads,dTLB-load-misses,dTLB-stores,dTLB-store-misses,iTLB-loads,iTLB-load-misses,cache-misses,page-faults,cycles"
# cycles when PMH is serving page walks caused by DTLB load misses
PERF_PME_1="r1008"
# cycles when PHM is serving page walks caused by ITLB load misses
PERF_PME_2="r1085"
# number of dtlb page walker loads from memory
PERF_PME_3="r18bc"
# number of itlb page walker loads from memory
PERF_PME_4="r28bc"

echo "PWD : ${DIR_YCSB}"
echo "${DB} ${OPT} test for ${HP_TYPE} in ${M_FRG} environment ..."
echo ""
echo "perf stat -e ${PERF_EVENT_LIST} -e ${PERF_PME_1} -e ${PERF_PME_2} -e ${PERF_PME_3} -e ${PERF_PME_4} -o ${DIR_OUTPUT_PERF}/${DB}-${OPT}-${HP_TYPE}-${M_FRG}.txt ./bin/ycsb ${OPT} ${DB} -P ${DIR_DB_CONF}/${DB}.prop -P ${DIR_WORKLOAD}/${TYPE_WR} -threads `nproc` -s > ${DIR_OUTPUT_OPT}/${OPT}-${HP_TYPE}-${M_FRG}.dat"

perf stat -e ${PERF_EVENT_LIST} -e ${PERF_PME_1} -e ${PERF_PME_2} -e ${PERF_PME_3} -e ${PERF_PME_4} -o ${DIR_OUTPUT_PERF}/${DB}-${OPT}-${HP_TYPE}-${M_FRG}_${SZ}.txt -a ./bin/ycsb ${OPT} ${DB} -P ${DIR_DB_CONF}/${DB}.prop -P ${DIR_WORKLOAD}/${TYPE_WR} -threads `nproc` -s > ${DIR_OUTPUT_OPT}/${DB}-${OPT}-${HP_TYPE}-${M_FRG}_${SZ}.dat 

