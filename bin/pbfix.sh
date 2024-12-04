#!/bin/bash
#------------------------------------------------------------------------------
# Transform the contents of the clipboard.
#------------------------------------------------------------------------------

scriptdir="$(dirname $0)"
scriptname="$(basename $0)"
metacmd=""
verbose=false
doListenForChange=false
sedTransform=""
genTransform=""
decorationFile=""

listPredefined() {
    cat <<PREDEFINES
Predefined patterns:
  em2hyphens    Rewrite emdash as two hyphens.
  xurlanchor    Trim the anchor (#...) from the end of a URL.
  xurlargs      Trim the args (?...) from the end of a URL.
  unindent4     Trim the leading 4 spaces on all lines.
  cr2space      Replace return characters with a space.
  4spacetab     Replace tab with 4 spaces.
  noeofcr       Remove the trailing return character.
  escnlargs     Insert escaped newlines before each arg.
  rmcr          Remove all newlines.

PREDEFINES
}

usage () {
    cat <<USAGE
Usage:  ${scriptname} [-h] [-s <sed args>] [-t <tr args>] [-d predefined] [-D file] [-l]

Transform the current string in the clipboard by regex.  Either an explicit
sed pattern string can be given, or a predefined transform can be used.
If applying the pattern makes no change, then nothing is done.

  -s args       The sed pattern to be applied (e.g. s/X/Y/g)
  -t args       The tr pattern to be applied (e.g. "[a-z] [A-Z]")
  -d transform  Use a predefined transform (see below)
  -D file       Decorate the clipboard value with the pattern from the file.
  -l            Listen for clipboard change to process.

USAGE
    listPredefined
}

predefined() {
    case "$1" in
        em2hyphens) sedTransform="s/\xe2\x80\x94/--/g";;
        xurlanchor) sedTransform="s/#.*$//";;
        xurlargs)   sedTransform="s/\?.*$//";;
        unindent4)  sedTransform="s/^    //";;
        cr2space)   sedTransform="s/\\n/ /g";; # doesn't work
        4spacetab)  sedTransform='s/\t/    /g';;
        escnlargs)  sedTransform="s/ --/ \\\\\n  --/g";;
        rmcr)       genTransform="-d '\\n'";;
        *)    printf "Undefined transform [%s].\n\n" "$1"; listPredefined; exit 22
    esac
}

while getopts "hqvs:t:d:D:l" optionName; do
    case "${optionName}" in
        h)  usage; exit 0;;
        q)  metacmd="echo";;
        v)  verbose=true;;
        s)  sedTransform="${OPTARG}";;
        t)  genTransform="${OPTARG}";;
        d)  predefined "${OPTARG}";;
        D)  decorationFile="${OPTARG}";;
        l)  doListenForChange=true;;
        \?) usage; exit 11
    esac
done
shift $(($OPTIND-1))

while true; do
    oldvalue=$(pbpaste)
    if [[ -n ${sedTransform} ]]; then
        [[ ${metacmd} == echo ]] && { ${metacmd} sed ${sedTransform}; exit; }
        newvalue=$(pbpaste | sed "${sedTransform}")
        [[ $? == 0 ]] || { printf "Regex error [%s]; no change.\n" "${sedTransform}"; exit 23; }
    elif [[ -n ${genTransform} ]]; then
        [[ ${metacmd} == echo ]] && { ${metacmd} tr ${genTransform}; exit; }
        newvalue=$(pbpaste | tr ${genTransform})
        [[ $? == 0 ]] || { printf "Regex error [%s]; no change.\n" "${genTransform}"; exit 24; }
    elif [[ -n ${decorationFile} ]]; then
        [[ -f ${decorationFile} ]] || { printf "No decoration file [%s].\n" "${decorationFile}"; exit 25; }
        pattern=$(cat ${decorationFile} | tr -d '\n')
        newvalue=$(echo "${pattern}" | sed s/@CONTENT@/${oldvalue}/)
    else
        printf "No transform given.\n"
        usage
        exit 12
    fi
    #echo Comparing [${newvalue}] to [${oldvalue}]
    if [[ "${newvalue}" == "${oldvalue}" ]]; then
        if ${verbose}; then
            printf "No change:\n"
            pbpaste
            printf "\n"
        else
            printf "No change.\n"
        fi
    else
        echo "${newvalue}" | pbcopy
        if ${verbose}; then
            printf "Updated to:\n"
            pbpaste
            printf "\n"
        else
            printf "Updated.\n"
        fi
    fi

    if ${doListenForChange}; then
        while [[ ${newvalue} == $(pbpaste) ]]; do
            sleep 1 #; echo Sleeping
        done
    else
        exit 0
    fi
done
