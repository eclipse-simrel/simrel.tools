#!/usr/bin/env bash

if [[ -z "${release}" ]]
then
    echo 
    echo "   ERRRO: The 'release' environment much be specified for this script. For example,"
    echo "   release=mars ./$( basename $0 )"
    echo
    exit 1
else
    echo
    echo "release: ${release}"
    echo
fi

source aggr_properties.shsource

# specify devworkspace 
# and JRE to use to runEclipse


devworkspace="${BUILD_HOME}"/antRunnerWorkspace

BUILDFILE=$1

if [ -e $BUILDFILE ] 
then
    BUILDFILESTR=" -file $BUILDFILE"
fi 

export devJRE=${JAVA_8_HOME}/jre/bin/java

ibmDevArgs="-Xms128M -Xmx256M -Dosgi.ws=gtk -Dosgi.os=linux -Dosgi.arch=x86" 

devArgs=$ibmDevArgs

echo dev:          $0
echo
echo devworkspace: $devworkspace
echo
echo devJRE:       $devJRE
$devJRE -version
echo



${ECLIPSE_EXE}  -nosplash -debug -consolelog -console -data $devworkspace -application org.eclipse.ant.core.antRunner $BUILDFILESTR -vm $devJRE -vmargs $devArgs


