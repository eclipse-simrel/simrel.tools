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


source promote.shsource 2>/dev/null
source ${BUILD_HOME}/org.eclipse.simrel.tools/promoteUtils/promote.shsource

INSTALL_ECLIPSE="true"

if [[ "${INSTALL_ECLIPSE}" == "true" ]]
then
  echo "FULL_FILENAME: ${FULL_FILENAME}"
  echo "ECLIPSE_HOME: ${ECLIPSE_HOME}"

  if [[ -e "${ECLIPSE_HOME}" ]]
  then
    # eventually we can skip re-install, once confident
    # but for now, we will remove and reinstall
    echo -e "\n\t[INFO] found ECLIPSE_HOME existed already. Will remove and reinstall\n"
    rm -fr "${ECLIPSE_HOME}"
  fi

  mkdir -p "${ECLIPSE_HOME}"
  tar -xf "${FULL_FILENAME}" -C "${ECLIPSE_HOME}"
fi
REPO="file:///home/data/httpd/download.eclipse.org/webtools/releng/repository"

${ECLIPSE_HOME}/eclipse/eclipse -nosplash -debug -data workspace-intallEclipseAndTools  \
  -application org.eclipse.equinox.p2.director \
  -repository  "${REPO}" \
  -installIU \
  org.eclipse.wtp.releng.tools.feature.feature.group -vm $JAVA_CMD -vmargs $devArgs
