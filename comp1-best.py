

# This scrips evaluate the acuracy of WixNLP morphological segmentarion.
# We take all cases that match 100% and then we 

def compare(hypfile, reffile, verbose=False, model=""):
    hyp = open(hypfile).read().split("\n")
    ref = open(reffile).read().split("\n")

    matched = 0
    i = 0
    for n in range(len(hyp)):
        i = i + 1
        if hyp[n] == ref[n]:
            matched = matched + 1
        else:
            if verbose:
                print(hyp[n], "!=",  ref[n])
    print(model, "Result 1-best match = ", str(float(matched)/float(i)))

if __name__ == "__main__":
    comb = "segtest/combined.hyp.wix"
    ref  = "segtest/segmentedtest.wix"
    wixa = "segtest/wixnlp-alone.hyp.wix"
    wixb = "segtest/wixnlp.hyp.wix"
    morf = "segtest/morfessor.hyp.wix"

    compare(morf, ref, model="Morfessor     ")
    compare(wixa, ref, model="WixNLP        ")
    compare(wixb, ref, model="WixNLP+MGrams ", verbose=True)
    compare(comb, ref, model="Hybrid        ")

