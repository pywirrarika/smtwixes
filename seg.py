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

from wixnlp.tools.sep import split, merge
from wixnlp.normwix import normwix as normalize
from wixnlp.normwix import tokenizewix as tokenize
from wixnlp.segadv import Segment

# Normalize and tokenize corpus
print(" ### Normalize and tokenize")
wix_corpus = "corpus/test.wix"
wix_corpus_norm = "corpus/test.norm.wix"

Fi = open(wix_corpus, "r")
Fo = open(wix_corpus_norm, "w")

text_norm = normalize(Fi.read())
text_tokens = tokenize(text_norm)

Fo.write(text_tokens)

# Morphological segmenarion

wix_corpus_comb_seg = "corpus/test.seg.wix"
wix_seg_model= "corpus/model.morph.bin"
wix_dic = "corpus/dicplur.norm2.wix"
wix_lm = "bin/wixgrams.pickle"
es_lm = "bin/esgrams.pickle"

def comb_seg():
    print(" ### SegCombined: Starting segmentation")
    #data = threading.local()
    seg = Segment(wix_corpus_norm, wix_corpus_comb_seg, wix_seg_model, wix_dic, wix_lm, es_lm)
    seg.classify()
    seg.segment_combined3()
    seg.out_to_file()
    print(" ### SegCombined: Done")

comb_seg()


