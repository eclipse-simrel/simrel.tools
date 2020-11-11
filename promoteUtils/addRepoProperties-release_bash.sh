#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# This script replaces the relevant parts of the addRepoProperties tool:
# https://wiki.eclipse.org/WTP/Releng/Tools/addRepoProperties
#
# It adds/sets the following:
# * repository name
# * p2.mirrorsURL
# * p2.statsURI
#
# To be compatible with the addRepoProperties tool, the following is set as well:
# * repository version (hardcoded to 1.0.0)
# * p2.timestamp (milliseconds since epoch)

release="${1:-}"
dirdate="${2:-}"

if [[ -z "${release}" ]]; then
  echo "ERROR: the 'release' environment variable is required for this script."
  exit 1
else
  echo "release: ${release}"
fi

if [ -z "$dirdate" ]; then
  echo "ERROR: the 'dirdate' directory variable is required for this script.";
  exit 1;
else
  echo "dirdate: ${dirdate}"
fi

# try different executable names
xmlstarlet_bin=$(which xmlstarlet)
if [[ $? != 0 || -z "${xmlstarlet_bin}" ]]; then
  xmlstarlet_bin=$(which xml)
  if [[ $? != 0 || -z "${xmlstarlet_bin}" ]]; then
    echo "ERROR: xmlstarlet executable not found (tried 'xmlstarlet' and 'xml'). Please install xmlstarlet.";
    exit 1
  fi
fi


REPO_ROOT="${REPO_ROOT:-/home/data/httpd/download.eclipse.org}"

stagingDirectory="${REPO_ROOT}/staging/${release}"
releaseDirectory="${REPO_ROOT}/releases/${release}/${dirdate}"

p2ArtifactRepositoryName="${release}/${dirdate}"
p2MirrorsURL="http://www.eclipse.org/downloads/download.php?format=xml&file=/releases/${release}/${dirdate}"
p2StatsURI="https://download.eclipse.org/stats/releases/${release}"

# extract artifacts.jar
unzip -q "${stagingDirectory}/artifacts.jar" -d "${stagingDirectory}"

# get epoch with milliseconds
timestamp="$(date +%s%3N)" #Attention: date +%N does not work on macOS!

echo "Editing artifacts.xml..."

# edit values and write new xml file (replace double quotes with single quotes)
"${xmlstarlet_bin}" ed -u "//repository/@name" -v "${p2ArtifactRepositoryName}" \
              -u "//repository/@version" -v "1.0.0" \
              -u "//repository/properties/@size" -v "5" \
              -u "//repository/properties/property[@name='p2.timestamp']/@value" -v "${timestamp}" \
              -s "//repository/properties" -t "elem" -n "property" \
              -i "//repository/properties/property[not(@name)]" -t "attr" -n "name" -v "p2.mirrorsURL" \
              -i "//repository/properties/property[@name='p2.mirrorsURL']" -t "attr" -n "value" -v "${p2MirrorsURL}" \
              -s "//repository/properties" -t "elem" -n "property" \
              -i "//repository/properties/property[not(@name)]" -t "attr" -n "name" -v "p2.statsURI" \
              -i "//repository/properties/property[@name='p2.statsURI']" -t "attr" -n "value" -v "${p2StatsURI}" \
              "${stagingDirectory}/artifacts.xml" | tr '"' "'" > "${releaseDirectory}/artifacts.xml"

# compress with zip to artifacts.jar file
rm -f "${releaseDirectory}/artifacts.jar"
zip -qj "${releaseDirectory}/artifacts.jar" "${releaseDirectory}/artifacts.xml"

# copy and extract content.jar
cp -p "${stagingDirectory}/content.jar" "${releaseDirectory}/content.jar"
unzip -q "${releaseDirectory}/content.jar" -d "${releaseDirectory}"

# compress with xz
XZ_EXE=$(which xz)
if [[ $? != 0 || -z "${XZ_EXE}" ]]; then
  echo -e "\n\tERROR: xz executable can not be found. Please install xz."
  exit 1
fi

echo "Compressing artifacts.xml and content.xml with xz..."

${XZ_EXE} -e --force "${releaseDirectory}/artifacts.xml"
${XZ_EXE} -e --verbose --force "${releaseDirectory}/content.xml"

# remove *.xml
rm -f "${releaseDirectory}/artifacts.xml" "${releaseDirectory}/content.xml"

echo "Creating p2.info..."
# write p2.info
cat <<EOF > "${releaseDirectory}/p2.index"
version=1
metadata.repository.factory.order=content.xml.xz,content.xml,!
artifact.repository.factory.order=artifacts.xml.xz,artifacts.xml,!
EOF

# remove staging artifacts.xml
rm -f "${stagingDirectory}/artifacts.xml"


