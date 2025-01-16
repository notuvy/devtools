#!/bin/bash
#------------------------------------------------------------------------------
# Generate and copy multiple UUID strings.
#------------------------------------------------------------------------------

usage () {
    scriptname="$(basename $0)"
    cat <<USAGE
Usage:  ${scriptname} [-h]
USAGE
}

[[ $# == 1 && $1 == -h ]] && { usage; exit 0; }
[[ $# == 0 ]] || { usage; exit 11; }

continuing=true
while ${continuing}; do
    id=$(uuidgen | tr [A-Z] [a-z] | tr -d '\n')
    echo -n ${id} | pbcopy
    printf "\n%s\n" ${id}

    continuing=false
    read -n 1 -p "Another? [Y/n] >" response; echo
    [[ -z ${response} || ${response} =~ ^[yY] ]] && continuing=true
done

