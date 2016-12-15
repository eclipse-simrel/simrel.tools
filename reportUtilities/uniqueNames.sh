#!/usr/bin/env bash

# TODO: This doesn't work well, because even limiting to "10 characers", there
# is some names followed by blanks, others not.

cat callisto-dev-ed.txt committerListGit.txt > combined.txt
sort combined.txt > sortedCombined.txt


uniq -u -w 10 sortedCombined.txt unique.txt


