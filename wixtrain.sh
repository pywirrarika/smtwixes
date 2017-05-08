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

withdic=0
dicwixes="$work/dicplur.wixes"

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


function partialtrainwixseg {
        echo "*  Train wixarika language model"

        # We need moses to train the language model
        if [ ! -f $moses/bin/moses ]; then
            echo "Moses not found!"
            echo $moses/bin/moses
            exit 0
        fi
        
        $moses/bin/lmplz -o 3 < $base/corpus/corpus.comb3.seg.wix >  $base/corpus/model.seg.arpa.wix
        $moses/bin/build_binary $base/corpus/model.seg.arpa.wix    $base/corpus/train.seg.blm.wix
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

    # Delete empty lines
    sed -i '/^[[:space:]]*$/d' $base/corpus/corpus.wix
    sed -i '/^[[:space:]]*$/d' $base/corpus/corpus.es

    python3 $wixnlp/normwix.py -a $base/corpus/corpus.wix $base/corpus/corpus.norm.wix 
    #python3 $wixnlp/normwix.py -a $base/corpus/corpus.wix $base/corpus/corpus.norm2.wix 
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

function trainmorph {
    echo "Train morphology..."
    $base/bin/trainsegment.py -i $base/corpus/corpus.wix -o $base/corpus/model.morph.bin
    $base/bin/segment.py -m $base/corpus/model.morph.bin -i $base/corpus/corpus.norm.wix -o $base/corpus/corpus.seg.wix
    cp $base/corpus/corpus.seg.wix $base/corpus/corpus.norm.wix
    if [ -d "$base/wixeswithmorph" ]; then
        mkdir $base/wixeswithmorph
    fi
    if [ -d "$base/eswixwithmorph" ]; then
        mkdir $base/eswixwithmorph
    fi
    if [ -d "$base/wixeswixnlp" ]; then
        mkdir $base/wixeswixnlp
    fi
    if [ -d "$base/eswixwixnlp" ]; then
        mkdir $base/eswixwixnlp
    fi
}

function dicwixesget {
    if (( withdic == 1 ))
    then
        cp $dicwixes $base/corpus/dicwixes.wixes
        python3 $wixnlp/tools/sep.py $base/corpus/dicwixes
        tr -d '-' < $base/corpus/dicwixes.wix > $base/corpus/dicwixes.pre.wix
        $wixnlp/normwix.py -a $base/corpus/dicwixes.pre.wix $base/corpus/dicwixes.norm.wix
        $moses/scripts/tokenizer/tokenizer.perl -l es < $base/corpus/dicwixes.es  > $base/corpus/dicwixes.tokens.es -threads 8
        tr '[:upper:]' '[:lower:]' < $base/corpus/dicwixes.tokens.es > $base/corpus/dicwixes.norm.es
        cat $base/corpus/dicwixes.norm.es >> $base/corpus/corpus.norm.es
        #cat $base/corpus/dicwixes.norm.wix >> $base/corpus/corpus.norm.wix
        cp $base/corpus/corpus.comb3.seg.wix $base/corpus/corpus.norm.wix
        cat $base/corpus/dicwixes.norm.wix >> $base/corpus/corpus.norm.wix
    fi
}

function trainwixeswithmorph {
    echo "Train statical phrase based model with morph"
    echo "----------------------------------------------------"
    
    rm -rf $base/wixeswithmorph/*
    $moses/scripts/training/train-model.perl\
        -root-dir $base/wixeswithmorph/\
        -external-bin-dir $moses/tools\
        --lm 0:3:$base/corpus/train.blm.es\
        -corpus $base/corpus/corpus.norm -f wix -e es\
        -alignment grow-diag-final-and \
        --mgiza \
        --parallel \
        -reordering msd-bidirectional-fe
}

function traineswixwithmoprh {
    echo "Train statical phrase based model with morph"
    echo "----------------------------------------------------"

    rm -rf $base/eswixwithmorph/*
    $moses/scripts/training/train-model.perl\
        -root-dir $base/eswixwithmorph/\
        -external-bin-dir $moses/tools\
        --lm 0:3:$base/corpus/train.seg.blm.wix\
        -corpus $base/corpus/corpus.norm -f es -e wix\
        -alignment grow-diag-final-and \
        --mgiza \
        --parallel \
        -reordering msd-bidirectional-fe
}

function trainwixessinmorph {
    echo "Train statical phrase based model"
    echo "----------------------------------------------------"
    
    rm -rf $base/wixsinmorph/*
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
    rm -rf $base/eswixsinmorph/*
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


function trainwixeswixnlp {
    echo "Train statical phrase based model"
    echo "----------------------------------------------------"
    
    rm -rf $base/wixeswixnlp/*
    cp $base/corpus/corpus.comb3.seg.wix $base/corpus/corpus.norm.wix
    
    dicwixesget

    $moses/scripts/training/train-model.perl\
        -root-dir $base/wixeswixnlp/\
        -external-bin-dir $moses/tools\
        --lm 0:3:$base/corpus/train.blm.es\
        -corpus $base/corpus/corpus.norm -f wix -e es\
        -alignment grow-diag-final-and \
        --mgiza \
        --parallel \
        -reordering msd-bidirectional-fe
}

function traineswixwixnlp {
    echo "Train statical phrase based model"
    echo "----------------------------------------------------"

    rm -rf $base/eswixwixnlp/*
    cp $base/corpus/corpus.comb3.seg.wix $base/corpus/corpus.norm.wix

    dicwixesget

    $moses/scripts/training/train-model.perl\
        -root-dir $base/eswixwixnlp/\
        -external-bin-dir $moses/tools\
        --lm 0:3:$base/corpus/train.seg.blm.wix\
        -corpus $base/corpus/corpus.norm -f es -e wix\
        -alignment grow-diag-final-and \
        --mgiza \
        --parallel \
        -reordering msd-bidirectional-fe
}

function trainwixeshier {
    echo "Train statical hierarchical model"
    echo "----------------------------------------------------"
    rm -rf $base/wixeshier/*
    cp $base/corpus/corpus.comb3.seg.wix $base/corpus/corpus.norm.wix
    $moses/scripts/training/train-model.perl\
        -root-dir $base/wixeshier/\
        -external-bin-dir $moses/tools\
        --lm 0:3:$base/corpus/train.blm.es\
        -corpus $base/corpus/corpus.norm -f wix -e es\
        -alignment grow-diag-final-and \
        --mgiza \
        --parallel \
        -hierarchical \
        -glue-grammar 
}
function traineswixhier {
    echo "Train statical hierarchical model"
    echo "----------------------------------------------------"
    rm -rf $base/eswixhier/*
    cp $base/corpus/corpus.comb3.seg.wix $base/corpus/corpus.norm.wix
    $moses/scripts/training/train-model.perl\
        -root-dir $base/eswixhier/\
        -external-bin-dir $moses/tools\
        --lm 0:3:$base/corpus/train.seg.blm.wix\
        -corpus $base/corpus/corpus.norm -f es -e wix\
        -alignment grow-diag-final-and \
        --mgiza \
        --parallel \
        -hierarchical \
        -glue-grammar 
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
hier=0
while getopts "h?pcnlemsid:" opt; do
    case "$opt" in
         h|\?)
             echo "wixtrain [-f(full DEF)|-p(partial)|-c(clean)|-m(morph DEF)|-n(nomoprh)|-t(morph with tags)|-e(spanish to wixarika)]"
              echo "  Default --full, and --moprh"
              exit 0
              ;;
        p)  
            partial=0 # Dont genertate LM
            ;;

        m) 
            morph=1
            ;;
        s)
            sep=1
            ;;
        i)
            hier=1
            ;;
        d)
            withdic=1
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
echo "############### STEP 1 ################"
echo "-- Clean folders"
rm $base/corpus/corpus.es
rm $base/corpus/corpus.wix
rm $base/corpus/corpus.norm*;
rm $base/corpus/corpus.tokens*;
rm $base/corpus/model.tokens*;

cp $corpus/trainset.wixes $base/corpus/corpus.wixes

if (( clean == 1 )) 
    then
        cleanlm
fi

###### Step 2
echo "############### STEP 2 ################"
echo " -- Nomralize wixarika text"
normwixcorp

###### Step 3 
echo "############### STEP 3 ################"
echo "-- Nomralize spanish text"
normescorp

###### Step 4
echo "############### STEP 4 ################"
echo ""
if (( morph == 1 ))
then
    if which morfessor >/dev/null; then
        echo "Morfessor Found!"
    else
        echo "Morfessor is not installed! This program is needed for morphological translation. Exiting..."
        exit
    fi
    trainmorph
fi

###### Step 5
echo "############### STEP 5 ################"
echo "-- Training bilingual model --"

if (( partial == 0 ))
    then
        partialtrainwix
        partialtrainwixseg
        partialtraineses
        exit 1
fi

##### Step 6 
echo "############### STEP 6 ################"
echo "-- Adding bilingual dictionary"

###### Step 7 (Starting Moses)
echo "############### STEP 7 ################"
echo "-- Training Moses"

if (( morph == 0  && sep == 0 && hier == 0))
    then
        trainwixessinmorph
        traineswixsinmorph
elif (( morph == 1 && sep == 0 && hier == 0))
    then
        trainwixeswithmorph
        traineswixwithmoprh
elif (( morph == 0 && sep == 1 && hier == 0))
    then
        trainwixeswixnlp
        traineswixwixnlp
elif (( morph == 0 && sep == 0 && hier == 1))
    then
        trainwixeshier
        traineswixhier
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
