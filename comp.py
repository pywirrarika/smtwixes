

def compare(hypfile, reffile):
    hyp = open(hypfile).read().split("\n")
    ref = open(reffile).read().split("\n")

    matched = 0
    i = 0
    for n in range(len(hyp)):
        i = i + 1
        if hyp[n] == ref[n]:
            matched = matched + 1
        else:
            pass
            #print(hyp[n], "!=",  ref[n])
    print("Result 1-best match = ", str(float(matched)/float(i)))

if __name__ == "__main__":
    comb = "segtest/combined.hyp.wix"
    ref  = "segtest/segmentedtest.wix"
    wixa = "segtest/wixnlp-alone.hyp.wix"
    wixb = "segtest/wixnlp.hyp.wix"
    morf = "segtest/morfessor.hyp.wix"

    compare(comb, ref)
    compare(wixb, ref)
    compare(wixa, ref)
    compare(morf, ref)

