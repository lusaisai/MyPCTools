#!/bin/bash -e

# color echo functions
function error {
	echo -e "\e[31m$@\e[39m"
}
function warn {
	echo -e "\e[33m$@\e[39m"
}
function success {
	echo -e "\e[32m$@\e[39m"
}
function info {
	echo -e "\e[34m$@\e[39m"
}

# command line parameters
if [[ $# < 1 ]]; then
	error "`basename $0` <filename> [webm|mp4]"
	exit 1
fi

# check input file exists
INPUT_FILE=$1

if [[ ! -f $INPUT_FILE ]]; then
	error "$INPUT_FILE does not exist"
	exit 1
fi

# other parameters
TARGET_CODEC=${2:-webm}
TARGET_DIR=/mnt/ent
TARGET_FILE=$TARGET_DIR/"`basename $INPUT_FILE | sed 's/\..*/\./' `$TARGET_CODEC"


# detect input file info
info "Detecting the file ..."
VIDEO_RATE=`avprobe $INPUT_FILE 2>&1 | sed '/Video/ !d' \
	|  awk -F"," '{ for(i = 1; i <= NF; i++) { if( $i ~ /kb\/s/ ) {gsub(/kb\/s/, "", $i); print $i;}  } }'`
AUDIO_RATE=`avprobe $INPUT_FILE 2>&1 | sed '/Audio/ !d' \
	|  awk -F"," '{ for(i = 1; i <= NF; i++) { if( $i ~ /kb\/s/ ) {gsub(/kb\/s/, "", $i); print $i;}  } }'`

if [[ -z $VIDEO_RATE || -z $AUDIO_RATE ]]; then
	error "Cannot get the bitrate info from the file"
fi

# convert
info "Converting, it will take some time, please wait ..."
avconv -i "$INPUT_FILE" -b:v "${VIDEO_RATE}k" -b:a "${AUDIO_RATE}k" "$TARGET_FILE"

if [[ $? == 0 ]]; then
	success "Finished converting, please check file $TARGET_FILE"
else
	error "Failed converting"
fi
