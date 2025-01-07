#!/bin/bash
#------------------------------------------------------------------------------
# 
#------------------------------------------------------------------------------

scriptdir="$(dirname $0)"
scriptname="$(basename $0)"
metacmd=""
doDiff=false
doExecuteCommit=false
doAddAll=false
doPush="" # undefined

if [[ -d ${HOME}/var ]]; then srcroot="${HOME}/var"; else srcroot=/var/tmp; fi
srcfile="${srcroot}/git_commit_msg.txt"

usage () {
    cat <<USAGE
Automate some of the standard development workflow with git.  This involves:
  1. Add files
  2. Diff changes
  3. Commit files (with a message)
  4. Push the commits

Usage:  ${scriptname} [-h] [-a] [-d] [-m | -M "msg"] [-X] [-p | -P]

  -a      Do 'git add .' before commit.
  -d      Show the diff before editing.
  -m      Commit with the predefined message (via git_commit_msg.sh).
  -M msg  Commit with the given (quoted) message text.
  -p      Do 'git push' after commit.
  -P      Do NOT 'git push' after commit.
USAGE
}

pushAfterCommit() {
    if [[ -z ${doPush} ]] && [[ -z ${metacmd} ]]; then
        read -n 1 -p "Do 'git push'? [y/N] >" response; echo
        if [[ ${response} =~ ^[yY] ]]; then
            doPush=true
        else
            doPush=false
        fi
    fi

    if ${doPush}; then
        ${metacmd} git push
    else
        printf "No push.\n"
    fi
}

while getopts "hadmM:pP" optionName; do
    case "${optionName}" in
        h)  usage; exit 0;;
        q)  metacmd=echo;;
        a)  doAddAll=true;;
        d)  doDiff=true;;
        m)  doExecuteCommit=true;;
        M)  doExecuteCommit=true; git_commit_msg.sh -M "${OPTARG}";;
        p)  doPush=true;;
        P)  doPush=false;;
        \?) usage; exit 3
    esac
done
shift $(($OPTIND-1))

if ! [[ $# == 0 ]]; then printf "Extra args [%s].\n\n" "$*"; usage; exit 21; fi

${doAddAll} && ${metacmd} git add .
${metacmd} git status --short
${doDiff} && ${metacmd} git diff --staged

if ${doExecuteCommit}; then
    if ! [[ ${metacmd} == echo ]]; then
        printf "Commit message:\n"
        git_commit_msg.sh
        echo
        read -n 1 -p "Continue with commit? [y/N] >" response; echo
        [[ ${response} =~ ^[yY] ]] || { printf "Aborted.\n"; exit 0; }
    fi
    ${metacmd} git commit -F "$(git_commit_msg.sh -P)"
    pushAfterCommit
fi
