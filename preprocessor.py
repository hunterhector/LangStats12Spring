#!/usr/bin/python 
import sys
import re 
import argparse
import os

parser = argparse.ArgumentParser(description='Data preprocessor')

parser.add_argument('-p','--prefix',help='The output processed file prefixes')
parser.add_argument('-l','--filelist',help='The path to file list')

args = vars(parser.parse_args())

prefix = args['prefix']
filelist = args['filelist']

if prefix is None:
	prefix = "preprocessed"

if filelist is None:
	filelist = "filelist"

fullDocument = ""
for line in sys.stdin.readlines():
	fullDocument = fullDocument + line

documents = filter(lambda d: d.strip().rstrip()!="", fullDocument.split("~~~~~"))

print len(documents),"parts in document"

fileListOut = open(filelist,'w')

for index, document in enumerate(documents):
	out = open("processed/"+prefix+"%0*d"%(4,index),'w')
	sentences = re.findall("<s>\s*(.*?)\s*</s>",document)
	print >> fileListOut, os.getcwd()+"/"+out.name
	for sent in sentences:	
		print >> out, sent[:1].upper() + sent[1:].lower(),"."
