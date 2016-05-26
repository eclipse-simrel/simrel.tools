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
baseEclipseDirSegment=eclipse/downloads/drops4/R-4.5.2-201602121500
baseEclipse=eclipse-platform-4.5.2-linux-gtk-x86_64.tar.gz
repoFileAccess=file:///home/data/httpd/download.eclipse.org/
repoHttpAccess=http://download.eclipse.org
repoAccess=${repoFileAccess}

declare -a namesArray
declare -a countsArray

if [[ -z "$quickCheck" ]]
then
  quickCheck="false"
fi
printf "\n\t[INFO] quickCheck was $quickCheck\n"

# We may want to check all of these  repos daily but after a promote, may want to pass
# quickCheck=true after the "makeVisisble" job.

# Note, we may want to use a one of the "locks" to prevent staging or neon
# from changing in the middle of a run.
# Also note: "staging" is a simple repo, at this time, but wouldn't hurt to
# get a listing, and see what was there?
repoList="\
  /releases/neon/ \
  /staging/neon/ \
  /releases/mars/ \
  "
# We may want to check only this repo after "makeVisible"
quickRepoList="\
  /releases/neon/ \
  "

if [[ "$quickCheck" == "true" ]]
then
  reposToCheck=${quickRepoList}
else
  reposToCheck=${repoList}
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
  printf "\n\tNumber of IUs in $repoShortName: $repoCount\n"

  namesArray[$loopCount]=$repoShortName
  countsArray[$loopCount]=$repoCount
  loopCount=$((loopCount + 1))
  #printf "\n\t[DEBUG] loopCount: $loopCount\n"
  RAW_DATE_END="$(date +%s )"
  printf "\t[INFO] Elapsed seconds for this repo: $(($RAW_DATE_END - $RAW_DATE_START))"

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
