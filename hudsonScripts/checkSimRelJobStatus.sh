#!/usr/bin/env bash
#
# Simple utility to run as cronjob to run help promote SimRel builds, when
# one is ready. 
#
#
# Start with minimal path for consistency across machines.
# This 'mimics' what cron jobs do anyway, as they do not inherit 
# users environment.
# Care is needed not have anything in ${HOME}/bin that would effect the build 
# unintentionally, but is required to make use of "source xxx.shsource" on 
# local, non-production machines.
# Likely only a "release engineer" would be interested, such as to override 
# standard, production values.
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

source aggr_properties.shsource

# default of 10 minutes (unless overridden in ~bin/aggr_properties.shsource)
defaultWaitOffsetTime=${defaultWaitOffsetTime:-600}

convertSecs() {
  seconds=$1
  if [[ $seconds =~ ^(['-']?)([[:digit:]].*)$ ]]
  then
    past=${BASH_REMATCH[1]}
    seconds=${BASH_REMATCH[2]}
    ((h=${seconds}/3600))
    ((m=(${seconds}%3600)/60))
    ((s=${seconds}%60))
    suffix=""
    if [[ ! -z "$past" ]]
    then
      suffix="past"
    fi
    printf "%02d hr %02d min %02d secs %s" $h $m $s "$suffix"
  else
    printf "%20s" "seconds invalid?"
  fi
}

function usage() {
printf "\n\tScript to check if ready to trigger 'lockForPromotion' job" >&2 
printf "\n\tUsage: %s -s <stream> [-w <waitOffsetTime>]" "$(basename $0)" >&2 
printf "\n\t\t%s" "where <stream> is 'main' or 'maintenance'" >&2 
printf "\n\t\t%s" "(and main currently means mars and maintenance means luna)" >&2
printf "\n\t\t%s" "and where <waitOffsetTime> is amount of seconds that must" >&2
printf "\n\t\t%s" "that must have elapsed from previous build, before we trigger promotion process." >&2
printf "\n\t\t%s" "Default waitOffsetTime is ${defaultWaitOffsetTime} seconds." >&2
printf "\n\t\t%s" "This offset time allows us to not necessarily promote every build, " >&2
printf "\n\t\t%s" "but to not wait too long before promoting one." >&2
printf "\n" >&2 
}

