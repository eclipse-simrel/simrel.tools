#!/usr/bin/env bash
FAIL_ON_ERROR=false      
source aggr_properties.shsource

if [ -z "${toDirectory}" ] 
then
    toDirectory=${stagingDirectory}  
fi  

echo "repository file statistics for ";
echo $toDirectory;

if [ ! -e "${toDirectory}" ]
then
    echo "repository directory does not exist. "
    if [[ "$FAIL_ON_ERROR" == "true" ]]
    then
        echo "   Exiting."  
        exit 1;
    fi
fi

featuresDirectory="${toDirectory}"${AGGR}/features
pluginsDirectory="${toDirectory}"${AGGR}/plugins

if [ ! -e "${featuresDirectory}" ]
then 
    echo "repository features directory structure not as expected." 
    if [[ "$FAIL_ON_ERROR" == "true" ]]
    then
        echo "   Exiting."  
        exit 1;
    fi
fi

if [ ! -e "${pluginsDirectory}" ]
then 
    echo "repository plugins directory structure not as expected."
    if [[ "$FAIL_ON_ERROR" == "true" ]]
    then
        echo "   Exiting."  
        exit 1;
    fi
fi

echo "Features: ";     
find "${featuresDirectory}" | wc -l  
du -sh "${featuresDirectory}"

echo "Plugin jar files: ";
find "${pluginsDirectory}" -name "*.jar" | wc -l 
du -sh --exclude=*.pack.gz "${pluginsDirectory}"

echo "Plugin pack.gz files: "; 
find "${pluginsDirectory}" -name "*jar.pack.gz" | wc -l
du -sh --exclude=*.jar "${pluginsDirectory}"

exit 0

