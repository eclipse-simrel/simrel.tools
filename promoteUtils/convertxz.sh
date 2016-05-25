#!/usr/bin/env bash
#*******************************************************************************
# Copyright (c) 2016 IBM Corporation and others.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#     IBM Corporation - initial API and implementation
#*******************************************************************************


# Utility function to convert repo site metadata files to XZ compressed files. 
# One use case is to invoke with something similar to
#
# find . -maxdepth 3  -name content.jar  -execdir convertxz.sh '{}' \;

source ${BUILD_TOOLS_DIR}/promoteUtils/createXZ.shsource
# don't think this "export function" is needed here?
#export -f createXZ
createXZ "${1}"
 