#!/bin/bash 
#perf stat -e dTLB ./bin/ycsb run redis -P ../workloads/workload -P ../conf/redis.prop -s -threads `nproc` > ../run_result/test.dat 

PGM=NUTCH
# how many times should nutch crawl the web page.
DEPTH=0
# hoa many pages nutch should crawl per depth.
TOPN=0
# nhp or thp
HP_TYPE=""

usage()
{
    echo ""
    echo "  usage : # ./exp_nutch.sh -d 3 -n 5  -h thp"   
    echo "        : # ./exp_nutch.sh -d 5 -n 10 -h nhp"
    echo ""
}

if [ $# -eq 0 ]
then 
    usage 
    exit 
fi

while getopts p:d:n:h: opt 
do
    case $opt in
        d)
            if [ $OPTARG -ne 0 ]
            then
                DEPTH=$OPTARG
            else  
                echo "  error : depth must be set" 
                usage 
                exit 0
            fi           
            ;;        
        n)
            if [ $OPTARG -ne 0 ]
            then
                TOPN=$OPTARG
            else  
                echo "  error : topN must be set" 
                usage 
                exit 0
            fi           
            ;;        
        h)
            if [ $OPTARG == "thp" ] || [ $OPTARG == "nhp" ]
            then
                HP_TYPE=$OPTARG
            else  
                echo "  error : huge page type must be set" 
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

if [ $DEPTH -eq 0] || [ $TOPN -eq 0 ] || [ -z $HP_TYPE ]
then 
    usage
    exit 0
fi

# db configuration file
DIR_NUTCH=$(pwd) 
PERF_LIST=${DIR_NUTCH}/../perf.sh
DIR_OUTPUT_OPT=${DIR_NUTCH}/crawl
DIR_OUTPUT_PERF=${DIR_NUTCH}/perf
# url directory.
DIR_INPUT_URL=${DIR_NUTCH}/urls

source $PERF_LIST

echo ""
echo "PWD : ${DIR_NUTCH}"
echo ""
echo "perf stat -e ${PMU_D}  -o ${DIR_OUTPUT_PERF}/${PGM}-${HP_TYPE}-${DEPTH}-${TOPN}.dat -a nutch crawl ${DIR_INPUT_URL} -dir ${DIR_OUTPUT_OPT} -depth ${DEPTH} -topN ${TOPN} > ${DIR_INPUT_URL}/${PGM}-${HP_TYPE}-${DEPTH}-${TOPN}.dat "
echo ""
# nutch crawl urls -dir crawl -depth 3 -topN 54
perf stat -e ${PMU_D} -o ${DIR_OUTPUT_PERF}/${PGM}-${HP_TYPE}-${DEPTH}-${TOPN}.dat -a nutch crawl ${DIR_INPUT_URL} -dir ${DIR_OUTPUT_OPT} -depth ${DEPTH} -topN ${TOPN} 
#> ${DIR_INPUT_URL}/${PGM}-${HP_TYPE}-${DEPTH}-${TOPN}.dat 

