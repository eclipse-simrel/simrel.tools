#!/usr/bin/env bash

stream=$1
checkpoint=$2

# check input

if [[ -z $stream ]]; then
  echo -e "\n[ERROR] The variable 'stream' was not passed to the writeComposites script"
  exit $RC
fi

if [[ -z $checkpoint ]]; then
  echo -e "\n[ERROR] The variable 'checkpoint' was not passed to the writeComposites script"
  exit $RC
fi

# Normally "writeRepoRoots" is the same as "repoRoots", but might not always be, 
# plus it is very handy for testing this script not to have to write 
# to the "production" area.
repoRoot="/home/data/httpd/download.eclipse.org/releases/${stream}"
# For testing: if WORKSPACE is not defined, the current directory is used.
WORKSPACE=${WORKSPACE:-${PWD}}
#writeRepoRoot="${PWD}/$stream"
# This is the "real" place to write results.
writeRepoRoot="${repoRoot}"

# TODO: replace with SSH call
dirs=$(ls -1rd ${repoRoot}/20* | xargs -d '\n' -n 1 basename)

#echo -e "\n[DEBUG] writeRepoRoot: ${writeRepoRoot}"
mkdir -p "${writeRepoRoot}"
RC=$?
if [[ $RC != 0 ]]; then
  echo -e "\n[ERROR] Could not create directory at ${writeRepoRoot}\n"
  exit $RC
fi

#echo -e "[DEBUG] repoRoot: ${repoRoot}\n"
templocation=${WORKSPACE}
artifactsCompositeName="compositeArtifacts"
artifactsCompositeFile="${templocation}/${artifactsCompositeName}.xml"
artifactsCompositeJar="${writeRepoRoot}/${artifactsCompositeName}${checkpoint}.jar"
contentCompositeName="compositeContent"
contentCompositeFile="${templocation}/${contentCompositeName}.xml"
contentCompositeJar="${writeRepoRoot}/${contentCompositeName}${checkpoint}.jar"


function writeArtifactsHeader {
  local outfile=$1
  local stream=$2
  local nChildren=$3
  local size=$(($nChildren+1))

  cat <<EOF > ${outfile}
<?xml version='1.0' encoding='UTF-8'?>
<?compositeArtifactRepository version='1.0.0'?>
<repository name='Eclipse Repository' type='org.eclipse.equinox.internal.p2.artifact.repository.CompositeArtifactRepository' version='1.0.0'>
  <properties size='3'>
    <property name='p2.timestamp' value='1313779613118'/>
    <property name='p2.compressed' value='true'/>
    <property name='p2.atomic.composite.loading' value='true'/>
  </properties>
  <children size='${size}'>
    <child location='../../technology/epp/packages/${stream}/'/>
EOF
}

function writeContentHeader {
  local outfile=$1
  local stream=$2
  local nChildren=$3
  local size=$((nChildren+1))

  cat <<EOG > ${outfile}
<?xml version='1.0' encoding='UTF-8'?>
<?compositeMetadataRepository version='1.0.0'?>
<repository name='Eclipse Repository' type='org.eclipse.equinox.internal.p2.artifact.repository.CompositeMetadataRepository' version='1.0.0'>
  <properties size='3'>
    <property name='p2.timestamp' value='1313779613118'/>
    <property name='p2.compressed' value='true'/>
    <property name='p2.atomic.composite.loading' value='true'/>
  </properties>
  <children size='${size}'>
    <child location='../../technology/epp/packages/${stream}/'/>
EOG
}

function writeFooter {
  local outfile=$1
  cat <<EOH > "${outfile}"
  </children>
</repository>
EOH
}

function writeCompositeP2Index {
  cat <<EOI > "p2.index"
version=1
metadata.repository.factory.order=compositeContent.xml
artifact.repository.factory.order=compositeArtifacts.xml
EOI
}

function writeChildren {
  local outfile=$1
  local dirs=$2
  local nChildren=$3

  children=$(printf "${dirs}\n" | head -n ${nChildren})

  for child in ${children}
  do
    printf "%s%s%s\n" "    <child location='" ${child} "' />"  >> ${outfile}
  done
}

# Main

# NOTE: we always take the "3 most recent builds" EXCEPT when we are doing a "final release". 
# We assume that RC2 will be the final release, in case of a respin we assume RC2a, RC2b, etc
#
# We use "20" as a prefix to match for all our child repo directories 
if [[ ${checkpoint} =~ ^RC2[a-z]*$ ]]; then
  nChildren=1
  echo -e "\n\t[INFO] Checkpoint, ${checkpoint}, was found to be a final release."
else
  nChildren=3
  echo -e "\n\t[INFO] Checkpoint, ${checkpoint}, was NOT found to be a final release."
fi

writeArtifactsHeader "${artifactsCompositeFile}" ${stream} ${nChildren}
writeChildren "${artifactsCompositeFile}" "${dirs}" ${nChildren}
writeFooter "${artifactsCompositeFile}"

writeContentHeader "${contentCompositeFile}" ${stream} ${nChildren}
writeChildren "${contentCompositeFile}" "${dirs}" ${nChildren}
writeFooter "${contentCompositeFile}"

# We go ahead and re-write the file, since even if it 
# exists already, we do not know what its contents are.
writeCompositeP2Index
#FIXME: use SCP
cp p2.index ${writeRepoRoot}/

zip -q --junk-paths "${artifactsCompositeJar}" "${artifactsCompositeFile}"
zip -q --junk-paths "${contentCompositeJar}" "${contentCompositeFile}"

# Since these files are in "workspace", we would not *have* to delete them, 
# but seems best to, to avoid looking at them. 
rm ${contentCompositeFile} ${artifactsCompositeFile}
rm p2.index

