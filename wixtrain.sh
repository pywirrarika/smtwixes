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
wixnlp="$work/wixnlp"
corpus="$work/wixarikacorpora"
europarl="$work/europarl"


####################################
# Configuration variables.
# Substitute the path to the tools
####################################

function cleanlm {
        echo "Removing data"
        rm -rf $base/wixsinmorph/*;
        echo "Done"
        exit 0
}

function partialtrainwix {
        echo "*  Train wixarika language model"

        # We need moses to train the language model
        if [ ! -f $moses/bin/moses ]; then
            echo "Moses not found!"
            echo $moses/bin/moses
            exit 0
        fi
        
        $wixnlp/normwix.py -a $base/corpus/corpus.wix $base/corpus/model.tokens.wix

        tr '[:upper:]' '[:lower:]' < $base/corpus/model.tokens.wix > $base/corpus/model.tokens.low.wix

        $moses/bin/lmplz -o 3 < $base/corpus/model.tokens.low.wix >  $base/corpus/model.arpa.wix
        $moses/bin/build_binary $base/corpus/model.arpa.wix    $base/corpus/train.blm.wix
}

function partialtraineses {
        echo "*  Train spanish language model"

        # We need moses to train the language model
        if [ ! -f $moses/bin/moses ]; then
            echo "Moses not found!"
            echo $moses/bin/moses
            exit 0
        fi

        $moses/scripts/tokenizer/tokenizer.perl -l es < $europarl/europarl-v7.es-en.es  > $base/corpus/model.tokens.es -threads 8
        tr '[:upper:]' '[:lower:]' < $base/corpus/model.tokens.es > $base/corpus/model.tokens.low.es

        $moses/bin/lmplz -o 3 < $base/corpus/model.tokens.low.es >  $base/corpus/model.arpa.es
        $moses/bin/build_binary $base/corpus/model.arpa.es    $base/corpus/train.blm.es
}



function normwixcorp {

    # Separete parallel corpus and normalize
    python3 $wixnlp/tools/sep.py $base/corpus/corpus

    echo $base/corpus
    ls $base/corpus

    # This corpus is inversed, so we need to fix the file extensions
    # TODO: Change the order

    cp $base/corpus/corpus.wix $base/corpus/corpus.estmp
    mv $base/corpus/corpus.es $base/corpus/corpus.wix
    mv $base/corpus/corpus.estmp $base/corpus/corpus.es

    # Delete empty lines
    sed -i '/^[[:space:]]*$/d' $base/corpus/corpus.wix
    sed -i '/^[[:space:]]*$/d' $base/corpus/corpus.es

    python3 $wixnlp/normwix.py -a $base/corpus/corpus.wix $base/corpus/corpus.norm.wix 
}



function normescorp {

    if [ ! -f $moses/bin/moses ]; then
        echo "Moses not found!"
        echo $moses/bin/moses
        exit 0
    fi

    # Normalize spanish part of the corpus
    $moses/scripts/tokenizer/tokenizer.perl -l es < $base/corpus/corpus.es  > $base/corpus/corpus.tokens.es -threads 8
    tr '[:upper:]' '[:lower:]' < $base/corpus/corpus.tokens.es > $base/corpus/corpus.norm.es
}

function trainwixessinmorph {
    echo "Train statical phrase based model"
    echo "----------------------------------------------------"
    
    #cat $base/corpus/corpus.wix | tr -d '-' > $base/corpus/corpus2.wix
    $moses/scripts/training/train-model.perl\
        -root-dir $base/wixsinmorph/\
        -external-bin-dir $moses/tools\
        --lm 0:3:$base/corpus/train.blm.es\
        -corpus $base/corpus/corpus.norm -f wix -e es\
        -alignment grow-diag-final-and \
        --mgiza \
        --parallel \
        -reordering msd-bidirectional-fe
}

function traineswixsinmorph {
    echo "Train statical phrase based model"
    echo "----------------------------------------------------"
    
    $moses/scripts/training/train-model.perl\
        -root-dir $base/eswixsinmorph/\
        -external-bin-dir $moses/tools\
        --lm 0:3:$base/corpus/train.blm.wix\
        -corpus $base/corpus/corpus.norm -f es -e wix\
        -alignment grow-diag-final-and \
        --mgiza \
        --parallel \
        -reordering msd-bidirectional-fe
}


#####################################
# Check if directories exists
######################################
if [ -d "$wixnlp" ]; then
    echo "wixNLP found."
else
    git clone https://github.com/pywirrarika/wixnlp.git $work/wixnlp
fi

if [ -d "$corpus" ]; then
    echo "Wixarika corpus found."
else
    git clone https://github.com/pywirrarika/wixarikacorpora.git $work/wixarikacorpora
fi


if [ -d "$corpus" ]; then
    echo "Wixarika corpus found."
else
    git clone https://github.com/pywirrarika/wixarikacorpora.git $work/wixarikacorpora
fi

if [ -d "$europarl" ]; then
    echo "Europarl Spanish corpus found."
else
    mkdir $europarl
    wget http://code.kiutz.com/wix/europarl-v7.es-en.es 
    mv europarl-v7.es-en.es $europarl/europarl-v7.es-en.es
fi

if [ ! -f $moses/bin/moses ]; then
    echo "----------------------------------------"
    echo "Moses not found!"
    echo "You need MOSES to run the translator and"
    echo "some text pre processing rutines. This"
    echo "script will stop at some point after doing"
    echo "all step where MOSES is not necesary."
    echo "----------------------------------------"
    exit 0
fi


#######################################
# Input line variables 
#######################################

OPTIND=1         # Reset in case getopts has been used previously in the shell.
partial=1
clean=0
morph=0
morferssor=0
tags=0
lang=0

while getopts "h?pcntlem:" opt; do
    case "$opt" in
         h|\?)
             echo "wixtrain [-f(full DEF)|-p(partial)|-c(clean)|-m(morph DEF)|-n(nomoprh)|-t(morph with tags)|-e(spanish to wixarika)]"
              echo "  Default --full, and --moprh"
              exit 0
              ;;
        p)  
            partial=0 # Dont genertate LM
            ;;
        c)  
            clean=1 # Remove all generated files
            ;;
    esac
done
shift $((OPTIND-1))
[ "$1" = "--" ] && shift


#############################
# Training steps
#############################


###### Step 1
echo "-- Clean folders"
rm $base/corpus/corpus.es
rm $base/corpus/corpus.wix
rm $base/corpus/corpus.norm*;
rm $base/corpus/corpus.tokens*;
rm $base/corpus/model.tokens*;
rm -rf $base/wixsinmorph/*
cp $corpus/trainset.wixes $base/corpus/corpus.wixes
cp $corpus/testset.wixes $base/corpus/test.wixes

if (( clean == 1 )) 
    then
        cleanlm
fi

###### Step 2
echo " -- Nomralize wixarika text"
normwixcorp

###### Step 3
echo "-- Training bilingual model --"
if (( partial == 0 ))
    then
        partialtrainwix
        partialtraineses
        exit 1
fi

###### Step 4 
echo "-- Nomralize spanish text"
normescorp


###### Step 5 (Starting Moses)
echo "-- Training Moses"
if (( morph == 0  && tags == 0))
    then
        trainwixessinmorph
        traineswixsinmorph
fi

####### Morphessor code
    #python3 corpus/wixpre.py corpus/train2.wix corpus/train.norm.wix
    #sed 's/$/ @@@/' corpus/train.norm.wix > corpus/train.norm.endl.wix
    #morfessor-train -s corpus/train.wix.morph.bin corpus/train.norm.wix
    #morfessor-segment -L corpus/train.wix.morph.model corpus/train.norm.endl.wix -o corpus/train.norm.morph.wix
    #~/corpus/wixmorph.py corpus/train.norm.wix corpus/train.wix.morph.bin > corpus/train.norm.morph.wix
    #mv corpus/train.norm.morph.wix corpus/train.norm.wix
    #tr '\n' ' ' < corpus/train.norm.morph.wix > corpus/train.norm.morph.endl.wix
    #tr '@@@' '\n' < corpus/train.norm.morph.endl.wix > corpus/train.norm.wix
    #sed -i '/^[[:space:]]*$/d' corpus/train.norm.wix

echo "DONE"
