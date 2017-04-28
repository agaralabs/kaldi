rm -rf data/test
mkdir -p data/test

for d in data/words_audio/*; do
  for f in $d/*; do
    id=`basename $f`
    id=${id%%.*}
    echo $id "ffmpeg -i $f -ac 1 -ar 8000 -f wav -|" >> data/test/wav.scp
  done
done

export LC_ALL=C
cat data/test/wav.scp | cut -d ' ' -f 1 | sort | xargs -I ID bash -c " echo ID | cut -d '_' -f 1 | xargs -I spk echo ID spk" > data/test/utt2spk

echo 'amit m
deepak m
gouri f
jubin m
mr f
pt f
vamsi m
varun m' > data/test/spk2gender

utils/utt2spk_to_spk2utt.pl data/test/utt2spk > data/test/spk2utt

cat data/test/spk2gender | cut -d ' ' -f 1 | while read -r spk; do
i=1
  while read -r line; do
    echo ${spk}_${i} $line >> data/test/text
    i=$((i+1))
  done < test_corpus
done

sort -o data/test/text data/test/text

utils/validate_data_dir.sh data/test

