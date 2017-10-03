#!/bin/bash
set -e
set -x

# perf event list
PERF_EVENT_LIST="dTLB-loads,dTLB-load-misses,dTLB-stores,dTLB-store-misses,iTLB-loads,iTLB-load-misses,cache-misses,page-faults,cycles"

# ============================================================================================
# (%) Cycles spent in page walks = (DTLB_LOAD_MISSES.WALK_DURATION + DTLB_STORE_MISSES.WALK_DURATION) /
#     due to data accesses          CPU_CLK_UNHALTED.THREAD_P

# (%) Cycles spent in page walks = (ITLB_MISSES.WALK_DURATION / CPU_CLK_UNHALTED.THREAD_P)
#     due to instruction accesses  

# Average cycles per page walk   = (DTLB_LOAD_MISSES.WALK_DURATION + DTLB_STORE_MISSES.WALK_DURATION) /
# due to data accesses             (DTLB_LOAD_MISSES.WALK_COMPLETED +DTLB_STORE_MISSES.WALK_COMPLETED)

# Average cycles per page walk   = (ITLB_MISSES.WALK_DURATION / ITLB_MISSES.WALK_COMPLETED)
# due to instruction accesses 


#  --------------------------------------------------------------------------------------------
# | CPU name:   Intel(R) Xeon(R) CPU E7-4809 v4 @ 2.10GHz |
# | CPU type:   Intel Xeon Broadwell EN/EP/EX processor   |
# ------------------------------------------------------- 

# Counts the number of thread cycles while the thread is not in a halt state. 
# The thread enters the halt state when it is running the HLT instruction. The core
# frequency may change from time to time due to power or thermal throttling
# CPU_CLK_UNHALTED.THREAD_P
#  umask=00H
#  eventnum=3CH
PMU_S_CYCLE="r003C"

# Number of instructions at retirement.
# INST_RETIRED.ANY_P
#  umask=00H
#  eventnum=c0H
PMU_S_INST_RETIRED="r00C0"

# Load misses in all TLB levels that cause a page walk of any page size
# DTLB_LOAD_MISSES.MISS_CAUSES_A_WALK
#   umask=01H
#   eventnum=08H
PMU_S_DTLB_LMPW="r0108"

# Miss in all TLB levels causes a page walk of any page size (4K/2M/4M/1G).
# DTLB_STORE_MISSES.MISS_CAUSES_A_WALK
#   umask=01H
#   eventnum=49H
PMU_S_DTLB_SMPW="r0149"

# Misses in ITLB that cause a page walk of any page size.
# ITLB_MISSES.MISS_CAUSES_A_WALK
#   umask=01H
#   eventnum=85H
PMU_S_ITLB_MPW="r0185"

# Cycle PMH is busy with a walks
# DTLB_LOAD_MISSES.WALK_DURATION
#  umask=10H
#  eventnum=08H
PMU_S_DTLB_LMWD="r1008"

# Cycles PMH is busy with this walk.
# DTLB_STORE_MISSES.WALK_DURATION
#  umask=10H
#  eventnum=49H
PMU_S_DTLB_SMWD="r1049"

# Cycle PMH is busy with a walk.
# ITLB_MISSES.WALK_DURATION
#  umask=10H
#  eventnum=85H
PMU_S_ITLB_MWD="r1085"

# Completed page walks due to demand load missesthat caused 4K page walks in any TLB levels.
# DTLB_LOAD_MISSES.WALK_COMPLETED_4K
#  umask=02H/04H/08H/0eH
#  eventnum=08H
PMU_S_DTLB_LMWC="r0e08"

# Completed page walks due to store misses in one or more TLB levels of 4K page structure.
# DTLB_STORE_MISSES.WALK_COMPLETED_4K 
#  umask=02H/04H/08H/0eH
#  eventnum=49H
PMU_S_DTLB_SMWC="r0e49"

# Completed page walks due to misses in ITLB 4K page entries.
# ITLB_MISSES.WALK_COMPLETED_4K
#  umask=02H/04H/08H/0eH
#  eventnum=85H
PMU_S_ITLB_MWC="r0e85"

PMU_S=${PERF_EVENT_LIST},${PMU_S_CYCLE},${PMU_S_INST_RETIRED},${PMU_S_DTLB_LMPW},${PMU_S_DTLB_SMPW},${PMU_S_ITLB_MPW},${PMU_S_DTLB_LMWD},${PMU_S_DTLB_SMWD},${PMU_S_ITLB_MWD},${PMU_S_DTLB_LMWC},${PMU_S_DTLB_SMWC},${PMU_S_ITLB_MWC}


