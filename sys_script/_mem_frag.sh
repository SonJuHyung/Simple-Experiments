#!/bin/bash 

CONTEXT=$(cat /proc/pagetypeinfo | grep "Normal" | grep "Movable")  

echo ""
echo "  memory context"
#echo "      ${CONTEXT}"

MEMFRAG_LIST=$(echo ${CONTEXT} | awk '{ split($0,arr," "); for(i=7; i < 18; i++) printf("%s ",arr[i]);}')

#echo "      ${MEMFRAG_LIST}"

#TEMP="7134 6419 2931 2148 1481 354 29 6 1 2 0"
#MEMFRAG=$(echo ${TEMP} | awk ' BEGIN { 
MEMFRAG=$(echo ${MEMFRAG_LIST} | awk ' BEGIN { 
        level[10];
        level_sub[10];
        level_frag[10];
        frag=0.0;
    } 
    {
        split($0,arr," ");
        for(i=0; i < 11; i++)
            level[i] = arr[i+1]; 

        for(i=0; i < 11; i++){
            for(j=i; j<11; j++){
                level_sub[i] += level[j] * (2**j); 
            }
            frag+=level_frag[i] = (level_sub[0] - level_sub[i]) * 100 / level_sub[0];
        }
        frag=frag / 11;        
    }
    END{
        printf("%7.3f", frag);
    }')

echo "      MFRAG : ${MEMFRAG} %"
echo ""
