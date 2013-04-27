#!/bin/bash
#
#This script try to run everything
#
#

#make the directory if not exist, and create new log files
mkdir -p data
mkdir -p features
echo '' > program.log
echo '' > error.log
echo '' > matlab.log

python preprocessor.py < developmentSet.dat
python genLMFeature.py 

matlab -nodesktop -nosplash -r "run('classify');exit"

cat result
