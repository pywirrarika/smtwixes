import os

from wixnlp.tools.sep import split, merge
from wixnlp.normwix import normwix as normalize
from wixnlp.normwix import tokenizewix as tokenize
from wixnlp.segadv import Segment



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

wix_corpus_seg = "corpus/corpus.seg.wix"
wix_seg_model= "corpus/model.morph.bin"
wix_dic = "corpus/dicplur.norm2.wix"
wix_lm = "bin/wixgrams.pickle"
es_lm = "bin/esgrams.pickle"

seg = Segment(wix_corpus_norm, wix_corpus_seg, wix_seg_model, wix_dic, wix_lm, es_lm)
seg.classify()
seg.print(lines=10)
seg.segment_morfessor()
seg.print(lines=10)

