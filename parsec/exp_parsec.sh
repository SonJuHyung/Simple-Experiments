#!/bin/bash 
#perf stat -e dTLB ./bin/ycsb run redis -P ../workloads/workload -P ../conf/redis.prop -s -threads `nproc` > ../run_result/test.dat 

PGM=PARSEC
# action
ACTION=""
# data set size 
INPUT=""
# number of threads.
NTHREAD=$(npoc)
# benchmark
BENCHMARK=""
# nhp or thp
HP_TYPE=""
M_FRG=""

usage()
{
    echo ""
    echo "  usage : # ./exp_parsec.sh -a build -p ferret -h thp -f f"   
    echo "        : # ./exp_parsec.sh -a run -p canneal -i native -h nhp -f nf"
    echo ""        
    echo "          <workk loads>" 
    echo "			        blackscholes - Option pricing with Black-Scholes Partial Differential Equation (PDE)"
    echo "			        bodytrack - Body tracking of a person"
    echo "			    [m] canneal - Simulated cache-aware annealing to optimize routing cost of a chip design"
    echo "			        dedup - Next-generation compression with data deduplication"
    echo "			    [m] facesim - Simulates the motions of a human face"
    echo "			    [m] ferret - Content similarity search server"
    echo "			        fluidanimate - Fluid dynamics for animation purposes with Smoothed Particle Hydrodynamics (SPH) method"
    echo "			        freqmine - Frequent itemset mining"
    echo "			        raytrace - Real-time raytracing"
    echo "			        streamcluster - Online clustering of an input stream"
    echo "			        swaptions - Pricing of a portfolio of swaptions"
    echo "			        vips - Image processing (Project Website)"
    echo "			        x264 - H.264 video encoding (Project Website)"
    echo ""
    echo "          <input>" 
    echo "			        test, simdev, simsmall, simmedium, simlarge, native"
    echo ""
}

if [ $# -eq 0 ]
then 
    usage 
    exit 
fi

while getopts a:i:p:h:f: opt 
do
    case $opt in
        a)
            if [ $OPTARG == "build" ] || [ $OPTARG == "run" ]
            then
                ACTION=$OPTARG 
            else  
                echo "  error : action must be set" 
                usage 
                exit 0
            fi           
            ;;
        i)
            if [ $OPTARG == "simsmall" ] || [ $OPTARG == "simmedium" ] || [ $OPTARG == "simlarge" ] || [ $OPTARG == "test" ] || [ $OPTARG == "simdev" ] || [ $OPTARG == "native" ]
            then
                INPUT=$OPTARG
            else  
                echo "  error : input must be set" 
                usage 
                exit 0
            fi           
            ;;
        p)
            BENCHMARK=$OPTARG
            ;;
        f)
            M_FRG=$OPTARG

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

#if [ $ACTION != "build" ]
#then
if [  -z $ACTION ] || [ $NTHREAD -eq 0 ] || [ -z $INPUT ] || [ -z $BENCHMARK ] || [ -z $HP_TYPE ]
then 
    usage
    exit 0
fi 
#else
#    echo "son"
#fi
DIR_PARSEC=$(pwd) 
PERF_LIST=${DIR_PARSEC}/../perf.sh
DIR_OUTPUT_OPT=${DIR_PARSEC}/run/${PGM}-${HP_TYPE}-${BENCHMARK}-${INPUT}-${M_FRAG}.dat
DIR_OUTPUT_PERF=${DIR_PARSEC}/perf/${PGM}-${HP_TYPE}-${BENCHMARK}-${INPUT}-${M_FRG}.dat

source ${PERF_LIST} 

echo ""
echo "PWD : ${DIR_PARSEC}" 
echo "PERF_LIST : ${PMU_S}"
echo ""
echo "perf stat -e ${PMU_S} -o ${DIR_OUTPUT_PERF} -a ./parsec-3.0/bin/parsecmgmt -a ${ACTION} -p ${BENCHMARK} -i ${INPUT} -n ${NTHREAD} > ${DIR_OUTPUT_OPT}/${PGM}-${HP_TYPE}-${BENCHMARK}-${INPUT}-${NTHREAD}.dat"
echo ""

if [ $ACTION == "run" ]
then
    perf stat -e ${PMU_S} -o ${DIR_OUTPUT_PERF} -a ./parsec-3.0/bin/parsecmgmt -a ${ACTION} -p ${BENCHMARK} -i ${INPUT} -n ${NTHREAD} > ${DIR_OUTPUT_OPT} 
else
    ./parsec-3.0/bin/parsecmgmt -a ${ACTION} -p ${BENCHMARK}
fi

PERF="perf"
PERF_PID=$(pgrep ${PERF})
kill -TERM ${PERF_PID}


