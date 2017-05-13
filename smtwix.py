#!/usr/bin/env python3

#import threading
import os
from multiprocessing import Process

from wixnlp.tools.sep import split, merge
from wixnlp.normwix import normwix as normalize
from wixnlp.normwix import tokenizewix as tokenize
from wixnlp.segadv import Segment
from wixnlp.morphgrams import Mgrams


print(" **  Wixarika corpus preprocessing **")
print("     using wixnlp ...")

# Split parallel corus into corpus.wix and corpus.es
print(" ### Spliting parallel corpus")
wix_root_corpus = "corpus/corpus"
split(wix_root_corpus)


# Normalize and tokenize corpus
print(" ### Normalize and tokenize")
wix_corpus = "corpus/corpus.wix"
wix_corpus_norm = "corpus/corpus.norm2.wix"

Fi = open(wix_corpus, "r")
Fo = open(wix_corpus_norm, "w")

text_norm = normalize(Fi.read())
text_tokens = tokenize(text_norm)

Fo.write(text_tokens)

# Morphological segmenarion

wix_corpus_morf_seg = "corpus/corpus.morf.seg.wix"
wix_corpus_wixnlp_seg = "corpus/corpus.wixnlp.seg.wix"
wix_corpus_wixnlp3_seg = "corpus/corpus.wixnlp3.seg.wix"
wix_corpus_comb_seg = "corpus/corpus.comb.seg.wix"
wix_corpus_comb3_seg = "corpus/corpus.comb3.seg.wix"
wix_corpus_comb_simple= "corpus/corpus.combs.seg.wix"
wix_seg_model= "corpus/model.morph.bin"
wix_dic = "corpus/dicplur.norm2.wix"
wix_lm = "bin/wixgrams.pickle"
es_lm = "bin/esgrams.pickle"

def morfessor_seg():
    print(" ### SegMorf: Starting segmentation")
    #data = threading.local()
    seg = Segment(wix_corpus_norm, wix_corpus_morf_seg, wix_seg_model, wix_dic, wix_lm, es_lm)
    seg.classify()  
    seg.segment_morfessor()
    seg.out_to_file()
    print(" ### SegMorf: Done")

def wixnlp_seg():
    print(" ### SegWixNLP: Starting segmentation")
    seg = Segment(wix_corpus_norm, wix_corpus_wixnlp_seg, wix_seg_model, wix_dic, wix_lm, es_lm)
    seg.classify()
    seg.segment_wixnlp()
    seg.out_to_file()
    print(" ### SegWixNLP: Done")

def comb_seg():
    print(" ### SegCombined: Starting segmentation")
    seg = Segment(wix_corpus_norm, wix_corpus_comb_seg, wix_seg_model, wix_dic, wix_lm, es_lm)
    seg.classify()
    seg.segment_combined()
    seg.out_to_file()
    print(" ### SegCombined: Done")


def wixnlp3_seg():
    print(" ### SegWixNLP3: Starting segmentation")
    #data = threading.local()
    seg = Segment(wix_corpus_norm, wix_corpus_wixnlp3_seg, wix_seg_model, wix_dic, wix_lm, es_lm)
    seg.classify()
    seg.segment_wixnlp3()
    seg.out_to_file()
    print(" ### SegWixNLP: Done")

def comb3_seg():
    print(" ### SegCombined3: Starting segmentation")
    #data = threading.local()
    seg = Segment(wix_corpus_norm, wix_corpus_comb3_seg, wix_seg_model, wix_dic, wix_lm, es_lm)
    seg.classify()
    seg.segment_combined3()
    seg.out_to_file()
    print(" ### SegCombined: Done")

def combsimp_seg():
    print(" ### SegWixNLP Simple: Starting segmentation")
    #data = threading.local()
    seg = Segment(wix_corpus_norm, wix_corpus_comb_simple, wix_seg_model, wix_dic, wix_lm, es_lm)
    seg.classify()
    seg.segment_combined_simple()
    seg.out_to_file()
    print(" ### SegWixNLP Simple: Done")

Process(target=morfessor_seg).start()
Process(target=wixnlp_seg).start()
Process(target=wixnlp3_seg).start()
Process(target=comb_seg).start()
Process(target=comb3_seg).start()
Process(target=combsimp_seg).start()

#morf = threading.Thread(target=morfessor_seg)
#wix  = threading.Thread(target=wixnlp_seg)
#comb = threading.Thread(target=comb_seg)
#threads.append(morf)
#threads.append(wix)
#threads.append(comb)
#morf.start()
#wix.start()
#comb.start()

