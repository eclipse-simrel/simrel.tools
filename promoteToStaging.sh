#!/usr/bin/env bash
# script to copy update jars from their working area to the staging area


function usage() {
printf "\n\tScript to promote aggregation to staging area" >&2 
printf "\n\tUsage: %s -s <stream> " "$(basename $0)" >&2 
printf "\n\t\t%s" "where <stream> is 'main' or 'maintenance'" >&2 
printf "\n\t\t%s" "(and main currently means kepler and maintenance means juno)" >&2 
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
        removeLock
        exit "${exitCode}"
    fi
}


case "$stream" in
        main)
            export release=kepler
            export stagingsegment=staging
            ;;
        maintenance)
            export release=juno
            export stagingsegment=maintenance
            ;;
        *)
            usage
            exit 1
			;;
esac

# finds file on users path, before current directory
# hence, non-production users can set their own values for test machines
# must be called after case statement sets release and statingsegment
source aggr_properties.shsource


fromDirectory=${AGGREGATOR_RESULTS}
toDirectory=${stagingDirectory} 

echo "stream: $stream"
echo "release: $release"
echo "stagingSegment: $stagingSegment"

echo "fromDirectory: $fromDirectory"
echo "toDirectory: $toDirectory"
echo "BUILD_TOOLS_DIR: ${BUILD_TOOLS_DIR}"

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
    rsync -rvp ${fromDirectory}/final${AGGR}/* ${toDirectory}${AGGR}/
    checkForErrorExit $? "could not copy files as expected"

    # technically, would not need this, if no 'aggregate' directory. 
    # TODO: add logic later to avoid extra copy?
    # composite artifact and content files
    rsync -vp ${fromDirectory}/final/*.jar ${toDirectory}
    checkForErrorExit $? "could not copy files as expected"

    # copy standard index page
    rsync -vp templateFiles/${stagingsegment}/index.html ${toDirectory}
    checkForErrorExit $? "could not copy files as expected"


    "${BUILD_TOOLS_DIR}"/addRepoProperties-staging.sh
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

