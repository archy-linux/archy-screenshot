#!/bin/bash

CMD=lqth
ARGS=""
PIPETO=ff2png
NOTIFY=
OUTFILE="$HOME/Pictures/screenshot.png"
SELTOOL=
COPY=

usage() {
    echo "Usage: $0 [--region|--activewindow|--notify|--output <output_file>|--copy]" >&2
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
            NOTIFY="notify-send --urgency=low --expire-time=900 --app-name=$0";;
        c | copy)
            COPY="xclip -selection clipboard -t image/png -i";;
        *)
            usage;;
    esac
    shift
done

if [[ -n $SELTOOL ]]; then
    [[ -n $NOTIFY ]] && $NOTIFY "Select an region to take a screenshot for" 
    ARGS="-r $($SELTOOL "x:%x,y:%y,w:%w,h:%h")"
fi

if [[ -n $COPY ]]; then
    $CMD $ARGS | $PIPETO | $COPY
    [[ -n $NOTIFY ]] && $NOTIFY "Screenshot copyed to system clipbooard"
else
    $CMD $ARGS | $PIPETO > $OUTFILE
    [[ -n $NOTIFY ]] && $NOTIFY "Screenshot saved at: $OUTFILE"
fi

