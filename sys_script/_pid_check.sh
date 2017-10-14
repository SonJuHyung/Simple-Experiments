#!/bin/bash 


#awk '$3=="kB"{if ($2>1024**2){$2=$2/1024**2;$3="GB";} else if ($2>1024){$2=$2/1024;$3="MB";}} 1' /proc/meminfo | column -t | grep Available

if [ $# -eq 0 ]
then 
    echo "process name must be specified" 
    exit 
fi

PID=0
NAME=""

usage()
{
    echo ""
    echo "  usage : # ./_pid_check.sh -n redis-server"   
    echo "        : # ./_pid_check.sh -p pid"
    echo ""
}

while getopts n:p: opt 
do
    case $opt in
        n)
            NAME=$OPTARG
            ;;
        p)
            PID=$OPTARG
            ;;
        *)
            usage 
            exit 0
            ;;
    esac
done

if [ $PID -ne 0 ]
then


    echo ""
    echo "${PID} memory usage info"
    echo "  PID          : ${PID}"
    # calculate anonymous page

    VMSIZE_KB=$(cat /proc/${PID}/status | grep -i vmsize | awk '{ split($0,arr," "); \
                                                                  printf("%s %s",arr[2],arr[3]); \
                                                                }')
    VMSIZE=$(echo ${VMSIZE_KB} | awk '$2=="kB"{ \
                                                if ($1>1024**2){ \
                                                    $1=$1/1024**2;$2="GB"; \
                                                } else if ($1>1024){ $1=$1/1024;$2="MB";} { \
                                                    printf("%011.6f %s",$1,$2); \
                                                } \
                                              }')  
     
    VMRSS_KB=$(cat /proc/${PID}/status | grep -i vmrss | awk '{ split($0,arr," "); \
                                                                printf("%s %s",arr[2],arr[3]); \
                                                              };')
    VMRSS=$(echo ${VMRSS_KB} | awk '$2=="kB"{ \
                                                if ($1>1024**2){ \
                                                    $1=$1/1024**2;$2="GB"; \
                                                } else if ($1>1024){  $1=$1/1024;$2="MB";} { \
                                                    printf("%011.6f %s",$1,$2); \
                                                } \
                                            }')  

    ANONYMOUS_PAGE_KB=$(cat /proc/${PID}/smaps | grep "Anonymous" | awk 'BEGIN {  anony_sum=0; } \
                                                                            { split($0,arr," "); anony_sum += arr[2];} \
                                                                      END   { printf("%d kB",anony_sum); }')
    ANONYMOUS_PAGE=$(echo ${ANONYMOUS_PAGE_KB} | awk '$2=="kB"{ if ($1>1024**2) { \
                                                                    $1=$1/1024**2;$2="GB"; \
                                                                } else if ($1>1024){ $1=$1/1024;$2="MB";} { \
                                                                    printf("%011.6f %s",$1,$2); \
                                                                } \
                                                              }') 

    # calculage anonymous huge page
    ANONYMOUS_HUGE_KB=$(cat /proc/${PID}/smaps | grep "AnonHugePages" | awk 'BEGIN { \
                                                                                anony_huge_sum=0; \
                                                                            } \
                                                                            { \
                                                                                split($0,arr," "); \
                                                                                anony_huge_sum += arr[2]; \
                                                                            } \
                                                                      END   { \
                                                                                printf("%d kB",anony_huge_sum); \
                                                                            }')    
    ANONYMOUS_HUGE=$(echo ${ANONYMOUS_HUGE_KB} | awk '$2=="kB"{ if ($1>1024**2){ \
                                                                    $1=$1/1024**2;$2="GB"; \
                                                                } else if ($1>1024){ $1=$1/1024;$2="MB";} { \
                                                                    printf("%011.6f %s",$1,$2); \
                                                                } \
                                                              }')

    ANONYMOUS_PAGE_RATIO=$(echo "${ANONYMOUS_PAGE_KB} ${VMSIZE_KB}" | awk 'BEGIN { avg=0.0;} { split($0,arr," "); avg=arr[1]/arr[3]*100.0 } END { printf("%05.3f",avg)}')
    ANONYMOUS_HUGE_RATIO=$(echo "${ANONYMOUS_HUGE_KB} ${ANONYMOUS_PAGE_KB}" | awk 'BEGIN { avg=0.0;} { split($0,arr," "); avg=arr[1]/arr[3]*100.0 } END { printf("%05.3f",avg)}')

    echo "  VmSize       : ${VMSIZE}    (${VMSIZE_KB})"
    echo "  VmRss        : ${VMRSS}    (${VMRSS_KB})    [VmRssAnon + RssFile + RssShmem]"
    echo "  AnonPage     : ${ANONYMOUS_PAGE}    (${ANONYMOUS_PAGE_KB})    [AnonPage/VmSize : ${ANONYMOUS_PAGE_RATIO} %] "
    echo "  AnonHugePage : ${ANONYMOUS_HUGE}    (${ANONYMOUS_HUGE_KB})    [AnonPage/AnonHugePage : ${ANONYMOUS_HUGE_RATIO} %]"

    echo""
    echo "${VMSIZE_KB}" | awk '{ split($0,arr," ");printf("%d\n",arr[1]);}'
    echo "${VMRSS_KB}" | awk '{ split($0,arr," ");printf("%d\n",arr[1]);}'
    echo "${ANONYMOUS_PAGE_KB}" | awk '{ split($0,arr," ");printf("%d\n",arr[1]);}'
    echo "${ANONYMOUS_HUGE_KB}" | awk '{ split($0,arr," ");printf("%d\n",arr[1]);}' 
    echo ""

    exit 0
