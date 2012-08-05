#!/usr/bin/env bash


# This script file is to help get builds started "fresh", when
# the ${BUILD_TOOLS} directory already exists on local file system.
# While it is in this source repository in ${BUILD_TOOLS}, it is
# meant to be executed from the parent directory
# of ${BUILD_TOOLS} on the file system. If completely fresh 
# (first time) install, some "sanity check" code below needs 
# overriden with -f after confirming correct current directory is 
# correctly set in CC, something like /shared/juno . 


# finds file on users path, before current directory
# hence, non-production users can set their own values for test machines
source aggr_properties.shsource

# define these essential variables for production machine, 
# so aggr_properties.shsource does not have to exist there, 
# for this script (in this directory)
BUILD_TOOLS=${BUILD_TOOLS:-org.eclipse.simrel.tools}
BRANCH_TOOLS=${BRANCH_TOOLS:-master}
TMPDIR_TOOLS=${TMPDIR_TOOLS:-sbtools}
CGITURL=${CGITURL:-http://git.eclipse.org/c/simrel}

function usage() 
{
    printf "\n\tUsage: %s [-f] [-v] " $(basename $0) >&2
    printf "\n\t\t%s\t%s" "-f" "Allow fresh creation (confirm correct current directory)." >&2
    printf "\n\t\t%s\t%s" "-c" "Force clean of prereqs directory" >&2
    printf "\n\t\t%s\t%s\n" "-v" "Print verbose debug info." >&2
}


verboseFlag=false
freshFlag=false
cleanFlag=false
while getopts 'hvfc' OPTION
do
    case $OPTION in
        h)    usage
        exit 1
        ;;
        v)    verboseFlag=true
        ;;
        f)    freshFlag=true
        ;;
		c)    cleanFlag=true
        ;;
        ?)    usage
        exit 2
        ;;
    esac
done

# This shift is not required in our particular, current case, 
# But is a common pattern to leave command line args at correct 
# point, so we leave it in. 
shift $(($OPTIND - 1))

# 'env' is handy to print all env variables to log, 
# if needed for debugging
if $verboseFlag
then
	env
	echo "fresh install: $freshFlag"
	echo "verbose output: $verboseFlag"
	echo "force clean prereqs: $cleanFlag"
	echo "BUILD_TOOLS: ${BUILD_TOOLS}"
 	echo "TMPDIR_TOOLS=${TMPDIR_TOOLS}"
		
fi

echo "CGITURL: ${CGITURL}"
echo "BRANCH_TOOLS: ${BRANCH_TOOLS}"

# echo current directory
echo "Current Directory: ${PWD}"

# This is just a sanity check, to see if things are as expected, 
# things might be wrong, if hudson setttings (such as "custom workspace" 
# are not right. 
# At times may have to be skipped, if completely fresh,
# after confirming "current directory" is as expected.

# if freshFlag is set, then "not freshFlag" is false and will skip 
# the sanity check.   
if ! $freshFlag && [[ ! -e ${BUILD_TOOLS} ]]
then
        echo "${BUILD_TOOLS} does not exist as sub directory";
        exit 1;
fi


# even though we define it above, for safety
# make sure BUILD_TOOLS has been defined and is not zero length, or 
# else the following or else some following "removes" could be bad. 
if [ -z "${BUILD_TOOLS}" ]
then
    echo "The variable BUILD_TOOLS must be defined to run this script"
    exit 1;
fi


echo "    removing all of ${BUILD_TOOLS} ..."
rm -fr ${BUILD_TOOLS}
mkdir -p "${BUILD_TOOLS}"

# remove if already exists
rm ${BRANCH_TOOLS}.zip* 2>/dev/null
rm -fr ${TMPDIR_TOOLS} 2>/dev/null 

wget --no-verbose -O  ${BRANCH_TOOLS}.zip ${CGITURL}/${BUILD_TOOLS}.git/snapshot/${BRANCH_TOOLS}.zip 2>&1
RC=$?
if [[ $RC != 0 ]] 
then
    echo "   ERROR: Failed to get ${BRANCH_TOOLS}.zip from  ${CGITURL}/${BUILD_TOOLS}.git/snapshot/${BRANCH_TOOLS}.zip"
    echo "   RC: $RC"
    exit $RC
fi

quietZipFlag=-q
if $verboseFlag
then
	quietZipFlag=
fi

unzip ${quietZipFlag} -o ${BRANCH_TOOLS}.zip -d ${TMPDIR_TOOLS} 
RC=$?
if [[ $RC != 0 ]] 
then
    echo "ERROR:  Failed to unzip ${BRANCH_TOOLS}.zip to ${TMPDIR_TOOLS}"
        echo "   RC: $RC"
    exit $RC
fi

rsynchvFlag=
if $verboseFlag
then
	rsynchvFlag=-v
fi

rsync $rsynchvFlag -r ${TMPDIR_TOOLS}/${BRANCH_TOOLS}/ ${BUILD_TOOLS}
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

if $cleanFlag
then
	# should very rarely need to do this, Like, once release. 
	# But Eclipse (OSGi?) creates some files with 
	# only group read access, so to complete remove them, must use 
	# hudsonbuild ID to get completely clean. 
	echo "    removing all of prereqs directory"
	rm -fr prereqs
fi

if ! $verboseFlag
then
	# cleanup unless verbose/debugging
 rm ${BRANCH_TOOLS}.zip* 2>/dev/null
rm -fr ${TMPDIR_TOOLS} 2>/dev/null
fi

exit 0



