#!/bin/bash
#------------------------------------------------------------------------------
# Truncate the clipboard to the first N (default 8) characters.
#------------------------------------------------------------------------------

count=8
scriptdir="$(dirname $0)"
scriptname="$(basename $0)"

usage () {
    cat <<USAGE
Trim the string in the pasteboard, keeping the leading characters.

Usage:  ${scriptname} [-h] [N]
  N    The number of characters to keep (default=${count}).
USAGE
}

while getopts "h" optionName; do
    case "${optionName}" in
        h)  usage; exit 0;;
        \?) usage; exit 3
    esac
done
shift $(($OPTIND-1))

if [[ $# == 1 ]]; then
    count="$1" # TODO validate that this is a number.
elif [[ $# > 0 ]]; then
    usage
    exit 21
fi

pbpaste | cut -c1-${count} | pbcopy
pbpaste
