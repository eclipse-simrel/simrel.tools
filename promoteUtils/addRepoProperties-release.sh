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

release="${1:-}"
dirdate="${2:-}"

if [ -z "$dirdate" ]; then
  echo "ERROR: the 'dirdate' directory variable is required for this script.";
  exit 1;
fi

if [[ -z "${release}" ]]; then
  echo "ERROR: the 'release' environment variable is required for this script."
  exit 1
else
  echo "release: ${release}"
fi

source promote.shsource 2>/dev/null
source "${BUILD_HOME}/org.eclipse.simrel.tools/promoteUtils/promote.shsource"

APP_NAME=org.eclipse.wtp.releng.tools.addRepoProperties

devworkspace="${BUILD_HOME}/workspace-addRepoProperties"

echo "dev:           $0"
echo "release:       ${release}"
echo "dirdate:       ${dirdate}"
echo "devworkspace:  ${devworkspace}"
echo "JAVA_CMD:      ${JAVA_CMD}"
echo "devArgs:       ${devArgs}"
echo "APP_NAME:      ${APP_NAME}"
$JAVA_CMD -version
echo

"${ECLIPSE_EXE}" -debug -nosplash -consolelog -console -data "${devworkspace}" --launcher.suppressErrors -application "${APP_NAME}" "${OTHER_ARGS}" -vm "${JAVA_CMD}" -vmargs "${devArgs}"

