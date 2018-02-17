#!/bin/bash

function clear_container()
{
#    CONTEXT=$(sudo docker ps --filter status=running --format "table {{.Names}}")   
    CONTEXT=$(sudo docker ps -a --format "table {{.Names}}")   
    RUNNING_COUNT=$(echo ${CONTEXT} | awk '{ n=split($0,arr," "); } END{ printf("%s ", n-1); }') 
    RUNNING_LIST=$(echo ${CONTEXT} | awk '{ n=split($0,arr," "); } {for(i=2; i <= n ; i++) printf("%s ",arr[i]); }')  

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
   
}

clear_container 

##docker run -dt --net=host --name=mysql_server cloudsuite/web-serving:db_server 220.149.250.11
##docker run -dt --net=host --name=memcache_server cloudsuite/web-serving:memcached_server
##docker run -dt --net=host --name=web_server cloudsuite/web-serving:web_server /etc/bootstrap.sh 127.0.0.1 127.0.0.1 80
##docker run -v /home/son/workspace/cloudsuite/run/web_serving/thp:/faban/output --net=host --name=faban_client cloudsuite/web-serving:faban_client 220.149.250.11 7

