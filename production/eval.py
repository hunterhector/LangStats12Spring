#!/usr/bin/python
import sys
import math

args = sys.argv

if len(args) < 3:
	print 'Usage: resultFile labelFile'
	sys.exit(1)

resultFile = open(args[1])
labelFile = open(args[2])

results = [r.rstrip().split() for r in resultFile.readlines()]
labels = [int(l) for l in labelFile.readlines()]

if len(results) != len(labels):
	print 'Result does not match label'
	sys.exit(1)

total = len(labels)

print '%d training samples'%(total)

accCount = 0.0
logProb = 0.0

for result, label in zip(results,labels):
	pFake = float(result[0])
	pReal = float(result[1])
	dec = int(result[2])
	addProb = pFake if label == 0 else pReal
	accCount += (dec == label)
	logProb += math.log(addProb)

print 'Eval result - Hard: %.4f , Soft: %.4f, Soft exp: %.4f'%(accCount/total, logProb/total, math.exp(logProb/total))

