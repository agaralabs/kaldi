# Set up the environment variables (again)
. cmd.sh
. path.sh

set -xe
 
# Set the paths of our input files into variables
model=exp/tdnn_7b_chain_online
phones_src=exp/tdnn_7b_chain_online/phones.txt
dict_src=data/local/dict
lm_src=data/local/lang/lm.arpa
 
lang=data/lang
dict=data/dict
dict_tmp=data/dict_tmp
graph=data/graph

# initializations
python -c "import numpy" || { echo >&2 "Missing numpy. Try pip install numpy"; exit 1; };
python -c "import num2words" || { echo >&2 "Missing num2words. Try pip install num2words"; exit 1; };
command -v swig >/dev/null 2>&1 || { echo >&2 "SWIG required. Try 'sudo apt-get install swig' on ubuntu.  Aborting."; exit 1; }
command -v ngram-count >/dev/null 2>&1 || { echo >&2 "SRILM required. Aborting."; exit 1; }
command -v g2p.py >/dev/null 2>&1 || { echo >&2 "SRILM required. Install from tools. Run 'extras/install_sequitur.sh'. Aborting."; exit 1; }

if [ ! -f local/model-b.key ] ; then
  wget https://chrisearch.files.wordpress.com/2017/03/model-b.key -O local/model-b.key
fi

rsync -a --ignore-existing -P ../s5/data/ data/
rsync -a --ignore-existing -P ../s5/exp/ exp/

if [ ! -d data/lang ] ; then
  cp -rf data/lang_pp_test data/lang
fi

mkdir -p data/local/lang

sh create_test_files.sh

cp data/local/corpus.txt data/corpus.txt.generated
seq 1 20 | xargs -I{} cat data/local/corpus.txt >> data/corpus.txt.generated
python generate_corpus.py >> data/corpus.txt.generated

grep -oE "[A-Za-z\\'\\.\\_]{1,}" data/corpus.txt.generated | sort | uniq > data/local/words.txt

cat data/local/words.txt | tr '[:lower:]' '[:upper:]' | g2p.py --model local/model-b.key --apply - | tr '[:upper:]' '[:lower:]' > $dict_src/lexicon.txt
cat data/local/custom_pronunciations.txt >> $dict_src/lexicon.txt

rm -f data/local/dict/lexiconp.txt

#cp ../s5/data/local/dict/lexiconp.txt data/local/dict/lexiconp.txt
#cat data/local/words.txt | tr '[:lower:]' '[:upper:]' | g2p.py --model local/model-b.key --apply - | tr '[:upper:]' '[:lower:]' | sed -e 's/\t/\t1.0\t/g' >> $dict_src/lexiconp.txt
#cat data/local/custom_pronunciations.txt | sed -e 's/\t/\t1.0\t/g' >> $dict_src/lexiconp.txt
#
#rm -f data/local/dict/lexicon.txt

ngram-count -text data/corpus.txt.generated -order 3 -limit-vocab -vocab data/local/words.txt -unk -map-unk "<unk>" -interpolate -lm $lm_src
 
# Compile the word lexicon (L.fst)
utils/prepare_lang.sh --phone-symbol-table $phones_src $dict_src "<unk>" $dict_tmp $dict
 
# Compile the grammar/language model (G.fst)
gzip < $lm_src > $lm_src.gz
utils/format_lm.sh $dict $lm_src.gz $dict_src/lexicon.txt $lang
 
# Finally assemble the HCLG graph
utils/mkgraph.sh --self-loop-scale 1.0 $lang $model $graph
 
# To use our newly created model, we must also build a decoding configuration, the following line will create these for us into the new/conf directory
steps/online/nnet3/prepare_online_decoding.sh --mfcc-config conf/mfcc_hires.conf $dict exp/nnet3/extractor exp/chain/tdnn_7b data

