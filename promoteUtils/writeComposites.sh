#!/usr/bin/env bash

function writeArtifactsHeader
{
  outfile=$1
  stream=$2
  printf "%s\n" "<?xml version='1.0' encoding='UTF-8'?>" > ${outfile}
  printf "%s\n" "<?compositeArtifactRepository version='1.0.0'?>" >> ${outfile}
  printf "%s\n" "<repository name='Eclipse Repository'  type='org.eclipse.equinox.internal.p2.artifact.repository.CompositeArtifactRepository' version='1.0.0'>" >> ${outfile}
  printf "%s\n" "  <properties size='3'>" >> ${outfile}
  printf "%s\n" "    <property name='p2.timestamp' value='1313779613118'/>" >> ${outfile}
  printf "%s\n" "    <property name='p2.compressed' value='true'/>" >> ${outfile}
  printf "%s\n" "    <property name='p2.atomic.composite.loading' value='true'/>" >> ${outfile}
  printf "%s\n" "  </properties>" >> ${outfile}
  printf "%s\n" "  <children size='4'>" >> ${outfile}
  printf "%s\n" "     <child location='http://download.eclipse.org/technology/epp/packages/$stream/'/>" >> ${outfile}


}

function writeContentHeader
{
  outfile=$1
  stream=$2
  printf "%s\n" "<?xml version='1.0' encoding='UTF-8'?>" > ${outfile}
  printf "%s\n" "<?compositeMetadataRepository version='1.0.0'?>" >> ${outfile}
  printf "%s\n" "<repository name='Eclipse Repository'  type='org.eclipse.equinox.internal.p2.metadata.repository.CompositeMetadataRepository' version='1.0.0'>" >> ${outfile}
  printf "%s\n" "  <properties size='3'>" >> ${outfile}
  printf "%s\n" "    <property name='p2.timestamp' value='1313779613118'/>" >> ${outfile}
  printf "%s\n" "    <property name='p2.compressed' value='true'/>" >> ${outfile}
  printf "%s\n" "    <property name='p2.atomic.composite.loading' value='true'/>" >> ${outfile}
  printf "%s\n" "  </properties>" >> ${outfile}
  printf "%s\n" "  <children size='3'>" >> ${outfile}
  printf "%s\n" "     <child location='http://download.eclipse.org/technology/epp/packages/$stream/'/>" >> ${outfile}

}

function writeFooter
{
  outfile=$1
  printf "%s\n" "  </children>" >> ${outfile}
  printf "%s\n" "</repository>" >> ${outfile}
}

function writeCompositeP2Index
{
  printf "%s\n" "version=1" > "${p2Index}"
  printf "%s\n" "metadata.repository.factory.order=compositeContent.xml" >> "${p2Index}"
  printf "%s\n" "artifact.repository.factory.order=compositeArtifacts.xml" >> "${p2Index}"
}

function writeChildren
{
  outfile=$1
  repoRoot=$2
  if [[ ! -d ${repoRoot} ]]
  then
    echo -e "\n[ERROR] repoRoot did not exist when passed into writeChildren." 
    echo -e "\t${repoRoot}"
    exit 1
  fi
  checkpoint=$3
  if [[ -z ${checkpoint} ]]
  then
    echo -e "\n[ERROR] checkpoint was not defined to writeChildren." 
    echo -e "\t${checkpoint}"
    exit 1
  fi
  # NOTE: we always take "most recent 3 builds" 
  # EXCEPT when we are doing a "final release". This especially matters for
  # "update releases" since we then we will eventually have more than 3 "dated directory"
  # and in that case we want them all, not just most recent 3.
  # This leads to a *hard assumption* that we name release checkpoints as "R[0..0]", such as 
  # R0 for initial release of "neon", R1 for "neon.1", etc. 
  # For the main stream development, we typically use M[1..9] for milestones, 
  # and RC[0-9] for Release candidates. But we make not assumption there, 
  # as long as it is not R[0-9].
  # We use "20" as a prefix to match for all our child repo directories to start with 
  # such as "2016...". So, in 80 years will need some maintenance. :) 
  # But, otherwise, this cheap heuristic would find existing files such as "composite*" files, 
  # which would be very wrong.
  pushd "${repoRoot}" >/dev/null
  if [[ $checkpoint ~= ^R([0-9])$ ]]
  then
    nChildren=${BASH_REMATCH[1]}
    nChildren=$((nChildren + 1))
    children=$(ls -1td 20*) | head -${nChildren}
    echo -e "\n\t[INFO] Note that checkpoint, $checkpoint, was found to be a final release"
    echo -e "\t       and nChildren computed to be $nChildren\n"
  else
    children=$(ls -1td 20* | head -3)
    echo -e "\n\t[INFO] Note that checkpoint, $checkpoint, was NOT found to be a final release"
    echo -e "\t       so nChildren was assumed to be '3'\n"
  fi
  popd >/dev/null

  for child in $children
  do
    printf "%s%s%s\n" "    <child location='" $child "' />"  >> ${outfile}
  done

}

stream=$1
checkpoint=$2
if [[ -z $stream ]]
then
  echo -e "\n[ERROR] The variable 'stream' was not passed to the writeComposites script"
  exit $RC
fi
if [[ -z $checkpoint ]]
then
  echo -e "\n[ERROR] The variable 'checkpoint' was not passed to the writeComposites script"
  exit $RC
fi
repoRoot="/home/data/httpd/download.eclipse.org/releases/${stream}"
# Normally "writeRepoRoots" is the same as "repoRoots", but might not always be, 
# plus it is very handy for testing this script not to have to write 
# to the "production" area.
# similarly, for some testing/debugging cases it is 
# handiest to execute from current directory, if WORKSPACE
# is not defined already. We can leave in this line, since 
# it will always be defined on Hudson. 
WORKSPACE=${WORKSPACE:-${PWD}}
#  writeRepoRoot="${PWD}/$stream"
# This is the "real" place to write results.
writeRepoRoot="${repoRoot}"

#echo -e "\n[DEBUG] writeRepoRoot: ${writeRepoRoot}"
mkdir -p "${writeRepoRoot}"
RC=$?
if [[ $RC != 0 ]]
then
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
p2Index="${writeRepoRoot}/p2.index"

writeArtifactsHeader "${artifactsCompositeFile}" ${stream}
writeChildren "${artifactsCompositeFile}" "${repoRoot}"
writeFooter "${artifactsCompositeFile}"

writeContentHeader "${contentCompositeFile}" ${stream}
writeChildren "${contentCompositeFile}" "${repoRoot}"
writeFooter "${contentCompositeFile}"

# We go ahead and re-write the file, since even if it 
# exists already, we do not know what its contents are.
writeCompositeP2Index "${p2Index}"

zip -q --junk-paths "${artifactsCompositeJar}" "${artifactsCompositeFile}"
zip -q --junk-paths "${contentCompositeJar}" "${contentCompositeFile}"

# Since these files are in "workspace", we would not *have* to delete them, 
# but seems best to, to avoid looking at them. 
rm ${contentCompositeFile} ${artifactsCompositeFile}

