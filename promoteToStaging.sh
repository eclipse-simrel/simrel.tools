#!/usr/bin/env bash
# script to copy update jars from their working area to the staging area

# Simple utility to run as cronjob to run Eclipse Platform builds
# Normally resides in $BUILD_HOME

# Start with minimal path for consistency across machines
# plus, cron jobs do not inherit an environment
# care is needed not have anything in ${HOME}/bin that would effect the build 
# unintentionally, but is required to make use of "source buildeclipse.shsource" on 
# local machines.  
# Likely only a "release engineer" would be interested, such as to override "SIGNING" (setting it 
# to false) for a test I-build on a remote machine. 
export PATH=/usr/local/bin:/usr/bin:/bin:${HOME}/bin
# unset common variables (some defined for e4Build) which we don't want (or, set ourselves)
unset JAVA_HOME
unset JAVA_ROOT
unset JAVA_JRE
unset CLASSPATH
unset JAVA_BINDIR
unset JRE_HOME

# 0002 is often the default for shell users, but it is not when ran from
# a cron job, so we set it explicitly, so releng group has write access to anything
# we create.
oldumask=`umask`
umask 0002
# Remember, don't echo except when testing, or mail will be sent each time it runs. 
#echo "umask explicitly set to 0002, old value was $oldumask"


function usage() {
printf "\n\tScript to promote aggregation to staging area" >&2 
printf "\n\tUsage: %s -s <stream> " "$(basename $0)" >&2 
printf "\n\t\t%s" "where <stream> is 'main' or 'maintenance'" >&2 
printf "\n\t\t%s" "(and main currently means mars and maintenance means luna)" >&2 
printf "\n" >&2 
}

if [[ $# == 0 ]]  
then 
    printf "\n\tNo arguments given.\n"
    usage
    exit 1
fi
if [[ $# > 21 ]]  
then 
    printf "\n\tToo many arguments given.\n"
    usage
    exit 1
fi

stream=
# the initial ':' keeps getopts in quiet mode ... meaning it doesn't print "illegal argument" type messages.
# to get it in completely silent mode, assign $OPTERR=0
# the other ':' is the ususal "OPTARG"
while getopts ':hs:' OPTION
do
    options_found=1
    case $OPTION in
        h)
            usage
            exit 1
            ;;
        s)
            stream=$OPTARG
            ;;
        \?)
            # I've seen examples wehre just ?, or [?] is used, which means "match any one character", 
            # whereas literal '?' is returned if getops finds unrecognized argument.     
            # I've not seen documented, but if no arguments supplied, seems getopts returns
            # '?' and sets $OPTARG to '-'. 
            # so ... decided to handle "no arguments" case before calling getopts.
            printf "\n\tUnknown option: -%s\n" $OPTARG
            usage
            ;;
        *)
            # This fall-through not really needed in this case, esp. with '?' clause. 
            # Usually need one or the other.
            # getopts appears to return '?' if no options or an unrecognized option. 
            # Decide to use it for program check, in case allowable options are added,  
            # but no matching case statemetns.
            printf "\n\t%s" "ERROR: unhandled option found: $OPTION. Check script case statements. " >&2
            printf "\n" >&2
            usage
            exit
            ;;
    esac
done

# while we currently don't use/expect additional arguments, it's best to 
# shift away arguments handled by above getopts, so other code (in future) could 
# handle additional trailing arguments not intended for getopts.
shift $(($OPTIND - 1))


function removeLock
{   
    # remove lock file from hundson build's "pauseAll.sh" script once we are all done.
    # remember, we need to _always_ remove the lock file, so do not "exit" from script with calling removeLock
    rm -vf "${BUILD_HOME}"/lockfile
    rm -vf "${BUILD_HOME}"/beingPromoted
}

function checkForErrorExit
{   
    # arg 1 must be return code, $?
    # arg 2 (remaining line) can be message to print before exiting do to non-zer exit code
    exitCode=$1
    shift
    message="$*"
    if [ "${exitCode}" -ne "0" ]
    then
        echo
        echo "   ERROR. exit code: ${exitCode}"  ${message}
        echo
        touch "${BUILD_HOME}"/promoteFailed
        removeLock 
        exit "${exitCode}"
    fi
}


