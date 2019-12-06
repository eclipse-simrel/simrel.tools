#!/usr/bin/env bash

#*******************************************************************************
# Copyright (c) 2019 Eclipse Foundation and others.
# This program and the accompanying materials are made available
# under the terms of the Eclipse Public License 2.0
# which is available at http://www.eclipse.org/legal/epl-v20.html,
# or the MIT License which is available at https://opensource.org/licenses/MIT.
# SPDX-License-Identifier: EPL-2.0 OR MIT
#*******************************************************************************

# This script requires the following files to be present in the same dir:
# * get_jars.sh
# * find_jars.sh
# * plugin_customization.ini

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

# Parameters:
# $1 = release name (e.g. neon, oxygen)
# $2 = path to platform zip (e.g. M-4.6.2RC3-201611241400/eclipse-platform-4.6.2RC3-linux-gtk-x86_64.tar.gz)
release_name=${1:-}
zip_path=${2:-}
p2_repo_dir=${3:-}
legacy_mode=${4:-'false'}

#help_home=/home/data/httpd/help.eclipse.org/
help_home=.
workdir=${help_home}/${release_name}
platform_dir=/home/data/httpd/download.eclipse.org/eclipse/downloads/drops4
p2_base_dir=/home/data/httpd/download.eclipse.org
script_name="$(basename ${0})"

info_center_port=8086

usage() {
  printf "Usage %s [releaseName] [pathToArchive] [p2RepoDir] [legacyMode]\n" "${script_name}"
  printf "\t%-16s the release name (e.g. neon, neon1, oxygen, oxygen1)\n" "releaseName"
  printf "\t%-16s the path to eclipse-platform archive (e.g. M-4.6.2RC3-201611241400/eclipse-platform-4.6.2RC3-linux-gtk-x86_64.tar.gz)\n" "pathToArchive"
  printf "\t%-16s the path to the P2 repo (e.g. releases/neon/201610111000) (optional)\n" "p2RepoDir"
  printf "\t%-16s set to 'true' to use legacy mode (default is 'false') (optional)\n" "legacyMode"
}

# Verify inputs
if [[ -z "${release_name}" && $# -lt 1 ]]; then
  printf "ERROR: a release name must be given.\n"
  usage
  exit 1
fi

if [[ -z "${zip_path}" && $# -lt 2 ]]; then
  printf "ERROR: a path to the eclipse-platform archive must be given.\n"
  usage
  exit 1
fi

prepare() {
  # Create new sub directory for info center
  echo "Create sub directory for new info center..."
  mkdir -p ${workdir}

  # TODO: exit when sub directory already exists?

  # Copy/download eclipse-platform
  echo "Downloading eclipse-platform..."
  if [ ! -f ${workdir}/eclipse-platform*.tar.gz ]; then
    cp ${platform_dir}/${zip_path} .
  fi

  # Extract eclipse-platform
  tar xzf eclipse-platform*.tar.gz -C ${workdir}

  # Copy eclipse/plugin_customization.ini
  echo "Copying plugin_customization.ini..."
  cp plugin_customization.ini ${workdir}/eclipse/

  # Create dropins/plugins dir
  echo "Create dropins/plugins dir..."
  mkdir -p ${workdir}/eclipse/dropins/plugins
}

find_base() {
  local workdir=${1:-}
  # Find org.eclipse.help.base
  help_base_path=$(find ${workdir} -name "org.eclipse.help.base*.jar")
  #TODO: deal with potential errors
  substring_tmp=${help_base_path#.*_}
  help_base_version=${substring_tmp%.jar}
  echo ${help_base_version}
}

find_doc_jars() {
  # Find doc JARs
  echo "Find doc JARs..."
  if [[ ${legacy_mode} == 'true' ]]; then
    # Run get_jars.sh (legacy)
    echo "Executing get_jars.sh (legacy_mode)... "
    ./get_jars.sh ${workdir}/eclipse/dropins/plugins
  else
    echo "Executing find_jars.sh (p2_repo_dir: ${p2_base_dir}/${p2_repo_dir})..."
    filename=doc_plugin_list.txt
    ./find_jars.sh ${p2_base_dir}/${p2_repo_dir}
    while read line; do
      cp $line ${workdir}/eclipse/dropins/plugins
    done < $filename
  fi
}

fix_banner() {
  local version=$1
  local banner_jar=org.foundation.helpbanner2_2.0.0.jar
  local jar_path=./${banner_jar}
  local tmpdir=./banner_tmp_dir
  local banner_path=${tmpdir}/banner.html

  local token="Eclipse Oxygen"

  printf "Fixing banner...\n"

  # remove new jar
  if [ -f ${jar_path}.new ]; then
    rm ${jar_path}.new
  fi

  # extract files
  unzip -q ${jar_path} -d ${tmpdir}

  # replace version
  sed -i "s/${token}/Eclipse IDE ${version}/g" ${banner_path}

  # create jar
  pushd ${tmpdir} > /dev/null
  zip -rq ../${banner_jar}.new .
  popd > /dev/null

  # remove tmp dir
  if [ -d ${tmpdir} ]; then
    rm -rf ${tmpdir}
  fi

  # Add custom banner
  echo "Add custom banner..."
  cp ${banner_jar}.new ${workdir}/eclipse/dropins/plugins/${banner_jar}
}

create_scripts() {
  local workdir=${1:-}
  local help_base_version=${2:-}
  local info_center_port=${3:-}
  # Create start script
  echo "Create start and stop scripts..."
  cat <<EOF > ${workdir}/startInfoCenter.sh
#!/usr/bin/env bash
port=${info_center_port}
java -Dhelp.lucene.tokenizer=standard -Dorg.eclipse.equinox.http.jetty.context.sessioninactiveinterval=60 -classpath eclipse/plugins/org.eclipse.help.base_${help_base_version}.jar org.eclipse.help.standalone.Infocenter -clean -command start -eclipsehome eclipse -port \${port} -nl en -locales en -plugincustomization plugin_customization.ini -vmargs -Xmx1024m -XX:+HeapDumpOnOutOfMemoryError &
echo "The Eclipse info center is now started and can be accessed here: http://localhost:\${port}/help/index.jsp"
EOF

  # Create stop script
  cat <<EOG > ${workdir}/stopInfoCenter.sh
#!/usr/bin/env bash
port=${info_center_port}
java -classpath eclipse/plugins/org.eclipse.help.base_${help_base_version}.jar org.eclipse.help.standalone.Infocenter -clean -command shutdown -eclipsehome eclipse -port \${port} 2>&1
echo "The Eclipse info center is now stopped."
EOG

  chmod +x ${workdir}/*InfoCenter.sh
}

create_archive() {
  local workdir=${1:-}
  local release_name=${2:-}
  # Create tar.gz
  # if [ -f info-center-${release_name}.tar.gz ]; then
  #   rm info-center-${release_name}.tar.gz
  # fi
  echo "Creating info center archive..."
  full_date=$(date +%Y-%m-%d-%H-%M-%S)
  tar czf info-center-${release_name}-${full_date}.tar.gz ${workdir}
}

prepare
help_base_version=$(find_base ${workdir})
echo "Found base version ${help_base_version}."
find_doc_jars
fix_banner ${release_name} ${workdir}
create_scripts ${workdir} ${help_base_version} ${info_center_port}
create_archive ${workdir} ${release_name}

printf "Done.\n"