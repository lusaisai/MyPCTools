#! /bin/bash -e

retry_times=10
song_num=${1:-15} # play 15 songs by default
song_index=0
audio_dir=/media/Collection/Music
cd $audio_dir

i=0
while [ $song_index -lt $song_num ]
do
   if [ $i -gt $retry_times ]; then
      cd $audio_dir # In case of going into a dir whthout musics
      i=0
   else
      ((i += 1))
   fi
   file_cnt=$(ls -1 | wc -l)
   random_num=$((RANDOM % file_cnt + 1))
   file="$( ls -1 | sed ''$random_num' !d' )"
   is_audio=$(echo "$file" | perl -e "while(<>) { if ( m/(mp3|ape|flac|m4a)$/i) {print "1";} else {print "0"} }")
   if [ $is_audio -eq 1 -a -f "$file" ]; then
      if [ $song_index -eq 0 ]; then
         echo "Playing song $file ..."
         audacious "$file" > /dev/null 2>&1 &
         sleep 1 # Give audacious some time to start up
      else
         echo "Adding song $file ..."
         audacious -e "$file" &
      fi
      cd $audio_dir
      (( song_index += 1 ))
   elif [ -d "$file" ]; then
      cd "$file"
   else
      continue
   fi
done
