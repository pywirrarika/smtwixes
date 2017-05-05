from wixnlp.tools.sep import split, merge
from wixnlp.normwix import normwix as normalize
from wixnlp.normwix import tokenizewix as tokenize
from wixnlp.segadv import Segment

# Normalize and tokenize corpus
print(" ### Normalize and tokenize")
wix_corpus = "corpus/test.wix"
wix_corpus_norm = "corpus/test.norm.wix"

Fi = open(wix_corpus, "r")
Fo = open(wix_corpus_norm, "w")

text_norm = normalize(Fi.read())
text_tokens = tokenize(text_norm)

Fo.write(text_tokens)

# Morphological segmenarion

wix_corpus_comb_seg = "corpus/test.seg.wix"
wix_seg_model= "corpus/model.morph.bin"
wix_dic = "corpus/dicplur.norm2.wix"
wix_lm = "bin/wixgrams.pickle"
es_lm = "bin/esgrams.pickle"

def comb_seg():
    print(" ### SegCombined: Starting segmentation")
    #data = threading.local()
    seg = Segment(wix_corpus_norm, wix_corpus_comb_seg, wix_seg_model, wix_dic, wix_lm, es_lm)
    seg.classify()
    seg.segment_combined3()
    seg.out_to_file()
    print(" ### SegCombined: Done")

comb_seg()