if [[ $# == 0 ]]  
then 
  printf "\n\tNo arguments given.\n"
  usage
  exit 1
fi
if [[ $# > 4 ]]  
then 
  printf "\n\tToo many arguments given.\n"
  usage
  exit 1
fi



stream=
waitOffsetTime=${defaultWaitOffsetTime}
# the initial ':' keeps getopts in quiet mode ... meaning it doesn't print "illegal argument" type messages.
# to get it in completely silent mode, assign $OPTERR=0
# the other ':' is the ususal "OPTARG"
while getopts ':hs:w:' OPTION
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
    w)
      waitOffsetTime=$OPTARG
      if [[ -z "${waitOffsetTime}" ]]
      then
        printf "\n\tWARNING: %s" "-w was specified, but no seconds given. Default of ${defaultWaitOffsetTime} seconds till be used."
      fi
      ;;
    \?)
      # I've seen examples wehre just ?, or [?] is used, which means "match any one character", 
      # whereas literal '?' is returned if getops finds unrecognized argument.     
      # I've not seen documented, but if no arguments supplied, seems getopts returns
      # '?' and sets $OPTARG to '-'. 
      # so ... decided to handle "no arguments" case before calling getopts.
      printf "\n\tUnknown option: -%s\n" $OPTARG
      usage
      exit 1
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
      exit 1
      ;;
  esac
done

# while we currently don't use/expect additional arguments, it's best to 
# shift away arguments handled by above getopts, so other code (in future) could 
# handle additional trailing arguments not intended for getopts.
shift $(($OPTIND - 1))

if [[ "${stream}" == "main" ]]
then
  RELEASE=mars
elif [[ "${stream}" == "maintenance" ]]
then 
  RELEASE=luna
else
  printf "\n\t%s" "ERROR: stream was neither main nor maintenance, value was ${stream}."
  usage
  exit 1
fi

# To use on local machine, depends on correct value in ~/bin/aggr_properties.shsource
HUDSON_HOST=${HUDSON_HOST:-https://hudson.eclipse.org/hudson}
#echo "DEBUG HUDSON_HOST: $HUDSON_HOST"
BUILD_TIME=$( wget  --no-verbose -O - "${HUDSON_HOST}/job/simrel.${RELEASE}.runaggregator/lastSuccessfulBuild/buildTimestamp?format=yyyy-MM-dd HH:mm:ss.SSSZ" 2>/dev/null )
#echo "DEBUG BUILD_TIME: $BUILD_TIME"
DURATION=$( wget  --no-verbose -O - "${HUDSON_HOST}/job/simrel.${RELEASE}.runaggregator/lastSuccessfulBuild/api/xml?xpath=/*/duration/text()" 2>/dev/null )
DURATION_SECS=$(($DURATION/1000))
UNIX_BUILD_TIME=$( date -d "${BUILD_TIME}" +%s  )
#echo "DEBUG UNIX_BUILD_TIME: $UNIX_BUILD_TIME"
UNIX_BUILD_TIME=$((UNIX_BUILD_TIME + DURATION_SECS))
PROMOTE_TIME=$( wget  --no-verbose -O - "${HUDSON_HOST}/job/simrel.${RELEASE}.lockForPromotion/lastBuild/buildTimestamp?format=yyyy-MM-dd HH:mm:ss.SSSZ" 2>/dev/null )
#echo "DEBUG PROMOTE_TIME: $PROMOTE_TIME"

UNIX_PROMOTE_TIME=$( date -d "${PROMOTE_TIME}" +%s  )
#echo "DEBUG UNIX_PROMOTE_TIME: $UNIX_PROMOTE_TIME"

TIME_DIFF=$(( UNIX_BUILD_TIME - UNIX_PROMOTE_TIME ))

# if "positive", then a build has occurred since last promotion.
# we may vary "amount" though ... such as "wait 30 minutes" before issuing a promote
# or, at times in dev cycle may wait 2 hours, or similar.
# The "time delay" can also be controlled by frequency of cron job.
# Need to also make sure it is long enough interval, that we don't queue multiple jobs,
# This is especially hard to do, based on time alone, since a "promote" might be in queue,
# but waiting for next build to complete. Perhaps cold find a way to "check if one in queue",
# and if so, do nothing? (i.e. do not even need to look at time?)
if [[ $TIME_DIFF -gt $waitOffsetTime ]]
then
  echo "TIME_DIFF, ${TIME_DIFF}, implies a successful build since last promote, so will check to trigger one."
  # first check if one is already building, so we do not just put another in queue
  # Interestingly, if one is in que a) seems hard to detect that, and b) even if 
  # we try to put another there, is is 'rejected' so that do no seem to "stack up". 
  URL="${HUDSON_HOST}/job/simrel.${RELEASE}.lockForPromotion/api/xml"
  DATA="-d depth=1 --data-urlencode xpath=/*/build/building/text() -d wrapper=job"
  RESULT=$( curl -s -X POST $URL $DATA )
  #echo "DEBUG RESULT: $RESULT"
  if [[ ! $RESULT =~ .*true.* ]] 
  then
    echo "A promotion job Was not found to be running so we will trigger one."
    URL="${HUDSON_HOST}/job/simrel.${RELEASE}.lockForPromotion/build"
    curl -s -X POST $URL -d token=65cb5d2246
  else
    echo "While time diff implies to trigger a promotion, we see one already running, so no need to do again."
  fi
else
  echo "TIME_DIFF, $( convertSecs ${TIME_DIFF} ), implies there has been a promtion, since last successful build. No need to do again."
fi

