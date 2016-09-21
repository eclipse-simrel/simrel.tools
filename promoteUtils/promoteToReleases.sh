#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2016 IBM Corporation and others.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#     IBM Corporation - initial API and implementation
#*******************************************************************************

# script to copy update jars from their staging area to the releases area

function usage
{
  printf "\n\tScript to promote aggregation to staging area" >&2
  printf "\n\tUsage: %s [-n] -s <stream> -d <datetimestamp>" "$(basename $0)" >&2
  printf "\n\t\t%s" "where <stream> is train name, such as 'neon' or 'oxygen'" >&2
  printf "\n\t\t%s" "and where <datetimestamp> is the date and time for the directory name of the composite child repository, such as '201208240900'" >&2
  printf "\n\t\t%s" "and the optional \"-n\" means \"no copying\" or 'dry-run'"
  printf "\n" >&2
}

datetimestamp=
stream=
DRYRUN=""
# the initial ':' keeps getopts in quiet mode ... meaning it doesn't print "illegal argument" type messages.
# to get it in completely silent mode, assign $OPTERR=0
# the other ':' is the ususal "OPTARG"
while getopts ':hns:d:' OPTION
do
  options_found=1
  case $OPTION in
    h)
      usage
      exit 1
      ;;
    n)
      DRYRUN="--dry-run"
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
  neon)
    export release=neon
    ;;
  oxygen)
    export release=oxygen
    ;;
  *)
    usage
    exit 1
    ;;
esac

export BUILD_HOME=${BUILD_HOME:-${WORKSPACE}}

# finds file on users path, before current directory
# hence, non-production users can set their own values for test machines
# must be called (included) after the above variables set, since
# above variables are used to compute some other values.

source promote.shsource 2>/dev/null
source ${BUILD_HOME}/tools/promoteUtils/promote.shsource

export stagingDirectory="${REPO_ROOT}/staging/${release}"

export fromDirectory=${stagingDirectory}
export toDirectory=${releaseDirectory}


# make sure 'toDirectory' has been defined and is not zero length
if [ -z "${toDirectory}" ]
then
  echo;
  echo "   Fatal Error: the variable toDirectory must be defined to run this script";
  echo;
  exit 1
else

  # make sure 'datetimestamp' has been defined and is no zero length
  if [ -z "${datetimestamp}" ]
  then
    echo
    echo "   Fatal Error: the variable datetimestamp must be defined to run this script."
    echo
    exit 1
  else

    toSubDir=${toDirectory}/${datetimestamp}

    if [[ -z "${DRYRUN}"]]
    then
      echo ""
      echo "    Copying new plugins and features "
      echo "        from  ${fromDirectory}"
      echo "          to  ${toSubDir}"
      echo ""
      mkdir -p ${toSubDir}
      RC=$?
      if [[ $RC != 0 ]]
      then
        echo -e "\n\t[ERROR] Could not make the directory ${toSubDir}. RC: $RC"
        exit $RC
      fi
    else
      printf "\n\tDoing DRYRUN. But if were not doing dry run, then would first make directory:"
      printf "\n\t\t ${toSubDir}"
      printf "\n\tAnd, if not dry run, would copy files there from:"
      printf "\n\t\t ${fromDirectory}"
    fi

    # plugins and features
    rsync ${DRYRUN}  -rp ${fromDirectory}/* ${toSubDir}/
    checkForErrorExit $? "could not copy files as expected"

    ${BUILD_TOOLS_DIR}/promoteUtils/installEclipseAndTools.sh
    RC=$?
    if [[ $RC != 0 ]]
    then
      echo -e "[ERROR] installEclipseAndTools.sh returned non zero return code: $RC"
      exit $RC
    fi

    if [[ -z "${DRYRUN}" ]]
    then
      "${BUILD_TOOLS_DIR}/promoteUtils/addRepoProperties-release.sh" ${release} ${datetimestamp}
      checkForErrorExit $? "repo properties could not be updated as expected"
      if [[ -e "${toSubDir}/p2.index" ]]
      then
        # remove p2.index, if exists, since convertxz will recreate, and
        # convertxz (may) not recreate xz files, after modifications made in
        # previous step, if p2.index already exists and appears correct.
        rm "${toSubDir}/p2.index"
      fi
      "${BUILD_TOOLS_DIR}/promoteUtils/convertxz.sh" "${toSubDir}"
    else
      echo "Doing DRYRUN, otherwise addRepoProperties and createxz would be performed here at end."
    fi

  fi
fi

