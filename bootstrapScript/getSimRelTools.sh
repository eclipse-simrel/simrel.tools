#!/usr/bin/env bash


# This script file is to help get builds started "fresh" by checking
# out the master branch of org.eclipse.simrel.tools.

# BUILD_HOME is normally set to $WORKSPACE when running on Hudson,
# but if running locally, you can set it to what ever you'd like.
# For example,
# $ BUILD_HOME=${PWD} ./getSimRelTools.sh

printf "\n[INFO] %s\n" "Updating (or cloning) org.eclipse.simrel.tools"


export BUILD_HOME=${BUILD_HOME:-"${WORKSPACE}"}
if [[ -z "${BUILD_HOME}" ]]
then
  printf "\n[ERROR] %s\n" "BUILD_HOME (or WORKSPACE) must be set before invoking this script."
  exit 1
else
  printf "\n[INFO] %s\n" "BUILD_HOME: $BUILD_HOME"
fi

if [[ -d "${BUILD_HOME}/org.eclipse.simrel.tools" ]]
then
  pushd "${BUILD_HOME}/org.eclipse.simrel.tools" 1>/dev/null
  RC=$?
  if [[ $RC != 0 ]]
  then
    printf "\n[ERROR] %s\n" "pushd to simrel.tools returned non-zero return code: $RC. Exiting."
    exit 1
  fi
  git fetch
  RC=$?
  if [[ $RC != 0 ]]
  then
    printf "\n[ERROR] %s\n" "Git fetch of simrel tools returned non-zero return code: $RC. Exiting."
    exit 1
  fi
  git reset --hard
  RC=$?
  if [[ $RC != 0 ]]
  then
    printf "\n[ERROR] %s\n" "Git reset of simrel tools returned non-zero return code: $RC. Exiting."
    exit 1
  fi
  git checkout master
  RC=$?
  if [[ $RC != 0 ]]
  then
    printf "\n[ERROR] %s\n" "Git checkout of simrel tools master returned non-zero return code: $RC. Exiting."
    exit 1
  fi
  git pull
  RC=$?
  if [[ $RC != 0 ]]
  then
    printf "\n[ERROR] %s\n" "Git pull of simrel tools returned non-zero return code: $RC. Exiting."
    exit 1
  fi
  popd 1>/dev/null
  RC=$?
  if [[ $RC != 0 ]]
  then
    printf "\n[ERROR] %s\n" "popd returned non-zero return code: $RC. Exiting."
    exit 1
  fi
else
  # if running remotely, the "git://" form is needed. If running on Eclpse.org, the "file://" form is better.
  #git clone file:///gitroot/simrel/org.eclipse.simrel.tools ${BUILD_HOME}/org.eclipse.simrel.tools
  git clone git://git.eclipse.org/gitroot/simrel/org.eclipse.simrel.tools ${BUILD_HOME}/org.eclipse.simrel.tools
  RC=$?
  if [[ $RC != 0 ]]
  then
    printf "\n[ERROR] %s\n" "git clone of simrel.tools returned non-zero return code: $RC. Exiting."
    exit 1
  fi
fi
exit 0



