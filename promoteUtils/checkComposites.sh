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

# can be retrieved, on Hudson, with 
# wget --no-verbose --no-cache  -O checkComposites.sh http://${GIT_HOST}/c/platform/eclipse.platform.releng.aggregator.git/plain/production/miscToolsAndNotes/checkComposites/checkComposites.sh;
# and typically set chmod +x checkComposites.sh
# and then executed in "bash script" build step.

baseEclipseAccessDir=/home/data/httpd/download.eclipse.org
baseEclipseDirSegment=eclipse/downloads/drops4/R-4.5.2-201602121500
baseEclipse=eclipse-platform-4.5.2-linux-gtk-x86_64.tar.gz
repoFileAccess=file:///home/data/httpd/download.eclipse.org/
repoHttpAccess=http://download.eclipse.org
repoAccess=${repoFileAccess}


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

# WORKSPACE will be defined in Hudson. For convenience of local, remote, testing we will make several
# assumptions if it is not defined.
if [[ -z "${WORKSPACE}" ]]
then
  echo -e "\n\tWORKSPACE not defined. Assuming local, remote test."
  WORKSPACE=${PWD}
  # access can remain undefined if we have direct access, such as on Hudson.
  # The value used here will depend on local users .ssh/config
  access=build:
  repoAccess=${repoHttpAccess}
fi

# Confirm that Eclipse Platform has already been installed, if not, install it
if [[ ! -d ${WORKSPACE}/eclipse ]]
then
  # We assume we have file access to 'downloads'. If not direct, at least via rsync.
  echo -e "\n\trsynching eclipse platform archive to ${WORKSPACE}"
  echo -e "\n\trsync command: rsync ${access}${baseEclipseDirSegment}/${baseEclipse} ${WORKSPACE}"
  rsync ${access}${baseEclipseAccessDir}/${baseEclipseDirSegment}/${baseEclipse} ${WORKSPACE}
  tar -xf ${baseEclipse} -C ${WORKSPACE}
fi

for repo in ${repoList}
do
  echo -e "\n\n\tChecking repo:\n\t${repoAccess}${repo}\n\n"
  nice -n 10 ${WORKSPACE}/eclipse/eclipse -nosplash -consolelog --launcher.suppressErrors -application org.eclipse.equinox.p2.director -repository ${repoAccess}${repo} -list -vm /shared/common/jdk1.8.0_x64-latest/bin/java
  RC=$?
  if [[ $RC != 0 ]]
  then
    echo -e "\n\t[ERROR]: p2.director list returned a non-zero return code: $RC"
    exit $RC
  fi
done

