#!/usr/bin/env bash


# This script file is to help get builds started "fresh", when
# the ${BUILD_TOOLS} directory already exists on local file system.
# While it is in this source repository in ${BUILD_TOOLS}, it is
# meant to be executed from the parent directory
# of ${BUILD_TOOLS} on the file system. If completely fresh 
# (first time) some "sanity check" code below needs to be commented out.


# finds file on users path, before current directory
# hence, non-production users can set their own values for test machines
source aggr_properties.shsource

# handy to get all variables to log, if needed for debugging
env

BUILD_TOOLS=${BUILD_TOOLS:-org.eclipse.simrel.tools}

# echo current directory for debugging
echo "PWD: ${PWD}"

# If there is no subdirectory, try going up one directory and looking again 
# (in case we are in it).
# This is just a sanity check, to see if things are as expected, 
# things might be wrong, if hudson setttings (such as "custom workspace" 
# are not right. 
# At times may have to be commented out if completely fresh,
# after confirming "current directory" is as expected.
if [ ! -e ${BUILD_TOOLS} ]
then
    cd ..
    if [ ! -e ${BUILD_TOOLS} ]
    then	
        echo "${BUILD_TOOLS} does not exist as sub directory";
        exit 1;
    fi
fi

# even though we define it above, for safety
# make sure BUILD_TOOLS has been defined and is not zero length, or 
# else the following or else some following "removes" could be bad. 
if [ -z "${BUILD_TOOLS}" ]
then
    echo "The variable BUILD_TOOLS must be defined to run this script"
    exit 1;
fi

# echo current directory for debugging
echo "PWD: ${PWD}"

echo "    removing all of ${BUILD_TOOLS} ..."
rm -fr ${BUILD_TOOLS}
mkdir -p "${BUILD_TOOLS}"

BRANCH_TOOLS=${BRANCH_TOOLS:-master}
TMPDIR_TOOLS=${TMPDIR_TOOLS:-sbtools}
CGITURL=${CGITURL:-http://git.eclipse.org/c/simrel/}

# echo current directory for debugging
echo "PWD: ${PWD}"
rm ${BRANCH_TOOLS}.zip*

# echo current directory for debugging
echo "PWD: ${PWD}"

wget  ${CGITURL}/${BUILD_TOOLS}/snapshot/${BRANCH_TOOLS}.zip 2>&1
RC=$?
if [[ $RC != 0 ]] 
then
    echo "   ERROR: Failed to get ${BRANCH_TOOLS}.zip from  ${CGITURL}/${BUILD_TOOLS}/snapshot/${BRANCH_TOOLS}.zip"
    echo "   RC: $RC"
    exit $RC
fi

# echo current directory for debugging
echo "PWD: ${PWD}"

unzip -o ${BRANCH_TOOLS}.zip -d ${TMPDIR_TOOLS} 
RC=$?
if [[ $RC != 0 ]] 
then
    echo "ERROR:  Failed to unzip ${BRANCH_TOOLS}.zip to ${TMPDIR_TOOLS}"
        echo "   RC: $RC"
    exit $RC
fi

rsync -r ${TMPDIR_TOOLS}/${BRANCH_TOOLS}/ ${BUILD_TOOLS}
RC=$?
if [[ $RC != 0 ]] 
then
    echo "ERROR: Failed to copy ${BUILD_TOOLS} from ${TMPDIR_TOOLS}/${BRANCH_TOOLS}/"
        echo "   RC: $RC"
        exit $RC
fi

echo "    make sure releng control files are executable and have proper EOL ..."
dos2unix ${BUILD_TOOLS}/*.sh* ${BUILD_TOOLS}/*.properties ${BUILD_TOOLS}/*.xml >/dev/null 2>>/dev/null
chmod +x ${BUILD_TOOLS}/*.sh > /dev/null
echo "    Done. "

exit 0



