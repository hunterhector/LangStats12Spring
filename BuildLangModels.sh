#!/bin/bash
#
# This script creates all necessary language models.
#
OutDir=MyModels

if [ ! -d $OutDir ] ; then
    mkdir $OutDir
fi

for n in 2 3 4 5 6 7 ; do 
    ./BuildNGRAM.sh MyData/LM-postag-100MW.txt $OutDir/LM-postag-1M 10000 $n 
    if [ "$?" != "0" ] ; then
        echo "Failure for n = $n"
    fi
done

for n in 2 3 4 5 6 7 ; do 
    ./BuildNGRAM.sh MyData/LM-train-100MW.txt $OutDir/LM-train-100MW 10000 $n
    if [ "$?" != "0" ] ; then
        echo "Failure for n = $n"
    fi
done
