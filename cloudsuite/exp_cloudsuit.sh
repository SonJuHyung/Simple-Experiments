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
    echo "  usage : # ./exp_cloudsuit.sh -p data_analytics -h nhp -f nf"
    echo "        : # ./exp_cloudsuit.sh -p data_caching -h hp -f f"
    echo ""
}

function clear_container()
{
#    CONTEXT=$(sudo docker ps --filter status=running --format "table {{.Names}}")   
    CONTEXT=$(sudo docker ps -a --format "table {{.Names}}")   
    RUNNING_COUNT=$(echo ${CONTEXT} | awk '{ n=split($0,arr," "); } END{ printf("%s ", n-1); }') 
    RUNNING_LIST=$(echo ${CONTEXT} | awk '{ n=split($0,arr," "); } {for(i=2; i <= n ; i++) printf("%s ",arr[i]); }')  
    NETWORK=$1

    #((RUNNING_COUNT=$(echo ${RUNNING_LIST} | cut -f 1 -d ' ') - 1 ))

    echo ""        
    echo "  currently ${RUNNING_COUNT} containers are running ... "

    if [ ${RUNNING_COUNT} -ne 0 ]
    then 
        echo "      ${RUNNING_LIST}"
        echo ""
        echo "  removing running containers, network ... "
        for((i=1; i <= ${RUNNING_COUNT}; i++))
        do
            RUNNING_CONTAINER=$(echo ${RUNNING_LIST} | cut -f ${i} -d ' ')
            echo -n "       removing ... "
            sudo docker rm -f ${RUNNING_CONTAINER}
            echo "       complete."
        done    
    fi
   
    if [ $NETWORK != "host" ]
    then 
        echo -n "       removing ${NETWORK} ... "
        sudo docker network rm ${NETWORK}
        echo "       complete."
    fi

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
            if [ $OPTARG == "data_analytics" ] || [ $OPTARG == "data_caching" ] || [ $OPTARG == "data_serving" ] || [ $OPTARG == "graph_analytics" ] || [ $OPTARG == "inmemory_analytics" ] || [ $OPTARG == "media_streaming" ] || [ $OPTARG == "web_search" ] || [ $OPTARG == "web_serving"  ]
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
    "data_analytics") # MapReduce

        NETWORK="hadoop-net" 
        DOCKER_IMAGE_SERVER="cloudsuite/data-analytics"
        DOCKER_IMAGE_CLIENT="cloudsuite/hadoop"
        NAME_SERVER="master"
        NAME_CLIENT="slave"
        echo ""
        clear_container ${NETWORK}
        echo ""
        echo "  ok .. ready to commit ${OP_TYPE} experiment !!!"

        # docker image 
        echo ""
        echo "  obtaining docker image ... ${DOCKER_IMAGE_SERVER}"
        sudo docker pull ${DOCKER_IMAGE_SERVER}
        echo ""
        echo "  obtaining docker image ... ${DOCKER_IMAGE_CLIENT}"
        sudo docker pull ${DOCKER_IMAGE_CLIENT}

        # create network
        echo ""        
        echo "  creating network ... ${NETWORK}"
        sudo docker network create ${NETWORK}

        # create container 
        echo ""
        echo "  start ${DOCKER_IMAGE_SERVER} containers ..."
        sudo docker run -d --net ${NETWORK} --name ${NAME_SERVER} --hostname ${NAME_SERVER} ${DOCKER_IMAGE_SERVER} ${NAME_SERVER}
        echo "" 
        echo "  start ${DOCKER_IMAGE_CLIENT} containers ..."
        sudo docker run -d --net ${NETWORK} --name ${NAME_CLIENT} --hostname ${NAME_CLIENT} ${DOCKER_IMAGE_CLIENT} ${NAME_CLIENT}
        
        # system status
#        source ./_check.sh > ${DIR_SYS}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}-before.dat
        # data_analytics experiment
        echo "  running ${OP_TYPE} experiment ..."
        sudo perf stat -e ${PMU_S} -o ${DIR_PERF}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}.dat -a docker exec ${NAME_SERVER} benchmark > ${DIR_RUN}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}.dat

        # system status
