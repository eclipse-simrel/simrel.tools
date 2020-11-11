#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html
# SPDX-License-Identifier: EPL-2.0
#*******************************************************************************

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

SCRIPT_FOLDER="$(dirname "$(readlink -f "${0}")")"

SSH_REMOTE="genie.simrel@projects-storage.eclipse.org"

REPO_ROOT=${REPO_ROOT:-/home/data/httpd/download.eclipse.org}

BUILD_HOME=${BUILD_HOME:-${WORKSPACE}}
BUILD_TOOLS_DIR=${BUILD_HOME}/org.eclipse.simrel.tools

release="${1:-}"
dirdate="${2:-}"

if [ -z "${release}" ]; then
  printf "\n\t[ERROR] the variable release must be defined to run this script\n"
  exit 1
fi

if [ -z "${dirdate}" ]; then
  printf "\n\t[ERROR] the variable dirdate must be defined to run this script\n"
  exit 1
fi

stagingDirectory="${REPO_ROOT}/staging/${release}"
releaseDirectory="${REPO_ROOT}/releases/${release}"
releaseSubDir="${releaseDirectory}/${dirdate}"

printf "\n\tCopying new plugins and features "
printf "\n\t\tfrom  %s" "${stagingDirectory}"
printf "\n\t\tto  %s\n" "${releaseSubDir}"

ssh "${SSH_REMOTE}" mkdir -p "${releaseSubDir}"
ssh "${SSH_REMOTE}" cp -rp "${stagingDirectory}/*" "${releaseSubDir}/"

scp "${BUILD_TOOLS_DIR}/addRepoProperties-release_bash.sh" "${SSH_REMOTE}:~/"
ssh "${SSH_REMOTE}" "addRepoProperties-release_bash.sh" "${release}" "${dirdate}"

