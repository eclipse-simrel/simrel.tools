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

# Utility to run on CI server, to periodically confirm that our atomic composite repositories are valid.

# can be retrieved as individual script with
# wget --no-verbose --no-cache  -O checkComposites.sh https://git.eclipse.org/c/simrel/org.eclipse.simrel.tools.git/plain/promoteUtils/checkComposites.sh;
#
# and typically set chmod +x checkComposites.sh and then executed in "bash script" build step.

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

RAW_OVERALL_DATE_START="$(date +%s )"
baseEclipseAccessDir="/home/data/httpd/download.eclipse.org"
baseEclipseDirSegment="eclipse/downloads/drops4/R-4.36-202505281830"
baseEclipse="eclipse-SDK-4.36-linux-gtk-x86_64.tar.gz"
repoFileAccess="file:///home/data/httpd/download.eclipse.org/"
repoHttpAccess="https://download.eclipse.org"

# direct file access is discouraged and not necessary, but if there is a good reason to still use it set repoAccess="${repoFileAccess}"
repoAccess="${repoHttpAccess}"

SSH_REMOTE="genie.simrel@projects-storage.eclipse.org"

declare -a namesArray
declare -a countsArray

# This script expects an argument similar to "trainname" but in this case can be "all" (in which the last 5 repos in /home/data/httpd/download.eclipse.org/releases" are checked) 
# Or, it can be just one, such as '2020-12', in which case only that one repository is checked. 

trainArg="${1:-}"

# Note, we may eventually want to use "locks" to prevent staging or other repo from changing in the middle of a run.
# Also note: "staging" is a simple repo, at this time, but wouldn't hurt to get a listing, and see what was there?

if [[ -z "$trainArg" ]]; then
  printf "[INFO] No argument was passed to %s so assuming \"all\".\n" "${0##*/}"
  # get last 5 releases from /home/data/httpd/download.eclipse.org/releases
  reposToCheck=$(ssh ${SSH_REMOTE} "cd ${baseEclipseAccessDir} ; ls -1d releases/* | grep '20' | tail -n 5")
else
  reposToCheck="releases/$trainArg"
fi

# WORKSPACE will be defined in CI instance, otherwise $PWD
WORKSPACE="${WORKSPACE:-$PWD}"

# Confirm that Eclipse Platform has already been installed, if not, install it
# If you want to run this script locally, download and extract a Eclipse platform to the working directory
if [[ ! -d "${WORKSPACE}/eclipse" ]]; then
  # We assume we have scp access to 'downloads'. If not direct, at least via rsync.
  printf "Copying Eclipse platform archive via SCP..."
  scp "${SSH_REMOTE}:${baseEclipseAccessDir}/${baseEclipseDirSegment}/${baseEclipse}" .
  tar --warning=no-unknown-keyword -xzf "${baseEclipse}" -C "${WORKSPACE}"
fi

printf "\n\tNote: see workspace for files of IU listings"
#printf "\n\t[DEBUG] reposToCheck: ${reposToCheck}"
loopCount=0
errorCount=0
for repo in ${reposToCheck}
do
  RAW_DATE_START="$(date +%s )"
  printf "\n\n\tChecking repo:\n\t%s%s\n\n" "${repoAccess}" "${repo}"
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
  nice -n 10 ${WORKSPACE}/eclipse/eclipse -nosplash --launcher.suppressErrors -application org.eclipse.equinox.p2.director -repository "${repoAccess}/${repo}" -list 1>"${WORKSPACE}/${repoListFilename}"
  RC=$?
  if [[ $RC != 0 ]]; then
    printf "\n\t[ERROR] p2.director list returned a non-zero return code: %s" "$RC"
    exit $RC
  fi

  repoCount=$(cat "${WORKSPACE}/${repoListFilename}" | wc -l)
  # there are always 4 lines of ouput, even if "0" IUs returned (see bug 502080) 
  # so we simply deduct 4 it be more accurate and provide a better test. 
  repoCount=$((repoCount - 4))
  printf "\n\tNumber of IUs in %s: %s\n" "$repoShortName" "$repoCount"

  if [[ ${repoCount} -le 0 ]]; then 
    errorCount=$((errorCount + 1))
  fi

  namesArray[$loopCount]="${repoShortName}"
  countsArray[$loopCount]="${repoCount}"
  loopCount=$((loopCount + 1))
  #printf "\n\t[DEBUG] loopCount: $loopCount\n"
  RAW_DATE_END="$(date +%s )"
  printf "\t[INFO] Elapsed seconds for this repo: %s" "$((RAW_DATE_END - RAW_DATE_START))"

  # I guess for errorCount errors, I could continue with whole loop, but seems
  # rare enough I will go ahead and "throw" error here, before finishing the whole loop.
  if [[ ${errorCount} -gt 0 ]]; then
    printf "\n\t[ERROR] %s has too few IUs reported. Perhaps a problem with p2.index files?\n" "$repoShortName"
    exit ${errorCount}
  fi
done
#printf "\t[DEBUG] names array: ${namesArray[*]}\n"
printf "\n\n\tRepository\t Number of IUs"
for arrayCount in "${!namesArray[@]}"
do
  printf "\n\t%s\t %s" "${namesArray[$arrayCount]}""${countsArray[$arrayCount]}"
done
printf "\n\n"
RAW_OVERALL_DATE_END="$(date +%s )"
printf "\t[INFO] Elapsed seconds for this script: %s" "$((RAW_OVERALL_DATE_END - RAW_OVERALL_DATE_START))"
printf "\n\n"
