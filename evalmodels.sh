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
seg=0
tranlate=0
hier=0
while getopts "h?mtesi:" opt; do
    case "$opt" in
         h|\?)
              echo "evalmodel.sh [--morph | --moprh | --tags]"
              echo "  Default --nomoprh"
              exit 0
              ;;
        m)  
            morph=1
            ;;
        s)  
            seg=1
            ;;
        i)
            hier=1
            ;;
        t)
            tags=1
            ;;
    esac
done
shift $((OPTIND-1))
[ "$1" = "--" ] && shift


cp $corpus/testset.wixes $base/corpus/test.wixes

echo "* Split test corpus"
python3 $wixnlp/tools/sep.py $base/corpus/test

echo "* Normalize test corpus"
python3 $wixnlp/normwix.py -a $base/corpus/test.wix $base/corpus/test.norm.wix

$moses/scripts/tokenizer/tokenizer.perl -l es < $base/corpus/test.es > $base/testing/test.tokens.es -threads 8
tr '[:upper:]' '[:lower:]' < $base/testing/test.tokens.es > $base/testing/test.norm.es
cp $base/testing/test.norm.es $base/testing/test.tokens.es

echo "##### Translate..."
if (( morph == 0 && seg == 0 && hier == 0))
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
        <  $base/testing/test.tokens.es\
        >  $base/testing/test.hyp.wix
    cat $base/testing/test.hyp.wix
fi


if (( morph == 0 && seg == 1 && hier == 0))
then
    echo "With improved morphological translation"
    echo "Translating..."

    python3 seg.py
    $moses/bin/moses            \
        -f $base/wixeswixnlp/model/moses.ini   \
        < $base/corpus/test.seg.wix\
        > $base/testing/test.hyp.es \

    $moses/bin/moses            \
        -f $base/eswixwixnlp/model/moses.ini   \
        <  $base/testing/test.tokens.es\
        >  $base/testing/test.hyp.wix
fi

if (( morph == 1 && seg == 0 && hier == 0))
then

    echo "Morphological Translation"
    echo "Translating..."

    $base/bin/segment.py -m $base/corpus/model.morph.bin -i $base/corpus/test.norm.wix -o $base/corpus/test.seg.wix
 

    $moses/bin/moses            \
        -f $base/wixeswithmorph/model/moses.ini   \
        < $base/corpus/test.seg.wix         \
        > $base/testing/test.hyp.es \

    $moses/bin/moses            \
        -f $base/eswixwithmorph/model/moses.ini   \
        <  $base/testing/test.tokens.es\
        >  $base/testing/test.hyp.wix
fi


if (( morph == 0 && seg == 0 && hier == 1))
then

    echo "Morphological Hierarchical Translation"

    python3 seg.py

    $moses/bin/moses            \
        -f $base/wixeshier/model/moses.ini   \
        < $base/corpus/test.seg.wix         \
        > $base/testing/test.hyp.es \

    $moses/bin/moses            \
        -f $base/eswixhier/model/moses.ini   \
        <  $base/testing/test.tokens.es\
        >  $base/testing/test.hyp.wix
fi

echo "##### Evaluation"
#corpus/wixmorph.py corpus/eval/prueba.norm.wix corpus/train.wix.morph.bin > corpus/eval/prueba.morph.wix
    #morfessor-segment -L corpus/train.wix.morph.model corpus/eval/prueba.endl.wix -o corpus/eval/prueba.morph.wix
    #tr '\n' ' ' < corpus/eval/prueba.morph.wix > corpus/eval/prueba.morph.endl.wix
    #tr '@@@' '\n' < corpus/eval/prueba.morph.endl.wix > corpus/eval/prueba.morph.wix
    #sed -i '/^[[:space:]]*$/d' corpus/eval/prueba.morph.wix
if (( morph == 0))
then
    echo "#TER"
    awk '{print $0, "(", NR, ")"}' $base/testing/test.hyp.es > $base/testing/test.hyp.ter.es
    awk '{print $0, "(", NR, ")"}' $base/testing/test.tokens.es > $base/testing/test.ter.es
    java -jar $tereval -r $base/testing/test.ter.es -h $base/testing/test.hyp.ter.es

    #echo "#WER"
    #python3 $wereval $base/corpus/test.es $base/testing/test.hyp.es

    echo "#TER"
    awk '{print $0, "(", NR, ")"}' $base/testing/test.hyp.wix > $base/testing/test.hyp.ter.wix
    awk '{print $0, "(", NR, ")"}' $base/corpus/test.wix > $base/testing/test.ter.wix
    java -jar $tereval -r $base/testing/test.ter.wix -h $base/testing/test.hyp.ter.wix
    #echo "#WER"
    echo "#BLEU"
    $moses/scripts/generic/multi-bleu.perl -lc $base/testing/test.tokens.es < $base/testing/test.hyp.es
    $moses/scripts/generic/multi-bleu.perl -lc $base/corpus/test.wix < $base/testing/test.hyp.wix

else

    echo '######## Morhological transaltion'


    echo "#TER"
    awk '{print $0, "(", NR, ")"}' $base/testing/test.hyp.es > $base/testing/test.hyp.ter.es
    awk '{print $0, "(", NR, ")"}' $base/testing/test.tokens.es > $base/testing/test.ter.es
    java -jar $tereval -r $base/testing/test.ter.es -h $base/testing/test.hyp.ter.es
    
    awk '{print $0, "(", NR, ")"}' $base/testing/test.hyp.wix > $base/testing/test.hyp.ter.wix
    awk '{print $0, "(", NR, ")"}' $base/corpus/test.seg.wix > $base/testing/test.seg.ter.wix
    java -jar $tereval -N -r $base/testing/test.seg.ter.wix -h $base/testing/test.hyp.ter.wix

    echo "#BLEU"
    $moses/scripts/generic/multi-bleu.perl -lc $base/testing/test.tokens.es < $base/testing/test.hyp.es
    $moses/scripts/generic/multi-bleu.perl -lc $base/corpus/test.seg.wix < $base/testing/test.hyp.wix
fi

