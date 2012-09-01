#! /bin/bash -e

video_dir=~/Videos
cd $video_dir
retry_times=10

i=0
while true
do
   if [ $i -gt $retry_times ]; then
      cd $video_dir
      i=0
   else
      ((i += 1))
   fi
   file_cnt=$(ls -1 | wc -l)
   random_num=$((RANDOM % file_cnt + 1))
   file="$( ls -1 | sed ''$random_num' !d' )"
   is_video=$(echo "$file" | perl -e "while(<>) { if ( m/(avi|mp4|rm|rmvb|wmv|iso|mkv)$/i) {print "1";} else {print "0"} }")
   if [ $is_video -eq 1 ]; then
      echo "Now playing $file ..."
      vlc "$file" > /dev/null 2>&1 &
      exit 0
   elif [ -d "$file" ]; then
      echo "Go into dir $file ..."
      cd "$file"
   else
      continue
   fi
done
