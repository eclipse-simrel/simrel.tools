#!/usr/bin/env bash

# TODO: print stats

SCRIPT_NAME="$(basename ${0})"
STAGING_SEG=staging
DOWNLOAD_BASE=/home/data/httpd/download.eclipse.org

# Parameters:
TRAIN_NAME="$1"

usage() {
  printf "Usage %s [train_name]\n" "${SCRIPT_NAME}"
  printf "\t%-16s the release train name (e.g. neon, oxygen, photon)\n" "train_name"
}

# Verify inputs
if [[ -z "$TRAIN_NAME" && $# -lt 1 ]]; then
  printf "ERROR: a release train name must be given.\n"
  usage
  exit 1
fi


STAGING_DIR=${STAGING_SEG}/${TRAIN_NAME}
CLEAN_BUILD_JOB=simrel.${TRAIN_NAME}.runaggregator.BUILD__CLEAN

echo -e "\n\tDEBUG: Who am I: $(whoami)"

# clean old staging first
printf "\n\tINFO: %s\t\n" "Cleaning old staging ($STAGING_DIR) repository ..."
rm -fr ${DOWNLOAD_BASE}/$STAGING_DIR/*
RC=$?
if [[ $RC != 0 ]]
then 
  printf "\n\tERROR: %s\t\n" "Cleaning (removing) previous staging ($STAGING_DIR) repo failed. RC: $RC"
  exit $RC
fi
printf "\n\tINFO: %s\t\n" "Cleaning old staging repository ended ok."

# assuming directories (and symbolic link, lastSuccessfulBuild) is predictable and accessible
printf "\n\tINFO: %s\t\n" "Copying from last successful clean build, to downloads staging server ..."
rsync -r --chmod=Dg+s,ug+w,Fo-w,+X --copy-links /home/hudson/genie.simrel/.hudson/jobs/${CLEAN_BUILD_JOB}/lastSuccessful/archive/aggregation/final/* ${DOWNLOAD_BASE}/$STAGING_DIR/
RC=$?
if [[ $RC != 0 ]]
then 
  printf "\n\tERROR: %s\t\n" "Error occurred during copy from Hudson archive to downloads staging. RC: $RC"
  exit $RC
fi
printf "\n\tINFO: %s\t\n" "Copying from last successful clean build logs, to staging location: ...${STAGING_DIR}/buildInfo/hudsonrecords"
# purposely do not recurse
mkdir -p ${DOWNLOAD_BASE}/$STAGING_DIR/buildInfo/hudsonrecords

# tried chmod, in rsync command, in past, to correct access problems, but, 
# should not be needed
# --chmod=Dg+s,ug+w,Fo-w,+X 
rsync  --copy-links /home/hudson/genie.simrel/.hudson/jobs/${CLEAN_BUILD_JOB}/lastSuccessful/* ${DOWNLOAD_BASE}/$STAGING_DIR/buildInfo/hudsonrecords/
RC=$?
if [[ $RC != 0 ]]
then 
  printf "\n\tERROR: %s\t\n" "Error occurred during copy from Hudson archive Hudson records to downloads $STAGING_DIR/buildInfo/hudsonrecords. RC: $RC"
  exit $RC
fi
printf "\n\tINFO: %s\t\n" "Copying from last successful clean build, to downloads staging server ended ok."

#TODO: print stats on new staging

#TODO: potentially may want to put this (or similar) at top, to be sure all will work ok before deleting current directories. 
#      in this case, though, could still manually start the EPP builds. 
CURL_EXE=$(which curl)
RC=$?
if [[ ! $RC == 0 ]]
then
    printf "\n\tERROR: 'curl' is nonexistent or not executable. Return code from 'which': %d\n" $RC
    printf "\t\tWe are running with 'USER' set to $USER\n"
    env > envOutput.txt
    printf "\t\tSee 'envOutput.txt' for full listing of environment variables\n"
    printf "\tExiting early due to this error.\n"
    exit 1
fi

${CURL_EXE} https://hudson.eclipse.org/packaging/job/${TRAIN_NAME}.epp-tycho-build/buildWithParameters?token=Yah6CohtYwO6b?6P
RC=$?
if [[ $RC != 0 ]]
then 
  printf "\n\tERROR: %s\t\n" "Notifying EPP Build returned an error. RC: $RC"
  exit $RC
fi
printf "\n\tINFO: %s\t\n" "Notifying EPP Build there is a new staging repo ended ok."

exit 0

