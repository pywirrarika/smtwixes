import sys 
from wixnlp.wmorph import Verb
from wixnlp.morphgrams import Mgrams, M3grams
import morfessor

debug=False

wix_seg_model= "segtest/model0.bin"
wix_seg_model1= "segtest/model.bin"
wix_seg = "segtest/testseg.wix"
wix_non_seg = "segtest/testnseg.wix"
wix_seg_train = "segtest/trainseg.wix"

# Hyp files
wix_morf1_hyp = "segtest/morfessor1.hyp.wix"
wix_morf_hyp = "segtest/morfessor.hyp.wix"
wix_wixnlp_alone_hyp = "segtest/wixnlp-alone.hyp.wix"
wix_wixnlp_hyp = "segtest/wixnlp.hyp.wix"
wix_wixnlp3_hyp = "segtest/wixnlp3.hyp.wix"
wix_combined = "segtest/combined.hyp.wix"
wix_combined3 = "segtest/combined3.hyp.wix"


Fseg = open(wix_seg, "r")
Fnon = open(wix_non_seg, "r")

FMorf = open(wix_morf_hyp, "w")
FMorf1 = open(wix_morf1_hyp, "w")
FWixnlpA = open(wix_wixnlp_alone_hyp, "w")
FWixnlp = open(wix_wixnlp_hyp, "w")
FWixnlp3 = open(wix_wixnlp3_hyp, "w")
FCombined = open(wix_combined, "w")
FCombined3 = open(wix_combined3, "w")

non = Fnon.read().split("\n")

#Load wixnlp segmentator
mgrams = Mgrams()
mgrams.train(wix_seg_train)
mgrams.load()

m3grams = M3grams()
m3grams.train(wix_seg_train)
m3grams.load()

#Load morfessor model
io = morfessor.MorfessorIO()
model = io.read_binary_model_file(wix_seg_model)

io1 = morfessor.MorfessorIO()
model1 = io.read_binary_model_file(wix_seg_model1)


#if len(seg) != len(non):
#    print("ERROR: Corpus has not equal lenght, exiting...")
#    sys.exit()

for i in range(len(non)):
    print(non[i])
    v = Verb(non[i])

    ### Simple WixNLP Segmentation
    path_op = []
    max = 0
    for p in v.paths:
        if len(p) > max:
            path_op = p
            max = len(p)
    pa = [e[1] for e in path_op]
    if len(pa) == 0:
        print(non[i], file=FWixnlpA)
    else:
        print(" ".join(pa), file=FWixnlpA) 

    ### MGrams Segmentation
    path = mgrams.best(v.paths)
    path3 = m3grams.best(v.paths)
    if debug:
        print(v.paths)
        print(path)
        print(path3)
    if len(path) == 0:
        print(non[i], file=FWixnlp)
        p = model.viterbi_segment(non[i])[0]
        print(" ".join(p), file=FCombined)
    else:
        print(" ".join(path), file=FWixnlp)
        print(" ".join(path), file=FCombined)

    if len(path3) == 0:
        print(non[i], file=FWixnlp3)
        p = model.viterbi_segment(non[i])[0]
        print(" ".join(p), file=FCombined3)
    else:
        print(" ".join(path3), file=FWixnlp3)
        print(" ".join(path3), file=FCombined3)

    ### Morfessor: Trained with segmentable words 
    path = model.viterbi_segment(non[i])[0]
    print(" ".join(path), file=FMorf)

    ### Morfessor: Trained with anotated semisupervised corpus
    path = model1.viterbi_segment(non[i])[0]
    print(" ".join(path), file=FMorf1)

