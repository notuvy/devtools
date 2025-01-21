#!/bin/bash
#------------------------------------------------------------------------------
# 
#------------------------------------------------------------------------------

scriptdir="$(dirname $0)"
scriptname="$(basename $0)"
metacmd=""
tmpdir="/var/tmp"
partbase="${tmpdir}/pbpart."
partnumber=100
doRecover=false
doIncludeCurrent=false
stillPolling=true

usage () {
    cat <<USAGE
Concatenate consecutive clipboard entries from a starting point.

Usage:  ${scriptname} [-h] [-r] [-c]

  -r  Recover a previous sequence.
  -c  Start with the current contents (default is to start with the next).
USAGE
}

while getopts "hqrc" optionName; do
    case "${optionName}" in
        h)  usage; exit 0;;
        q)  metacmd=echo;;
        r)  doRecover=true;;
        c)  doIncludeCurrent=true;;
        \?) usage; exit 3
    esac
done
shift $(($OPTIND-1))

[[ $# == 0 ]] || { printf "Extra arguments.\n"; usage; exit 21; }

if ${doRecover}; then
    if [[ -f ${partbase}${partnumber} ]]; then
        cat ${partbase}* | pbcopy
        pbpaste && echo
        rm ${partbase}*
    else
        printf "No data to recover.\n"
    fi
else
    printf "Enter 'q' at any time to quit polling for entries to concatenate.\n"
    if ${doIncludeCurrent}; then
        pbpaste > "${partbase}${partnumber}"
        echo >> "${partbase}${partnumber}" # add trailing newline
        cat "${partbase}${partnumber}" # show it on screen
        partnumber=$((partnumber+1))
    fi
    while ${stillPolling}; do
        previous="$(pbpaste)"
        unchanged=true
        while ${unchanged} && ${stillPolling}; do
            #sleep 1
            read -n 1 -t 1 response
            [[ ${response} =~ ^[qQ] ]] && stillPolling=false
            current="$(pbpaste)"
            [[ "${current}" == "${previous}" ]] || unchanged=false
        done
        if ! ${unchanged}; then
            echo "${current}" > "${partbase}${partnumber}"
            cat "${partbase}${partnumber}" # show it on screen
            partnumber=$((partnumber+1))
        fi
    done
    cat ${partbase}* | pbcopy
    printf "Copied\n"
    rm ${partbase}*
fi
