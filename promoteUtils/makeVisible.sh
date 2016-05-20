#!/usr/bin/env bash

# Small utility to more automatically do the renames the morning of "making visible", 
# after artifacts have mirrored. In theory, could be done by a cron or at job. 
#
# Note, copy is used, instead of move, so that the parent directory's "modified time" does not change. 
# That way the mirroring script won't falsely report "no mirrors" (for a while). 
# 
# Plus, we "copy over" any existing files, under the assumption that previous labeled files are left in place, 
# for a while, so they'd serve as backup. If that ever changes, should make a --backup of 
# the original files ... just in case ... but then modified time of parent directory would be 
# changed.
#
# And notice we do "artifacts" first, so by the time "content" can be retrieved, by p2, thre will be 
# valid artifacts "pointed to". If anyone has already fetched 'content' and in the middle of getting 
# artifacts, their downloads should nearly always continue to work (except we do keep only 3 milestones
# in composite, so in theory, they might have stale 'content' data that pointed to an old artifact that 
# was no longer in (the newly copied) 'artifacts' file. 

function usage ()
{
    printf "\n\t%s\n" "This utility is to copy the two composte*XX.jars to their final name of composite*.jar." >&2
    printf "\n\t%s\n" "The first (and only) argument is expected to be the pre-visibility label given to the composite files," >&2
    printf "\t%s\n\n" "such as M4, RC1, etc." >&2
}

if [[ ! $# = 1 ]]
then
    usage
    exit 1
fi

LABEL=$1

if [[ -z "${LABEL}" ]]
then
    # presumably this would occur if ever called from another script, with an error in it. 
    # That is, don't think humans would type ./makevisible.sh "" ?
    printf "\n\t%s\n" "ERROR: first argument was an empty string?! " >&2
    usage
    exit 1
fi
REPO_ROOT=/home/data/httpd/download.eclipse.org/releases/neon

cp --verbose ${REPO_ROOT}/compositeArtifacts${LABEL}.jar ${REPO_ROOT}/compositeArtifacts.jar
cp --verbose ${REPO_ROOT}/compositeContent${LABEL}.jar   ${REPO_ROOT}/compositeContent.jar

# I don't think these exist an more?
if [[ -e ${REPO_ROOT}/index${LABEL}.html ]]
then
    cp --verbose ${REPO_ROOT}/index${LABEL}.html ${REPO_ROOT}/index.html
fi

