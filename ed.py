import argparse
from distance import levenshtein

def compare(hypfile, reffile, name=""):
    hyp = open(hypfile).read().split("\n")
    ref = open(reffile).read().split("\n")

    i = 0
    ac_dist = 0
    for n in range(len(hyp)):
        i = i + 1
        ac_dist += levenshtein(hyp[n], ref[n])
    if name:
        text = name.replace(":", "\t")
        print(text, str(float(ac_dist)/float(i)), sep="\t")
    else:
        print(str(float(ac_dist)/float(i)), sep="\t")

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Segment word into morphemes.')
    parser.add_argument('--hyp', dest='hyp', type=str, required=True)
    parser.add_argument('--gold', dest='gold', type=str, required=True)
    parser.add_argument('--name', dest='name', type=str)

    args = parser.parse_args()

    compare(args.hyp, args.gold, name=args.name)

