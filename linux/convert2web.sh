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

# getopts
REDUCE_FACTOR=1
while getopts ":r:" opt; do
  case $opt in
    r)
      REDUCE_FACTOR=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an reduce factor." >&2
      exit 1
      ;;
  esac
done

shift $((OPTIND-1))

# command line parameters
if [[ $# < 1 ]]; then
	error "`basename $0` [-r <2>] <filename> [webm|mp4]"
	exit 1
fi

# check input file exists
INPUT_FILE=$1

if [[ ! -f $INPUT_FILE ]]; then
	error "$INPUT_FILE does not exist"
	exit 1
fi

# other parameters
TARGET_CODEC=${2:-mp4}
TARGET_DIR=/mnt/ent
TARGET_FILE=$TARGET_DIR/"`basename "$INPUT_FILE" | sed 's/\.[^.]*$/\./' `$TARGET_CODEC"

# detect input file info
info "Detecting the file ..."
TOTAL_RATE=`ffprobe "$INPUT_FILE" 2>&1 | sed '/Duration/ !d' \
	|  awk -F"," '{ for(i = 1; i <= NF; i++) { if( $i ~ /kb\/s/ ) {gsub(/[^0-9]+/, "", $i); print $i;}  } }'`
VIDEO_RATE=`ffprobe "$INPUT_FILE" 2>&1 | sed '/Video/ !d' \
	|  awk -F"," '{ for(i = 1; i <= NF; i++) { if( $i ~ /kb\/s/ ) {gsub(/[^0-9]+/, "", $i); print $i;}  } }'`
AUDIO_RATE=`ffprobe "$INPUT_FILE" 2>&1 | sed '/Audio/ !d' \
	|  awk -F"," '{ for(i = 1; i <= NF; i++) { if( $i ~ /kb\/s/ ) {gsub(/[^0-9]+/, "", $i); print $i;}  } }'`

if [[ -z $AUDIO_RATE  ]]; then
	error "Cannot get the audio bitrate info from the file"
	info "Please let me know the audio bitrate"
	printf '> '
	read AUDIO_RATE
fi

if [[ -z $VIDEO_RATE  ]]; then
	if [[ ! -z $TOTAL_RATE ]]; then
		VIDEO_RATE=$(( TOTAL_RATE - AUDIO_RATE ))
	else
		error "Cannot get the video bitrate info from the file"
		info "Please let me know the video bitrate"
		printf '> '
		read VIDEO_RATE
	fi
fi

VIDEO_RATE=$((VIDEO_RATE / REDUCE_FACTOR))


info "Converting, it will take some time, please wait ..."
time ffmpeg -i "$INPUT_FILE" -b:v "${VIDEO_RATE}k" -b:a "${AUDIO_RATE}k" -threads `nproc` "$TARGET_FILE"

if [[ $? == 0 ]]; then
	success "Finished converting, please check file $TARGET_FILE"
else
	error "Failed converting"
fi
