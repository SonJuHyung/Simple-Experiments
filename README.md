My Simple Experiment.
===========================
## 1. False sharing
------------------------------------------------------------
####    Move read-write variables which are often written to by different threads onto  their own cache line.

            
 * My PC architecture
--------------------        
    * Socket 0:
    +---------------------------------------------+ 
    | +--------+ +--------+ +--------+ +--------+ |
    | |  0 4   | |  1 5   | |  2 6   | |  3 7   | |
    | +--------+ +--------+ +--------+ +--------+ |
    | +--------+ +--------+ +--------+ +--------+ |
    | |  32 kB | |  32 kB | |  32 kB | |  32 kB | |
    | +--------+ +--------+ +--------+ +--------+ |
    | +--------+ +--------+ +--------+ +--------+ |
    | | 256 kB | | 256 kB | | 256 kB | | 256 kB | |
    | +--------+ +--------+ +--------+ +--------+ |
    | +-----------------------------------------+ |
    | |                   8 MB                  | |
    | +-----------------------------------------+ |
    +---------------------------------------------+
            
 * Simple Experiment
----------------------
```c
    struct node { 
        int var_odd; 
        int var_even;
    }
```
    + thread count : 8, interation count : 500000000, without lock
    + odd number thread write to var_odd (in odd number core with affinity option)
    + even number thread write to var_even (in even number core with affinity option)
        
        default : 11.234876 seconds
        cl_v1   : 11.544897 seconds
        cl_v2   : 7.091140  seconds 

        default core affinity : 10.124900 seconds 
        cl_v1   core affinity : 10.067641 seconds
        cl_v2   core affinity : 6.832389  seconds
       


## 2. YCSB/Redis, YCSB/MongoDB
--------------------------------------------------------------
####    THP related Redis, MongoDB expriment.

## 3. CloudSuite 3.0 basic experiment script
--------------------------------------------------------------
####    CloudSuite 3.3 basic experiment script for THP test

