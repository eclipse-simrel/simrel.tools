#!/usr/bin/env bash

source promote.shsource

INSTALL_ECLIPSE="true"

if [[ "${INSTALL_ECLIPSE}" == "true" ]]
then
  echo "FULL_FILENAME: ${FULL_FILENAME}"
  echo "ECLIPSE_HOME: ${ECLIPSE_HOME}"

  mkdir -p "${ECLIPSE_HOME}"
  tar -vxf "${FULL_FILENAME}" -C "${ECLIPSE_HOME}"
fi
REPO="file:///home/data/httpd/download.eclipse.org/webtools/releng/repository"

${ECLIPSE_HOME}/eclipse/eclipse -nosplash -debug -data workspace-intallEclipseAndTOols  \
  -application org.eclipse.equinox.p2.director \
  -repository  "${REPO}" \
  -installIU \
  org.eclipse.wtp.releng.tools.feature.feature.group -vm $JAVA_CMD