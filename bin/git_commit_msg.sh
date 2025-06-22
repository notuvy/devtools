#!/bin/bash
#------------------------------------------------------------------------------
# 
#------------------------------------------------------------------------------

scriptdir="$(dirname $0)"
scriptname="$(basename $0)"
metacmd=""
doDiff=false
doSave=false
doEdit=false
doClipboard=false
doDelete=false
commit_msg=""

if [[ -d ${HOME}/var ]]; then srcroot="${HOME}/var"; else srcroot=/var/tmp; fi
srcfile="${srcroot}/git_commit_msg.txt"

usage () {
    cat <<USAGE
Save/show the text to be used as a commit message to a file (${srcfile}).
Return the text if the file exists.
If it does not, either ask for input or exit with an error.

Usage:  ${scriptname} [-h] [-S | -M "msg" | -v | -D | -C] [-d] [-P]

  -S      Query for (one line) text to save as the commit message.
  -M msg  Set the given (quoted) message text.
  -v      Edit the commit message with vi.
  -d      Show the diff before editing.
  -D      Delete the message file.
  -C      Use the current clipboard contents as the message.
  -P      Just print the full path of the file.
USAGE
}

while getopts "hqSM:vdCDP" optionName; do
    case "${optionName}" in
        h)  usage; exit 0;;
        q)  metacmd=echo;;
        S)  doSave=true;;
        M)  doSave=true; commit_msg="${OPTARG}";;
        v)  doEdit=true;;
        d)  doDiff=true;;
        C)  doClipboard=true;;
        D)  doDelete=true;;
        P)  echo "${srcfile}"; exit 0;;
        \?) usage; exit 3
    esac
done
shift $(($OPTIND-1))

if ! [[ $# == 0 ]]; then printf "Extra args [%s].\n\n" "$*"; usage; exit 21; fi

if ${doClipboard}; then
    pbpaste > "${srcfile}"
fi

if ${doEdit}; then
    if ${doDiff}; then
        ${metacmd} git diff --staged
        if ! [[ ${metacmd} == echo ]]; then
            read -n 1 -p "Continue with edit? [y/N] >" response; echo
            [[ ${response} =~ ^[yY] ]] || { printf "Aborted.\n"; exit 0; }
        fi
    fi
    ${metacmd} vi "${srcfile}"
elif ${doSave}; then
    if [[ -z ${commit_msg} ]]; then
        printf "Enter the one-line commit message to use.\n"
        read -p "> " commit_msg
        if [[ -z ${commit_msg} ]]; then printf "Aborted.\n"; exit 22; fi
    fi
    ${metacmd} echo "${commit_msg}" > "${srcfile}"
fi

if ${doDelete}; then
    ${metacmd} rm -i "${srcfile}"
elif [[ -f ${srcfile} ]]; then
    ${metacmd} cat "${srcfile}"
else
    printf "No file [%s].\n" "${srcfile}"
    exit 23
fi
