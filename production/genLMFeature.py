#!/usr/bin/python

'''This script process each file and output the language model features'''

from subprocess import Popen, PIPE, STDOUT
import sys
import re
import argparse
import os


print "Preparing Language model features"

modelBaseName = 'LM-train-100MW-N#GRAM#.binlm'
sep = ','

parser = argparse.ArgumentParser(description='Feature generator')

parser.add_argument('-p','--prefix',help='The output processed file prefixes')
parser.add_argument('-l','--filelist',help='The path to file list')
parser.add_argument('-m','--model',help='The path to models')
parser.add_argument('-f','--features',help='The path to output features')

args = vars(parser.parse_args())

prefix = args['prefix']
filelist = args['filelist']
modelPath = args['model']
featurePath = args['features']

if prefix is None:
        prefix = "data/preprocessed"

if filelist is None:
        filelist = "filelist"

if modelPath is None:
	modelPath = 'models'

if featurePath is None:
	featurePath = 'features'

shortFeatureOut = open(featurePath+'/fshort.csv','w')
longFeatureOut =open(featurePath+'/flong.csv','w')

shortSet = set( [3,4] )
longSet = set( [2,3,4,5,6,7] )

print >> shortFeatureOut, 'W3,W4'
print >> longFeatureOut, 'W2,W3,W4,W5,W6,W7'

fileList = open(filelist)

pRegex = 'Perplexity\s=\s([0-9.]+)[,a-z]'

for line in fileList:
	line = line.rstrip()
	for n in range(2,8):
		cmd = './EvalNGRAM.sh '+line +' ' + modelPath + '/' + modelBaseName.replace('#GRAM#',str(n))
		print ' - Running command : [ '+cmd+' ]'
		eval = Popen(cmd, shell=True, stdin=PIPE, stdout=PIPE, stderr=STDOUT, close_fds=True)
		output = eval.stdout.read()
		matches = re.findall(pRegex,output)
	
		per =  matches[0] if (len(matches) > 0)	else 100
		
		per = 100

		if (len(matches) > 0):
			per = matches[0]
		else:
			print >> sys.stderr, 'Cannot find perplexity for '+line			

		if n in shortSet:		
			print >> shortFeatureOut, per,
		print >> longFeatureOut,per,
	
	print >> shortFeatureOut,''
	print >> longFeatureOut ,''
