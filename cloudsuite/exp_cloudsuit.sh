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
    echo "                  data_analytics(MapReduce)"
    echo "                      The explosion of accessible human-generated information necessitates auto"
    echo "                      mated analytical processing to cluster, classify, and filter this informa"
    echo "                      tion. The MapReduce paradigm has emerged as a popular approach to handlin"
    echo "                      g large-scale analysis, farming out requests to a cluster of nodes that f"
    echo "                      irst perform filtering and transformation of the data (map) and then aggr"
    echo "                      egate the results (reduce). The Data Analytics benchmark is included in C"
    echo "                      loudSuite to cover the increasing importance of machine learning tasks an"
    echo "                      alyzing large amounts of data in datacenters using the MapReduce framewor"
    echo "                      k. It is composed of Mahout, a set of machine learning libraries, running" 
    echo "                      on top of Hadoop, an open-source implementation of MapReduce. The benchma"
    echo "                      rk consists of running a Naive Bayes classifier on a Wikimedia dataset. I"
    echo "                      t uses Hadoop version 2.7.3 and Mahout version 0.12.2."
    echo ""
    echo "                  data_caching(Memcached)"
    echo "                      This benchmark uses the Memcached data caching server, simulating the beh"
    echo "                      avior of a Twitter caching server using a twitter dataset. The metric of "
    echo "                      interest is throughput expressed as the number of requests served per sec"
    echo "                      ond. The workload assumes strict quality of service guarantees."
    echo ""
    echo "                  data_serving(YCSB)"
    echo "                      The data serving benchmark relies on the Yahoo! Cloud Serving Benchmark  "
    echo "                      (YCSB). YCSB is a framework to benchmark data store systems. This framewo"
    echo "                      rk comes with appropriate interfaces to populate and stress many popular "
    echo "                      data serving systems. Here we provide the instructions and pointers to do"
    echo "                      wnload and install YCSB and use it with the Cassandra data store."
    echo ""
    echo "                  graph_analytics(Cloudsuite)"
    echo "                      This repository contains the docker image for Cloudsuite’s Graph Analytic"
    echo "                      s benchmark.The Graph Analytics benchmark relies the Spark framework to p"
    echo "                      erform graph analytics on large-scale datasets. Apache provides a graph p"
    echo "                      rocessing library, GraphX, designed to run on top of Spark. The benchmark" 
    echo "                      performs PageRank on a Twitter dataset."
    echo ""
    echo "                  inmemory_analytics(Spark)"
    echo "                      This benchmark uses Apache Spark and runs a collaborative filtering algor"
    echo "                      ithm in-memory on a dataset of user-movie ratings. The metric of interest"
    echo "                      is the time in seconds of computing movie recommendations.The explosion o"
    echo "                      f accessible human-generated information necessitates automated analytica"
    echo "                      l processing to cluster, classify, and filter this information. Recommend"
    echo "                      er systems are a subclass of information filtering system that seek to pr"
    echo "                      edict the ‘rating’ or ‘preference’ that a user would give to an item. Rec"
    echo "                      ommender systems have become extremely common in recent years, and are ap"
    echo "                      plied in a variety of applications. The most popular ones are movies, mus"
    echo "                      ic, news, books, research articles, search queries, social tags, and prod"
    echo "                      ucts in general. Because these applications suffer from I/O operations, n"
    echo "                      owadays, most of them are running in memory. This benchmark runs the alte"
    echo "                      rnating least squares (ALS) algorithm which is provided by Spark MLlib."
    echo ""
    echo "                  media_streaming(Nginx)"
    echo "                      This benchmark uses the Nginx web server as a streaming server for hosted" 
    echo "                      videos of various lengths and qualities. The client, based on httperf’s w"
    echo "                      sesslog session generator, generates a request mix for different videos, "
    echo "                      to stress the server."
    echo ""
    echo "                  web_search(Solr)"
    echo "                      This repository contains the docker image for Cloudsuite’s Web Search ben"
    echo "                      chmark.The Web Search benchmark relies on the Apache Solr search engine f"
    echo "                      ramework. The benchmark includes a client machine that simulates real-wor"
    echo "                      ld clients that send requests to the index nodes. The index nodes contain" 
    echo "                      an index of the text and fields found in a set of crawled websites."
    echo ""
    echo "                  web_serving"
    echo "                      Web Serving is a main service in the cloud. Traditional web services with"
    echo "                      dynamic and static content are moved into the cloud to provide fault-tole"
    echo "                      rance and dynamic scalability by bringing up the needed number of servers" 
    echo "                      behind a load balancer. Although many variants of the traditional web sta"
    echo "                      ck are used in the cloud (e.g., substituting Apache with other web server" 
    echo "                      software or using other language interpreters in place of PHP), the under"
    echo "                      lying service architecture remains unchanged. Independent client requests" 
    echo "                      are accepted by a stateless web server process which either directly serv"
    echo "                      es static files from disk or passes the request to a stateless middleware"
    echo "                      script, written in a high-level interpreted or byte-code compiled languag"
    echo "                      e, which is then responsible for producing dynamic content. All the state"
    echo "                      information is stored by the middleware in backend databases such as clou"
    echo "                      d NoSQL data stores or traditional relational SQL servers supported by ke"
    echo "                      y-value cache servers to achieve high throughput and low latency. This be"
    echo "                      nchmark includes a social networking engine (Elgg) and a client implement"
    echo "                      ed using the Faban workload generator."
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
        MEM_SIZE=8192 # MB unit
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
        DRIVER_MEMORY="8g" # Amount of memory to use for the driver process,
        EXECUTOR_MEMORY="8g" # Amount of memory to use per executor process (e.g. 2g, 8g). 
#        DRIVER_MEMORY="1g" # Amount of memory to use for the driver process,
#        EXECUTOR_MEMORY="4g" # Amount of memory to use per executor process (e.g. 2g, 8g).
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
        sudo perf stat -e ${PMU_S} -o ${DIR_PERF}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}.dat -a docker run --rm --volumes-from ${NAME_DATA} ${DOCKER_IMAGE_SERVER} --driver-memory ${DRIVER_MEMORY} --executor-memory ${EXECUTOR_MEMORY} > ${DIR_RUN}/${OP_TYPE}/${HP_TYPE}/${OP_TYPE}-${HP_TYPE}-${MFRG_TYPE}.dat

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
        DRIVER_MEMORY="8g" # Amount of memory to use for the driver process,
        EXECUTOR_MEMORY="8g" # Amount of memory to use per executor process (e.g. 2g, 8g). 
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

PERF="perf"
PERF_PID=$(pgrep ${PERF})
kill -TERM ${PERF_PID}

