
#include "thp.h"

//double get_timeval_sec(struct timeval *tv, struct timeval *tv_end){
//
//    double tv_s = tv->tv_sec + (tv->tv_usec / 1000000.0);
//    double tv_e = tv_end->tv_sec + (tv_end->tv_usec / 1000000.0);
//
//    return (tv_e - tv_s);
//}
//
//double get_timeval_usec(struct timeval *tv, struct timeval *tv_end){
//
//    double tv_s = tv->tv_sec * 1000000.0 + tv->tv_usec;
//    double tv_e = tv_end->tv_sec * 1000000.0 + tv_end->tv_usec;
//
//    return (tv_e - tv_s);
//}

void thp_ex_usage(char *cmd)
{
    fprintf(stdout,"\n Usage for %s : \n",cmd); 
    fprintf(stdout,"    -a: memory size to allocate in GB unit ( e.g. 4 )\n");
    fprintf(stdout,"    -t: memory access pattern type ( e.g. random, stride )\n");
    fprintf(stdout,"    -f: random dataset filename ( e.g. data/thp_rand_set_1.txt ) \n"); 
    fprintf(stdout,"    -s: stride pattern  (default node size : 4K )\n");
    fprintf(stdout,"    -d: debug mode output \n");

}

void thp_ex_example(char *cmd)
{
    fprintf(stdout,"\n Example : \n");
    fprintf(stdout,"    #sudo %s -a 4 -t stride -s 1 \n", cmd);
    fprintf(stdout,"    #sudo %s -a 4 -t random -f data/thp_rand_set_1.txt -d \n\n", cmd);
}


double get_timeval_sec(struct timeval *tv){
    return (tv->tv_sec + (tv->tv_usec / 1000000.0));
}

double get_timeval_usec(struct timeval *tv){
    return ((tv->tv_sec * 1000000.0) + tv->tv_usec);
}

int timeval_subtract(struct timeval *result, struct timeval *x, struct timeval *y)
{
	/* Perform the carry for the later subtraction by updating y. */
	if (x->tv_usec < y->tv_usec) {
		int nsec = (y->tv_usec - x->tv_usec) / 1000000 + 1;
		y->tv_usec -= 1000000 * nsec;
		y->tv_sec += nsec;
	}
	if (x->tv_usec - y->tv_usec > 1000000) {
		int nsec = (x->tv_usec - y->tv_usec) / 1000000;
		y->tv_usec += 1000000 * nsec;
		y->tv_sec -= nsec;
	}

	/* Compute the time remaining to wait.
	*      tv_usec is certainly positive. */
	result->tv_sec = x->tv_sec - y->tv_sec;
	result->tv_usec = x->tv_usec - y->tv_usec;

	/* Return 1 if result is negative. */
	return x->tv_sec < y->tv_sec;
}

void rusage_diff(struct rusage *x, struct rusage *y, struct rusage *result)
{
	timeval_subtract(&result->ru_stime,
			 &y->ru_stime,
			 &x->ru_stime);

	timeval_subtract(&result->ru_utime,
			 &y->ru_utime,
			 &x->ru_utime);

	result->ru_maxrss = y->ru_maxrss - x->ru_maxrss;        /* maximum resident set size */
	result->ru_ixrss = y->ru_ixrss - x->ru_ixrss;         /* integral shared memory size */
	result->ru_idrss = y->ru_idrss - x->ru_idrss;         /* integral unshared data size */
	result->ru_isrss = y->ru_isrss - x->ru_isrss;         /* integral unshared stack size */
	result->ru_minflt = y->ru_minflt - x->ru_minflt;        /* page reclaims (soft page faults) */
	result->ru_majflt = y->ru_majflt - x->ru_majflt;        /* page faults (hard page faults) */
	result->ru_nswap = y->ru_nswap - x->ru_nswap;         /* swaps */
	result->ru_inblock = y->ru_inblock - x->ru_inblock;       /* block input operations */
	result->ru_oublock = y->ru_oublock - x->ru_oublock;       /* block output operations */
	result->ru_msgsnd = y->ru_msgsnd - x->ru_msgsnd;        /* IPC messages sent */
	result->ru_msgrcv = y->ru_msgrcv - x->ru_msgrcv;        /* IPC messages received */
	result->ru_nsignals = y->ru_nsignals - x->ru_nsignals;      /* signals received */
	result->ru_nvcsw = y->ru_nvcsw - x->ru_nvcsw;         /* voluntary context switches */
	result->ru_nivcsw = y->ru_nivcsw - x->ru_nivcsw;        /* involuntary context switches */
}

void print_status(unsigned long long count, unsigned long long index,struct rusage *ru_result, double *stime_usec_sum, double *utime_usec_sum, long *minflt_sum, long *majflt_sum, int debug){ 

    unsigned long long kb, mb, gb, tmp_index; 
    double utime_usec = get_timeval_usec(&ru_result->ru_utime);
    double stime_usec = get_timeval_usec(&ru_result->ru_stime);
    *utime_usec_sum += utime_usec;
    *stime_usec_sum += stime_usec;
    long minflt = ru_result->ru_minflt;
    long majflt = ru_result->ru_majflt;
    *minflt_sum += minflt;
    *majflt_sum += majflt;

    gb = index / GB;
    tmp_index = index % GB;

    mb = tmp_index / MB;
    tmp_index = tmp_index % MB;

    kb = tmp_index / KB;
    tmp_index = tmp_index % KB;

    if(debug){
//        fprintf(stdout,"%llu GB, %llu MB, %llu KB, %lf utime_usec,%lf stime_usec,%ld min fault,%ld maj fault \n", gb, mb, kb,utime_usec_sum,stime_usec_sum,total_minflt,total_majflt); 
        fprintf(stdout,"%llu count,%llu,%llu GB,%llu MB,%llu KB,%lf utime_usec,%lf utime_usec_sum,%lf stime_usec,%lf stime_usec_sum,%ld min_fault,%ld min_fault_sum,%ld maj_fault,%ld maj_fault_sum \n", count,index,gb,mb,kb,utime_usec,*utime_usec_sum,stime_usec,*stime_usec_sum,minflt,*minflt_sum,majflt,*majflt_sum);
    }else{
//        fprintf(stdout,"%llu,%llu,%llu,%lf,%lf,%ld,%ld \n", gb, mb, kb,utime_usec_sum,stime_usec_sum,total_minflt,total_majflt); 
        fprintf(stdout,"%llu,%llu,%llu,%llu,%llu,%lf,%lf,%lf,%lf,%ld,%ld,%ld,%ld \n", count,index,gb,mb,kb,utime_usec,*utime_usec_sum,stime_usec,*stime_usec_sum,minflt,*minflt_sum,majflt,*majflt_sum);
    }
}

