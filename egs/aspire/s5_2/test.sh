. ./path.sh

rm -f /tmp/temp_8k.wav

ffmpeg -i $1 -ac 1 -ar 8000 /tmp/temp_8k.wav 2>/dev/null
fname=`basename $1`
fname=${fname%%.wav}

rm -rf exp/decode-$fname
mkdir -p exp/decode-$fname

frame_subsampling_factor=3

time online2-wav-nnet3-latgen-faster \
  --online=false \
  --do-endpointing=false \
  --frame-subsampling-factor=${frame_subsampling_factor} \
  --config=data/conf/online.conf \
  --max-active=7000 \
  --beam=15.0 \
  --lattice-beam=6.0 \
  --acoustic-scale=1.0 \
  --word-symbol-table=data/graph/words.txt \
  exp/tdnn_7b_chain_online/final.mdl \
  data/graph/HCLG.fst \
  'ark:echo '$fname' '$fname'|' \
  'scp:echo '$fname' /tmp/temp_8k.wav|' \
  'ark:|gzip -c > exp/decode-'$fname'/lat.1.gz' 2> /dev/null

echo $frame_subsampling_factor > exp/frame_subsampling_factor

#local/score.sh data/test data/graph exp/decode-$fname

local/multi_condition/get_ctm_conf.sh data/test data/lang exp/decode-$fname

#cat exp/decode-$fname/score_10/test.ctm

