#!/usr/bin/env bash
: '
Convert the PNG images into proper bitmaps for the LCD Panel (BMP3).
Must be called each time the images are modified.
'

scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ret=$?; if [[ $ret != 0 ]]; then exit $ret; fi

root="$( cd "${scripts}/../LCD-Panel" && pwd )"
ret=$?; if [[ $ret != 0 ]]; then exit $ret; fi

dgus="$( cd "${root}/DGUS-root" && pwd )"
ret=$?; if [[ $ret != 0 ]]; then exit $ret; fi

mkdir -p "${root}/DGUS-root/25_Controls"
mkdir -p "${root}/DGUS-png"
mkdir -p "${root}/Export"

png="$( cd "${root}/DGUS-png" && pwd )"
ret=$?; if [[ $ret != 0 ]]; then exit $ret; fi

export="$( cd "${root}/Export" && pwd )"
ret=$?; if [[ $ret != 0 ]]; then exit $ret; fi

quiet=false
if [[ "$1" == "--quiet" ]]; then
    quiet=true
fi

function clean_export() {
    echo "Clean images from ${export}"
    rm -r "${export:?}"/*
}

function copy_images() {
    echo "Copy images from ${export} to ${png}"

    mkdir -p "${png}/DWIN_SET" "${png}/Controls" "${png}/Screenshots" "${png}/Images"

    find "${export}" -name "*.png" -print0 | while read -r -d $'\0' file
    do
      name=$(basename "${file}")
      if [[ "${name}" == "DWIN_SET-"* ]]; then
        convert "${file}" -format png -background black -flatten "${png}/DWIN_SET/${name#DWIN_SET-}"
      elif [[ "${name}" == "Widget-"* ]]; then
        convert "${file}" -format png -background black -flatten "${png}/Controls/${name#Widget-}"
      elif [[ "${name}" == "Screenshots-"* ]]; then
        convert "${file}" -format png -background black -flatten "${png}/Screenshots/${name#Screenshots-}"
      elif [[ "${name}" == "Image-"* ]]; then
        cp "${file}" "${png}/Images/${name#Image-}"
      else
        echo WARNING: Unknown file "${file}"
      fi
    done
}

function convert_images() {
    echo "Convert images from $1 to 24 bit BMP and copy them into $2..."
    shopt -s nullglob
    local files=("$1/"*.png)
    shopt -u nullglob
    if [[ ${#files[@]} -eq 0 ]]; then
        echo "  No PNG files found in $1, skipping."
        return 0
    fi
    for f in "${files[@]}" ; do
        filename=$(basename "$f")
        name="${filename%.*}"
        convert "$f" -type truecolor "BMP3:$2/${name}.bmp"
        ret=$?; if [[ $ret != 0 ]]; then exit $ret; fi
    done
}

if ! $quiet ; then
  read -p "Clean Export? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    printf "\n"
    clean_export
    printf "\nPlease, export the images.\n"
  else
    printf "\nFiles not cleaned\n"
  fi
  read -p "Continue? [y/N] " answer
  if [[ ! "$answer" =~ ^[Yy]$ ]]; then
    printf "\nAbort.\n"
    exit 1
  fi
  printf "\n"
fi

rm -rf "${png}/DWIN_SET" "${png}/Controls" "${png}/Screenshots"
rm -f "${dgus}/DWIN_SET/"*.bmp 2>/dev/null
rm -f "${dgus}/25_Controls/"*.bmp 2>/dev/null

copy_images
convert_images "${png}/Boot"            "${dgus}/DWIN_SET"
convert_images "${png}/DWIN_SET"        "${dgus}/DWIN_SET"
convert_images "${png}/Controls"        "${dgus}/25_Controls"
