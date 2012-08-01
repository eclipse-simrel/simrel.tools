#!/usr/bin/env bash

# it is assumed we are executing this in BUILD_TOOLS or the parent of BUILD_TOOLS

# finds file on users path, before current directory
# hence, non-production users can set their own values for test machines
source aggr_properties.shsource

if [ -z ${BUILD_TOOLS} ] ; then
   BUILD_TOOLS=org.eclipse.simrel.tools
fi

# This script file is to help get builds started "fresh", when
# the ${BUILD_TOOLS} directory already exists on local file system.
# While it is in the cvs repository in ${BUILD_TOOLS}, it is
# meant to be executed from the parent directory
# of ${BUILD_TOOLS} on the file system.

# export is used, instead of checkout, just to avoid the CVS directories and since this code
# for a local build, there should never be a need to check it back in to CVS.

# If there is no subdirectory, try going up one directory and looking again (in case we are in it).
if [ ! -e ${BUILD_TOOLS} ]
then
	cd ..
	if [ ! -e ${BUILD_TOOLS} ]
	then	
         echo "${BUILD_TOOLS} does not exist as sub directory";
	     exit 1;
	fi
fi


# make sure BUILD_TOOLS has been defined and is no zero length, or 
# else following will eval to "rm -fr /*" ... potentially catastrophic
if [ -z "${BUILD_TOOLS}" ]
then
   echo "The variable BUILD_TOOLS must be defined to run this script"
   exit 1;
fi
echo "    removing all of ${BUILD_TOOLS} ..."
rm -fr "${BUILD_TOOLS}"/*
rm -fr "${BUILD_TOOLS}"/.project
rm -fr "${BUILD_TOOLS}"/.settings
rm -fr "${BUILD_TOOLS}"/.classpath
mkdir -p "${BUILD_TOOLS}"

BRANCH_TOOLS=master
TMPDIR_TOOLS=sbtools
CGITURL=http://davidw.com/git

rm ${BRANCH_TOOLS}.zip*
rm -fr ${BUILD_TOOLS}
wget --no-verbose -O ${BRANCH_TOOLS}.zip ${CGITURL}/${BUILD_TOOLS}/snapshot/${BRANCH_TOOLS}.zip 2>&1
RC=$?
if [[ $RC? != 0 ]] 
then
	printf "/n/t%s/t%s/n" "ERROR:" "Failed to get ${BRANCH_TOOLS}.zip from  ${CGITURL}/${BUILD_TOOLS}/snapshot/${BRANCH_TOOLS}.zip"
 exit $RC
fi

unzip -o ${BRANCH_TOOLS}.zip -d ${TMPDIR_TOOLS} 
RC=$?
if [[ $RC? != 0 ]] 
then
	printf "/n/t%s/t%s/n" "ERROR:" "Failed to unzip ${BRANCH_TOOLS}.zip to ${TMPDIR_TOOLS}"
 exit $RC
fi

rsync -r ${TMPDIR_TOOLS}/${BRANCH_TOOLS}/ ${BUILD_TOOLS}
RC=$?
if [[ $RC? != 0 ]] 
then
	printf "/n/t%s/t%s/n" "ERROR:" "Failed to copy ${BUILD_TOOLS} to ${TMPDIR_TOOLS}/${BRANCH_TOOLS}/"
 exit $RC
fi

echo "    making sure releng control files are executable and have proper EOL ..."
dos2unix ${BUILD_TOOLS}/*.sh* ${BUILD_TOOLS}/*.properties ${BUILD_TOOLS}/*.xml >/dev/null 2>>/dev/null
chmod +x ${BUILD_TOOLS}/*.sh > /dev/null
echo





