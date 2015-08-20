#!/usr/bin/env bash

release=$1
datetimestamp=$2

if [ -z $datetimestamp ] ; then
    echo "ERROR: 'datetimestamp' directory variable is required for this script.";
    exit 1;
fi

if [[ -z "${release}" ]]
then
    echo
    echo "   ERROR: The 'release' environment variable is required for this script."
    echo
    exit 1
else
    echo
    echo "release: ${release}"
    echo
fi

source promote.shsource

APP_NAME=org.eclipse.wtp.releng.tools.addRepoProperties

devworkspace="${BUILD_HOME}/addRepoPropertiesWorkspace"

devJRE=${JAVA_HOME}/jre/bin/java

ibmDevArgs="-Xms128M -Xmx256M -Dosgi.ws=gtk -Dosgi.os=linux -Dosgi.arch=x86"


# remember, the '&' should be unescaped here ... the p2 api (or underlying xml) will escape it.
devArgs="$ibmDevArgs -Dp2MirrorsURL=http://www.eclipse.org/downloads/download.php?format=xml&file=/releases/${release}/${datetimestamp} -DartifactRepoDirectory=${REPO_ROOT}/releases/${release}/${datetimestamp} -Dp2StatsURI=http://download.eclipse.org/stats/releases/${release} -Dp2ArtifactRepositoryName=${release}/${datetimestamp}"

echo "dev:          " $0
echo
echo "release:      " $release
echo
echo "datetimestampe: " $datetimestamp
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

${ECLIPSE_EXE}   -debug -nosplash -consolelog -console -data $devworkspace --launcher.suppressErrors -application ${APP_NAME} ${OTHER_ARGS} -vm $devJRE -vmargs $devArgs

