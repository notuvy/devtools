#!/bin/bash
#------------------------------------------------------------------------------
# Generate and copy multiple UUID strings.
#------------------------------------------------------------------------------

scriptdir="$(dirname $0)"
scriptname="$(basename $0)"
metacmd=""
jsonVar=""
count="0"
limit=""
multiresult=""
confirmation=false

getUserResponse() {
    confirmation=false
    prompt="$*"
    read -n 1 -p "${prompt}? [y/N] >" resp; echo
    [[ ${resp} =~ ^[yY] ]] && confirmation=true
}

usage () {
    scriptname="$(basename $0)"
    cat <<USAGE
Generate a random UUID.  Multiple can be consecutively created interactively.

Usage:  ${scriptname} [-h] [-n number] [-j var]

  -n number   Create a set number of IDs.
  -j var      Format as a JSON variable with the given name
USAGE
}

while getopts "hqn:j:" optionName; do
    case "${optionName}" in
        h)  usage; exit 0;;
        q)  metacmd=echo;;
        n)  limit="${OPTARG}";;
        j)  jsonVar="${OPTARG}";;
        \?) usage; exit 3
    esac
done
shift $(($OPTIND-1))

[[ $# == 1 && $1 == -h ]] && { usage; exit 0; }
[[ $# == 0 ]] || { usage; exit 11; }

continuing=true
while ${continuing}; do
    id=$(uuidgen | tr [A-Z] [a-z] | tr -d '\n')
    if [[ -n ${jsonVar} ]]; then
        id="${jsonVar}: \"$id\","
    fi
    count=$((count+1))

    if [[ -z ${limit} ]]; then
        printf "\n"
        echo "${id}" | pbcopy
        pbpaste
        getUserResponse "Another"; continuing=${confirmation}
    else
        [[ -n ${multiresult} ]] && multiresult+=$'\n'
        multiresult+=${id}
        [[ ${count} -ge ${limit} ]] && continuing=false
    fi
done

if [[ -n ${multiresult} ]]; then
    echo "${multiresult}" | pbcopy
    pbpaste
fi
