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
    echo "          <workk loads>" 
    echo "                  data_analytics(MapReduce) - The Data Analytics benchmark is included in CloudSuite to cover the increasing importance of machine learning tasks analyzing large amounts of data in datacenters using the MapReduce framework."
    echo "                  data_caching(Memcached) - This benchmark uses the Memcached data caching server, simulating the behavior of a Twitter caching server using a twitter dataset."
    echo "                  data_serving(YCSB) - The data serving benchmark relies on the Yahoo! Cloud Serving Benchmark."
    echo "                  graph_analytics(Cloudsuite) - The Graph Analytics benchmark relies the Spark framework to perform graph analytics on large-scale datasets."
    echo "                  inmemory_analytics(Spark) - This benchmark uses Apache Spark and runs a collaborative filtering algorithm in-memory on a dataset of user-movie ratings."    
    echo "                  media_streaming(Nginx) - This benchmark uses the Nginx web server as a streaming server for hosted videos of various lengths and qualities."
    echo "                  web_search(Solr) - The benchmark includes a client machine that simulates real-world clients that send requests to the index nodes. The index nodes contain an index of the text and fields found in a set of crawled websites."    
    echo "                  web_serving"
    echo ""
    echo ""
}

function clear_container()
{
#    CONTEXT=$(sudo docker ps --filter status=running --format "table {{.Names}}")   
    CONTEXT=$(sudo docker ps -a --format "table {{.Names}}")   
    RUNNING_COUNT=$(echo ${CONTEXT} | awk '{ n=split($0,arr," "); } END{ printf("%s ", n-1); }') 
    RUNNING_LIST=$(echo ${CONTEXT} | awk '{ n=split($0,arr," "); } {for(i=2; i <= n ; i++) printf("%s ",arr[i]); }')  
    NETWORK=$1

    source ${FILE_PERF}
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
    
    echo -n "       removing ${NETWORK} ... "
    sudo docker network rm ${NETWORK}
    echo "       complete."

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
#            if [ $OPTARG == "data_analytics" ] || [ $OPTARG = "data_caching"] || [ $OPTARG == "data_serving"] || [ $OPTARG == "graph_analytics"] || [ $OPTARG == "inmemory_analytics"] || [ $OPTARG == "media_streaming"] || [ $OPTARG == "web_search"] || [ $OPTARG == "web_serving" ]
            if [ $OPTARG == "data_analytics" ] || [ $OPTARG == "data_caching" ]
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
            if [ $OPTARG == "nf" ] || [ $OPTARG == "f" ]
            then
                MFRG_TYPE=$OPTARG
            else

                echo "  error : mfrage must be nr of f"
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

#if [ -z ${HP_TYPE} ] || [ -z ${MFRG_TYPE} ] || [ -z ${OP_TYPE} ] || [ ${HP_TYPE} == "" ] || [ ${MFRG_TYPE} == ""] || [ ${OP_TYPE} == "" ]
if [ -z ${HP_TYPE} ] || [ -z ${MFRG_TYPE} ] || [ -z ${OP_TYPE} ]
then 
    usage 
    exit 0
fi

case ${OP_TYPE} in 
    "data_analytics")

        NETWORK="hadoop-net" 
        DOCKER_IMAGE_SERVER="cloudsuite/data_analytics"
        DOCKER_IMAGE_CLIENT="cloudsuite/hadoop"
        echo ""
        clear_container ${NETWORK}
        echo ""
        echo "  ok .. ready to commit data analytics experiment !!!"

        # docker image
        echo "  obtaining docker image ... ${DOCKER_IMAGE_1} , ${DOCKER_IMAGE_2}"
        $(sudo docker pull ${DOCKER_IMAGE_SERVER})
        $(sudo docker pull ${DOCKER_IMAGE_CLIENT})

        # create network
        echo "  creating network ... ${NETWORK}"
        $(sudo docker network create ${NETWORK})

        # create container
        echo "  start ${DOCKER_IMAGE_SERVER}, ${DOCKER_IMAGE_CLIENT} containers ..."
        sudo docker run -d --net ${NETWORK} --name master --hostname master ${DOCKER_IMAGE_SERVER} master
        sudo docker run -d --net ${NETWORK} --name slave01 --hostname slave01 ${DOCKER_IMAGE_CLIENT} slave
        sudo docker run -d --net ${NETWORK} --name slave02 --hostname slave02 ${DOCKER_IMAGE_CLIENT} slave 

        # system status
        source ./_check.sh > ${DIR_SYS}/${OP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}-before.dat
        # data_analytics experiment
        $(sudo perf stat -e ${PMU_S} -o ${DIR_PERF}/${OP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}.dat -a docker exec master benchmark > ${DIR_RUN}/${OP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}.dat)
        # system status
        source ./_check.sh > ${DIR_SYS}/${OP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}-after.dat

        echo ""
        clear_container ${NETWORK}
        echo ""

        ;;
    "data_caching")

        NETWORK="caching_network" 
        DOCKER_IMAGE_SERVER="cloudsuite/data-caching:server"        
        DOCKER_IMAGE_CLIENT="cloudsuite/data-caching:client"
        THREAD_NUM=4
        MEM_SIZE=257852 # MB unit
        OBJ_SIZE_MIN=550

        echo ""
        clear_container ${NETWORK}
        echo ""
        echo "  ok .. ready to commit data caching experiment !!!"
        echo ""

        # create network
        echo "  creating network ... ${NETWORK}"
        sudo docker network create ${NETWORK}

        # get docker server image
        echo "  obtaining docker image ... ${DOCKER_IMAGE_SERVER}"
        sudo docker pull ${DOCKER_IMAGE_SERVER}
        
        # start Memcached server container
        echo " start ${DOCKER_IMAGE_SERVER} container ..."
#        sudo docker run --name dc-server --net ${NETWORK} -d ${DOCKER_IMAGE_SERVER} -t $THREAD_NUM -m ${MEM_SIZE} -n ${OBJ_SIZE_MIN}
#        sudo docker run -u 0 --privileged --name dc-server --net ${NETWORK} -d ${DOCKER_IMAGE_SERVER} -t $THREAD_NUM -m ${MEM_SIZE} -n ${OBJ_SIZE_MIN}
        sudo docker run --name dc-server --net ${NETWORK} -d ${DOCKER_IMAGE_SERVER} -t $THREAD_NUM -m ${MEM_SIZE} -n ${OBJ_SIZE_MIN}

        echo ""
        # get docker client image
        echo "  obtaining docker image ... ${DOCKER_IMAGE_CLIENT} " 
        sudo docker pull ${DOCKER_IMAGE_CLIENT}
        # start Memcached client container
        echo " start ${DOCKER_IMAGE_CLIENT} container and login as memcached user..."
#        sudo docker run -u 0 --privileged -it --name dc-client --net ${NETWORK} ${DOCKER_IMAGE_CLIENT} /bin/bash
#        sudo docker run -u 0 --privileged --security-opt seccomp=my-seccomp.json -it --name dc-client --net ${NETWORK} ${DOCKER_IMAGE_CLIENT} /bin/bash
        sudo docker run -u 0 --privileged --security-opt seccomp=my-seccomp.json -v /home/son/workspace/cloudsuite/volume/:/son -it --name dc-client --net ${NETWORK} ${DOCKER_IMAGE_CLIENT} /bin/bash

        echo ""
        clear_container ${NETWORK}
        echo ""

        ;;
    "data_serving")
        ;;
    "graph_analytics")
        ;;
    "inmemory_analytics")
        ;;
    "media_streaming")
        ;;
    "web_search")
        ;;
    "web_serving")
        ;;
esac

