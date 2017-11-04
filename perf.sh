#!/bin/bash
# perf event list
PERF_EVENT_LIST="dTLB-loads,dTLB-load-misses,dTLB-stores,dTLB-store-misses,iTLB-loads,iTLB-load-misses,cache-misses,page-faults,cycles"
# LLC-loads,LLC-load-misses

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
#  -------------------------------------------------------------------------------------------``
# | CPU name:  Intel(R) Core(TM) i7-6700 CPU @ 3.40GHz    |
# | CPU type:  Intel Skylake processor                    |
#  ------------------------------------------------------

# Counts the number of thread cycles while the thread is not in a halt state. 
# The thread enters the halt state when it is running the HLT instruction. The core
# frequency may change from time to time due to power or thermal throttling
# CPU_CLK_UNHALTED.THREAD_P
#  umask=00H
#  eventnum=3CH
PMU_D_CYCLE="r003C"

# Number of instructions at retirement.
# INST_RETIRED.ANY_P
#  umask=00H
#  eventnum=c0H
PMU_D_INST_RETIRED="r00C0"

# Load misses in all TLB levels that cause a page walk of any page size -> o
# DTLB_LOAD_MISSES.MISS_CAUSES_A_WALK
#   umask=01H
#   eventnum=08H
PMU_D_DTLB_LMPW="r0108"

# Store misses in all TLB levels that cause page walks. -> o
# DTLB_STORE_MISSES.MISS_CAUSES_A_WALK
#   umask=01H
#   eventnum=49H
PMU_D_DTLB_SMPW="r0149"

# Misses at all ITLB levels that cause page walks. -> o
# ITLB_MISSES.MISS_CAUSES_A_WALK
#   umask=01H
#   eventnum=85H
PMU_D_ITLB_MPW="r0185"

# Counts 1 per cycle for each PMH that is busy with a page walk for a load. -> ?
# DTLB_LOAD_MISSES.WALK_PENDING
#  umask=10H
#  eventnum=08H
PMU_D_DTLB_LMWD="r1008"

# Cycles when at least one PMH is busy with a page walk for a store. -> ?
# Counts 1 per cycle for each PMH that is busy with a page walk for a store.
# DTLB_STORE_MISSES.WALK_ACTIVE
# DTLB_STORE_MISSES.WALK_PENDING
#  umask=10H
#  eventnum=49H
PMU_D_DTLB_SMWD="r1049"

# Counts 1 per cycle for each PMH that is busy with a page walk for an instruction fetch request. -> ?
# ITLB_MISSES.WALK_PENDING
#  umask=10H
#  eventnum=85H
PMU_D_ITLB_MWD="r1085"

# Load misses in all TLB levels causes a page walk that completes. (All page sizes.) ->0EH
# DTLB_LOAD_MISSES.WALK_COMPLETED
#  umask=02H/04H/08H/0eH
#  eventnum=08H
PMU_D_DTLB_LMWC_4K="r0208"
PMU_D_DTLB_LMWC_2M="r0408"
PMU_D_DTLB_LMWC_1G="r0808"
PMU_D_DTLB_LMWC_ALL="r0e08"

# Counts completed page walks in any TLB levels due to store misses (all page sizes). ->0EH
# DTLB_STORE_MISSES.WALK_DURATION
#  umask=02H/04H/08H/0eH
#  eventnum=49H
PMU_D_DTLB_SMWC_4K="r0249"
PMU_D_DTLB_SMWC_2M="r0449"
PMU_D_DTLB_SMWC_1G="r0849"
PMU_D_DTLB_SMWC_ALL="r0e49"

# Counts completed page walks in any TLB level due to code fetch misses -> 0EH
# ITLB_MISSES.WALK_COMPLETED
#  umask=02H/04H/08H/0eH
#  eventnum=85H 
PMU_D_ITLB_MWC_4K="r0285"
PMU_D_ITLB_MWC_2M="r0485"
PMU_D_ITLB_MWC_1G="r0885"
PMU_D_ITLB_MWC_ALL="r0e85"


PMU_D=${PERF_EVENT_LIST},${PMU_D_CYCLE},${PMU_D_INST_RETIRED},${PMU_D_DTLB_LMPW},${PMU_D_DTLB_SMPW},${PMU_D_ITLB_MPW},${PMU_D_DTLB_LMWD},${PMU_D_DTLB_SMWD},${PMU_D_ITLB_MWD},${PMU_D_DTLB_LMWC_ALL},${PMU_D_DTLB_SMWC_ALL},${PMU_D_ITLB_MWC_ALL}

