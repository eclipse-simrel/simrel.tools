#!/bin/bash
#*******************************************************************************
#* Copyright (c) 2018 Eclipse Foundation.
#* All rights reserved. This program and the accompanying materials
#* are made available under the terms of the Eclipse Public License v1.0
#* which accompanies this distribution, and is available at
#* http://www.eclipse.org/legal/epl-v10.html
#*
#* Contributors:
#*   Frederic Gurr (Eclipse Foundation)
#*******************************************************************************/

# This script prepares a respin according to https://wiki.eclipse.org/SimRel/Simultaneous_Release_Engineering#How_to_do_a_re-spin

set -e

script_name="$(basename ${0})"

release_name="$1"       # e.g. photon, 2018.09, etc
tag="$2"                # e.g. Photon.0
release_dir_name="$3"   # e.g. 201806271001

simrel_build_path="../../org.eclipse.simrel.build"
simrel_tools_path="../org.eclipse.simrel.tools"

## Usage
usage() {
  printf "Usage: %s release_name tag release_dir_name \n" "${script_name}"
  printf "\t%-16s release name (e.g. photon, 2018.09).\n" "release_name"
  printf "\t%-16s tag (e.g. Photon.0).\n" "tag"
  printf "\t%-16s release dir name (e.g. 201806271001).\n" "release_dir_name"
}

## Verify inputs
if [ "${release_name}" == "" ]; then
  printf "ERROR: a release_name must be given.\n"
  usage
  exit 1
fi

if [ "${tag}" == "" ]; then
  printf "ERROR: a tag must be given.\n"
  usage
  exit 1
fi

if [ "${release_dir_name}" == "" ]; then
  printf "ERROR: a release_dir_name must be given.\n"
  usage
  exit 1
fi

pushd ${simrel_build_path}

#create respin branch
git checkout ${tag}
git checkout -b ${tag}_respin

#transform repo
ant -f ${simrel_tools_path}/transformToOneRepo/changeAllRepos.xml -DnewRepository=https://download.eclipse.org/releases/${release_name}/${release_dir_name}/ -Djavax.xml.transform.TransformerFactory=com.sun.org.apache.xalan.internal.xsltc.trax.TransformerFactoryImpl
#git diff
git diff ${tag} || true

git_commit() {
  git add *.aggrcon
  git commit -m "Preparations for respin"
}

read -p "Do you want to commit the changes? (Y)es, (N)o: " yn
case $yn in
  [Yy]* ) git_commit;;
  [Nn]* ) exit 1;;
      * ) printf "Please answer (Y)es, (N)o\n";;
esac

printf "Next steps:\n"
printf "1. Apply change(s) for respin\n"
printf "2. 'Validate' and 'Validate aggregation'\n"
printf "3. Push changes\n"
printf "4. Run (modified) BUILD_CLEAN and trigger promoteToStaging\n"
printf "5. Use p2diff to compare staging with last release\n"

popd
