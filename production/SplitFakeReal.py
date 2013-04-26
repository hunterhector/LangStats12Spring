#!/usr/bin/python 
# This script splits the set into two files:
# One file contains sentences from FAKE documents 
# Another file contains sentences from REAL documents
#
import sys
import re 
import argparse
import os

parser = argparse.ArgumentParser(description='Split sentences into real and fake ones')

parser.add_argument('input',help='Input file')
parser.add_argument('-l','--labels',help='File with document labels')
parser.add_argument('-f','--fake',help='The file to store fake ones')
parser.add_argument('-r','--real',help='The file to store real ones')

args = vars(parser.parse_args())

InputFile = args['input']
LabelFile = args['labels']
FakeFile  = args['fake']
RealFile  = args['real']

FakeFileOut = open(FakeFile, 'w')
RealFileOut = open(RealFile, 'w')

InputFileIn = open(InputFile, 'r')

fullDocument = ""
for line in InputFileIn.readlines():
	fullDocument = fullDocument + line

LabelFileIn = open(LabelFile, 'r')

labels = []
for line in LabelFileIn.readlines():
    labels.append(line.rstrip('\n'))

documents = filter(lambda d: d.strip().rstrip()!="", fullDocument.split("~~~~~"))

print "# of documents ", len(documents)
print "# of labels ",    len(labels)

if len(documents) != len(labels):
    raise Exception("# of labels is not equal to # of docs!")


for i in range(0,len(labels)):
    doc = documents[i]
    if labels[i] == '0':
        FakeFileOut.write(doc)
    else:
        RealFileOut.write(doc)