void do_expr(int type, int debug, char *filename, int stride, int _allocsize){
    node *thp_node; 
    struct rusage ru_start, ru_end, ru_result;
//    unsigned long long allocsize = 4*GB;    
    unsigned long long allocsize = _allocsize * GB, index=0,count=0; 
    int freq = allocsize / sizeof(node), fd, res; 
    double stime_usec_sum=0;
    double utime_usec_sum=0;
    long minflt_sum=0;
    long majflt_sum=0;
    char *buffer = NULL, *ptr;
    int *arr = NULL;
    struct stat stat;

    thp_node = (node*)memalign(PAGE_SIZE, allocsize);

    if(type == RANDOM){ 
//        fprintf(stdout,"\n thp test... random pattern data set from %s \n", filename);
        
        arr = (int*)calloc(freq,sizeof(int));

        fd = open(filename, O_RDONLY);
        if(fd == ERR){
            fprintf(stdout, "   no such file \n");
            return;
        }

        fstat(fd, &stat);
        buffer = (char*)calloc(1, stat.st_size);

        res = read(fd, buffer,stat.st_size);
        if(res == ERR){
            fprintf(stdout,"   read error\n");
            return;
        }

        ptr = strtok(buffer, ",");
        while(ptr != NULL){
            if(!strcmp(ptr,"\n"))
                break;
            arr[index++] = atoi(ptr);
            ptr = strtok(NULL, ",");
        }

//        printf(" thp random data set memory size : %llu GB \n", index * sizeof(node) / GB);

        for(count=0,index=0 ; index < freq ; index+=stride,count++){ 

            getrusage(RUSAGE_SELF, &ru_start); 

            (thp_node+arr[index])->val=index;

            getrusage(RUSAGE_SELF, &ru_end);

            rusage_diff(&ru_start, &ru_end, &ru_result);
            print_status(count,arr[index], &ru_result, &stime_usec_sum, &utime_usec_sum, &minflt_sum, &majflt_sum, debug);
        }

    }else if(type == STRIDE){ 
//        fprintf(stdout,"\n thp test... stride pattern data set %ld B unit \n", stride * sizeof(node));

        for(count=0,index=0 ; index < freq ; index+=stride, thp_node++, count++){ 

            getrusage(RUSAGE_SELF, &ru_start); 

            thp_node->val=index;               

            getrusage(RUSAGE_SELF, &ru_end);

            rusage_diff(&ru_start, &ru_end, &ru_result);
            print_status(count,index, &ru_result, &stime_usec_sum, &utime_usec_sum, &minflt_sum, &majflt_sum, debug);

        }
    }else{
        fprintf(stdout, "   eype error \n");
    }
    //    while(1){}

    close(fd);
}

int main(int argc, char *argv[]){

    char op;
    int fd, type=ERR, debug=0, stride=0, allocsize=0;
    char *filename= NULL;

    optind = 0;

    while ((op = getopt(argc, argv, "a:dt:f:s:")) != -1) {
        switch (op) { 
            case 'a':
                allocsize = atoi(optarg);
                break; 
            case 's':
                stride = atoi(optarg);
                break; 
            case 'd':
                debug = 1;
                break; 
            case 't':
                if(!strcmp(optarg, "random")){
                    type = RANDOM;                   
                }else if(!strcmp(optarg, "stride")){
                    type = STRIDE;
                }else{
                    type = ERR;
                }
                break; 
            case 'f':
                if(optarg){
                    filename = (char*)calloc(1,strlen(optarg) + 1);
                    strncpy(filename, optarg, strlen(optarg));
                }
                else
                    filename = NULL;
                break;
            default :
                type = ERR;
                filename = NULL;
                goto INVALID_ARGS;
        }
    }
    if(type != ERR && allocsize != 0){
        if(type == RANDOM){
            if(!filename){
                fprintf(stdout,"\n random needs file data !!!\n");
                goto INVALID_ARGS; 
            }
        }else if(type == STRIDE){
            if(filename){
                fprintf(stdout,"\n stride doesn't need file data !!!\n");
                goto INVALID_ARGS;
            }
            if(!stride){
                 fprintf(stdout,"\n stride needs stride data !!!\n");
                goto INVALID_ARGS;                
            }
        }
        do_expr(type,debug,filename, stride,allocsize); 
    }else{
        goto INVALID_ARGS;
    }
    goto FREE_MEM;

INVALID_ARGS:
    thp_ex_usage(argv[0]);
    thp_ex_example(argv[0]);
FREE_MEM:
    if(filename)
        free(filename);   
    return 0; 
} 

//--fms-extensions
