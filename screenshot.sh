#!/bin/bash

CMD=lqth
ARGS=""
PIPETO=ff2png
NOTIFY=
OUTFILE="$HOME/Pictures/screenshot.png"
SELTOOL=

usage() {
    echo "Usage: $0 [--region|--activewindow|--notify|--output <output_file>]" >&2
    echo "The default output file: $OUTFILE" >&2
    exit 1
}

while [ $# -gt 0 ]; do
    arg="$1"
    if [[ $1 == "-"* ]]; then
        arg="${arg#-}" 
    else
        echo "Invalid argument $1" >&2
        exit 1
    fi
    case $arg in
        o | output)
            shift
            if [[ $# -eq 0 ]]; then
                echo "Missing file path" >&2
                exit 1
            fi
            OUTFILE=$1
            ;;
        r | region)
            SELTOOL=xrectsel;;
        w | activewindow)
            ARGS="-w $(printf "%d" $(xdo id))" 2>/dev/null || ARGS="-w $(xdotool getactivewindow)";;
        n | notify)
            NOTIFY=notify-send;;
        *)
            usage;;
    esac
    shift
done

if [[ -n $SELTOOL ]]; then
    ARGS="-r $($SELTOOL "x:%x,y:%y,w:%w,h:%h")"
fi

$CMD $ARGS | $PIPETO > $OUTFILE

if [[ -n $NOTIFY ]]; then
    $NOTIFY "Screenshot saved at: $OUTFILE"
fi

