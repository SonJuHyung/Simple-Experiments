
#include <stdio.h>
#include "thp.h"


int main(){
//    unsigned long long allocsize = 4*GB; 
    unsigned long long allocsize = 40*KB; 
    unsigned long long  freq = allocsize / sizeof(node);  
    int fd ,i = 0, j=0, value=0;
    char filename[32] = {0,};
    char buffer[32] = {0,};

    srand(time(NULL)); 

    for(i = 0 ; i < 5 ; i ++){
        snprintf(filename,sizeof(filename),"data/thp_rand_set_%d.txt",(i+1));
        printf("    creating ... %s\n",filename);
        fd = open(filename, O_CREAT | O_RDWR | O_TRUNC, 0644);
        memset(filename, 0,sizeof(filename));
        for(j=0; j < freq; j++){
            snprintf(buffer, sizeof(buffer), "%llu,", rand() % freq);
            write(fd, buffer, strlen(buffer));
        }
        write(fd,"\n",1);
        close(fd);
    } 
}

