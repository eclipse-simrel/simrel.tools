#!/bin/bash

P2_REPO_DIR=${1:-/home/data/httpd/download.eclipse.org/releases/neon/201610111000}
OUTPUT_FILE=${2:-doc_plugin_list.txt}

printf "Looking up all JAR files that contain the string 'org.eclipse.help.toc'...\n"
printf "Using the following P2 repository: $P2_REPO_DIR \n"
printf "Output file: $OUTPUT_FILE \n"

NO_OF_FILES=`ls -l $P2_REPO_DIR/plugins/*.jar | wc -l`
printf "Found $NO_OF_FILES JAR files.\n"

if [ -f $OUTPUT_FILE ]; then
  echo "Removing previous output file $OUTPUT_FILE..."
  rm $OUTPUT_FILE
fi

start=`date +%s`
for file in $P2_REPO_DIR/plugins/*.jar; do
if [[ ${file} != *"source_"* ]];then
#   if ( unzip -c "$file" | grep -q "org.eclipse.help.toc"); then
    if ( unzip -p "$file" plugin.xml 2>&1 | grep -q "org.eclipse.help.toc"); then
        echo "$file" >> $OUTPUT_FILE
    fi
fi
done
end=`date +%s`
runtime=$((end-start))

printf "Done in $runtime seconds\n"