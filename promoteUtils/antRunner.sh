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

source promote.shsource 2>/dev/null
source ${BUILD_HOME}/tools/promoteUtils/promote.shsource

# specify devworkspace
# and JRE to use to runEclipse


devworkspace="${BUILD_HOME}"/workspace-antrunner

BUILDFILE=$1

if [ -e $BUILDFILE ]
then
    BUILDFILESTR=" -file $BUILDFILE"
fi

export JAVA_CMD=${JAVA_HOME}/jre/bin/java


echo dev:          $0
echo devArgs:      $devArgs
echo devworkspace: $devworkspace
echo
echo JAVA_CMD:       $JAVA_CMD
echo
$JAVA_CMD -version
echo



${ECLIPSE_EXE} --launcher.suppressErrors -nosplash -debug -consolelog -console -data $devworkspace -application org.eclipse.ant.core.antRunner $BUILDFILESTR -vm $JAVA_CMD -vmargs $devArgs


