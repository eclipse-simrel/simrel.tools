#!/bin/bash
#
# Utility, originally from  Matthias Sohn (bug 450186), to check who has
# committed to "simrel.build" repo, but then has not, for one year.
# Part of a routine yearly process to remove inactive committers from
# callisto-dev.
#
# In general, besides these "commit records" some people want to be left on,
# as "backups" for their projects.
# And, a few cases of "people recently added" so they would not have had time
# yet to commit.
#
# For 2014 effort, in November/December of 2014, see
#    https://bugs.eclipse.org/bugs/show_bug.cgi?id=450186
#
#
# This script can be ran in an "complete clone" of org.eclipse.simrel.build.

# Note that this script will not capture those in the "calisto-dev"
# group who have never contributed to the "git repo".

# Note too, that in future, it will continue to "re-find" people who hae been removed already,
# from callisto-dev. May want to adjust "authors" to be "only authors since November, 2013,
# since any prior to that will have been "dealt with" already? And/or find a better way
# to automate this "git listing" with the "listing" of ids from callisto-dev list.

BUILD_DIR=/home/davidw/gitsimrel/org.eclipse.simrel.build
SCRIPT_DIR=/home/davidw/gitsimrel/org.eclipse.simrel.tools/reportUtilities

pushd $BUILD_DIR

allauthors() { git shortlog --all -sen | cut -s -f2 | sort; }
authors() { git shortlog --all -sn | cut -s -f2 | sort; }
lastyear() { git shortlog --all -sn --since="1 year ago" | cut -s -f2 | sort; }

# allauthors is used, instead of authors, to write a temporary file, allauthors.txt,
# that can be used to improve the .mailmap file,
# which is in root of repository, and makes sure the mistakes or changes
# in names or emails get mapped to just one name and email. Having a good
# .mailmap file improves the "final output" quite a bit. Otherwise, the report may show
# same person on both active and inactive lists, and other anomilies, depending on which id they
# used for the commit.

# get "date of run" for putting in files.
now=$( date --utc +%s )

ALL_AUTHORS_FILE=$SCRIPT_DIR/allauthors.txt

echo -e "\n\t\tReport as of  $( date --utc -d @$now ) \n" >$ALL_AUTHORS_FILE
allauthors >> $ALL_AUTHORS_FILE


COMMITTER_LIST_FILE=$SCRIPT_DIR/committerList.txt
echo -e "\n\t\tReport as of  $( date --utc -d @$now ) \n" >$COMMITTER_LIST_FILE
echo "Active during last year" >>$COMMITTER_LIST_FILE
echo "=======================" >>$COMMITTER_LIST_FILE
lastyear >>$COMMITTER_LIST_FILE
echo >>$COMMITTER_LIST_FILE
echo "Inactive during last year" >>$COMMITTER_LIST_FILE
echo "=========================" >>$COMMITTER_LIST_FILE

comm -13 <(lastyear) <(authors) >>$COMMITTER_LIST_FILE
echo -e "\n\t\tOutput written to $COMMITTER_LIST_FILE"

