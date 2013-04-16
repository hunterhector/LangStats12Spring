#!/usr/bin/env python

import gzip
import re
import itertools
from collections import defaultdict

from gensim import corpora, models, similarities, utils
from gensim.corpora import TextCorpus
import numpy as np

import logging
logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)

class BroadcastCorpus(TextCorpus):
    def get_texts(self):
        length = 0
        self.input.seek(0)
        for line in self.input:
            length += 1
            line = re.sub(r'</?s>', '', line)
            line = line.rstrip('\n')
            yield utils.tokenize(line)
        self.length = length

def loadCorpus(filename, load):
    if load:
        corpus = corpora.MmCorpus('corpus.ser')
        dictionary = corpora.Dictionary.load("dict.ser")
    else:
        corpus = BroadcastCorpus(input=open(filename))
        dictionary = corpus.dictionary
        corpus.dictionary.save("dict.ser")
        corpora.MmCorpus.save_corpus("corpus.ser", corpus)
    return corpus, dictionary

def lenbincount(corpus):
    lengths = []
    for docno, bow in enumerate(corpus):
        length = 0
        for termid, tf in bow:
            length += tf
        lengths.append(len(bow))
    hist = np.bincount(lengths)
    print "histogram of lengths:", hist
    return hist

def cooccurmap(corpus):
    cooccur = defaultdict(int)
    for docno, bow in enumerate(corpus):
        for pair in itertools.combinations(bow, 2):
            cooccur[(pair[0][0],pair[1][0])] += 1  #TODO propose use tfidf instead of 1
    print "#cooccur:", len(cooccur)
    return cooccur

def lsi(corpus, dictionary):
    tfidf = models.TfidfModel(corpus)
    corpus_tfidf = tfidf[corpus]
    lsi = models.LsiModel(corpus_tfidf, id2word=dictionary, num_topics=50)

def main():

    corpus, dictionary = loadCorpus('../input/trainingSet.dat', True)

    lenbc = lenbincount(corpus)
    print "p(len=10)", float(lenbc[10])/lenbc.sum()

    cooc = cooccurmap(corpus)


if __name__ == '__main__':
    main()

