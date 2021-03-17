#!/usr/bin/env bash

#*******************************************************************************
# Copyright (c) 2020 Eclipse Foundation and others.
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
release_name="${1:-}"

# scale down and delete statefulset
oc scale statefulset "infocenter-${release_name}" -n=infocenter --replicas=0
sleep 5
oc get statefulset "infocenter-${release_name}" -n=infocenter
oc delete pod "infocenter-${release_name}-0" -n=infocenter --force --grace-period=0
sleep 5
oc get pods -n=infocenter
oc delete statefulset "infocenter-${release_name}" -n=infocenter
sleep 5
oc get statefulset -n=infocenter
# apply statefulset
oc apply -f "${release_name}/statefulset.yml"
