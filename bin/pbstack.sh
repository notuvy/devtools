#!/bin/bash
#------------------------------------------------------------------------------
# 
#------------------------------------------------------------------------------

scriptdir="$(dirname $0)"
scriptname="$(basename $0)"
metacmd=""
stashfile="/var/tmp/pbstash.txt"
#swapfile="/var/tmp/pbswap.txt"

usage () {
    cat <<USAGE
Stash the current clipboard contents, or restore it, or swap it.

Usage:  ${scriptname} [-h] <push | pop | swap | show>
  push  Stash the current clipboard contents.
  pop   Restore the stashed clipboard contents.
  swap  Replace the clipboard contents with the stashed (and vice versa).
  show  Show the stashed value.
USAGE
}

getStashContent() {
    if [[ -f ${stashfile} ]]; then
        stashContent="$(cat ${stashfile})"
    else
        printf "Nothing stashed.\n"
        exit 31
    fi
}

while getopts "hq" optionName; do
    case "${optionName}" in
        h)  usage; exit 0;;
        q)  metacmd=echo;;
        \?) usage; exit 3
    esac
done
shift $(($OPTIND-1))

[[ $# == 0 ]] && { printf "No command.\n"; usage; exit 21; }
[[ $# == 1 ]] || { printf "Extra commands.\n"; usage; exit 22; }

case $1 in
    pu*)
        pbpaste > ${stashfile}
        printf "Stashed.\n"
        ;;
    po*)
        getStashContent
        echo "${stashContent}" | pbcopy
        rm ${stashfile}
        printf "Unstashed.\n"
        ;;
    sw*)
        getStashContent
        pbpaste > ${stashfile}
        echo "${stashContent}" | pbcopy
        printf "Swapped.\n"
        ;;
    sh*)
        getStashContent
        echo "${stashContent}"
        ;;
    *)
        printf "Unrecognized command [%s].\n" "$1"
        usage
        exit 23
esac