#        source ./_check.sh > ${DIR_SYS}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}-after.dat

        echo ""
        clear_container ${NETWORK}
        echo ""

        ;;
    "data_caching") # Memcached

        NETWORK="caching_network" 
        DOCKER_IMAGE_SERVER="cloudsuite/data-caching:server"        
        DOCKER_IMAGE_CLIENT="cloudsuite/data-caching:client"
        NAME_SERVER="dc_server"
        NAME_CLIENT="dc_client"
        THREAD_NUM=$(nproc)
        MEM_SIZE=30000 # MB unit
        OBJ_SIZE_MIN=550
        DIR_VOLUME=${DIR_CUR}/volume/

        if [ ! -d $ ${DIR_VOLUME} ]
        then 
            mkdir ${DIR_VOLUME}
        fi 

        echo ""
        clear_container ${NETWORK}
        echo ""
        echo "  ok .. ready to commit ${OP_TYPE} experiment !!!"
        echo ""

        # create network
        echo "  creating network ... ${NETWORK}"
        sudo docker network create ${NETWORK}

        # get docker server image 
        echo ""
        echo "  obtaining docker image ... ${DOCKER_IMAGE_SERVER}"
        sudo docker pull ${DOCKER_IMAGE_SERVER}
        echo ""
        echo "  obtaining docker image ... ${DOCKER_IMAGE_CLIENT} " 
        sudo docker pull ${DOCKER_IMAGE_CLIENT}
       
        # start Memcached server container 
        echo ""
        echo "  start ${DOCKER_IMAGE_SERVER} container ..."
        sudo docker run --name ${NAME_SERVER} --net ${NETWORK} -d ${DOCKER_IMAGE_SERVER} -t $THREAD_NUM -m ${MEM_SIZE} -n ${OBJ_SIZE_MIN}

        echo ""
        # get docker client image
        # start Memcached client container
        echo " start ${DOCKER_IMAGE_CLIENT} container and login as memcached user..."
        sudo docker run -u 0 --privileged --security-opt seccomp=my-seccomp.json -v ${DIR_VOLUME}:/son -v ${DIR_RUN}/${OP_TYPE}/${HP_TYPE}:/son_run -v ${DIR_PERF}/${OP_TYPE}/${HP_TYPE}:/son_perf -v ${DIR_SYS}/${OP_TYPE}/${HP_TYPE}:/son_sys -it --name ${NAME_CLIENT} --net ${NETWORK} ${DOCKER_IMAGE_CLIENT} /bin/bash
        echo ""
        clear_container ${NETWORK}
        echo ""

        ;;
    "data_serving") # YCSB cassandra

        NETWORK="serving_network"  
        DOCKER_IMAGE_SERVER="cloudsuite/data-serving:server"
        DOCKER_IMAGE_CLIENT="cloudsuite/data-serving:client"
        NAME_SERVER="cassandra-server"        
        NAME_CLIENT="cassandra-client"
        THREAD_NUM=`nproc`
        RCD_COUNT=1572864
        OPT_COUNT=10000000
        RCD_FLD_LENGTH=400 
        RCD_FLD_COUNT=10


        echo ""
        clear_container ${NETWORK}
        echo ""
        echo "  ok .. ready to commit ${OP_TYPE} experiment !!!"
        echo ""

        # create network
        echo "  creating network ... ${NETWORK}"
        sudo docker network create ${NETWORK}
        
        # start YCSB server container 
        echo ""
        echo "  start ${DOCKER_IMAGE_SERVER} container ..."       
        sudo docker run --name ${NAME_SERVER} --net ${NETWORK} ${DOCKER_IMAGE_SERVER} 

        echo ""
        echo "  control switch by client"

        echo ""
        clear_container ${NETWORK}
        echo ""
       
        ;;
    "graph_analytics") # Apache Solr
        NETWORK="host" 
        DOCKER_IMAGE_SERVER="cloudsuite/graph-analytics"        
        DOCKER_IMAGE_DATAST="cloudsuite/twitter-dataset-graph"
