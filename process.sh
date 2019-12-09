#!/bin/bash

clear

echo "Starting processing"

in_dir=${1:-$PWD}
echo $in_dir

out_dir=${2:-$in_dir}
echo $out_dir

out_file_ext=${3:-"mp4"}
echo $out_file_ext

in_file_exts=( "**/*.avi" "**/*.mkv" "**/*.mp4" "**/*.m4v" "**/*.ts" "**/*.mpg")
videocodecs=( "h264" )
audiocodecs=( "aac" "ac3")

# Disable case sensitivity
shopt -s nocaseglob
shopt -s globstar


  for i in ${in_dir}/${in_file_exts[*]}; do
    in_file=$(readlink -m "$i")
    in_filename=`basename "$in_file"`
    in_filename_wo_ext="${in_filename%.*}"
  
    if [ "$in_filename_wo_ext" == "*" ]; then
      continue  
    fi

    echo "Begin processing $in_filename"
    in_file_ext="${in_filename##*.}"

    #set video codec
    vconvert='libx264'
    for vcodec in ${videocodecs[*]}; do
      if ffprobe -show_streams -loglevel quiet "$in_file" | grep "$vcodec"; then
        vconvert='copy'
      fi
    done
    echo "Video convert: $vconvert"

    #set audio codec
    aconvert='aac'
    for acodec in ${audiocodecs[*]}; do
      if ffprobe -show_streams -loglevel quiet "$in_file" | grep "$acodec"; then
        aconvert='copy'
      fi
    done
    echo "Audio convert: $aconvert"

    if [ "$in_file_ext" == "$out_file_ext" ] && [ "$vconvert" == 'copy' ] && [ "$aconvert" == 'copy' ]; then
      echo "Nothing to convert: $in_file"
      continue
    fi

    out_file="$out_dir"/"$in_filename_wo_ext"."$out_file_ext"
    echo $out_file
    if [ -f "$out_file" ]; then
      echo "Output file already exist: $out_file"
      continue
    fi


    echo "Begin conversion of $in_filename"
    ffmpeg -y -i "$in_file" -c:v "$vconvert" -c:a "$aconvert" -flags global_header -map_metadata -1 "$out_file"
    
    if [ "$?" -eq 0 ]; then
      echo "Sucessfully converted $in_file"
    else
      echo "Error converting $in_file"
    fi

  done

echo "Finished processing"

shopt -u nocaseglob
exit 0;
