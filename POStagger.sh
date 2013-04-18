#!/bin/bash
#
# This script converts all words in sentences into respective POS tags.
# usage: ./stanford-postagger.sh model textFile
#  e.g., ./stanford-postagger.sh models/english-left3words-distsim.tagger sample-input.txt
PREFIX="stanford-postagger-2013-04-04"
InputFile=$1
OutFile=$2
ModelFile="models/english-left3words-distsim.tagger"
if [ "$InputFile" == "" ] ; then
    echo "Specify InputFile"
    exit 1
fi
if [ "$OutFile" == "" ] ; then
    echo "Specify OutFile"
    exit 1
fi
if [ ! -d $PREFIX ] ; then
    wget "http://nlp.stanford.edu/software/stanford-postagger-2013-04-04.zip"
    if [ "$?" != "0" ] ; then
        echo "Cannot download the tagger software!"
        exit 
    fi
    unzip "$PREFIX.zip"
    if [ "$?" != "0" ] ; then
        echo "Cannot unzip the tagger software!"
        exit 
    fi
    rm -f "$PREFIX.zip"
fi

TmpIn=`mktemp`
TmpOut=`mktemp`

# First delete <s> & </s>
cat "$InputFile" |sed -r 's|</?s>||g' > $TmpIn

if [ "$?" != "0" ] ; then
    echo "cat failed!"
    exit 1
fi

# don't want to delete newlines, hence, set -tokenize false 

java -cp "$PREFIX/stanford-postagger.jar:" edu.stanford.nlp.tagger.maxent.MaxentTagger -model "$PREFIX/$ModelFile" -textFile "$TmpIn" -tagSeparator "_" -outputFile "$TmpOut" -tokenize false

if [ "$?" != "0" ] ; then
    echo "Java tagger failed!"
    exit 1
fi

# Get rid of the words, need only POS tags
cat $TmpOut | sed -r 's/(^|\s+)[^_]+_/ /g' | sed "s/^/<s> /" |sed "s|$| </s>|" | sed "s|\s+| |g" > $OutFile

if [ "$?" != "0" ] ; then
    echo "cat/sed failed!"
    exit 1
fi

rm $TmpOut
rm $TmpIn
