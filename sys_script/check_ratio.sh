#!/bin/bash 
MAX_ANON=0
MAX_HUGE=0
MAX_RATIO=0

VALUE_ANON=0
VALUE_HUGE=0
VALUE_RATIO=0

CONTEXT_ANON_FIRST=$(cat /proc/meminfo | column -t | grep "AnonPages")
VALUE_ANON_FIRST=$(echo ${CONTEXT_ANON_FIRST} | awk '{split($0,arr," "); printf("%s",arr[2])}')

#echo ${CONTEXT_ANON_VALUE} 
CONTEXT_HUGE_FIRST=$(cat /proc/meminfo | column -t | grep "AnonHugePages")
VALUE_HUGE_FIRST=$(echo ${CONTEXT_HUGE_FIRST} | awk '{split($0,arr," "); printf("%s",arr[2])}')


while :
do
    #cat /proc/meminfo | column -t | grep Available
    #cat /proc/meminfo | column -t | grep Anon 

    CONTEXT_ANON=$(cat /proc/meminfo | column -t | grep "AnonPages")
    VALUE_ANON=$(echo ${CONTEXT_ANON} | awk '{split($0,arr," "); printf("%s",arr[2])}')
    ((VALUE_ANON=${VALUE_ANON}-${VALUE_ANON_FIRST}))

##    #echo ${CONTEXT_ANON_VALUE} 
##    CONTEXT_HUGE=$(cat /proc/meminfo | column -t | grep "AnonHugePages")
##    VALUE_HUGE=$(echo ${CONTEXT_HUGE} | awk '{split($0,arr," "); printf("%s",arr[2])}')
##    ((VALUE_HUGE=${VALUE_HUGE}-${VALUE_HUGE_FIRST}))


##    if ((${VALUE_ANON} > ${MAX_ANON})) && ((${VALUE_ANON} > 0)) && ((${VALUE_HUGE} > 0))
##    then
##        MAX_ANON=${VALUE_ANON}
##        MAX_HUGE=${VALUE_HUGE}
##        MAX_RATIO=$(echo ${VALUE_ANON} ${VALUE_HUGE} | awk '{printf("%4.2f",$2*100.0/$1)}')
###        ((MAX_RATIO=${MAX_HUGE}*100.0/${MAX_ANON}))
##        printf "\r MAX: %s / %s / %s %%" ${MAX_ANON} ${MAX_HUGE} ${MAX_RATIO}
##    fi

    if ((${VALUE_ANON} > ${MAX_ANON})) && ((${VALUE_ANON} > 0))
    then
        MAX_ANON=${VALUE_ANON} 

        #echo ${CONTEXT_ANON_VALUE} 
        CONTEXT_HUGE=$(cat /proc/meminfo | column -t | grep "AnonHugePages")
        VALUE_HUGE=$(echo ${CONTEXT_HUGE} | awk '{split($0,arr," "); printf("%s",arr[2])}')
        ((VALUE_HUGE=${VALUE_HUGE}-${VALUE_HUGE_FIRST}))
        MAX_HUGE=${VALUE_HUGE}
        MAX_RATIO=$(echo ${VALUE_ANON} ${VALUE_HUGE} | awk '{printf("%4.2f",$2*100.0/$1)}')
        printf "\r MAX: %s / %s / %s %%" ${MAX_ANON} ${MAX_HUGE} ${MAX_RATIO}

#        printf "\r MAX: %s KB" ${MAX_ANON} 
    fi

done
