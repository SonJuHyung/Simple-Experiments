#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/time.h>
#include <pthread.h>
#include <sched.h>

#define SUCCESS          0
#define ERROR           -1

#define CLSIZE          64
#define MAX_CORE         8

#define DEFAULT 0
#define CL_V1   1
#define CL_V2   2

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

static double get_time_usage(struct timeval *tv_start, struct timeval *tv_end){

    double tv_s = tv_start->tv_sec + (tv_start->tv_usec / 1000000.0);
    double tv_e = tv_end->tv_sec + (tv_end->tv_usec / 1000000.0);

    return (tv_e - tv_s);
}


struct node_default {        
    int num_iterations;
    int thread_id;
    int is_sync;   
    int var_odd;    
    int var_even; 
};

struct node_clsize_v1 {
    struct all{
        int num_iterations;
        int thread_id;
        int is_sync;
        int var_odd;
        int var_even;
    };
    char pad[CLSIZE - sizeof(struct all)];
} __attribute__((aligned(CLSIZE)));

struct node_clsize_v2 {
    struct read_v2{
        int num_iterations;
        int thread_id;
        int is_sync;
    };
    struct write_odd_v2{
        int var_odd;
        char pad_odd[60];
    }__attribute__((aligned(CLSIZE)));
    struct write_even_v2{
        int var_even;
        char pad_even[60];
    }__attribute__((aligned(CLSIZE)));    
};

void ex_usage(char *cmd)
{
    printf("\n Usage for %s : \n",cmd);
    printf("    -t: thread count, must be bigger than 0 ( e.g. 4 )\n"); 
    printf("    -i: iteration count ( e.g. 1,000,000 )\n");
    printf("    -s: struct padding ( e.g. d, cl_v1, cl_v2 )\n");
    printf("    -m: mutex sync \n");
    printf("    -m: core affinity \n");
}

void ex_example(char *cmd)
{
    printf("\n Example : \n");
    printf("    # %s -t 4 -i 1000000 -s d \n", cmd);
    printf("    # %s -t 4 -i 1000000 -s cl_v1 -m \n", cmd);
    printf("    # %s -t 4 -i 1000000 -s cl_v2 -m -a \n\n", cmd);
}

void print_result(int num_threads, int num_iterations, int is_padding, 
        struct timeval *tv_start, struct timeval *tv_end, void* arg)
{
    char *cond[] = {"default","cache line padding v1(one structure)","cache line padding v2(two structures)"};
    double time = get_time_usage(tv_start, tv_end);
    int *p_odd = NULL, *p_even = NULL, size = 0;
    switch (is_padding){
        case DEFAULT:
            p_odd = &((struct node_default*)arg)->var_odd;
            p_even = &((struct node_default*)arg)->var_even;
            size = sizeof(struct node_default);
            break;
        case CL_V1:
            p_odd = &((struct node_clsize_v1*)arg)->var_odd;
            p_even = &((struct node_clsize_v1*)arg)->var_even;
            size = sizeof(struct node_clsize_v1);
            break;
        case CL_V2:
            p_odd = &((struct node_clsize_v2*)arg)->var_odd;
            p_even = &((struct node_clsize_v2*)arg)->var_even;
            size = sizeof(struct node_clsize_v2);
            break;
    }

    printf("\n Experiment info \n");
    printf("    num_threads         : %d \n",num_threads);
    printf("    num_iterations      : %d \n",num_iterations);
    printf("    experiment type     : %s \n",cond[is_padding]);
    printf("    sizeof struct       : %d \n",size);

    printf("\n Experiment result : \n");
    printf("    execution time      : %lf seconds \n",time);
    printf("    odd value           : %d \n",*p_odd);
    printf("    even value          : %d \n",*p_even);
}


void do_sync_add(int *p_int, int num_iterations){
    int i;
    for(i=0; i < num_iterations ;i++){
        pthread_mutex_lock(&mutex);
        (*p_int)++;
        pthread_mutex_unlock(&mutex);
    }    
}

void do_add(int *p_int, int num_iterations){
    int i;
    for(i=0; i < num_iterations ;i++){
        (*p_int)++;
        asm volatile("": : "m" (*p_int));
    }
}

void* _test_df(void *arg){
    struct node_default *n_df = (struct node_default*)arg;
    int *p_int = NULL, is_sync = n_df->is_sync;

    if(n_df->thread_id % 2 == 0)
        p_int = &n_df->var_even; 
    else
        p_int = &n_df->var_odd;

    if(is_sync)
        do_sync_add(p_int, n_df->num_iterations);
    else
        do_add(p_int, n_df->num_iterations);          
}

void* _test_cl_v1(void *arg){
    struct node_clsize_v1 *n_cl = (struct node_clsize_v1*)arg;
    int *p_int = NULL, is_sync = n_cl->is_sync;

    if(n_cl->thread_id % 2 == 0)
        p_int = &n_cl->var_even; 
    else
        p_int = &n_cl->var_odd;

    if(is_sync)
        do_sync_add(p_int, n_cl->num_iterations);
    else
        do_add(p_int, n_cl->num_iterations);          
}

void* _test_cl_v2(void *arg){
    struct node_clsize_v2 *n_cl = (struct node_clsize_v2*)arg;
    int *p_int = NULL, is_sync = n_cl->is_sync;

    if(n_cl->thread_id % 2 == 0)
        p_int = &n_cl->var_even; 
    else
        p_int = &n_cl->var_odd;

    if(is_sync)
        do_sync_add(p_int, n_cl->num_iterations);
    else
        do_add(p_int, n_cl->num_iterations);          
}


void* (*_test)(void*) = NULL;

