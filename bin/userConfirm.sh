#!/bin/bash
#------------------------------------------------------------------------------
# 
#------------------------------------------------------------------------------

scriptdir="$(dirname $0)"
scriptname="$(basename $0)"
metacmd=""
confirmation=false

getUserResponse() {
    confirmation=false
    prompt="$*"
    read -n 1 -p "${prompt}? [y/N] >" resp; echo
    [[ ${resp} =~ ^[yY] ]] && confirmation=true
}

usage () {
    cat <<USAGE
Usage:  ${scriptname} [-h]
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

getUserResponse "$*"
if ${confirmation}; then echo TRUE; else echo FALSE; fi
