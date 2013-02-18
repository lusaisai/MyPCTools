#! /bin/bash -e
 
#######################################################################################
# Variables initializtion
#######################################################################################
topDir="/home/lusaisai/MyPCTools"
dbFile="$topDir/files/allVideo.db"
tmpDir="$topDir/tmp"
videoFile="$tmpDir/videos.txt"
videoDir="/home/lusaisai/Videos"
 
 
#######################################################################################
# several functions
#######################################################################################
# Update database
function dbUpdate {
   find $videoDir | perl -e "while(<>) { if ( m/\.(avi|mp4|rm|rmvb|wmv|iso|mkv|mpg|mpeg|vob|mov)$/i) {print $_;}}" > $videoFile
 
   sqlite3 $dbFile << EOF
create table if not exists video ( full_path text primary key, play_times integer default 0 );
create table if not exists stage ( full_path text primary key);
drop table if exists video_old;
drop table if exists video_new;
create table video_new ( full_path text primary key, play_times integer default 0 );
delete from stage;
.import $videoFile stage
insert into video_new
select s.full_path, coalesce(v.play_times, 0)
from stage s
left join video v
on s.full_path = v.full_path;
alter table video rename to video_old;
alter table video_new rename to video;
EOF
 
   rm -f $videoFile
}
 
# randomly choose a file from those less played before
function getFile {
   sqlite3 $dbFile << EOF
select full_path
from video v
join ( select min(play_times) as times from video ) m
on   v.play_times = m.times
order by random() limit 1;
EOF
}
 
# add the play times with 1
function timesUpdate {
   sqlite3 $dbFile << EOF
update video
set play_times = play_times + 1
where full_path = '$file';
EOF
}
 
#######################################################################################
# The main process
#######################################################################################
if [ $# -gt 0 ]; then
   echo "Updating database ..."
   dbUpdate
fi
file=$(getFile)
echo "Playing $file ..."
vlc "$file" > /dev/null 2>&1 &
timesUpdate
 
exit 0

