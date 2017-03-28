#/bin/bash
#
# Author: Manuel Mager
# Copyright 2017
# License: GPL 3+
#


####################################
# Configuration variables.
# Substitute the path to the tools
####################################

base="$HOME/wixes/smtwixes"
moses="$HOME/mosesdecoder"
wixnlp="$HOME/wixes/wixnlp"
corpus="$HOME/wixes/wixarikacorpora"
europarl="$HOME/wixes/europarl"

#####################################
# Check if directories exists
######################################
if [ ! -d "$wixnlp" ]; then
    git clone https://github.com/pywirrarika/wixnlp.git $base/wixes/wixnlp
else
    echo "wixNLP found."
fi

if [ ! -d "$corpus" ]; then
    git clone https://github.com/pywirrarika/wixarikacorpora.git $base/wixes/wixarikacorpora
else
    echo "Wixarika corpus found."
fi

if [ ! -f $moses/bin/moses ]; then
    echo "Moses not found!"
    echo $moses/bin/moses
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
es=0

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


rm $base/corpus/train.es
rm $base/corpus/train.wix
rm $base/corpus/train.norm*;
rm $base/corpus/train.arpa*;
rm $base/corpus/train.tokens*;
cp $corpus/largecorpus.wixes $base/corpus/corpus.wixes

if (( clean == 1 )) 
    then
        echo "Removing data"
        rm -rf $base/wixsinmorph/*;
        echo "Done"
        exit 0
fi

echo "-- Training bilingual model --"

if (( partial == 0 ))
    then
        echo "   | - Train spanish language model"
        #rm $base/corpus/model*;
        #rm $base/corpus/train.blm*;
        $moses/scripts/tokenizer/tokenizer.perl -l es < $europarl/europarl-v7.es-en.es  > $base/corpus/model.tokens.es -threads 8
        tr '[:upper:]' '[:lower:]' < $base/corpus/model.tokens.es > $base/corpus/model.tokens.low.es

        $moses/bin/lmplz -o 3 < $base/corpus/model.tokens.low.es >  $base/corpus/model.arpa.es
        $moses/bin/build_binary $base/corpus/model.arpa.es    $base/corpus/train.blm.es

        exit 1

fi

echo "   | - Nomralize wixarika text"

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

echo "   | - Nomralize spanish text"
# Normalize spanish part of the corpus
$moses/scripts/tokenizer/tokenizer.perl -l es < $base/corpus/corpus.es  > $base/corpus/corpus.tokens.es -threads 8
tr '[:upper:]' '[:lower:]' < $base/corpus/corpus.tokens.es > $base/corpus/corpus.norm.es

echo "   | - Training Moses"
if (( morph == 0  && es == 0 && tags == 0))
then
    echo "Train statical phrase based model"
    echo "----------------------------------------------------"
    

    #Use each word as a word, removing the moprh separator of 
    #the corpus.
    cat $base/corpus/corpus.wix | tr -d '-' > $base/corpus/corpus2.wix
    python3 $wixnlp/normwix.py -a $base/corpus/corpus2.wix corpus/corpus.norm.wix 
    $moses/scripts/training/train-model.perl\
        -root-dir $base/wixsinmorph/\
        -external-bin-dir $moses/tools\
        --lm 0:3:$base/corpus/train.blm.es\
        -corpus $base/corpus/corpus.norm -f wix -e es\
        -alignment grow-diag-final-and \
        --mgiza \
        --parallel \
        -reordering msd-bidirectional-fe
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
