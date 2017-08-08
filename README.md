My Simple Experiment.
===========================
 1. Adding paddint at tthe end of structure to fill a remainder of cacheline size is effective?
------------------------------------------------------------
>>> Move read-write variables which are often written to by different threads onto  their own cache line.

            
> * My PC architecture
--------------------        
>>  Socket 0:
>> +---------------------------------------------+ 
>> | +--------+ +--------+ +--------+ +--------+ |
>> | |  0 4   | |  1 5   | |  2 6   | |  3 7   | |
>> | +--------+ +--------+ +--------+ +--------+ |
>> | +--------+ +--------+ +--------+ +--------+ |
>> | |  32 kB | |  32 kB | |  32 kB | |  32 kB | |
>> | +--------+ +--------+ +--------+ +--------+ |
>> | +--------+ +--------+ +--------+ +--------+ |
>> | | 256 kB | | 256 kB | | 256 kB | | 256 kB | |
>> | +--------+ +--------+ +--------+ +--------+ |
>> | +-----------------------------------------+ |
>> | |                   8 MB                  | |
>> | +-----------------------------------------+ |
>> +---------------------------------------------+
            
> * Simple Experiment
----------------------
"
    struct node { 
        int var_odd; 
        int var_even;
    }
"
> + thread count : 8, interation count : 500000000, without lock
> + odd number thread write to var_odd in odd number core 
> + even number thread write to var_even in even number core
        
>>> default : 11.234876 seconds
>>> cl_v1   : 9.753389  seconds
>>> cl_v2   : 7.091140  seconds 

    default core affinity : 10.124900 seconds 
    cl_v1   core affinity : 
    cl_v2   core affinity : 
       


2. How to use software prefetch and does it really effective?
--------------------------------------------------------------
>>> Todo.