fi

PROCESS_NAME=$NAME 
PID_CONTEXT=$(pgrep ${PROCESS_NAME}) 
if [ ${#PID_CONTEXT} -ne 0 ]
then 
    echo ""
    echo "${PROCESS_NAME} detected"  
    PID=${PID_CONTEXT}
#    PID=$(echo $PID_CONTEXT | awk '{ split($0,arr," "); printf("%s",arr[2]);  }')
    echo ""
    echo "${PROCESS_NAME} memory usage info"
    echo "  PID          : ${PID}"
    # calculate anonymous page

    VMSIZE_KB=$(cat /proc/${PID}/status | grep -i vmsize | awk '{ split($0,arr," "); \
                                                                  printf("%s %s",arr[2],arr[3]); \
                                                                }')
    VMSIZE=$(echo ${VMSIZE_KB} | awk '$2=="kB"{ \
                                                if ($1>1024**2){ \
                                                    $1=$1/1024**2;$2="GB"; \
                                                } else if ($1>1024){ $1=$1/1024;$2="MB";} { \
                                                    printf("%011.6f %s",$1,$2); \
                                                } \
                                              }')  
     
    VMRSS_KB=$(cat /proc/${PID}/status | grep -i vmrss | awk '{ split($0,arr," "); \
                                                                printf("%s %s",arr[2],arr[3]); \
                                                              };')
    VMRSS=$(echo ${VMRSS_KB} | awk '$2=="kB"{ \
                                                if ($1>1024**2){ \
                                                    $1=$1/1024**2;$2="GB"; \
                                                } else if ($1>1024){  $1=$1/1024;$2="MB";} { \
                                                    printf("%011.6f %s",$1,$2); \
                                                } \
                                            }')  

    ANONYMOUS_PAGE_KB=$(cat /proc/${PID}/smaps | grep "Anonymous" | awk 'BEGIN {  anony_sum=0; } \
                                                                            { split($0,arr," "); anony_sum += arr[2];} \
                                                                      END   { printf("%d kB",anony_sum); }')
    ANONYMOUS_PAGE=$(echo ${ANONYMOUS_PAGE_KB} | awk '$2=="kB"{ if ($1>1024**2) { \
                                                                    $1=$1/1024**2;$2="GB"; \
                                                                } else if ($1>1024){ $1=$1/1024;$2="MB";} { \
                                                                    printf("%011.6f %s",$1,$2); \
                                                                } \
                                                              }') 

    # calculage anonymous huge page
    ANONYMOUS_HUGE_KB=$(cat /proc/${PID}/smaps | grep "AnonHugePages" | awk 'BEGIN { \
                                                                                anony_huge_sum=0; \
                                                                            } \
                                                                            { \
                                                                                split($0,arr," "); \
                                                                                anony_huge_sum += arr[2]; \
                                                                            } \
                                                                      END   { \
                                                                                printf("%d kB",anony_huge_sum); \
                                                                            }')    
    ANONYMOUS_HUGE=$(echo ${ANONYMOUS_HUGE_KB} | awk '$2=="kB"{ if ($1>1024**2){ \
                                                                    $1=$1/1024**2;$2="GB"; \
                                                                } else if ($1>1024){ $1=$1/1024;$2="MB";} { \
                                                                    printf("%011.6f %s",$1,$2); \
                                                                } \
                                                              }')
    
    ANONYMOUS_PAGE_RATIO=$(echo "${ANONYMOUS_PAGE_KB} ${VMSIZE_KB}" | awk 'BEGIN { avg=0.0;} { split($0,arr," "); avg=arr[1]/arr[3]*100.0 } END { printf("%05.3f",avg)}')
    ANONYMOUS_HUGE_RATIO=$(echo "${ANONYMOUS_HUGE_KB} ${ANONYMOUS_PAGE_KB}" | awk 'BEGIN { avg=0.0;} { split($0,arr," "); avg=arr[1]/arr[3]*100.0 } END { printf("%05.3f",avg)}')

    echo ""
    echo "  VmSize       : ${VMSIZE}    (${VMSIZE_KB})"
    echo "  VmRss        : ${VMRSS}    (${VMRSS_KB})    [VmRssAnon + RssFile + RssShmem]"
    echo "  AnonPage     : ${ANONYMOUS_PAGE}    (${ANONYMOUS_PAGE_KB})    [AnonPage/VmSize : ${ANONYMOUS_PAGE_RATIO} %] "
    echo "  AnonHugePage : ${ANONYMOUS_HUGE}    (${ANONYMOUS_HUGE_KB})    [AnonPage/AnonHugePage : ${ANONYMOUS_HUGE_RATIO} %]"
    echo ""

    echo""
    echo "${VMSIZE_KB}" | awk '{ split($0,arr," ");printf("%d\n",arr[1]);}'
    echo "${VMRSS_KB}" | awk '{ split($0,arr," ");printf("%d\n",arr[1]);}'
    echo "${ANONYMOUS_PAGE_KB}" | awk '{ split($0,arr," ");printf("%d\n",arr[1]);}'
    echo "${ANONYMOUS_HUGE_KB}" | awk '{ split($0,arr," ");printf("%d\n",arr[1]);}' 
    echo "" 

else
    echo "no such process"
    exit 0
fi

