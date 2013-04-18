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
parser.add_argument('-f','--fake',help='The file')
parser.add_argument('-r','--real',help='The path to file list')

args = vars(parser.parse_args())

InputFile = args['prefix']
LabelFile = args['labels']
FakeFile  = args['fake']
RealFile  = args['real']

FakeFileOut = open(FakeFile, 'w')
RealFileOut = open(RealFile, 'w')


fullDocument = ""
for line in InputFile.readlines():
	fullDocument = fullDocument + line

labels = []
for line in LabelFile.readlines():
    labels.append(line)

documents = filter(lambda d: d.strip().rstrip()!="", fullDocument.split("~~~~~"))

print "# of documents ", len(documents)
print "# of labels ",    len(labels)

