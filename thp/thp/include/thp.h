#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <malloc.h>
#include <time.h>
#include <fcntl.h>
#include <error.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h> 
#include <sys/resource.h>
#include <sys/mman.h>


#include "list.h"

#define TB ((unsigned long long)1024*1024*1024*1024)
#define GB ((unsigned long long)1024*1024*1024)
#define MB (1024*1024)
#define KB (1024)
#define PAGE_SIZE 4*KB 
#define HPAGE_SIZE 2*MB

#define TRUE    1
#define FALSE   0
#define SUCCESS 0
#define FAIL    1


#define RANDOM  1
#define STRIDE  0
#define ERR    -1

typedef struct node_test{
    struct in{
        int val;
    };
    char pad[PAGE_SIZE - sizeof(struct in)];
}__attribute__((aligned(PAGE_SIZE))) node;

#define FROM_FILE 0
#define DEBUG 0

typedef struct hnode_test{
    struct hin{
        int val;
        struct list_head list_head;
    };
    char pad[HPAGE_SIZE - sizeof(struct in)];
}__attribute__((aligned(HPAGE_SIZE))) hnode;



struct hnode_manager{
    int num;
    struct list_head list;
};
