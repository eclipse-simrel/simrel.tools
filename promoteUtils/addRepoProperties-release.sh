#!/usr/bin/env bash

release=$1
datetimestamp=$2

if [ -z $datetimestamp ] ; then
    echo "ERROR: 'datetimestamp' directory variable is required for this script.";
    exit 1;
fi

if [[ -z "${release}" ]]
then
    echo
    echo "   ERROR: The 'release' environment variable is required for this script."
    echo
    exit 1
else
    echo
    echo "release: ${release}"
    echo
fi
 
source promote.shsource

APP_NAME=org.eclipse.wtp.releng.tools.addRepoProperties

devworkspace="${BUILD_HOME}/workspace-addRepoProperties"

echo "dev:          " $0
echo
echo "release:      " $release
echo
echo "datetimestampe: " $datetimestamp
echo
echo "devworkspace: " $devworkspace
echo
echo "JAVA_CMD:       " $JAVA_CMD
echo
echo "devArgs:      " $devArgs
echo
echo "APP_NAME:     " $APP_NAME
$JAVA_CMD -version
echo

${ECLIPSE_EXE}   -debug -nosplash -consolelog -console -data $devworkspace --launcher.suppressErrors -application ${APP_NAME} ${OTHER_ARGS} -vm $JAVA_CMD -vmargs $devArgs

