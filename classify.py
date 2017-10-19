from itertools import permutations
import pickle
from nltk.util import ngrams
import sys
from wixnlp.normwix import normwix

def train_ngrams(filename):
    Fes = open(filename).read().split()
    data = {}

    permlen = 0

    for word in Fes:
        chrs = [c for c in word]
        twograms = ngrams(chrs,2)
        for g in twograms:
            try:
                data[g]=data[g]+1
            except KeyError:
                data[g]=1
            permlen = permlen + 1

    ngramses = {}
    for par in data.keys():
        ngramses[par] = data[par]/float(permlen)

    with open('esgrams.pickle', 'wb') as f:
        pickle.dump(ngramses, f, pickle.HIGHEST_PROTOCOL)


    Fes = open("../corpus/corpus.norm2.wix").read().split()
    data = {}

    chars = "abcdefghijkllmnopqrrstuvwxyzñáéíóúü+-1234567890'?¿!¡$&;.,ÁÉÍÓÚ:"
    permlen = 0

    for word in Fes:
        chrs = [c for c in word]
        twograms = ngrams(chrs,2)
        for g in twograms:
            try:
                data[g]=data[g]+1
            except KeyError:
                data[g]=1
            permlen = permlen + 1

    ngramswix = {}
    for par in data.keys():
        ngramswix[par] = data[par]/float(permlen)

    with open('wixgrams.pickle', 'wb') as f:
        pickle.dump(ngramswix, f, pickle.HIGHEST_PROTOCOL)

    print(data)

def classif(word, esmodel, wixmodel, verbose=0):

    if verbose:
        print(word)

    chrs = [c for c in word]
    twograms = ngrams(chrs,2)
    pes = 0
    pwix = 0
    i = 1
    for g in twograms:
        i=i+1
        try:
            pes = pes + esmodel[g]
        except KeyError:
            pass
    es = pes/float(i)

    i = 1
    twograms = ngrams(chrs,2)
    for g in twograms:
        i=i+1
        try:
            pwix = pwix + wixmodel[g]
        except KeyError:
            pass
    wix = pwix/float(i)

    if verbose: 
        print("P(wix|word) =", str(wix))
        print("P(esp|word) =", str(es))

    if wix < es:
        if verbose:
            print("ES")
        return 1
    elif wix > es:
        if verbose:
            print("WIX")
        return 0
    else:
        if verbose:
            print("INF")
        return -1

if __name__ == "__main__":
    wix_lm = "bin/wixgrams.pickle"
    es_lm = "bin/esgrams.pickle"
    action = sys.argv[1]
    if action == "-t":
        train_ngrams(sys.argv[2])
    elif action == "-c":
        with open(wix_lm, 'rb') as f:
            wixmodel= pickle.load(f)

        with open(es_lm, 'rb') as f:
            esmodel= pickle.load(f)

        with open(sys.argv[2], 'r', encoding='utf-8') as F:
            for line in F:
                line = normwix(line)
                line = line.split()

                for word in line:
                    cl = classif(word, esmodel, wixmodel, verbose=0)
                    if cl == 1: lang = "ES"
                    if cl == 0: lang = "WIX"
                    if cl == -1: lang = "IND"
                    print(word,"[",lang,"]", sep="", end=" ")
                print()
            


