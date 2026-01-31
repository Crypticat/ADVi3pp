#!/usr/bin/env bash

scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ret=$?; if [[ $ret != 0 ]]; then exit $ret; fi

root="$( cd "${scripts}/../LCD-Panel" && pwd )"
ret=$?; if [[ $ret != 0 ]]; then exit $ret; fi

masters="$( cd "${root}/Masters" && pwd )"
ret=$?; if [[ $ret != 0 ]]; then exit $ret; fi

png="${root}/DGUS-png"
mkdir -p "${png}/Boot/"
rm -f "${png}/Boot/"*.png

nb_images=10
for ((i=1; i < nb_images; i++))
do
  # Calculate opacity as percentage (10%, 20%, ... 90%)
  opacity=$((i * 100 / nb_images))
  convert "${masters}"/Boot.png -alpha set -background opaque -channel A -evaluate multiply "${opacity}%" +channel -flatten "PNG24:${png}/Boot/$(printf "%03d" $((i-1+240)))_boot.png"
done

convert "${masters}"/Boot.png "${masters}"/Connecting.png -layers flatten ${png}/Boot/249_boot.png
