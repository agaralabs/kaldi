ls $1/ | xargs -I FILE bash -c 'echo utterance-id1: FILE && sh test.sh '$1'/FILE' 2>&1 #\ 
#| grep -E '^utterance-id1'
