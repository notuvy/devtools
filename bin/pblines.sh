#!/bin/bash
#------------------------------------------------------------------------------
# Copy the lines of a file one-by-one.
#------------------------------------------------------------------------------

scriptdir="$(dirname $0)"
scriptname="$(basename $0)"
sourcelines="${HOME}/var/tmp/pblines.txt"
originalIFS="${IFS}"

usage () {
    cat <<USAGE
Copy the lines of a file one-by-one.

Usage:  ${scriptname} [-h]
USAGE
}

while getopts "h" optionName; do
    case "${optionName}" in
        h)  usage; exit 0;;
        \?) usage; exit 3
    esac
done
shift $(($OPTIND-1))

[[ -f ${sourcelines} ]] || { printf "No source: %s\n" "${source:}"; exit 21; }

IFS='
'
for line in $(cat ${sourcelines}); do
    echo ${line}
    echo "${line}" | pbcopy
    read -n 1 -p ">" response
done
