#!/usr/bin/env bash

#*******************************************************************************
# Copyright (c) 2021 Eclipse Foundation and others.
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

# Verify inputs
if [[ -z "${release_name}" ]]; then
  printf "ERROR: a release name must be given.\n"
  exit 1
fi

oc delete pod infocenter-${release_name}-0 -n infocenter --force --grace-period=0
oc delete sts infocenter-${release_name} -n infocenter
oc delete service infocenter-${release_name} -n infocenter
oc delete route infocenter-${release_name} -n infocenter

remove_question() {
  read -p "Do you want to remove the folder for ${release_name}? (Y)es, (N)o, E(x)it: " yn
  case $yn in
    [Yy]* ) rm -rf ${release_name};;
    [Nn]* ) exit 0;;
    [Xx]* ) exit 0;;
        * ) echo "Please answer (Y)es, (N)o, E(x)it"; question;
  esac
}

remove_question