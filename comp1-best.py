

# This scrips evaluate the acuracy of WixNLP morphological segmentarion.
# We take all cases that match 100% and then we 

def compare(hypfile, reffile, verbose=False, model=""):
    hyp = open(hypfile).read().split("\n")
    ref = open(reffile).read().split("\n")

    matched = 0
    i = 0
    if verbose:
        print(len(hyp))
    for n in range(len(hyp)):
        i = i + 1
        try:
            if hyp[n] == ref[n]:
                matched = matched + 1
            else:
                if verbose:
                    print(hyp[n], "!=",  ref[n])
        except IndexError:
            break
    print(model, "Result 1-best match = ", str(float(matched)/float(i)))

if __name__ == "__main__":
    ref  = "segtest/testseg.wix"
    morf = "segtest/morfessor.hyp.wix"
    morf1 = "segtest/morfessor1.hyp.wix"
    wixa = "segtest/wixnlp-alone.hyp.wix"
    wixb = "segtest/wixnlp.hyp.wix"
    wixb3 = "segtest/wixnlp3.hyp.wix"
    comb = "segtest/combined.hyp.wix"
    comb3 = "segtest/combined3.hyp.wix"

    compare(morf, ref,  model="Morfessor                ")
    compare(morf1, ref, model="Morfessor semisuperviced ")
    compare(wixa, ref,  model="WixNLP                   ")
    compare(wixb, ref,  model="WixNLP+2Grams            ")
    compare(wixb3, ref, model="WixNLP+3Grams            ")
    compare(comb, ref,  model="Hybrid                   ")
    compare(comb3, ref, model="Hybrid3                  ")

