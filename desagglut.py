import sys
from wixnlp.tools.sep import split, merge
from wixnlp.normwix import normwix as normalize
from wixnlp.normwix import tokenizewix as tokenize
from wixnlp.segadv import Segment
from wixnlp.morphgrams import Mgrams
#from .ngrams import classif
from wixnlp.wmorph import Verb


wix_corpus_comb_seg = "corpus/test.seg.wix"
wix_seg_model= "corpus/model.morph.bin"
wix_dic = "corpus/dicplur.norm2.wix"
wix_lm = "bin/wixgrams.pickle"
es_lm = "bin/esgrams.pickle"

def segment_wixnlp(word):
    mgrams = Mgrams(debug=True)
    mgrams = Mgrams()
    mgrams.load()
    v = Verb(word, debug=1)
    print("Word to segment:", word)
    print(v.paths)
    path = mgrams.best(v.paths)
    print(path)

if __name__ == "__main__":
    if len(sys.argv) < 1:
        print("desagglut.py Morph descomposition ")
        print(". It has GPL licence, so feel free to share it.")
        print("     desagglut.py word")
        sys.exit()
    op = sys.argv[1]
    segment_wixnlp(op)

