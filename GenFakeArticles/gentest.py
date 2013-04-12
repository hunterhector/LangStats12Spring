#!/usr/bin/env python
import sys
import re
import random
from nltk.model import NgramModel 
from nltk.probability import GoodTuringProbDist 

def main(argv):
    AllWords = []

    OutFile = argv[1]
    GenQty = int(argv[2])
    print "Will try to generate " + str(GenQty) + " sentences!"

    sentLen = dict()
    lineQty = 0
    for line in sys.stdin:
        line = re.sub(r'</?s>', '', line)
        line = line.rstrip('\n')
        elems = re.split('\s+', line)
        AllWords.extend(elems)
        lineQty = lineQty + 1
        slen = len(elems)
        if not slen in sentLen:
            sentLen[slen] = 0
        sentLen[slen] = sentLen[slen] + 1

    print(sentLen)
            

    print str(len(AllWords)) + "\n"

    Estim = lambda fdist, bins: GoodTuringProbDist(fdist) 

    N = 3
    print "Words are read, now let's compute the " + str(N) + "-gram model.\n";

    model = NgramModel(N, AllWords, estimator = Estim) 

    print "" + str(N) + "-gram model is computed.\n";

    outf = open(OutFile, 'w')

    for i in range(1, GenQty+1):
        RandSum = random.randint(1, lineQty)
        sum = 0
        RandLen = -1
        for k in sentLen.keys():
            sum = sum + sentLen[k]
            if sum >= RandSum:
                RandLen = k
                break

        if RandLen == -1:
            print("Internal error! Cannot select len for sent: " + str(i))
            sys.exit(1)

        text_words = model.generate(RandLen)  
  
        # Concatenate all words generated in a string separating them by a space.  
        text = ' '.join([word for word in text_words]);

        outf.write("<s> " + text + " </s>\n")


if __name__ == '__main__':
    main(sys.argv)

