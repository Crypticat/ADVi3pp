#!/usr/bin/env bash
: '
Create a microSD disk image for the LCD Panel.
'

# Get the directory where this script is located
scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ret=$?; if [[ $ret != 0 ]]; then exit $ret; fi

cd "${scripts}" || exit 1

echo
echo "***** Convert images..."
echo
./generate-boot-images.sh
ret=$?; if [[ $ret != 0 ]]; then exit $ret; fi
./convert-images.sh --quiet
ret=$?; if [[ $ret != 0 ]]; then exit $ret; fi

./create-sd-image-from-dir.sh "DGUS-root" "ADVI3PP" "ADVi3pp-LCD" 1
