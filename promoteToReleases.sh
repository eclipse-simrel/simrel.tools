#!/usr/bin/env bash
# script to copy update jars from their staging area to the releases area

# finds file on users path, before current directory
# hence, non-production users can set their own values for test machines
source aggr_properties.shsource

function checkForErrorExit
{   
    # arg 1 must be return code, $?
    # arg 2 (remaining line) can be message to print before exiting do to non-zero exit code
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


fromDirectory=${stagingDirectory}
toDirectory=${releaseDirectory} 

datetimestamp=$1

# make sure 'toDirectory' has been defined and is not zero length
if [ -z "${toDirectory}" ]
then
    echo;
    echo "   Fatal Error: the variable toDirectory must be defined to run this script";
    echo;
else

    # make sure 'datetimestamp' has been defined and is no zero length
    if [ -z "${datetimestamp}" ]
    then
        echo;
        echo "   Fatal Error: the variable datetimestamp must be defined to run this script."
        echo;
    else 

        toSubDir=${toDirectory}/${datetimestamp}

        echo ""
        echo "    Copying new plugins and features "
        echo "        from  ${fromDirectory}"
        echo "          to  ${toSubDir}"
        echo ""

        # plugins and features
        rsync -rvp ${fromDirectory}${AGGR}/* ${toSubDir}${AGGR}/
        checkForErrorExit $? "could not copy files as expected"

        # technically, would not need this, if no 'aggregate' directory. 
        # TODO: add logic later to avoid extra copy?
        # composite artifact and content files
        rsync -vp ${fromDirectory}/*.jar ${toSubDir}
        checkForErrorExit $? "could not copy files as expected"

        # static index page
        rsync -vp templateFiles/release/index.html ${toDirectory}
        checkForErrorExit $? "could not copy files as expected"



        "${BUILD_TOOLS_DIR}"/addRepoProperties-release.sh ${datetimestamp}
        checkForErrorExit $? "repo properties could not be updated as expected"

        # copy standard p2.index page
        # We do it last, to use as an indicator file that we are done.
        # TODO: as is, if no composited artifacts, this would have been 
        # copied earlier, so will need work to ever use as "we are done" 
        # indicator file.
        rsync -vp ${fromDirectory}/p2.index ${toSubDir}
        checkForErrorExit $? "could not copy files as expected"
    fi	
fi

