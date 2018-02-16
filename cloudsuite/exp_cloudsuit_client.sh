#!/bin/bash 

# common 
OP_TYPE=""
HP_TYPE=""
MFRG_TYPE=""
DIR_CUR=$(pwd) 
DIR_RUN=${DIR_CUR}/run 
DIR_PERF=${DIR_CUR}/perf
DIR_SYS=${DIR_CUR}/sys
FILE_PERF=${DIR_CUR}/../perf.sh
source ${FILE_PERF}

function usage()
{
    echo ""
    echo "  usage : # ./exp_cloudsuit_client.sh -p data_analytics -h nhp -f nf"
    echo "        : # ./exp_cloudsuit_client.sh -p data_caching -h hp -f f"
    echo ""        
    echo "          <workk loads>" 
    echo "                  data_serving(YCSB)"
    echo "                  web_search(Solr)"
    echo ""
    echo ""
}

if [ $# -eq 0 ]
then 
    usage 
    exit 
fi

while getopts p:h:f: opt 
do
    case $opt in
        p) 
            if [ $OPTARG == "web_search" ] || [ $OPTARG == "data_serving" ]
            then
                OP_TYPE=$OPTARG
            else
                echo "  error : benchmark type missing"
                usage 
                exit 0
            fi
            ;;

        h)
            HP_TYPE=$OPTARG
            ;;        
        f)
            MFRG_TYPE=$OPTARG
            ;;
        *)
            usage 
            exit 0
            ;;
    esac
done

if [ -z ${HP_TYPE} ] || [ -z ${MFRG_TYPE} ] || [ -z ${OP_TYPE} ]
then 
    usage 
    exit 0
fi

case ${OP_TYPE} in 
    "data_serving") 

        NETWORK="serving_network"  
        DOCKER_IMAGE_SERVER="cloudsuite/data-serving:server"
        DOCKER_IMAGE_CLIENT="cloudsuite/data-serving:client"
        NAME_SERVER="cassandra-server"        
        NAME_CLIENT="cassandra-client"
        THREAD_NUM=`nproc`
        RCD_COUNT=4000000
        OPT_COUNT=10000000
        RCD_FLD_LENGTH=400 
        RCD_FLD_COUNT=10
        # system status
        source ./_check.sh > ${DIR_SYS}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}-before.dat

        echo "  running ${OP_TYPE} experiment ..."      
        sudo perf stat -e ${PMU_S} -o ${DIR_PERF}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}.dat -a docker run -e RECORDCOUNT=${RCD_COUNT} -e OPERATIONCOUNT=${OPT_COUNT} -e THREADS=${THREAD_NUM} -e FIELDLENGTH=${RCD_FLD_LENGTH} -e FIELDCOUNT=${RCD_FLD_COUNT} --name ${NAME_CLIENT} --net ${NETWORK} ${DOCKER_IMAGE_CLIENT} ${NAME_SERVER} > ${DIR_RUN}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}.dat

        # system status
        source ./_check.sh > ${DIR_SYS}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}-after.dat
       
        ;;
    "web_search") 
        NETWORK="search_network" 
        DOCKER_IMAGE_SERVER="cloudsuite/web-search:server"        
        DOCKER_IMAGE_CLIENT="cloudsuite/web-search:client"
        NAME_SERVER="server"        
        NAME_CLIENT="client"
        PORT_NUM=8393
        JAVA_P_MEM_SZ="60g" # The pregenerated Solr index occupies 12GB of memory, and therefore we use 12g to avoid disk accesses. 
        NODE_COUNT=1
        SERVER_ADDRESS=172.20.0.2
        NUM_CON_CLI=50 # number of concurrent client
        TIME_WARMUP=90 # time required to warm up the server (seconds unit)
        TIME_STEADY=60 # time the benchmark is in the steady state
        TIME_ENDING=60 # time to wait before ending the benchmark

        echo ""
        echo "  obtaining docker image and dataset ... ${DOCKER_IMAGE_CLIENT}"
        sudo docker pull ${DOCKER_IMAGE_CLIENT}

        # system status
        source ./_check.sh > ${DIR_SYS}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}-before.dat

        echo ""
        echo "  start ${DOCKER_IMAGE_CLIENT} container ..."
        # run
        # start client 
        echo "  running ${OP_TYPE} experiment ..."      
        sudo perf stat -e ${PMU_S} -o ${DIR_PERF}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}.dat -a docker run -it --name ${NAME_CLIENT} --net ${NETWORK} ${DOCKER_IMAGE_CLIENT} ${SERVER_ADDRESS} ${NUM_CON_CLI} ${TIME_WARMUP} ${TIME_STEADY} ${TIME_ENDING} > ${DIR_RUN}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}.dat 

        # system status
        source ./_check.sh > ${DIR_SYS}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}-after.dat

        ;;
esac

source /home/son/chech_mem.sh > sys/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}.dat

PERF="perf"
PERF_PID=$(pgrep ${PERF})
kill -TERM ${PERF_PID}

