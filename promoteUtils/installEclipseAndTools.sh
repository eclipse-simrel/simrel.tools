#!/usr/bin/env bash

source promote.shsource

tar -xf "${FULL_FILENAME}" -C "${ECLIPSE_HOME}"

REPO="file:///home/data/httpd/download.eclipse.org/webtools/releng/repository"

${ECLIPSE_HOME}/eclipse -nosplash  \
    -application org.eclipse.equinox.p2.director \
    -repository  "${REPO}" \
    -installIU \
    org.eclipse.releng.tools.feature.group
