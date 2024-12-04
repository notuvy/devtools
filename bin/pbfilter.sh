#!/bin/bash
#------------------------------------------------------------------------------
# Filter the current contents of the clipboard.
#------------------------------------------------------------------------------

scriptdir="$(dirname $0)"
scriptname="$(basename $0)"
metacmd="eval"
removeCr=false
intermediateCmd=""

usage () {
    cat <<USAGE
Filter the current contents of the clipboard.

Usage:  ${scriptname} [-h] [-g grep args] -N

  -g args   Use grep with args (sub-args must be quoted).
  -N        Strip the newlines from the result.
USAGE
}

while getopts "hqg:N" optionName; do
    case "${optionName}" in
        h)  usage; exit 0;;
        q)  metacmd=echo;;
        g)  intermediateCmd="grep ${OPTARG}";;
        N)  removeCr=true;;
        \?) usage; exit 3
    esac
done
shift $(($OPTIND-1))

if [[ -n ${intermediateCmd} ]]; then
    cmd="pbpaste | ${intermediateCmd} | pbcopy"
    [[ ${metacmd} == echo ]] && cmd=$(echo "${cmd}" | sed s/\|/\\\|/g)
    ${metacmd} ${cmd}
fi

if ${removeCr}; then
    pbpaste | tr -d '\n' | pbcopy
fi
