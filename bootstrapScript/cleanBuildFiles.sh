#!/usr/bin/env bash


# This script file is to help get builds started "fresh", when
# the ${BUILD_TOOLS} directory already exists on local file system.
# While it is in this source repository in ${BUILD_TOOLS}, it is
# meant to be executed from the parent directory
# of ${BUILD_TOOLS} on the file system. If completely fresh 
# (first time) install, some "sanity check" code below needs 
# overriden with -f after confirming correct current directory is 
# correctly set in CC, something like /shared/simrel/luna . 

# It is required to specify a top level directory, that will contain all else involved with build, control and output
if [[ -z "${BUILD_HOME}" ]]
then
    export BUILD_HOME=/shared/simrel/${release}
    echo "BUILD_HOME: $BUILD_HOME"
fi

rm -fr ${BUILD_HOME}/org.eclipse.simrel.build

# let Hudson make the empty directory, not Git
mkdir ${BUILD_HOME}/org.eclipse.simrel.build