case "$stream" in
        main)
            export release=mars
            export stagingsegment=staging
            ;;
        maintenance)
            export release=luna
            export stagingsegment=maintenance
            ;;
        *)
            usage
            exit 1
			;;
esac

# finds file on users path, before current directory
# hence, non-production users can set their own values for test machines
# must be called after case statement sets release and staging segment

# It is required to specify a top level directory, that will contain all else involved with build, control and output
if [[ -z "${BUILD_HOME}" ]]
then
   export BUILD_HOME=${BUILD_HOME:-/shared/simrel/${release}}
   #echo "BUILD_HOME: $BUILD_HOME"
fi

# remember to leave no slashes on first filename in source command,
# so that users path is used to find it (first, if it exists)
# variables that user might want/need to override, should be defined, 
# in our own aggr_properties.shsource using the X=${X:-"xyz"} syntax.
source aggr_properties.shsource 2>/dev/null
source ${BUILD_HOME}/org.eclipse.simrel.tools/aggr_properties.shsource

# First check if being promoted by another job. If so, can exit immediately
if [[ -e "${BUILD_HOME}"/beingPromoted ]]
then
   exit
fi


if [[ ! -e "${BUILD_HOME}"/lockfile ]]
then
   # if lock file does not exist, then do not try and promote, just exit.
   # For now, we'll write message, but eventually, after cronjob proven, we'll 
   # do this silently. 
   # echo "No lock file found, so exiting promote"
   exit
fi

# first thing is to create the beingPromoted file, so other promote jobs won't run
touch "${BUILD_HOME}"/beingPromoted

fromDirectory=${AGGREGATOR_RESULTS}
export toDirectory=${stagingDirectory}


echo "BUILD_HOME: $BUILD_HOME"
echo "BUILD_TOOLS_DIR: ${BUILD_TOOLS_DIR}"
echo "stream: $stream"
echo "release: $release"
echo "stagingSegment: $stagingSegment"
echo "fromDirectory: $fromDirectory"
echo "toDirectory: $toDirectory"

# make sure 'toDirectory' has been defined and is no zero length, or 
# else following will eval to "rm -fr /*" ... potentially catastrophic
if [ -z "${toDirectory}" ]
then
    checkForErrorExit 1 "The variable 'toDirectory' must be defined to run this script"
else
    echo
    echo "    Count of old features, bundle jars, and packed jars prior to promotion";
    "${BUILD_TOOLS_DIR}"/printStats.sh
    checkForErrorExit $? "printStats did not return normally"
    echo 

    echo 
    echo "    Removing previous staging directory files at"
    echo "    "${toDirectory} 
    echo 

    if [ -d ${toDirectory} ]
    then
        rm -fr "${toDirectory}"/*
        checkForErrorExit $? "could not remove " ${toDirectory}
    fi

    echo 
    echo "    Copying new plugins and features "
    echo "        from  ${fromDirectory}"
    echo "          to  ${toDirectory}"
    echo 

    # plugins and features
    rsync -rvp ${fromDirectory}/final/* ${toDirectory}/
    checkForErrorExit $? "could not copy files as expected"

    # technically, would not need this, if no 'aggregate' directory. 
    # TODO: add logic later to avoid extra copy?
    # composite artifact and content files
    rsync -vp ${fromDirectory}/final/*.jar ${toDirectory}
    checkForErrorExit $? "could not copy files as expected"

    # copy standard index page
    rsync -vp "${BUILD_TOOLS_DIR}/templateFiles/${stagingsegment}/index.html" ${toDirectory}
    checkForErrorExit $? "could not copy files as expected"


    "${BUILD_TOOLS_DIR}"/addRepoProperties-staging.sh ${stagingsegment}
    checkForErrorExit $? "repo properties could not be updated as expected"

    # copy standard p2.index page
    # We do it last, to use as an indicator file that we are done.
    rsync -vp ${fromDirectory}/final/p2.index ${toDirectory}
    checkForErrorExit $? "could not copy files as expected"


    # TODO: eventually, we could make "sanity check" test on number of files, etc., and fail if more than 10% off, or similar
    echo
    echo "    Count of new features, bundle jars, and packed jars after promotion";
    "${BUILD_TOOLS_DIR}"/printStats.sh
    checkForErrorExit $? "printStats did not return normally"
    echo

fi

removeLock

