#!/usr/bin/env bash
: '
Upload a firmware.
'

# Get the directory where this script is located
scripts="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ret=$?; if [[ $ret != 0 ]]; then exit $ret; fi

project="$( cd "${scripts}/.." && pwd )"
ret=$?; if [[ $ret != 0 ]]; then exit $ret; fi

img="${project}/.pio/build/advi3pp_51_bltouch/firmware.hex"

if [[ ! -f "${img}" ]]; then
    echo "Firmware not found: ${img}"
    echo "Please build with: platformio run -e advi3pp_51_bltouch"
    exit 1
fi

avrdude="${HOME}/.platformio/packages/tool-avrdude/avrdude"

if [[ ! -f "${avrdude}" ]]; then
    echo "avrdude not found: ${avrdude}"
    echo "Please install PlatformIO or run: platformio pkg install -g -t tool-avrdude"
    exit 1
fi

# Default port - can be overridden by passing as first argument
port="${1:-/dev/ttyUSB0}"

if [[ ! -e "${port}" ]]; then
    echo "Serial port not found: ${port}"
    echo "Available ports:"
    ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null || echo "  (none found)"
    exit 1
fi

"${avrdude}" -C"${HOME}/.platformio/packages/tool-avrdude/avrdude.conf" -pm2560 -P"${port}" -b115200 -cwiring -D -U flash:w:"${img}":i
