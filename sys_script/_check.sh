#!/bin/bash 
echo ""
awk '$3=="kB"{if ($2>1024**2){$2=$2/1024**2;$3="GB";} else if ($2>1024){$2=$2/1024;$3="MB";}} 1' /proc/meminfo | column -t | grep Available
awk '$3=="kB"{if ($2>1024**2){$2=$2/1024**2;$3="GB";} else if ($2>1024){$2=$2/1024;$3="MB";}} 1' /proc/meminfo | column -t | grep Anon
awk '$3=="kB"{if ($2>1024**2){$2=$2/1024**2;$3="GB";} else if ($2>1024){$2=$2/1024;$3="MB";}} 1' /proc/meminfo | column -t | grep PageTables 
awk '$3=="kB"{if ($2>1024**2){$2=$2/1024**2;$3="GB";} else if ($2>1024){$2=$2/1024;$3="MB";}} 1' /proc/meminfo | column -t | grep SwapTotal
echo ""
cat /proc/vmstat | grep thp_
echo ""
cat /proc/vmstat | grep compact_ 
echo ""
cat /proc/buddyinfo 
echo ""
#cat /proc/pagetypeinfo
#echo ""
CONTEXT=$(cat /proc/pagetypeinfo | grep "Normal" | grep "Movable" ) 
NODE0_CONTEXT=$(echo ${CONTEXT} | awk '{ split($0,arr," "); for(i=7; i < 18; i++) printf("%6d ",arr[i]);}')
#NODE1_CONTEXT=$(echo ${CONTEXT} | awk '{ split($0,arr," "); for(i=24; i < 35; i++) printf("%6d ",arr[i]);}')
#NODE2_CONTEXT=$(echo ${CONTEXT} | awk '{ split($0,arr," "); for(i=41; i < 52; i++) printf("%6d ",arr[i]);}')
#NODE3_CONTEXT=$(echo ${CONTEXT} | awk '{ split($0,arr," "); for(i=58; i < 69; i++) printf("%6d ",arr[i]);}')
NODE0_MFRAG=$(echo ${NODE0_CONTEXT} | awk ' BEGIN { 
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

##NODE1_MFRAG=$(echo ${NODE1_CONTEXT} | awk ' BEGIN { 
##        level[10];
##        level_sub[10];
##        level_frag[10];
##        frag=0.0;
##    } 
##    {
##        split($0,arr," ");
##        for(i=0; i < 11; i++)
##            level[i] = arr[i+1]; 
##
##        for(i=0; i < 11; i++){
##            for(j=i; j<11; j++){
##                level_sub[i] += level[j] * (2**j); 
##            }
##            frag+=level_frag[i] = (level_sub[0] - level_sub[i]) * 100 / level_sub[0];
##        }
##        frag=frag / 11;        
##    }
##    END{
##        printf("%7.3f", frag);
##    }')

##NODE2_MFRAG=$(echo ${NODE2_CONTEXT} | awk ' BEGIN { 
##        level[10];
##        level_sub[10];
##        level_frag[10];
##        frag=0.0;
##    } 
##    {
##        split($0,arr," ");
##        for(i=0; i < 11; i++)
##            level[i] = arr[i+1]; 
##
##        for(i=0; i < 11; i++){
##            for(j=i; j<11; j++){
##                level_sub[i] += level[j] * (2**j); 
##            }
##            frag+=level_frag[i] = (level_sub[0] - level_sub[i]) * 100 / level_sub[0];
##        }
##        frag=frag / 11;        
##    }
##    END{
##        printf("%7.3f", frag);
##    }')
##
##NODE3_MFRAG=$(echo ${NODE3_CONTEXT} | awk ' BEGIN { 
##        level[10];
##        level_sub[10];
##        level_frag[10];
##        frag=0.0;
##    } 
##    {
##        split($0,arr," ");
##        for(i=0; i < 11; i++)
##            level[i] = arr[i+1]; 
##
##        for(i=0; i < 11; i++){
##            for(j=i; j<11; j++){
##                level_sub[i] += level[j] * (2**j); 
##            }
##            frag+=level_frag[i] = (level_sub[0] - level_sub[i]) * 100 / level_sub[0];
##        }
##        frag=frag / 11;        
##    }
##    END{
##        printf("%7.3f", frag);
##    }')
      
echo ""
echo "  memory context"
echo "      NODE0, Zone, Normal, Movable : ${NODE0_CONTEXT}"
#echo "      NODE1, Zone, Normal, Movable : ${NODE1_CONTEXT}"
#echo "      NODE2, Zone, Normal, Movable : ${NODE2_CONTEXT}"
#echo "      NODE3, Zone, Normal, Movable : ${NODE3_CONTEXT}"
echo ""

echo " memory fragmentatino ratio"
echo "      node0 mfrag ratio : ${NODE0_MFRAG} %"
#echo "      node0 mfrag ratio : ${NODE1_MFRAG} %"
#echo "      node0 mfrag ratio : ${NODE2_MFRAG} %"
#echo "      node0 mfrag ratio : ${NODE3_MFRAG} %"

echo ""
 
