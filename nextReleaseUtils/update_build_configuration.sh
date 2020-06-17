#!/usr/bin/env bash

#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# This script does the following:
# * Update TRAIN_NAME in Jenkinsfile
# * Update pom.xml

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
script_name="$(basename ${0})"

xmlstarlet_bin=xmlstarlet

jenkinsfile=../../org.eclipse.simrel.build/Jenkinsfile
pom_xml=../../org.eclipse.simrel.build/pom.xml

release_name=${1:-}
reference_repo=${2:-}
eclipse_repo_url=${3:-}

usage() {
  printf "Usage: %s release_name reference_repo eclipse_repo_url\n" "${script_name}"
  printf "\t%-16s release name (e.g. 2020-09).\n" "project_name"
  printf "\t%-16s reference repo (e.g. 'releases/2020-06/202006171000').\n" "reference_repo"
  printf "\t%-16s Eclipse repo URL (e.g. 'https://download.eclipse.org/eclipse/updates/4.16/R-4.16-202006040540/').\n" "eclipse_repo_url"
}

## Verify inputs

#TODO: check number of arguments

if [ "${release_name}" == "" ]; then
  printf "ERROR: a release name must be given (e.g. 2020-09).\n"
  usage
  exit 1
fi

if [ "${reference_repo}" == "" ]; then
  printf "ERROR: a reference repo must be given (e.g. 'releases/2020-06/202006171000').\n"
  usage
  exit 1
fi

if [ "${eclipse_repo_url}" == "" ]; then
  printf "ERROR: an Eclipse repo URL must be given (e.g. 'https://download.eclipse.org/eclipse/updates/4.16/R-4.16-202006040540/').\n"
  usage
  exit 1
fi

# Update TRAIN_NAME in Jenkinsfile
sed -i "s/TRAIN_NAME = \".*\"/TRAIN_NAME = \"${release_name}\"/g" ${jenkinsfile}

# Update pom.xml
# Unfortunately the namesspaces has to be defined for pom.xml files
${xmlstarlet_bin} ed -L -N p="http://maven.apache.org/POM/4.0.0" -u /p:project/p:properties/p:trainName -v "${release_name}" ${pom_xml}
${xmlstarlet_bin} ed -L -N p="http://maven.apache.org/POM/4.0.0" -u /p:project/p:properties/p:referenceRepo -v "${reference_repo}" ${pom_xml}
${xmlstarlet_bin} ed -L -N p="http://maven.apache.org/POM/4.0.0" -u /p:project/p:properties/p:eclipse.repo.url -v "${eclipse_repo_url}" ${pom_xml}

