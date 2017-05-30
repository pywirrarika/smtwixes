#!/bin/bash

WER=$HOME/wixes/WERpp/wer++.py

python3 comp1-best.py

echo "Morfessor unsupervised"
$WER segtest/morfessor.hyp.wix segtest/testseg.wix 

echo "Morfessor semi-superviced"
$WER segtest/morfessor1.hyp.wix segtest/testseg.wix 

echo "WixNLP"
$WER segtest/wixnlp-alone.hyp.wix segtest/testseg.wix 

echo "WixNLP 2-grams"
$WER segtest/wixnlp.hyp.wix segtest/testseg.wix 

echo "WixNLP 3-grams"
$WER segtest/wixnlp3.hyp.wix segtest/testseg.wix 

echo "WixNLP Hybrid"
$WER segtest/combined.hyp.wix segtest/testseg.wix 

echo "WixNLP Hybrid3"
$WER segtest/combined3.hyp.wix segtest/testseg.wix 


echo "CER: Morfessor unsupervised"
$WER --cer segtest/morfessor.hyp.wix segtest/testseg.wix 

echo "CER: Morfessor semi-superviced"
$WER --cer  segtest/morfessor1.hyp.wix segtest/testseg.wix 

echo "CER: WixNLP"
$WER  --cer segtest/wixnlp-alone.hyp.wix segtest/testseg.wix 

echo "CER: WixNLP 2-grams"
$WER  --cer segtest/wixnlp.hyp.wix segtest/testseg.wix 

echo "CER: WixNLP 3-grams"
$WER  --cer segtest/wixnlp3.hyp.wix segtest/testseg.wix 

echo "CER: WixNLP Hybrid"
$WER  --cer segtest/combined.hyp.wix segtest/testseg.wix 

echo "CER: WixNLP Hybrid3"
$WER  --cer segtest/combined3.hyp.wix segtest/testseg.wix 


echo "Morfessor unsupervised"
python bin/EMMA.py -g segtest/seg.wix.emma -p segtest/morfessor.hyp.wix.emma
echo "Morfessor semi-superviced"
python bin/EMMA.py -g segtest/seg.wix.emma -p segtest/morfessor1.hyp.wix.emma
echo "WixNLP"
python bin/EMMA.py -g segtest/seg.wix.emma -p segtest/wixnlp-alone.hyp.wix.emma
echo "WixNLP 2-grams"
python bin/EMMA.py -g segtest/seg.wix.emma -p segtest/wixnlp.hyp.wix.emma
echo "WixNLP 3-grams"
python bin/EMMA.py -g segtest/seg.wix.emma -p segtest/wixnlp3.hyp.wix.emma
echo "WixNLP Hybrid2"
python bin/EMMA.py -g segtest/seg.wix.emma -p segtest/combined.hyp.wix.emma
echo "WixNLP Hybrid2"
python bin/EMMA.py -g segtest/seg.wix.emma -p segtest/combined3.hyp.wix.emma
