#!/usr/bin/env bash

#*******************************************************************************
# Copyright (c) 2021 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# This script creates the metadata files for a p2repo at the beginning of a release cycle.
# It pre-populates the composite repository with the content of the last release.
# last_release_dir can be specified with a relative path (e.g. '../2019-03/201903201000') or absolute
# (e.g. 'https://download.eclipse.org/releases/2019-03/201903201000').

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

release_name=${1:-}

releases_root_dir="/home/data/httpd/download.eclipse.org/releases"
release_dir="${releases_root_dir}/${release_name}"

ssh_remote="genie.simrel@projects-storage.eclipse.org"

if [[ -z "${release_name}" ]]; then
 printf "ERROR: a release name must be given.\n"
 exit 1
fi

# compare location in compositeContent.jar and latest release dir 
release_in_composite_jar="$(ssh ${ssh_remote} unzip -p "${release_dir}/compositeContent.jar" "compositeContent.xml" | grep 'child location' | grep -v 'epp' | sed "s/.*='//" | sed "s/'.*//")"
latest_release_dir="$(ssh ${ssh_remote} find "${release_dir}" -maxdepth 1 -type d -name '20*' | sort | tail -n 1)"
latest_release_dir="$(basename "${latest_release_dir}")"

if [[ "${release_in_composite_jar}" == "${latest_release_dir}" ]]; then
  echo "Location in compositeContent.jar and latest release dir match: ${latest_release_dir}"
else
  echo "ERROR: Location in compositeContent.jar and latest release dir do not match:"
  echo "  compositeContent.jar: ${release_in_composite_jar}" 
  echo "  Latest release dir:   ${latest_release_dir}"
fi 

ssh ${ssh_remote} /bin/bash << EOF
# find and delete all release dirs EXCEPT the last one
for dir in \$(find ${release_dir}/* -maxdepth 1 -type d -name '20*' | sort | head -n -1); do
  echo "Removing \${dir}..."
  rm -rf "\${dir}"
done

# remove milestone and release candidate composite jars
for rel in M1 M2 M3 RC1 RC2; do
 echo "Removing composite jars for \${rel}..."
 rm -f "${release_dir}/compositeArtifacts\${rel}.jar"
 rm -f "${release_dir}/compositeContent\${rel}.jar"
done
EOF

echo "Done."