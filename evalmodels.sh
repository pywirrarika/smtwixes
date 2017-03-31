#!/bin/bash
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

####################################
# Configuration variables.
# Substitute the path to the tools
####################################

work="$HOME/wixes"
base="$work/smtwixes"
moses="$HOME/mosesdecoder"
tereval=$moses/tools/ter/ter.jar
wareval=$moses/tools/wer/wer.py
wixnlp="$work/wixnlp"
corpus="$work/wixarikacorpora"
europarl="$work/europarl"

morph=0
tags=0
while getopts "h?nte:" opt; do
    case "$opt" in
         h|\?)
              echo "evalmodel.sh [--morph | --nomoprh | --tags]"
              echo "  Default --nomoprh"
              exit 0
              ;;
        n)  
            morph=0
            ;;
        t)
            tags=1
            ;;
    esac
done
shift $((OPTIND-1))
[ "$1" = "--" ] && shift

echo "* Split test corpus"
python3 $wixnlp/tools/sep.py $base/corpus/test
mv $base/corpus/test.es $base/corpus/test.es2
mv $base/corpus/test.wix $base/corpus/test.es
mv $base/corpus/test.es2 $base/corpus/test.wix

echo "* Normalize test corpus"
python3 $wixnlp/normwix.py -a $base/corpus/test.wix $base/corpus/test.norm.wix


echo "##### Translate..."
if (( morph == 0 ))
then
    echo "No morphological translation"
    echo "Translating..."
    $moses/bin/moses            \
        -f $base/wixsinmorph/model/moses.ini   \
        < $base/corpus/test.norm.wix         \
        > $base/testing/test.hyp.es \
    cat $base/testing/test.hyp.es

    $moses/bin/moses            \
        -f $base/eswixsinmorph/model/moses.ini   \
        <  $base/corpus/test.es\
        >  $base/testing/test.hyp.wix
    cat $base/testing/test.hyp.wix
fi

echo "##### Evaluation"
#corpus/wixmorph.py corpus/eval/prueba.norm.wix corpus/train.wix.morph.bin > corpus/eval/prueba.morph.wix
    #morfessor-segment -L corpus/train.wix.morph.model corpus/eval/prueba.endl.wix -o corpus/eval/prueba.morph.wix
    #tr '\n' ' ' < corpus/eval/prueba.morph.wix > corpus/eval/prueba.morph.endl.wix
    #tr '@@@' '\n' < corpus/eval/prueba.morph.endl.wix > corpus/eval/prueba.morph.wix
    #sed -i '/^[[:space:]]*$/d' corpus/eval/prueba.morph.wix
if (( es == 0))
then
    echo "#BLEU"
    $moses/scripts/generic/multi-bleu.perl -lc $base/corpus/test.es < $base/testing/test.hyp.es
    $moses/scripts/generic/multi-bleu.perl -lc $base/corpus/test.wix < $base/testing/test.hyp.wix
    echo "#TER"
    awk '{print $0, "(", NR, ")"}' corpus/eval/prueba.hyp.es > corpus/eval/prueba.hyp.ter.es
    awk '{print $0, "(", NR, ")"}' corpus/eval/prueba.es > corpus/eval/prueba.ter.es
    java -jar $tereval -r corpus/eval/prueba.ter.es -h corpus/eval/prueba.hyp.ter.es

    echo "#WER"
    python3 $wereval /home/gog/corpus/eval/prueba.es /home/gog/corpus/eval/prueba.hyp.es

    echo "#BLEU"
    echo "#TER"
    awk '{print $0, "(", NR, ")"}' corpus/eval/prueba.hyp.wix > corpus/eval/prueba.hyp.ter.wix
    awk '{print $0, "(", NR, ")"}' corpus/eval/prueba.wix > corpus/eval/prueba.ter.wix
    java -jar $tereval -r corpus/eval/prueba.ter.wix -h corpus/eval/prueba.hyp.ter.wix
    echo "#WER"
    python3 $wereval /home/gog/corpus/eval/prueba.wix /home/gog/corpus/eval/prueba.hyp.wix

fi

