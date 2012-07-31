#!/usr/bin/env bash

# it is assumed we are executing this in RELENG_TOOLS or the parent of RELENG_TOOLS

# finds file on users path, before current directory
# hence, non-production users can set their own values for test machines
source aggr_properties.shsource

if [ -z ${RELENG_TOOLS} ] ; then
   RELENG_TOOLS=org.eclipse.simrel.tools
fi

# This script file is to help get builds started "fresh", when
# the ${RELENG_TOOLS} directory already exists on local file system.
# While it is in the cvs repository in ${RELENG_TOOLS}, it is
# meant to be executed from the parent directory
# of ${RELENG_TOOLS} on the file system.

# export is used, instead of checkout, just to avoid the CVS directories and since this code
# for a local build, there should never be a need to check it back in to CVS.

# If there is no subdirectory, try going up one directory and looking again (in case we are in it).
if [ ! -e ${RELENG_TOOLS} ]
then
	cd ..
	if [ ! -e ${RELENG_TOOLS} ]
	then	
         echo "${RELENG_TOOLS} does not exist as sub directory";
	     exit 1;
	fi
fi


# make sure RELENG_TOOLS has been defined and is no zero length, or 
# else following will eval to "rm -fr /*" ... potentially catastrophic
if [ -z "${RELENG_TOOLS}" ]
then
   echo "The variable RELENG_TOOLS must be defined to run this script"
   exit 1;
fi
echo "    removing all of ${RELENG_TOOLS} ..."
rm -fr "${RELENG_TOOLS}"/*
rm -fr "${RELENG_TOOLS}"/.project
rm -fr "${RELENG_TOOLS}"/.settings
rm -fr "${RELENG_TOOLS}"/.classpath
mkdir -p "${RELENG_TOOLS}"

#controltag=david_williams_tempBranch3
controltag=HEAD
#echo "    checking out $controltag of ${RELENG_TOOLS} from cvs ..."

#export CVS_RSH=SSH
#if [ -z ${CVS_INFO} ] ; then
#   CVS_INFO=:pserver:anonymous@dev.eclipse.org:
#fi

#cvs -Q -f -d ${CVS_INFO}/cvsroot/callisto  export -d ${RELENG_TOOLS} -r $controltag ${RELENG_TOOLS}
wget http://davidw.com/git/org.eclipse.simrel.tools/snapshot/master.zip && unzip master.zip -d sbtools && rsync -r sbtoolstests/master/ ${RELENG_TOOLS}

echo "    making sure releng control files are executable and have proper EOL ..."
dos2unix ${RELENG_TOOLS}/*.sh* ${RELENG_TOOLS}/*.properties ${RELENG_TOOLS}/*.xml >/dev/null 2>>/dev/null
chmod +x ${RELENG_TOOLS}/*.sh > /dev/null
echo





