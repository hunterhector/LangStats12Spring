#!/bin/bash
#
# A script to build an n-gram model for the CMU-Cambridge Language Toolkit
#
#
InputFile=$1
if [ "$InputFile" == "" ] ; then
    echo "Specify InputFile"
    exit 1
fi
OutPref=$2
if [ "$OutPref" == "" ] ; then
    echo "Specify OutPref"
    exit 1
fi
TopK=$3
if [ "$TopK" == "" ] ; then
    echo "Specify TopK"
    exit 1
fi
N=$4
if [ "$N" == "" ] ; then
    echo "Specify N"
    exit 1
fi
#CutOffs=""
#CN=1
#if [ "$N" == "2" ] ; then
#    CutOffs="$CN"
#fi
#if [ "$N" == "3" ] ; then
#    CutOffs="$CN $CN"
#fi
#if [ "$N" == "4" ] ; then
#    CutOffs="$CN $CN $CN"
#fi
#if [ "$N" == "5" ] ; then
#    CutOffs="$CN $CN $CN $CN"
#fi
#if [ "$N" == "6" ] ; then
#    CutOffs="$CN $CN $CN $CN $CN"
#fi
#if [ "$N" == "7" ] ; then
#    CutOffs="$CN $CN $CN $CN $CN $CN"
#fi
#if [ "$N" -gt "7" ] ; then
#    echo "N > 7 is not supported!"
#    exit 1
#fi
OutPref="$OutPref-N$N"
BIN="ToolkitBin"
TempVocab=`mktemp`
TempNgram=`mktemp`
cat $InputFile | $BIN/text2wfreq | $BIN/wfreq2vocab -top $TopK > "$TempVocab"
if [ "$?" != 0 ] ; then
    echo "text2idngram failed!"
    exit 1
fi
echo "Vocabulary is created! TopK=$TopK"
cat $InputFile | $BIN/text2idngram -temp /tmp -n $N -vocab $TempVocab > "$TempNgram"
if [ "$?" != 0 ] ; then
    echo "text2idngram failed!"
    exit 1
fi
echo "idngram-file is created N=$N"
$BIN/idngram2lm -n $N -context cue.ccs -idngram $TempNgram -vocab $TempVocab  -four_byte_counts -good_turing -calc_mem -binary $OutPref.binlm #-cutoffs $CutOffs #-arpa $OutPref.arpa 
if [ "$?" != 0 ] ; then
    echo "idngram2lm failed!"
    exit 1
fi
echo "The model is computed, N=$N!"
rm $TempVocab
rm $TempNgram



