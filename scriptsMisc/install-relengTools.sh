#!/usr/bin/env bash

APP_NAME=org.eclipse.equinox.p2.director

OTHER_ARGS="-metadataRepository http://download.eclipse.org/webtools/releng/repository/ -artifactRepository http://download.eclipse.org/webtools/releng/repository/ -installIU org.eclipse.wtp.releng.tools.feature.feature.group"

devworkspace=./workspace

# Java should be configured per machine, 
# so this variable point to valid installs
# we "share" with orbits versions
JAVA_5_HOME=/home/shared/orbit/apps/ibm-java2-i386-50
JAVA_6_HOME=/home/shared/orbit/apps/ibm-java-i386-60
JAVA_HOME=${JAVA_6_HOME}
devJRE=$JAVA_HOME/jre/bin/java

ibmDevArgs="-Xms128M -Xmx256M -Dosgi.ws=gtk -Dosgi.os=linux -Dosgi.arch=x86" 

devArgs=$ibmDevArgs

echo "dev:          " $0
echo
echo "devworkspace: " $devworkspace
echo
echo "devJRE:       " $devJRE
echo "OTHER_ARGS:   " ${OTHER_ARGS}
echo
$devJRE -version
echo

ECLIPSE_INSTALL=/home/shared/webtools/apps/eclipse36RC3/eclipse

$ECLIPSE_INSTALL/eclipse  -debug -nosplash -consolelog -console -data $devworkspace -application ${APP_NAME} ${OTHER_ARGS} -vm $devJRE -vmargs $devArgs

