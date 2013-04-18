#!/bin/bash
#
# A script to evaluate perplexity of the text
# using a precomputed n-gram model.
#
TextFile=$1
if [ "$TextFile" == "" ] ; then
    echo "Specify TextFile"
    exit 1
fi
BinModel=$2
if [ "$BinModel" == "" ] ; then
    echo "Specify BinModel"
    exit 1
fi

BIN="ToolkitBin"

function Perplexity {
    text=$1
    bin=$2
    echo "perplexity -text  $text" | $BIN/evallm -binary $bin  -context cue.ccs 2>&1| grep Perplexity
    if [ "$?" != 0 ] ; then
        echo "evallm failed!"
        exit 1
    fi
}


Perplexity "$TextFile" "$BinModel"
