#!/usr/bin/env bash

RELEASE=$1
shift
if [[ -z "$RELEASE" ]]
then
  RELEASE=mars
fi

MAX_WAIT=$1
if [[ -z "$MAX_WAIT" ]]
then
  # 600 seconds = 10 minutes
  MAX_WAIT=600
fi

BUILD_TIME=$( wget  --no-verbose -O - "https://hudson.eclipse.org/hudson/job/simrel.${RELEASE}.runaggregator/lastSuccessfulBuild/buildTimestamp?format=yyyy-MM-dd HH:mm:ss.SSSZ" 2>/dev/null )
echo "BUILD_TIME: $BUILD_TIME"

UNIX_BUILD_TIME=$( date -d "${BUILD_TIME}" +%s  )
echo "UNIX_BUILD_TIME: $UNIX_BUILD_TIME"

PROMOTE_TIME=$( wget  --no-verbose -O - "https://hudson.eclipse.org/hudson/job/simrel.${RELEASE}.lockForPromotion/lastSuccessfulBuild/buildTimestamp?format=yyyy-MM-dd HH:mm:ss.SSSZ" 2>/dev/null )
echo "PROMOTE_TIME: $PROMOTE_TIME"

UNIX_PROMOTE_TIME=$( date -d "${PROMOTE_TIME}" +%s  )
echo "UNIX_PROMOTE_TIME: $UNIX_PROMOTE_TIME"

TIME_DIFF=$(( UNIX_BUILD_TIME - UNIX_PROMOTE_TIME ))

# if "positive", then a build has occurred since last promotion.
# we may vary "amount" though ... such as "wait 30 minutes" before issuing a promote
# or, at times in dev cycle may wait 2 hours, or similar.
# The "time delay" can also be controlled by frequency of cron job.
# Need to also make sure it is long enough interval, that we don't queue multiple jobs,
# This is especially hard to do, based on time alone, since a "promote" might be in queue,
# but waiting for next build to complete. Perhaps cold find a way to "check if one in queue",
# and if so, do nothing? (i.e. do not even need to look at time?)
if [[ $TIME_DIFF -gt $MAX_WAIT ]]
then
  echo "TIME_DIFF, ${TIME_DIFF}, triggers next promote."
else
  echo "TIME_DIFF, ${TIME_DIFF}, not large enough to trigger next promote."
fi

URL="https://hudson.eclipse.org/hudson/job/simrel.${RELEASE}.lockForPromotion/build"
curl -X POST $URL -d token=65cb5d2246



