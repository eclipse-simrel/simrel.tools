#!/usr/bin/env bash
# script to copy update jars from their working area to the staging area

# finds file on users path, before current directory
# hence, non-production users can set their own values for test machines
source aggr_properties.shsource

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


fromDirectory=${AGGREGATOR_RESULTS}
toDirectory=${stagingDirectory} 

# TODO remove this? who uses it? 
tempDir=${HOME}/temp/work

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
    rsync -vp templateFiles/staging/index.html ${toDirectory}
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

