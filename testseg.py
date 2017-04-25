import sys 
from wixnlp.wmorph import Verb
from wixnlp.morphgrams import Mgrams
import morfessor


wix_seg_model= "corpus/model.morph.bin"
wix_seg = "segtest/segmentedtest.wix"
wix_non_seg = "segtest/nonsegmentedtest.wix"
wix_morf_hyp = "segtest/morfessor.hyp.wix"
wix_wixnlp_hyp = "segtest/wixnlp.hyp.wix"


Fseg = open(wix_seg, "r")
Fnon = open(wix_non_seg, "r")

FMorf = open(wix_morf_hyp, "w")
FWixnlp = open(wix_wixnlp_hyp, "w")

seg = Fseg.read().split("\n")
non = Fnon.read().split("\n")

#Load wixnlp segmentator
mgrams = Mgrams()
mgrams.load()

#Load morfessor model
io = morfessor.MorfessorIO()
model = io.read_binary_model_file(wix_seg_model)

#if len(seg) != len(non):
#    print("ERROR: Corpus has not equal lenght, exiting...")
#    sys.exit()

for i in range(len(non)):
    print(non[i])
    v = Verb(non[i])
    path = mgrams.best(v.paths)
    if len(path) == 0:
        print(non[i], file=FWixnlp)
    else:
        print(" ".join(path), file=FWixnlp)


    path = model.viterbi_segment(non[i])[0]
    print(" ".join(path), file=FMorf)







