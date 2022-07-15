#!/usr/bin/env bash

# This script is similar to /org.eclipse.cbi.p2repo.releng.parent/buildScripts/writeComposites.sh 

# Bash strict-mode
set -o errexit
set -o nounset
set -o pipefail

IFS=$'\n\t'

release="${1:-}"
checkpoint="${2:-}"

# check input

if [[ -z "${release}" ]]; then
  echo -e "[ERROR] The variable 'release' was not passed to the writeComposites script"
  exit 1
fi

if [[ -z "${checkpoint}" ]]; then
  echo -e "[ERROR] The variable 'checkpoint' was not passed to the writeComposites script"
  exit 1
fi

ssh_remote="genie.simrel@projects-storage.eclipse.org"

releaseRepoRoot="${RELEASE_REPO_ROOT:-/home/data/httpd/download.eclipse.org/releases/${release}}"
# For testing: if WORKSPACE is not defined, the current directory is used.
WORKSPACE="${WORKSPACE:-${PWD}}"

#echo -e "[DEBUG] releaseRepoRoot: ${releaseRepoRoot}\n"

write_header() {
  local outfile="$1"
  local type="$2"
  local name="$3"
  # get epoch with milliseconds
  local timestamp
  timestamp="$(date +%s%3N)" #Attention: date +%N does not work on macOS!
  cat > "${outfile}" <<EOL
<?xml version='1.0' encoding='UTF-8'?>
<?compositeMetadataRepository version='1.0.0'?>
<repository name='${name}' type='org.eclipse.equinox.internal.p2.metadata.repository.${type}' version='1.0.0'>
  <properties size='3'>
    <property name='p2.timestamp' value='${timestamp}'/>
    <property name='p2.compressed' value='true'/>
    <property name='p2.atomic.composite.loading' value='true'/>
  </properties>
EOL
}

write_footer() {
  local outfile="$1"
  cat >> "${outfile}" <<EOL
  </children>
</repository>
EOL
}

write_composite_P2Index() {
  local outfile="$1"
  cat > "${outfile}" <<EOL
version=1
metadata.repository.factory.order=compositeContent.xml
artifact.repository.factory.order=compositeArtifacts.xml
EOL
}

write_composite_repo() {
  local outfile="$1"
  local dirs="$2"
  local type="$3"
  local maxChildren="$4"
  local release="$5"
  local repo_name="Eclipse Repository"

  write_header "${outfile}" "${type}" "${repo_name}"

  local children=$(printf "%s\n" "${dirs}" | head -n "${maxChildren}")

  local nChildren=$(echo -e "${children}" | wc -l)
  nChildren=$((nChildren + 1)) # add one for epp entry
  echo "  <children size='${nChildren}'>" >> "${outfile}"
  echo "    <child location='../../technology/epp/packages/${release}/'/>" >> "${outfile}"
  for child in ${children}
  do
    printf "%s%s%s\n" "    <child location='" "${child}" "' />" >> "${outfile}"
  done

  write_footer "${outfile}"
}

create_composite_repo() {
  local templocation=${WORKSPACE}

  local artifactsCompositeName="compositeArtifacts"
  local artifactsCompositeFile="${templocation}/${artifactsCompositeName}.xml"
  local artifactsCompositeJar="${templocation}/${artifactsCompositeName}${checkpoint}.jar"
  local contentCompositeName="compositeContent"
  local contentCompositeFile="${templocation}/${contentCompositeName}.xml"
  local contentCompositeJar="${templocation}/${contentCompositeName}${checkpoint}.jar"
  local numberOfChildren

  # NOTE: we always take the "3 most recent builds" EXCEPT when we are doing a "final release". 
  # We assume that RC2 will be the final release, in case of a respin we assume RC2a, RC2b, etc
  # We use "20" as a prefix to match for all our child repo directories 
  if [[ ${checkpoint} =~ ^RC2[a-z]*$ ]]; then
    numberOfChildren=1
    echo -e "\n[INFO] Checkpoint, ${checkpoint}, was found to be a final release."
  else
    numberOfChildren=3
    echo -e "\n[INFO] Checkpoint, ${checkpoint}, was NOT found to be a final release."
    numberOfChildren=1
    echo -e "\n[INFO] Number of children will be set to 1 nevertheless."
  fi

  # xargs -d works on projects-storage.eclipse.org, but not on default jnlp agent!
  local dirs=$(ssh ${ssh_remote} "ls -1rd ${releaseRepoRoot}/20* | xargs -d '\n' -n 1 basename")

  # write files to temp location
  write_composite_repo "${artifactsCompositeFile}" "${dirs}" "CompositeArtifactRepository" "${numberOfChildren}" "${release}"
  write_composite_repo "${contentCompositeFile}" "${dirs}" "CompositeMetadataRepository" "${numberOfChildren}" "${release}"
  write_composite_P2Index "${templocation}/p2.index"

  # create jar files
  zip -q --junk-paths "${artifactsCompositeJar}" "${artifactsCompositeFile}"
  zip -q --junk-paths "${contentCompositeJar}" "${contentCompositeFile}"

  # debug
  printf "\ncompositeArtifacts.xml:\n"
  cat "${artifactsCompositeFile}"
  printf "\n"

  printf "\ncompositeContent.xml:\n"
  cat "${contentCompositeFile}"
  printf "\n"

  # upload files
  ssh ${ssh_remote} mkdir -p "${releaseRepoRoot}"
  scp "${artifactsCompositeJar}" "${ssh_remote}:${releaseRepoRoot}"
  scp "${contentCompositeJar}" "${ssh_remote}:${releaseRepoRoot}"
  scp "${templocation}/p2.index" "${ssh_remote}:${releaseRepoRoot}"
}

create_composite_repo
