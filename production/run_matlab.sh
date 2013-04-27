#!/bin/bash
matlab -nodesktop -nosplash -r "run 'classify.m';exit"
if [ "$?" != "0" ] ; then
    exit 1
fi
