
echo "Train morfessor with 600 sentences"
morfessor-train -s model0.bin nonsegmentedtest.wix
echo "Train morfessor with 600 sentences and anotated data for semi-superviced segmentation"
morfessor-train -s model.bin -A morfguided.wix nonsegmentedtest.wix