#        DRIVER_MEMORY="8g" # Amount of memory to use for the driver process,
#        EXECUTOR_MEMORY="8g" # Amount of memory to use per executor process (e.g. 2g, 8g). 
        DRIVER_MEMORY="1g" # Amount of memory to use for the driver process,
        EXECUTOR_MEMORY="4g" # Amount of memory to use per executor process (e.g. 2g, 8g).
        NAME_DATA="data"        

        echo ""
        clear_container ${NETWORK}
        echo ""
        echo "  ok .. ready to commit ${OP_TYPE} experiment !!!"
        echo ""

        # get docker server image
        echo ""
        echo "  obtaining docker image and dataset ... ${DOCKER_IMAGE_SERVER}"
        sudo docker pull ${DOCKER_IMAGE_SERVER}
        echo ""
        echo "  obtaining docker image and dataset ... ${DOCKER_IMAGE_DATAST}"
        sudo docker pull ${DOCKER_IMAGE_DATAST}
        
        # start Memcached server container 
        echo ""
        echo "  start ${DOCKER_IMAGE_DATAST} container ..."
        sudo docker create --name ${NAME_DATA} ${DOCKER_IMAGE_DATAST}

        # system status
#        source ./_check.sh > ${DIR_SYS}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}-before.dat

        echo ""
        echo "  running ${OP_TYPE} experiment ..."      
        sudo perf stat -e ${PMU_S} -o ${DIR_PERF}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}.dat -a docker run --rm --volumes-from ${NAME_DATA} ${DOCKER_IMAGE_SERVER} > ${DIR_RUN}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}.dat

        # system status
#        source ./_check.sh > ${DIR_SYS}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}-after.dat

        echo ""
        clear_container ${NETWORK}
        echo ""

        ;;
    "inmemory_analytics") # Apache Spark
        NETWORK="host" 
        DOCKER_IMAGE_SERVER="cloudsuite/in-memory-analytics"
        DOCKER_IMAGE_DATAST="cloudsuite/movielens-dataset"
        DRIVER_MEMORY="1g" # Amount of memory to use for the driver process,
        EXECUTOR_MEMORY="4g" # Amount of memory to use per executor process (e.g. 2g, 8g). 
#        DRIVER_MEMORY="1g" # Amount of memory to use for the driver process,
#        EXECUTOR_MEMORY="4g" # Amount of memory to use per executor process (e.g. 2g, 8g).
        NAME_DATA="data"

        echo ""
        clear_container ${NETWORK}
        echo ""
        echo "  ok .. ready to commit ${OP_TYPE} experiment !!!"
        echo ""

        # get server image 
        echo ""
        echo "  obtaining docker image and dataset ... ${DOCKER_IMAGE_SERVER}"
        sudo docker pull ${DOCKER_IMAGE_SERVER}
        # get dataset image
        echo ""
        echo "  obtaining docker image and dataset ... ${DOCKER_IMAGE_DATAST}"
        sudo docker pull ${DOCKER_IMAGE_DATAST}
        
        # start data set 
        echo ""
        echo "  start ${DOCKER_IMAGE_DATAST} container ..."
        sudo docker create --name ${NAME_DATA} ${DOCKER_IMAGE_DATAST}

        # system status
#        source ./_check.sh > ${DIR_SYS}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}-before.dat

        # run 
        echo ""
        echo "  running ${OP_TYPE} experiment ..."      
#        sudo perf stat -e ${PMU_S} -o ${DIR_PERF}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}.dat -a docker run --rm --volumes-from ${NAME_DATA} ${DOCKER_IMAGE_SERVER} /data/ml-latest-small /data/myratings.csv --driver-memory ${DRIVER_MEMORY} --executor-memory ${EXECUTOR_MEMORY} > ${DIR_RUN}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}.dat
        sudo perf stat -e ${PMU_S} -o ${DIR_PERF}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}.dat -a docker run --rm --volumes-from ${NAME_DATA} ${DOCKER_IMAGE_SERVER} /data/ml-latest-small /data/myratings.csv --driver-memory ${DRIVER_MEMORY} --executor-memory ${EXECUTOR_MEMORY} > ${DIR_RUN}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}.dat

        # system status
