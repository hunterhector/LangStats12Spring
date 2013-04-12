#!/usr/bin/env python
import sys
import re
from nltk.model import NgramModel 
from nltk.probability import GoodTuringProbDist 

def main(argv):
    AllWords = []

    for line in sys.stdin:
        line = line.rstrip('\n')
        elems = re.split('\s+', line)
        AllWords.extend(elems)

    print str(len(AllWords)) + "\n"

    Estim = lambda fdist, bins: GoodTuringProbDist(fdist) 

    N = 2
    print "Words are read, now let's compute the " + str(N) + "-gram model.\n";

    model = NgramModel(N, AllWords, estimator = Estim) 

    print "" + str(N) + "-gram model is computed.\n";

    text_words = model.generate(500)  
  
    # Concatenate all words generated in a string separating them by a space.  
    text = ' '.join([word for word in text_words]);

    if (re.match('</s>\s*$',  text)==0):
        text = text + ' </s> ';

    print text + "\n"


if __name__ == '__main__':
    main(sys.argv)

