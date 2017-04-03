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
import morfessor

class Segment:
    def __init__(self, infile, outfile, modelfile):
        self.io = morfessor.MorfessorIO()

        print("Open model file")
        self.model = self.io.read_binary_model_file(modelfile)
        self.inF = open(infile, "r")
        self.outF = open(outfile, "w")
        self.seg = []
        self.segment()

    def segment(self):
        for line in self.inF:
            cline = line.replace("\n", "").split()
            lineseg = []
            for word in cline:
                seg = self.word_morph(word)
                lineseg.append(seg)
            self.seg.append(lineseg)

    def print_segmentation(self):
        for line in self.seg:
            for word in line:
                for morph in word:
                    print(morph, end=" ")
            print("")

    def write_segmentation(self):
        for line in self.seg:
            for word in line:
                for morph in word:
                    print(morph, end=" ", file=self.outF)
            print("", file=self.outF)


    def word_morph(self, word):
        return self.model.viterbi_segment(word)[0]

if __name__ == "__main__":
    parser = OptionParser()
    parser.add_option("-m", "--model", dest="model", help="read binary model file", metavar="FILE")
    parser.add_option("-i", "--input", dest="input", help="read text file", metavar="FILE")
    parser.add_option("-o", "--output", dest="output", help="binary file for the model", metavar="FILE")
    (options, args) = parser.parse_args()
    s = Segment(options.input, options.output, options.model)
    if options.output == "":
        s.print_segmentation()
    else:
        s.write_segmentation()

