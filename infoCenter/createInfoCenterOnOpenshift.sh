#!/usr/bin/env bash

#*******************************************************************************
# Copyright (c) 2019 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

# Parameters:
release_name=${1:-}
url=${2:-}

# Verify inputs
if [[ -z "${release_name}" && $# -lt 1 ]]; then
  printf "ERROR: a release name must be given.\n"
  exit 1
fi

if [[ -z "${url}" && $# -lt 1 ]]; then
  printf "ERROR: a url to the infocenter archive on SimRel JIPP must be given.\n"
  exit 1
fi


pushd docker/
wget ${url}
./build_infocenter_docker_img.sh ${release_name}
popd

pushd k8s/
./createInfoCenter_yaml.sh ${release_name}
./deployInfoCenter.sh ${release_name}
popd