int test(int num_threads, int num_iterations,int is_padding, int is_sync, int is_affinity)
{
    int res=ERROR, i, set = 0;
    long double result= 0.0;
    void *arg;
    struct timeval tv_start, tv_end;
    struct node_default *n_df = (struct node_default*)calloc(1, sizeof(struct node_default));
    struct node_clsize_v1 *n_cl_v1 = (struct node_clsize_v1*)calloc(1, sizeof(struct node_clsize_v1));
    struct node_clsize_v2 *n_cl_v2 = (struct node_clsize_v2*)calloc(1, sizeof(struct node_clsize_v2));   
    pthread_t *pthreads = NULL;
    pthread_attr_t attr;
    cpu_set_t c_set;

    pthreads = (pthread_t*)calloc(1,sizeof(pthread_t)*num_threads);
//    memset(pthreads, 0x0, sizeof(pthread_t) * num_threads);
    pthread_attr_init(&attr);

    gettimeofday(&tv_start, NULL);
    for(i = 0 ; i < num_threads; i++){ 
        switch(is_padding){
            case DEFAULT :
                n_df->num_iterations = num_iterations;
                n_df->thread_id = i;
                n_df->is_sync = is_sync;
                _test = _test_df;
                arg = (void*)n_df;
                break;
            case CL_V1 :
                n_cl_v1->num_iterations = num_iterations;
                n_cl_v1->thread_id = i;
                n_cl_v1->is_sync = is_sync;
                _test = _test_cl_v1;
                arg = (void*)n_cl_v1;

                break;
            case CL_V2 :
                n_cl_v2->num_iterations = num_iterations;
                n_cl_v2->thread_id = i;
                n_cl_v2->is_sync = is_sync;
                _test = _test_cl_v2;
                arg = (void*)n_cl_v2;
                break;
        }
        if(is_affinity){
            CPU_ZERO(&c_set);
            /*
             * My PC architecture
             *
             * Socket 0:
             * +---------------------------------------------+
             * | +--------+ +--------+ +--------+ +--------+ |
             * | |  0 4   | |  1 5   | |  2 6   | |  3 7   | |
             * | +--------+ +--------+ +--------+ +--------+ |
             * | +--------+ +--------+ +--------+ +--------+ |
             * | |  32 kB | |  32 kB | |  32 kB | |  32 kB | |
             * | +--------+ +--------+ +--------+ +--------+ |
             * | +--------+ +--------+ +--------+ +--------+ |
             * | | 256 kB | | 256 kB | | 256 kB | | 256 kB | |
             * | +--------+ +--------+ +--------+ +--------+ |
             * | +-----------------------------------------+ |
             * | |                   8 MB                  | |
             * | +-----------------------------------------+ |
             * +---------------------------------------------+
             *
             */
            CPU_SET(i, &c_set);
            pthread_attr_setaffinity_np(&attr, sizeof(cpu_set_t), &c_set);
            res = pthread_create(&pthreads[i], &attr, _test, arg);
        }else{
            res = pthread_create(&pthreads[i], &attr, _test, arg);
        }

        if(res == ERROR){
            printf(" Error: _perf_metadata - pthread_create error \n");
            goto TEST_ERROR;
        }
    }

    for(i = 0 ; i < num_threads ; i++){
        pthread_join(pthreads[i], NULL);
    }
    gettimeofday(&tv_end, NULL);
    
    print_result(num_threads, num_iterations, is_padding, &tv_start, &tv_end, arg);

    return SUCCESS;
TEST_ERROR:
    free(pthreads);
    free(n_cl_v1);
    free(n_cl_v2);
    free(n_df);
    return ERROR;
}

int main(int argc, char *argv[]){
    char op;
    int num_threads=0, num_iterations=0, is_padding=0, is_sync = 0, is_affinity = 0;
    int fd;

    long l1d_clsz,l1i_clsz,l2_clsz, l3_clsz;

   l1d_clsz = sysconf(_SC_LEVEL1_DCACHE_LINESIZE);
   l1i_clsz = sysconf(_SC_LEVEL1_ICACHE_LINESIZE);
   l2_clsz = sysconf(_SC_LEVEL2_CACHE_LINESIZE);
   l3_clsz = sysconf(_SC_LEVEL3_CACHE_LINESIZE);

   printf("\nL1D cache line size : %ld\n", l1d_clsz);
   printf("L1I cache line size : %ld\n", l1i_clsz);
   printf("L2  cache line size : %ld\n", l2_clsz);
   printf("L3  cache line size : %ld\n\n", l3_clsz);



    optind = 0;

    while ((op = getopt(argc, argv, "t:i:s:ma")) != -1) {
        switch (op) {
            case 't':
                num_threads=atoi(optarg);
                break;
            case 'i':
                num_iterations = atoi(optarg);
                break;
            case 's':
                if(!strcmp(optarg, "d")){
                    is_padding=0;
                    break;
                }
                else if(!strcmp(optarg, "cl_v1")){
                    is_padding=1;              
                    break;
                } 
                else if(!strcmp(optarg, "cl_v2")){
                    is_padding=2;              
                    break;
                } 
            case 'm':
                is_sync = 1;
                break;
            case 'a':
                is_affinity = 1;
                break;
            default:
                goto INVALID_ARGS;
        }
    }
    if((num_threads > 0) && (num_iterations > 0))
    {        
        test(num_threads,num_iterations,is_padding, is_sync, is_affinity);
    }
    else{
        goto INVALID_ARGS;
    }

    return SUCCESS;
INVALID_ARGS:
    ex_usage(argv[0]);
    ex_example(argv[0]);

    return ERROR;
}
