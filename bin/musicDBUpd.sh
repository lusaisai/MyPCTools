#! /bin/bash

# Variables initializtion
topDir="/home/lusaisai/MyPCTools"
dbFile="$topDir/files/allMusic.db"
tmpDir="$topDir/tmp"
musicFile="$tmpDir/musics.txt"
musicDir="/media/Collection/Music"

# Generate the file to load
find $musicDir | perl -e "while(<>) { if ( m/\.(mp3|ape|flac|m4a)$/i) {print $_;}}" > $musicFile

# Creating a sqlite DB file
rm -f $dbFile
sqlite3 $dbFile << EOF
create table music ( full_path text );
.import $musicFile music
EOF

exit 0
