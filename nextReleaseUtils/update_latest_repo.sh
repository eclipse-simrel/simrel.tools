#!/usr/bin/env bash

#*******************************************************************************
# Copyright (c) 2019 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# This script updates the latest repo (https://download.eclipse.org/releases/latest) to point
# to the current release repo.

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'
script_name="$(basename ${0})"

release_name=${1:-}
local_dir_name=${2:-}

releases_root_dir="/home/data/httpd/download.eclipse.org/releases"
timestamp=$(date +%s%3N)

ssh_remote="genie.simrel@projects-storage.eclipse.org"

usage() {
  printf "Usage: %s release_name local_dir_name\n" "$script_name"
  printf "\t%-16s release name (e.g., 2024-03).\n" "release_name"
  printf "\t%-16s local dir name (e.g., latest-03).\n" "local_dir_name"
}

if [[ -z "${release_name}" ]]; then
  printf "ERROR: release_name must not be empty\n"
  usage
  exit 1
fi

if [[ -z "${local_dir_name}" ]]; then
  printf "ERROR:  local_dir_name must not be empty\n"
  usage
  exit 1
fi


create_latest_repo() {
  #create local dir
  mkdir -p ${local_dir_name}

  pushd ${local_dir_name}

  echo "Creating p2.index..."
  cat <<EOF > p2.index
version=1
metadata.repository.factory.order=compositeContent.xml
artifact.repository.factory.order=compositeArtifacts.xml
EOF

  echo "Creating metadata..."
  #create compositeArtifacts.xml
  cat <<EOG > compositeArtifacts.xml
<?xml version='1.0' encoding='UTF-8'?>
<?compositeArtifactRepository version='1.0.0'?>
<repository name='Eclipse SimRel ${local_dir_name^}'  type='org.eclipse.equinox.internal.p2.artifact.repository.CompositeArtifactRepository' version='1.0.0'>
  <properties size='3'>
    <property name='p2.timestamp' value='${timestamp}'/>
    <property name='p2.compressed' value='true'/>
    <property name='p2.atomic.composite.loading' value='true'/>
  </properties>
  <children size='1'>
    <child location='https://download.eclipse.org/releases/${release_name}'/>
  </children>
</repository>
EOG

  #create compositeContent.xml
  cat <<EOH > compositeContent.xml
<?xml version='1.0' encoding='UTF-8'?>
<?compositeMetadataRepository version='1.0.0'?>
<repository name='Eclipse SimRel ${local_dir_name^}'  type='org.eclipse.equinox.internal.p2.metadata.repository.CompositeMetadataRepository' version='1.0.0'>
  <properties size='3'>
    <property name='p2.timestamp' value='${timestamp}'/>
    <property name='p2.compressed' value='true'/>
    <property name='p2.atomic.composite.loading' value='true'/>
  </properties>
  <children size='1'>
    <child location='https://download.eclipse.org/releases/${release_name}'/>
  </children>
</repository>
EOH

  echo "compositeArtifacts.xml"
  cat compositeArtifacts.xml
  echo "compositeContent.xml"
  cat compositeContent.xml

  echo "Creating jars..."
  zip compositeArtifacts.jar compositeArtifacts.xml
  zip compositeContent.jar compositeContent.xml
  rm *.xml

  echo "Check dir structure..."
  ls -al

  popd
}

create_latest_repo

echo "SCPing to download server..."
echo "scp -r ${local_dir_name} ${ssh_remote}:${releases_root_dir}"

scp -r ${local_dir_name} ${ssh_remote}:${releases_root_dir}/

echo "Done."