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
GetPOS=$3
if [ "$GetPOS" == "" ] ; then
    echo "Specify GetPOS"
    exit 1
fi

BIN="ToolkitBin"

function Perplexity {
    text=$1
    bin=$2
    echo "perplexity -text  $text" | $BIN/evallm -binary $bin  -context cue.ccs | grep Perplexity
    if [ "$?" != 0 ] ; then
        echo "evallm failed!"
        exit 1
    fi
}

if [ "$GetPOS" == "1" ] ; then
    tmp=`mktemp`
    ./POStagger.sh $TextFile $tmp
    Perplexity "$tmp" "$BinModel"
    rm $tmp
else
    Perplexity "$TextFile" "$BinModel"
fi
