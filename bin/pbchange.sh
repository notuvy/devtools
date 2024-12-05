#!/bin/bash
#------------------------------------------------------------------------------
# Return the pasteboard value once it has changed from the current.
#------------------------------------------------------------------------------

scriptdir="$(dirname $0)"
scriptname="$(basename $0)"
unchanged=true

usage () {
    cat <<USAGE
Return the pasteboard value once it has changed from the current.

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

previous="$(pbpaste)"
while ${unchanged}; do
    sleep 1
    current="$(pbpaste)"
    [[ "${current}" == "${previous}" ]] || unchanged=false
done

echo "${current}"
