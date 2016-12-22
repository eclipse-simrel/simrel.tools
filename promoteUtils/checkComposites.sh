#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2016 IBM Corporation and others.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#     David Williams - initial API and implementation
#*******************************************************************************

# Utility to run on Hudson, to periodically confirm that our
# atomic composite repositories are valid.

# can be retrieved as individual script with
#
# wget --no-verbose --no-cache  -O checkComposites.sh http://git.eclipse.org/c/simrel/org.eclipse.simrel.tools.git/plain/promoteUtils/checkComposites.sh;
#
# and typically set chmod +x checkComposites.sh
# and then executed in "bash script" build step.
RAW_OVERALL_DATE_START="$(date +%s )"
baseEclipseAccessDir=/home/data/httpd/download.eclipse.org
baseEclipseDirSegment=eclipse/downloads/drops4/R-4.6.2-201611241400
baseEclipse=eclipse-platform-4.6.2-linux-gtk-x86_64.tar.gz
repoFileAccess=file:///home/data/httpd/download.eclipse.org/
repoHttpAccess=http://download.eclipse.org
repoAccess=${repoFileAccess}

declare -a namesArray
declare -a countsArray

# This script expects an argument similar to "trainname" but 
# but in this case can be "all" (in which all repos in "repoList" are 
# checked -- that is the "periodic use case".
# Or, it can be just one, such as 'neon' or 'oxygen', in which case 
# only that one repository is checked. 

trainArg=$1

if [[ -z "$trainArg" ]] 
then
  printf "[INFO] No argument was passed to ${0##*/} so assuming \"all\".\n"
  trainArg=all
fi

# Note, we may eventually want to use "locks" to prevent staging or other repo from
# from changing in the middle of a run.

# Also note: "staging" is a simple repo, at this time, but wouldn't hurt to
# get a listing, and see what was there?

repoList="\
  releases/oxygen/ \
  releases/neon/ \
  staging/neon/ \
  staging/oxygen/ \
  releases/mars/ \
  "

if [[ "$trainArg" == "all" ]]
then
  reposToCheck=${repoList}
else
  reposToCheck="releases/$trainArg"
fi

# WORKSPACE will be defined in Hudson. For convenience of local, remote, testing we will make several
# assumptions if it is not defined.
if [[ -z "${WORKSPACE}" ]]
then
  echo -e "\n\t[INFO] WORKSPACE not defined. Assuming local, remote test."
  WORKSPACE="$PWD"
  #printf "\n\tWORKSPACE: $WORKSPACE\n"
  # access can remain undefined if we have direct access, such as on Hudson.
  # The value used here will depend on local users .ssh/config
  access="build:"
  repoAccess="${repoHttpAccess}"
fi

# Confirm that Eclipse Platform has already been installed, if not, install it
if [[ ! -d "${WORKSPACE}/eclipse" ]]
then
  # We assume we have file access to 'downloads'. If not direct, at least via rsync.
  printf "\n\t[DEBUG] rsynching eclipse platform archive to ${WORKSPACE}"
  printf "\n\t[DEBUG] rsync command: rsync ${access}${baseEclipseAccessDir}/${baseEclipseDirSegment}/${baseEclipse} ${WORKSPACE}"
  rsync "${access}${baseEclipseAccessDir}/${baseEclipseDirSegment}/${baseEclipse}" "${WORKSPACE}"
  RC=$?
  if [[ $RC != 0 ]]
  then
    printf "[ERROR] rsync returned a non-zero return code: $RC"
    exit $RC
  fi

  tar -xf "${baseEclipse}" -C "${WORKSPACE}"
  RC=$?
  if [[ $RC != 0 ]]
  then
    printf "[ERROR] Tar extraction returned a non-zero return code: $RC"
    exit $RC
  fi
fi
printf "\n\n\tNote: see workspace for files of IU listings"
#printf "\n\t[DEBUG] reposToCheck: ${reposToCheck}"
loopCount=0
errorCount=0
for repo in ${reposToCheck}
do
  RAW_DATE_START="$(date +%s )"
  printf "\n\n\tChecking repo:\n\t${repoAccess}${repo}\n\n"
  # first remove trailing slash, if there is one
  repoShortName=${repo%/}
  # then leading slash, if one
  repoShortName=${repoShortName#/}
  #printf "\n\t[DEBUG] repoShortName with trimmed slashed: ${repoShortName}"
  # then remove everything else except final name segment
  # now translate remaining ones with underscores
  repoShortName="${repoShortName//\//_}"
  repoListFilename="${repoShortName}-Listing.txt"
  #printf "\n\t[DEBUG] repoShortName: ${repoShortName}"
  #printf "\n\t[DEBUG] repoListFilename: ${repoListFilename}"
  nice -n 10 ${WORKSPACE}/eclipse/eclipse -nosplash --launcher.suppressErrors -application org.eclipse.equinox.p2.director -repository "${repoAccess}${repo}" -list -vm /shared/common/jdk1.8.0_x64-latest/bin/java  1>"$WORKSPACE/${repoListFilename}"
  RC=$?
  if [[ $RC != 0 ]]
  then
    printf "\n\t[ERROR] p2.director list returned a non-zero return code: $RC"
    exit $RC
  fi

  repoCount=$(cat "$WORKSPACE/${repoListFilename}" | wc -l)
  # there are always 4 lines of ouput, even if "0" IUs returned (see bug 502080) 
  # so we simply deduct 4 it be more accurate and provide a better test. 
  repoCount=$((repoCount - 4))
  printf "\n\tNumber of IUs in $repoShortName: $repoCount\n"

  if [[ $repoCount -le 0 ]] 
  then 
    errorCount=$((errorCount + 1))
  fi

  namesArray[$loopCount]=$repoShortName
  countsArray[$loopCount]=$repoCount
  loopCount=$((loopCount + 1))
  #printf "\n\t[DEBUG] loopCount: $loopCount\n"
  RAW_DATE_END="$(date +%s )"
  printf "\t[INFO] Elapsed seconds for this repo: $(($RAW_DATE_END - $RAW_DATE_START))"

  # I guess for errorCount errors, I could continue with whole loop, but seems
  # rare enough I will go ahead and "throw" error here, before finishing the 
  # whole loop.
  if [[ $errorCount > 0 ]] 
  then
    printf "\n\t[ERROR] $repoShortName has too few IUs reported. Perhaps a problem with p2.index files?\n"
    exit $errorCount
  fi
done
#printf "\t[DEBUG] names array: ${namesArray[*]}\n"
printf "\n\n\tRepository\t Number of IUs"
for arrayCount in "${!namesArray[@]}"
do
  printf "\n\t${namesArray[$arrayCount]}\t ${countsArray[$arrayCount]}"
done
printf "\n\n"
RAW_OVERALL_DATE_END="$(date +%s )"
printf "\t[INFO] Elapsed seconds for this script: $(($RAW_OVERALL_DATE_END - $RAW_OVERALL_DATE_START))"
printf "\n\n"
