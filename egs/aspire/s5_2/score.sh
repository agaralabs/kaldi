. ./path.sh

rm -rf exp/decode-nnet3
mkdir -p exp/decode-nnet3

frame_subsampling_factor=3

online2-wav-nnet3-latgen-faster \
  --online=false \
  --do-endpointing=false \
  --frame-subsampling-factor=${frame_subsampling_factor} \
  --config=data/conf/online.conf \
  --acoustic-scale=1 \
  --max-active=7000 \
  --beam=15.0 \
  --lattice-beam=6.0 \
  --word-symbol-table=data/graph/words.txt \
  exp/tdnn_7b_chain_online/final.mdl \
  data/graph/HCLG.fst \
  'ark:'$1'/spk2utt' \
  'scp:'$1'/wav.scp' \
  'ark:|gzip -c > exp/decode-nnet3/lat.1.gz' 

echo $frame_subsampling_factor > exp/frame_subsampling_factor

local/score.sh --min_lmwt 1 --max_lmwt 5 $1 data/graph exp/decode-nnet3

for f in exp/decode-nnet3/wer_*; do
  echo $f
  grep -hE '[W,S]ER' $f
done

#local/multi_condition/get_ctm_conf.sh --min_lmwt 1 --max_lmwt 5 data/test data/lang exp/decode-nnet3

#cat exp/decode-$fname/score_10/test.ctm

