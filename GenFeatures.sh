#!/bin/bash
for prefix in development developmentAdd training trainingAddLong ; do 
    ./GenFeatures.pl data/${prefix}Set.dat  data/${prefix}SetLabels.dat Features/LongFeat_$prefix.csv MyModels/LM-train-100MW-N2.binlm W2 0 MyModels/LM-train-100MW-N3.binlm W3 0  MyModels/LM-train-100MW-N4.binlm W4 0 MyModels/LM-train-100MW-N5.binlm W5 0 MyModels/LM-train-100MW-N6.binlm W6 0 MyModels/LM-train-100MW-N7.binlm W7 0  
  cut -d , -f 1,3,4 Features/LongFeat_$prefix.csv > Features/ShortFeat_$prefix.csv
done
