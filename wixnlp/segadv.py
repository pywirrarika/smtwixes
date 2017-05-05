#!/usr/bin/env python3
#
# Copyright (C) 2017.
# Author: Jesús Manuel Mager Hois
# e-mail: <fongog@gmail.com>
# Project website: http://turing.iimas.unam.mx/wix/

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.



from optparse import OptionParser
import pickle
import re

import nltk
import morfessor
from .ngrams import classif
from .wmorph import Verb
from .morphgrams import Mgrams, M3grams

class Segment():
    def __init__(self, infile, outfile, modelfile, dicfile, wixlm="wixgrams.pickle", eslm="esgrams.pickle", debug=False):
        #F = open("../corpus/corpus.norm2.wix", "r").read()
        #corpus = F.split()
        #fq = nltk.FreqDist(corpus)
        #print(fq.most_common(100))


        # Collect data for the classification
        dicwix = open(dicfile, "r").read()
        dicwix = dicwix.replace(" \n", "\n")

        dic = set(dicwix.split("\n"))
        self.dicw = list(dic)

        self.F = open(infile, "r")
        self.corp = []

        self.debug = debug

        with open(wixlm, 'rb') as f:
            self.wixngrams= pickle.load(f)

        with open(eslm, 'rb') as f:
            self.esngrams= pickle.load(f)

        self.punct = ".,;:\"{}[]()$%&/¿?¡!-"

        self.io = morfessor.MorfessorIO()

        self.model = self.io.read_binary_model_file(modelfile)
        self.inF = open(infile, "r")
        self.outF = open(outfile, "w")

        #Stadistics
        self.nonsegwords=0
        self.eswords=0
        self.segwords=0

    # This method classify the words into 4 categories:
    #   * [P] Other simbols.
    #   * [N] Non segmentable words. We identify this kind of 
    #         Words with a dicctionary
    #   * [ES]Spanish words. We use 2grams on characters to this classification
    #   * [S] If no other possibilty is left, we classify this word as segmentable
    def classify(self):
        i=0
        outseg = open("segcorp.wix", "w")
        for line in self.F:
            linelist = []
            sline= line.split()
            #if i < 20:
            #    print(sline)
            i = i + 1
            for word in sline:
                if word in self.punct:
                    linelist.append((word, "P"))
                elif word in self.dicw:
                    linelist.append((word, "N"))
                    self.nonsegwords=self.nonsegwords+1
                elif classif(word, self.esngrams, self.wixngrams):
                    linelist.append((word, "ES"))
                    self.eswords=self.eswords+1
                else:
                    linelist.append([word, "S"])
                    self.segwords= self.segwords + 1
                    print(word, file=outseg, end=" ")
            self.corp.append(linelist)
            print("", file=outseg)

    def segment_morfessor(self):
        for line in self.corp:
            for word in line:
                if word[1] == "S":
                    segmentation = " ".join(self.word_morph(word[0]))
                    word[0] = segmentation

    def segment_wixnlp(self):
        #mgrams = Mgrams(debug=True)
        mgrams = Mgrams()
        mgrams.load()
        for line in self.corp:
            for word in line:
                if word[1] == "S":
                    v = Verb(word[0])
                    #print(word[0])
                    path = mgrams.best(v.paths)
                    #print(path)
                    if len(path) == 0:
                        path = word
                    word[0] = path
    def segment_wixnlp3(self):
        #mgrams = Mgrams(debug=True)
        mgrams = M3grams()
        mgrams.load()
        for line in self.corp:
            for word in line:
                if word[1] == "S":
                    v = Verb(word[0])
                    #print(word[0])
                    path = mgrams.best(v.paths)
                    #print(path)
                    if len(path) == 0:
                        path = word
                    word[0] = path


    def segment_combined(self):
        """Method that use WixNLP +2grams to segment a word, but if it
        fails, then it uses morfessor."""
        #mgrams = Mgrams(debug=True)
        mgrams = Mgrams()
        mgrams.load()
        for line in self.corp:
            if self.debug:
                print(line)
            for word in line:
                if word[1] == "S":
                    v = Verb(word[0])
                    #print(word[0])
                    path = mgrams.best(v.paths)
                    if len(path) == 0:
                        path = self.word_morph(word[0])
                    #print(path)
                    word[0] = path

    def segment_combined3(self):
        """Method that use WixNLP +3grams to segment a word, but if it
        fails, then it uses morfessor."""
        #mgrams = Mgrams(debug=True)
        mgrams = M3grams()
        mgrams.load()
        for line in self.corp:
            if self.debug:
                print(line)
            for word in line:
                if word[1] == "S":
                    v = Verb(word[0])
                    #print(word[0])
                    path = mgrams.best(v.paths)
                    if len(path) == 0:
                        path = self.word_morph(word[0])
                    #print(path)
                    word[0] = path


    def print(self, lines=-1):
        """Print results on screen. The printed lines can be 
        limited with lines argument. The default is -1, that 
        meens all."""
        i = 0
        for line in self.corp:
            if line != -1:
                i=i+1
                if i > lines:
                   break 
            print(line)
        print("Non segmentable words:", str(self.nonsegwords))
        print("Segmentable words:", str(self.segwords))
        print("Spanish words:", str(self.eswords))

    def word_morph(self, word):
        """Segmentation interface to morfessor."""
        return self.model.viterbi_segment(word)[0]

    def output(self):
        for line in self.corp:
            for word in line:
                print(word[0], end=" ")
            print(" ")

    def out_to_file(self):
        """Output segmentation to file in self.outF"""
        for line in self.corp:
            for word in line:
                if isinstance(word[0], list):
                    for e in word[0]:
                        print(e, end=" ", file=self.outF)
                else:
                    print(word[0], end=" ", file=self.outF)
            print(" ", file=self.outF)


    def outseg(self):
        print("Only Semgentable words")
        for line in self.corp:
            for word in line:
                if word[1] == "S":
                    print(word[0], end=" ")
            print("")

if __name__ == "__main__":
    parser = OptionParser()
    parser.add_option("-m", "--model", dest="model", help="read binary model file", metavar="FILE")
    parser.add_option("-i", "--input", dest="input", help="read text file", metavar="FILE")
    parser.add_option("-o", "--output", dest="output", help="binary file for the model", metavar="FILE")
    parser.add_option("-p", "--print", action="store_false", dest="prints", default=True, help="Print segmented file", metavar="FILE")
    parser.add_option("-v", "--verbose", action="store_false", dest="verbose", default=True, help="Verbose print (With word clasificacion)", metavar="FILE")
    parser.add_option("-s", "--segmentable", action="store_false", dest="seg", default=True, help="Output only segmentable words", metavar="FILE")
    (options, args) = parser.parse_args()

    co = Segment(options.input, options.output, options.model, dicfile="../corpus/dicplur.norm2.wix")
    co.segment()
    if options.prints:
        co.print()
    if options.verbose:
        co.output()

