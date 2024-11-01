#!/bin/bash
#------------------------------------------------------------------------------
# 
#------------------------------------------------------------------------------

scriptdir="$(dirname $0)"
scriptname="$(basename $0)"
metacmd=""

usage () {
    cat <<USAGE
Usage:  ${scriptname} [-h]

Wrap 'String(describing: )' around the clipboard contents.
USAGE
}

while getopts "hq" optionName; do
    case "${optionName}" in
        h)  usage; exit 0;;
        q)  metacmd=echo;;
        \?) usage; exit 3
    esac
done
shift $(($OPTIND-1))

[[ $# == 0 ]] || { printf "Extra args.\n\n"; usage; exit 21; }
echo "String(describing: $(pbpaste))" | pbcopy
