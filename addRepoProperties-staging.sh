#!/usr/bin/env bash

if [[ -z "${release}" | -z "${stagingsegment}" ]]
then
    echo 
    echo "   ERROR: The 'release' and 'stagingsegment' environment much be specified for this script. For example,"
    echo "   release=juno stagingsegment=maintenance ./$( basename $0 )"
    echo
    exit 1
else
    echo
    echo "release: ${release}"
    echo "stagingsegment: ${stagingsegment}"
    echo
fi

source aggr_properties.shsource

APP_NAME=org.eclipse.wtp.releng.tools.addRepoProperties

devworkspace="${BUILD_HOME}"/addRepoPropertiesWorkspace

devJRE=${JAVA_6_HOME}/jre/bin/java

ibmDevArgs="-Xms128M -Xmx256M -Dosgi.ws=gtk -Dosgi.os=linux -Dosgi.arch=x86" 


# remember, the '&' should be unescaped here ... the p2 api (or underlying xml) will escape it. 
devArgs="$ibmDevArgs -Dp2MirrorsURL=http://www.eclipse.org/downloads/download.php?format=xml&file=/releases/${stagingsegment}${AGGR}/ -DartifactRepoDirectory=/home/data/httpd/download.eclipse.org/releases/${stagingsegment}${AGGR}/ -Dp2StatsURI=http://download.eclipse.org/stats/releases/${stagingsegment}"

echo "dev:          " $0
echo
echo "devworkspace: " $devworkspace
echo
echo "devJRE:       " $devJRE
echo
echo "devArgs:      " $devArgs
echo
echo "APP_NAME:     " $APP_NAME
$devJRE -version
echo


${ECLIPSE_EXE} -debug -nosplash -consolelog -console -data $devworkspace --launcher.suppressErrors -application ${APP_NAME} ${OTHER_ARGS} -vm $devJRE -vmargs $devArgs

