#!/usr/bin/env bash
FAIL_ON_ERROR=false

# remember to leave no slashes on first filename in source command,
# so that users path is used to find it (first, if it exists)
# variables that user might want/need to override, should be defined, 
# in our own aggr_properties.shsource using the X=${X:-"xyz"} syntax.
source aggr_properties.shsource 2>/dev/null
source ${BUILD_HOME}/org.eclipse.simrel.tools/aggr_properties.shsource

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

featuresDirectory="${toDirectory}/features"
pluginsDirectory="${toDirectory}/plugins"

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

