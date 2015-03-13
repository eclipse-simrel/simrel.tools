#!/usr/bin/env bash
# script to copy update jars from their staging area to the releases area

function usage() {
printf "\n\tScript to promote aggregation to staging area" >&2 
printf "\n\tUsage: %s -s <stream> -d <datetimestamp>" "$(basename $0)" >&2 
printf "\n\t\t%s" "where <stream> is 'main' or 'maintenance'" >&2 
printf "\n\t\t%s" "   (and main currently means mars and maintenance means luna)" >&2 
printf "\n\t\t%s" "and where <datetimestamp> is the date and time for the directory name of the composite child repository, such as '201208240900'" >&2 
printf "\n" >&2 
}

if [[ $# != 4 ]]  
then 
    printf "\n\tIncorrect number of arguments given.\n"
    usage
    exit 1
fi

datetimestamp=
stream=
# the initial ':' keeps getopts in quiet mode ... meaning it doesn't print "illegal argument" type messages.
# to get it in completely silent mode, assign $OPTERR=0
# the other ':' is the ususal "OPTARG"
while getopts ':hs:d:' OPTION
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
        d)
            datetimestamp=$OPTARG
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


# no 'removelock' since no associated lock file.
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
        exit "${exitCode}"
    fi
}

case "$stream" in
        main)
            export release=mars
            export stagingsegment=staging
            export releasesegment=current
            ;;
        maintenance)
            export release=luna
            export stagingsegment=maintenance
            export releasesegment=maintenance
            ;;
        *)
            usage
            exit 1
			;;
esac



# finds file on users path, before current directory
# hence, non-production users can set their own values for test machines
# must be called (included) after the above variables set, since 
# above variables are used to compute some other values
# such as stagingsegment is used to define stagingDirectory

source aggr_properties.shsource


export fromDirectory=${stagingDirectory}
export toDirectory=${releaseDirectory} 


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
        rsync -rvp ${fromDirectory}/* ${toSubDir}/
        checkForErrorExit $? "could not copy files as expected"

        # technically, would not need this, if no 'aggregate' directory. 
        # TODO: add logic later to avoid extra copy?
        # composite artifact and content files
        rsync -vp ${fromDirectory}/*.jar ${toSubDir}
        checkForErrorExit $? "could not copy files as expected"

        # static index page
        rsync -vp "${BUILD_TOOLS_DIR}/templateFiles/release/${releasesegment}/index.html" ${toDirectory}
        checkForErrorExit $? "could not copy files as expected"



        "${BUILD_TOOLS_DIR}"/addRepoProperties-release.sh ${release} ${datetimestamp}
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