#        source ./_check.sh > ${DIR_SYS}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}-after.dat

        echo ""
        clear_container ${NETWORK}
        echo ""

        ;;
    "media_streaming") # Nginx 
        NETWORK="streaming_network" 
        DOCKER_IMAGE_SERVER="cloudsuite/media-streaming:server"
        DOCKER_IMAGE_DATAST="cloudsuite/media-streaming:dataset"
        DOCKER_IMAGE_CLIENT="cloudsuite/media-streaming:client"
        NAME_SERVER="streaming_server"        
        NAME_DATASET="streaming_dataset"        
        NAME_CLIENT="streaming_client"

        echo ""
        clear_container ${NETWORK}
        echo ""
        echo "  ok .. ready to commit ${OP_TYPE} experiment !!!"
        echo ""

        # create network
        echo "  creating network ... ${NETWORK}"
        sudo docker network create ${NETWORK}

        # get docker server image
        echo ""
        echo "  obtaining docker image and dataset ... ${DOCKER_IMAGE_SERVER}"
        sudo docker pull ${DOCKER_IMAGE_SERVER}
        echo ""
        echo "  obtaining docker image and dataset ... ${DOCKER_IMAGE_DATAST}"
        sudo docker pull ${DOCKER_IMAGE_DATAST}
        echo ""
        echo "  obtaining docker image and dataset ... ${DOCKER_IMAGE_CLIENT}"
        sudo docker pull ${DOCKER_IMAGE_CLIENT}

        # start data set
        echo ""
        echo "  start ${DOCKER_IMAGE_DATAST} container ..."
        sudo docker create --name ${NAME_DATASET} ${DOCKER_IMAGE_DATAST} 
        
        # start Nginx streaming server 
        echo ""
        echo "  start ${DOCKER_IMAGE_SERVER} container ..."
        sudo docker run -d --name ${NAME_SERVER} --volumes-from ${NAME_DATASET} --net ${NETWORK} ${DOCKER_IMAGE_SERVER}

        # system status
#        source ./_check.sh > ${DIR_SYS}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}-before.dat

        echo ""
        echo "  start ${DOCKER_IMAGE_CLIENT} container ..."
        echo "  running ${OP_TYPE} experiment ..."      
        # run
        # start httperf client 
        sudo perf stat -e ${PMU_S} -o ${DIR_PERF}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}.dat -a docker run -t --name=${NAME_CLIENT} -v ${DIR_RUN}/${OP_TYPE}/${HP_TYPE}:/output --volumes-from ${NAME_DATASET} --net ${NETWORK} ${DOCKER_IMAGE_CLIENT} ${NAME_SERVER} > ${DIR_RUN}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}.dat

        # system status
