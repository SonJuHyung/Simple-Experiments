#!/bin/bash 

TYPE=$1
./thp_test -a 4 -t stride -s 1 > run/${TYPE}_stride_1.txt
./thp_test -a 4 -t stride -s 512 > run/${TYPE}_stride_512.txt
./thp_test -a 4 -t random -s 1 -f data/thp_rand_set_1.txt > run/${TYPE}_random_1.txt
./thp_test -a 4 -t random -s 1 -f data/thp_rand_set_2.txt > run/${TYPE}_random_2.txt
./thp_test -a 4 -t random -s 1 -f data/thp_rand_set_3.txt > run/${TYPE}_random_3.txt
./thp_test -a 4 -t random -s 1 -f data/thp_rand_set_4.txt > run/${TYPE}_random_4.txt
./thp_test -a 4 -t random -s 1 -f data/thp_rand_set_5.txt > run/${TYPE}_random_5.txt 