apt-get update 
#apt-get install ssh 
#scp son@220.149.236.109:/home/son .
apt-get install -y linux-tools-common linux-tools-generic linux-tools-`uname -r`

mkdir perf


mkdir out

DIR_CUR=$(pwd)
DIR_PERF=${DIR_CUR}/perf
DIR_RUN=${DIR_CUR}/out
DIR_SYS=${DIR_SYS}/sys

if [ ! -d $DIR_PERF ]
then 
	mkdir perf
fi

if [ ! -d $DIR_RUN ]
then 
	mkdir out
fi

if [ ! -d $DIR_SYS ]
then
    mkdir sys
fi

if [ "$1" = '-rps' ]; then
	# default configuration
	echo "dc-server, 11211" > "/usr/src/memcached/memcached_client/servers.txt"
	/usr/src/memcached/memcached_client/loader \
		-a /usr/src/memcached/twitter_dataset/twitter_dataset_unscaled \
		-o /usr/src/memcached/twitter_dataset/twitter_dataset_5x \
		-s /usr/src/memcached/memcached_client/servers.txt \
		-w 4 -S 5 -D 2048 -j

	/usr/src/memcached/memcached_client//loader \
		-a /usr/src/memcached/twitter_dataset/twitter_dataset_5x \
		-s /usr/src/memcached/memcached_client/servers.txt \
		-g 0.8 -c 200 -w 4 -e -r "$2" -t 123 -T 120

else
	# custom command
	THREAD_NUM=4
	THREAD_NUM_2=8
	SCALING_FACTOR=30
	TARGET_SERVER_MEMORY=257852 #MB
	STATISTICS_INTERVAL=1
	GET_SET_RATIO=0.8
	CONNECTION_NUM=200		

	echo "dc-server, 11211" > "/usr/src/memcached/memcached_client/docker_servers.txt"
	/usr/src/memcached/memcached_client/loader \
		-a /usr/src/memcached/twitter_dataset/twitter_dataset_unscaled \
		-o /usr/src/memcached/twitter_dataset/twitter_dataset_30x \
		-s /usr/src/memcached/memcached_client/docker_servers.txt \
		-w ${THREAD_NUM} -S ${SCALING_FACTOR} -D ${TARGET_SERVER_MEMORY} -j -T ${STATISTICS_INTERVAL}

    source ./_check.sh > ${DIR_SYS}/sys_before.dat 
	perf stat -e ${PMU_S} -o ${DIR_PERF}/perf_memcached.dat -a /usr/src/memcached/memcached_client//loader \
		-a /usr/src/memcached/twitter_dataset/twitter_dataset_30x \
		-s /usr/src/memcached/memcached_client/docker_servers.txt \
		-g ${GET_SET_RATIO} -T ${STATISTICS_INTERVAL} -c ${CONNECTION_NUM} -w ${THREAD_NUM_2} > ${DIR_RUN}/run_memcached.dat
    source ./_check.sh > ${DIR_SYS}/sys_after.dat    

#	exec "$@"
fi


#usage: loader [-option]
#        [-a arg  input distribution file]
#        [-c arg  total number of connections]
#        [-d arg  value size distribution file]
#        [-D arg  size of main memory available to each memcached server in MB]
#        [-e use  an exponential arrival distribution (default: constant)]
#        [-f arg  fixed object size]
#        [-k arg  num keys (default: 1000)]
#        [-g arg  fraction of requests that are gets (The rest are sets)]
#        [-h prints this message]
#        [-j preload data]
#        [-l arg use a fixed number of gets per multiget]
#        [-m arg fraction of requests that are multiget]
#        [-n enable naggle's algorithm]
#        [-N arg provide a key population distribution file]
#        [-u use UDP protocl (default: TCP)]
#        [-o arg  ouput distribution file, if input needs to be scaled]
#        [-r ATTEMPTED requests per second (default: max out rps)]
#        [-s server configuration file]
#        [-S dataset scaling factor]
#        [-t arg  runtime of loadtesting in seconds (default: run forever)]
#        [-T arg  interval between stats printing (default: 1)]
#        [-w number of worker threads]
#        [-x run timing tests instead of loadtesting]

