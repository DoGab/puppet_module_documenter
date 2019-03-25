#!/bin/bash
#
# Script to create the README.md documentation
# for every module in the site folder
#
# This script needs to be run in a git repository
#
# To do:
#  - run pdk validate

SCRIPTVERSION="1.0.0"
AUTHOR="Dominic Gabriel"
EMAIL="gabriel@puzzle.ch"

GITBIN="/usr/bin/git"

MODULEDIRNAME="site"
PUPPETBIN="/opt/puppetlabs/bin/puppet"
DOCFORMAT="markdown"
DOCFILE="README.md"
PUPPETARGS="strings generate --format $DOCFORMAT --out $DOCFILE"
PUPPETRUN="$PUPPETBIN $PUPPETARGS"

PDKBIN="/usr/local/bin/pdk"
PDKARGS="update --force"
PDKRUN="$PDKBIN $PDKARGS"

EXITCODE=0

usage() {
  cat << EOF
Usage: $0 [-h|--help] [-v|--verbose] [-V|--version]

  -h|--help           Print this help text
  -v|--verbose        Run the script in verbose mode
  -V|--version        Print the version of this script
EOF
  exit 0
}

print_version() {
  cat << EOF
Name:         $0
Version:      $SCRIPTVERSION
Author:       $AUTHOR <$EMAIL>
EOF
  exit 0
}

while [ $# -gt 0 ]; do
  key=$1
  case $key in
    -h|--help)
      usage
      shift
      ;;
    -v|--verbose)
      VERBOSE=true
      shift
      ;;
    -V|--version)
      print_version
      shift
      ;;
    *)
      usage
      shift
      ;;
  esac
done


print_verbose() {
  if [ "$VERBOSE" == true ]; then
    echo "$1"
  fi
}

run_puppet_strings() {
  eval $PUPPETRUN
  if [ $? != 0 ]; then
    EXITCODE=1
  fi
}

run_pdk_update() {
  eval $PDKRUN
  if [ $? != 0 ]; then
    EXITCODE=1
  fi
}

check_for_binary() {
  if [ ! -f $1 ]; then
    echo "Error: Binary ${1} not found!"
    exit 1
  else
    print_verbose "Binary found: ${1}"
  fi
}

preparation_checks() {
  check_for_binary $GITBIN
  check_for_binary $PUPPETBIN
  check_for_binary $PDKBIN

  if [ -d .git ]; then
    GITTOPDIR=$(pwd)
  else
    GETGITDIR=$($GITBIN rev-parse --git-dir 2> /dev/null)
    if [ $? == 0 ]; then
      GITTOPDIR=$(dirname $GETGITDIR)
      cd $GITTOPDIR
    else
      echo "Error: The current directory $(pwd) seems not to be a git directory!"
      exit 1
    fi
  fi
}

get_modules() {
  print_verbose "Gittopdir: $GITTOPDIR"
  GITMODULEDIR=$GITTOPDIR/$MODULEDIRNAME

  print_verbose "Module dir: $GITMODULEDIR"
  MODULES=($(ls -d ${GITMODULEDIR}/*/ 2>/dev/null))
  if [ ${#MODULES[@]} -eq 0 ]; then
    echo "Error: No modules found!"
    exit 1
  fi
}

run() {
  preparation_checks
  get_modules

  if [ "$VERBOSE" != true ]; then
    PUPPETRUN="$PUPPETRUN > /dev/null 2>&1"
    PDKRUN="$PDKRUN > /dev/null 2>&1"
  fi

  print_verbose "Command: $PUPPETRUN"
  print_verbose "Command: $PDKRUN"

  for module in "${MODULES[@]}"; do
    module_name=$(basename $module)
    print_verbose "**********************************************"
    print_verbose "module: $module_name"
    print_verbose "**********************************************"
    cd $module
    run_puppet_strings
    run_pdk_update
  done
}

run

if [ $EXITCODE -eq 1 ]; then
  echo "There were some errors, please check!"
fi

exit $EXITCODE