#        source ./_check.sh > ${DIR_SYS}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}-after.dat

        echo ""
        clear_container ${NETWORK}
        echo ""
        ;;
    "web_search") # Apace Solr
        NETWORK="search_network" 
        DOCKER_IMAGE_SERVER="cloudsuite/web-search:server"        
        DOCKER_IMAGE_CLIENT="cloudsuite/web-search:client"
        NAME_SERVER="server"
        NAME_CLIENT="client"
        PORT_NUM=8393
        JAVA_P_MEM_SZ="8g" # The pregenerated Solr index occupies 12GB of memory, and therefore we use 12g to avoid disk accesses. 
        NODE_COUNT=1
        SERVER_ADDRESS="172.20.0.2"
        NUM_CON_CLI=50 # number of concurrent client
        TIME_WARMUP=90 # time required to warm up the server (seconds unit)
        TIME_STEADY=60 # time the benchmark is in the steady state
        TIME_ENDING=60 # time to wait before ending the benchmark

        echo ""
        clear_container ${NETWORK}
        echo ""
        echo "  ok .. ready to commit ${OP_TYPE} experiment !!!"
        echo ""

        # create network
        echo "  creating network ... ${NETWORK}"
        sudo docker network create ${NETWORK}

        # get docker server image
        echo ""
        echo "  obtaining docker image and dataset ... ${DOCKER_IMAGE_SERVER}"
        sudo docker pull ${DOCKER_IMAGE_SERVER}
                
        # start Solr server  
        echo ""
        echo "  start ${DOCKER_IMAGE_SERVER} container ..."
        sudo docker run -it --name ${NAME_SERVER} --net ${NETWORK} -p ${PORT_NUM}:${PORT_NUM} ${DOCKER_IMAGE_SERVER} ${JAVA_P_MEM_SZ} ${NODE_COUNT}

        echo ""
        echo "  switch control to client"

        echo ""
        clear_container ${NETWORK}
        echo ""
        ;;
    "web_serving") # web server, memcached server, MYSQL, faban client
        NETWORK="host"  

        DOCKER_IMAGE_DB_SERVER="cloudsuite/web-serving:db_server"
        DOCKER_IMAGE_MEMCACHED_SERVER="cloudsuite/web-serving:memcached_server"        
        DOCKER_IMAGE_WEB_SERVER="cloudsuite/web-serving:web_server"
        DOCKER_IMAGE_CLIENT="cloudsuite/web-serving:faban_client"

        NAME_DB_SERVER="mysql_server"
        NAME_MEMCACHED_SERVER="memcache_server"
        NAME_WEB_SERVER="web_server"
        NAME_CLIENT="faban_client"

        WEB_SERVER_IP=220.149.236.109

        DATABASE_SERVER_IP=127.0.0.1
        MEMCACHED_SERVER_IP=127.0.0.1
        MAX_PM_CHILDREN=80 # pm.max_children in the php-fpm setting. The default value is 80.
        LOAD_SCALE=`nproc`

        echo ""
        clear_container ${NETWORK}
        echo ""
        echo "  ok .. ready to commit ${OP_TYPE} experiment !!!"
        echo ""

        # get docker server image
        echo ""
        echo "  obtaining docker image and dataset ... ${DOCKER_IMAGE_DB_SERVER}"
        sudo docker pull ${DOCKER_IMAGE_DB_SERVER}
        echo ""
        echo "  obtaining docker image and dataset ... ${DOCKER_IMAGE_MEMCACHED_SERVER}"
        sudo docker pull ${DOCKER_IMAGE_MEMCACHED_SERVER}
        echo ""
        echo "  obtaining docker image and dataset ... ${DOCKER_IMAGE_WEB_SERVER}"
        sudo docker pull ${DOCKER_IMAGE_WEB_SERVER}
        echo ""
        echo "  obtaining docker image and dataset ... ${DOCKER_IMAGE_CLIENT}"
        sudo docker pull ${DOCKER_IMAGE_CLIENT}
                
        # start db server 
        echo ""
        echo "  start ${DOCKER_IMAGE_DB_SERVER} container ..."
        sudo docker run -dt --net=${NETWORK} --name=${NAME_DB_SERVER} ${DOCKER_IMAGE_DB_SERVER} ${WEB_SERVER_IP} 
        sleep 2

        # start memcached server
        echo ""
        echo "  start ${DOCKER_IMAGE_MEMCACHED_SERVER} container ..."
        sudo docker run -dt --net=${NETWORK} --name=${NAME_MEMCACHED_SERVER} ${DOCKER_IMAGE_MEMCACHED_SERVER} 
        sleep 2

        # start seb server
        echo ""
        echo "  start ${DOCKER_IMAGE_WEB_SERVER} container ..."      
        sudo docker run -dt --net=${NETWORK} --name=${NAME_WEB_SERVER} ${DOCKER_IMAGE_WEB_SERVER} /etc/bootstrap.sh ${DATABASE_SERVER_IP} ${MEMCACHED_SERVER_IP} ${MAX_PM_CHILDREN}
        sleep 2

        # system status
#        source ./_check.sh > ${DIR_SYS}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}-before.dat         

        echo ""
        echo "  start ${DOCKER_IMAGE_CLIENT} container ..."
        echo "  running ${OP_TYPE} experiment ..."      
        # run
        # start client
        sudo perf stat -e ${PMU_S} -o ${DIR_PERF}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}.dat -a docker run --net=${NETWORK} -v  ${DIR_RUN}/${OP_TYPE}/${HP_TYPE}:/faban/output --name=${NAME_CLIENT} ${DOCKER_IMAGE_CLIENT} ${WEB_SERVER_IP} ${LOAD_SCALE} 

        # system status
#        source ./_check.sh > ${DIR_SYS}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}-after.dat

        echo ""
        clear_container ${NETWORK}
        echo ""

        ;;
esac

SON_EXPR="son_expr"
SON_EXPR_PID=$(pgrep ${SON_EXPR})
kill -2 ${SON_EXPR_PID}

