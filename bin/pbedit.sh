#!/bin/bash
#------------------------------------------------------------------------------
# Edit the current contents of the clipboard.
#------------------------------------------------------------------------------

scriptdir="$(dirname $0)"
scriptname="$(basename $0)"
dumpfile="/var/tmp/pb.txt"
editor="${EDITOR}"

usage () {
    cat <<USAGE
Edit the current contents of the clipboard.

Usage:  ${scriptname} [-h] [-f file]

  -f file   Save the contents to the give file (default: ${dumpfile})
  -v        Edit with vi (default: ${editor})
USAGE
}

getSum() {
    sum ${dumpfile} | cut -d' ' -f1
}

while getopts "hf:v" optionName; do
    case "${optionName}" in
        h)  usage; exit 0;;
        f)  dumpfile="${OPTARG}";;
        v)  editor=vi;;
        \?) usage; exit 3
    esac
done
shift $(($OPTIND-1))

[[ $# == 0 ]] || { usage; exit 12; }

pbpaste > ${dumpfile}
origsum=$(getSum)
${editor} ${dumpfile} 2> /var/tmp/stderr.txt
postsum=$(getSum)
if [[ ${postsum} == ${origsum} ]]; then
    printf "No change.\n"
else
    cat ${dumpfile} | pbcopy
    printf "Updated.\n"
fi
