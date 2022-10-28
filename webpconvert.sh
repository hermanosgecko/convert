#!/bin/bash

#DEBUG=true
function debug_echo {
    if [ ! -z "$DEBUG" ]
    then
        echo "$*"
    fi
}

debug_echo "Checking dependencies"
DEPS=( "ffmpeg" )
for DEP in ${DEPS[*]}; do
  debug_echo "Dependency ${DEP}"
  if ! command -v $DEP >/dev/null 2>&1 ; then
      echo "$DEP not found"
      exit 1;
  fi
done 

echo "Starting processing"

IN_FILE_REGEX='.*\.\(jpg\|gif\|png\|jpeg\|bmp\)$'

IN_DIR=${1:-$PWD}
debug_echo "Input directory ${IN_DIR}" 

OUT_FILE_EXT=${2:-"webp"}
debug_echo "Outout file type ${OUT_FILE_EXT}"

find "${IN_DIR}" -type f -iregex "$IN_FILE_REGEX" -exec bash -c 'echo "$1" && ffmpeg -n -i "$1" "${1%.*}.webp" -hide_banner -loglevel error' _ {} \;

echo "Finished processing"

exit 0;

########################################################################
# count files in directory
## ls -l | wc -l
# find unique file types in directory
#find . -type f | perl -ne 'print $1 if m/\.([^.\/]+)$/' | sort -u
########################################################################