#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2009-2016 Eclipse Foundation and others.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#     David Williams - initial implementation
#*******************************************************************************

# Simple script to count number of mirrors available for a particular URL
#
# To be useful, this script must be downloaded to "local" machine, so it accesses eclipse.org
# from outside eclipse.org. (Mirrors are not suggested, when running on build.eclipse.org.)
# Also, to be useful, most will want to change the list of default URLs to check, in your local copy.


function usage() {
  printf "\n\t%s\n" "Simple script to count number of mirrors available for a particular URL" >&2
  printf "\t%s\n"   "Usage: $(basename $0) [-h] | [-v] [-f] [-p] [-t number] [urls]"  >&2
  printf "\t\t%s\t%s\n" "-h" "help" >&2
  printf "\t\t%s\t%s\n" "-v" "verbose" >&2
  printf "\t\t%s\t%s\n" "-f" "ftp only" >&2
  printf "\t\t%s\t%s\n" "-p" "http only" >&2
  printf "\t\t%s\t%s\n" "-b" "both ftp and http (default)" >&2
  printf "\t\t%s\t%s\n" "-l" "list mirrors (saved in mirrorsList.txt) " >&2
  printf "\t\t%s\t%s\n" "-t n" "test against number n" >&2
  printf "\t\t%s\t%s\n"  "urls" "space delimited list of URI parameters such as /releases/galileo/" >&2
  printf "\n"
}

function checkMirrorsForURL() {
  if [ -z $1 ]; then
    echo "Error: internal funtion requires mirror url parameter";
    exit 3;
  else
    mirrorURL=$1
  fi
  if [ -z $2 ]; then
    protocol=
    pword="http and ftp"
  else
    protocolarg="&protocol=$2"
    pword="$2"
  fi
  if [[ $listMirrors -eq 1 ]]; then
    listOfMirrors=$(wget -q -O - "http://www.eclipse.org/downloads/download.php?file=${mirrorURL}&format=xml${protocolarg}")
    printf "\n\t%s\n\n%s\n\n" "${mirrorURL}" "${listOfMirrors}" >> mirrorsList.txt
  fi
  nMirrors=$(wget -q -O - "http://www.eclipse.org/downloads/download.php?file=${mirrorURL}&format=xml${protocolarg}" | grep "<mirror\ " | wc -l)
  #printf "\t%s%4d%s\n" "number of ${pword} mirrors: " ${nMirrors} "  for ${mirrorURL}" >&2
  printf "%s%4d%s\n" "number of mirrors:" ${nMirrors} " for ${mirrorURL}" >&2
  # echo to get nMirrors "returned" to caller
  echo $nMirrors
}

function minvalue() {
  ref=$1
  comp=$2
  #echo "DEBUG: ref: $ref" >&2
  #echo "DEBUG: comp: $comp" >&2
  result=
  if [ -z $comp ]; then
    result=$ref
  else
    if [ $ref -lt $comp ]; then
      result=$ref
    else
      result=$comp
    fi
  fi
  echo $result
}

# by default, check for both FTP and HTTP sites.
urls=
ftponly=0
httponly=0
protocol=
listMirrors=0
while getopts 'hvlfpbt:' OPTION
do
  case $OPTION in
    h)    usage
      exit 1
      ;;
    f)    ftponly=1
      httponly=0
      ;;
    p)    httponly=1
      ftponly=0
      ;;
    b)    httponly=0
      ftponly=0
      ;;
    l)    listMirrors=1
      ;;
    v)    verbose=1
      ;;
    t)    testNumber=$OPTARG
      ;;
      # No fall-through. We run without any arguments
  esac
done

shift $(($OPTIND - 1))

urls="$@"

if [ $ftponly == 1 ]; then
  protocol="ftp"
fi
if [ $httponly == 1 ]; then
  protocol="http"
fi
if [ $ftponly == 1 -a $httponly == 1 ]; then
  protocol=
fi

if [ $verbose ]; then
  echo "ftponly: " $ftponly " httponly: " $httponly
  echo "protocol: " $protocol
  echo "urls on cmd line: " $urls
  echo "listMirrors: $listMirrors"
  if [[ $listMirrors -eq 1 ]]; then
    echo "check for list of mirrors in mirrorsList.txt"
  fi
fi

if [[ $listMirrors -eq 1 ]]; then
  # remove any existing mirrorsList.txt files
  rm -f mirrorsList.txt
fi

get_dir_list() {
  local url="$1"
  # get html, only extract the dirlist, remove the dirlist title (<h2>), fix the html, select the div,
  # get rid of all empty lines, grep for "20"
  curl -s -L -H 'X-Cache-Bypass: true' "${url}" | \
  sed -n "/<div id='dirlist'>/,/<\/div>/p" | \
  sed "s/<h2>.*<\/h2>//" | \
  xmlstarlet fo -R --noindent 2>/dev/null | \
  xmlstarlet sel -t -v "//div" | \
  sed '/^[[:space:]]*$/d'| \
  grep "20"
}

get_epp_releases() {
  for release in $(get_dir_list "https://download.eclipse.org/technology/epp/packages")
  do
    echo "/technology/epp/packages/${release}"
  done 
}

get_simrel_releases() {
  local releases_url="https://download.eclipse.org/releases"
  for release in $(get_dir_list "${releases_url}")
  do
    # get list of release subdirs, take the last one, trim string
    subdir=$(get_dir_list "${releases_url}/${release}" | tail -n 1 | sed -e 's/^[[:space:]]*//')
    if [[ ! -z "${subdir}" ]]; then
      echo "/releases/${release}/${subdir}"
    fi
  done 
}

if [ -z "${urls}" ]; then
   # line breaks are not really handled nicely here, but it still works
   urls="\
     /tools/orbit/downloads/drops/R20160520211859/repository/ \
     /cbi/updates/aggregator/ide/4.8/ \
     /cbi/updates/aggregator/headless/4.8/ \
     /eclipse/updates/4.6/R-4.6-201606061100 \
     /eclipse/updates/4.6/R-4.6.1-201609071200 \
     /eclipse/updates/4.6/R-4.6.2-201611241400 \
     /eclipse/updates/4.6/R-4.6.3-201703010400 \
     $(get_epp_releases) \
     $(get_simrel_releases)"
fi

if [ $verbose ]; then
  echo "\$HOSTNAME: " $HOSTNAME
fi

# if [ "davidw-hp-m10" == $HOSTNAME ]
if [ "build" == $HOSTNAME ]; then
  printf "\n\t%s\n" "[WARNING] Remmember, when running on 'build.eclipse.org' 0 (zero) mirrors are expected"
fi

minimumMirrors=
if [ "${urls}" ]; then
  #echo -e "\n[DEBUG] urls: $urls\n"
  for mirrorURL in ${urls}
  do
    nm=$(checkMirrorsForURL $mirrorURL $protocol)
    minimumMirrors=`minvalue $nm $minimumMirrors`
  done
  echo
else
  usage
fi

if [ -z $testNumber ]; then
  if [ $verbose ]; then
    echo "no test mode"
  fi
  exit 0
else
  fresult=$((testNumber - minimumMirrors))
  if [ $fresult -le 0 ]; then
    if [ $verbose ]; then
      echo "minimum mirrors, $minimumMirrors, was greater than or equal to criteria, $testNumber"
    fi
    exit 0
  else
    echo "[ERROR] minimum mirrors, $minimumMirrors, was not as large as criteria, $testNumber"
    exit $fresult
  fi
fi
