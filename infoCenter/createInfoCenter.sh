#!/bin/sh
# This script requires the following files to be present in the same dir:
# * get_jars.sh
# * find_jars.sh
# * plugin_customization.ini

set -e

# Parameter:
# $1 = release name (e.g. neon, oxygen)
# $2 = path to platform zip (e.g. M-4.6.2RC3-201611241400/eclipse-platform-4.6.2RC3-linux-gtk-x86_64.tar.gz)
RELEASE_NAME="$1"
ZIP_PATH="$2"
P2_REPO_DIR="$3"
LEGACY_MODE=${4:-'false'}

#HELP_HOME=/home/data/httpd/help.eclipse.org/
HELP_HOME=.
WORKDIR=$HELP_HOME/$RELEASE_NAME
DOWNLOADDIR=/home/data/httpd/download.eclipse.org/eclipse/downloads/drops4
SCRIPT_NAME="$(basename ${0})"
BANNER_FILE=org.foundation.helpbanner2_2.0.0.jar

usage() {
  printf "Usage %s [releaseName] [pathToArchive] [p2RepoDir] [legacyMode]\n" "${SCRIPT_NAME}"
  printf "\t%-16s the release name (e.g. neon, neon1, oxygen, oxygen1)\n" "releaseName"
  printf "\t%-16s the path to eclipse-platform archive (e.g. M-4.6.2RC3-201611241400/eclipse-platform-4.6.2RC3-linux-gtk-x86_64.tar.gz)\n" "pathToArchive"
  printf "\t%-16s the path to the P2 repo (e.g. /home/data/httpd/download.eclipse.org/releases/neon/201610111000) (optional)\n" "p2RepoDir"
  printf "\t%-16s set to 'true' to use legacy mode (default is 'false') (optional)\n" "legacyMode"
}

# Verify inputs
[[ -z "$RELEASE_NAME" && $# -lt 1 ]] && {
  printf "ERROR: a release name must be given.\n"
  usage
  exit 1
}

[[ -z "$ZIP_PATH" && $# -lt 2 ]] && {
  printf "ERROR: a path to the eclipse-platform archive must be given.\n"
  usage
  exit 1
}

# Create new sub directory for info center
echo "Create sub directory for new info center..."
if [ ! -d "$WORKDIR" ]; then
  mkdir -p $WORKDIR
fi
# TODO: exit when sub directory already exists?


# Copy/download eclipse-platform
echo "Downloading eclipse-platform..."
if [ ! -f $WORKDIR/eclipse-platform*.tar.gz ]; then
  cp $DOWNLOADDIR/$ZIP_PATH .
fi

# Extract eclipse-platform
tar xzf eclipse-platform*.tar.gz -C $WORKDIR

# Copy eclipse/plugin_customization.ini
echo "Copying plugin_customization.ini..."
cp plugin_customization.ini $WORKDIR/eclipse/

# Create dropins/plugins dir
echo "Create dropins/plugins dir..."
mkdir -p $WORKDIR/eclipse/dropins/plugins

# Add custom banner
echo "Add custom banner..."
cp $BANNER_FILE $WORKDIR/eclipse/dropins/plugins

# Find org.eclipse.help.base
echo "Locating org.eclipse.help.base..."
HELP_BASE_PATH=`find $WORKDIR -name "org.eclipse.help.base*.jar"`
echo "Found $HELP_BASE_PATH."
substring_tmp=${HELP_BASE_PATH#.*_}
HELP_BASE_VERSION=${substring_tmp%.jar}
echo "Found base version $HELP_BASE_VERSION."

# Find doc JARs
echo "Find doc JARs..."
if [[ $LEGACY_MODE == 'true' ]]; then
  # Run get_jars.sh (legacy)
  echo "Executing get_jars.sh (LEGACY MODE)... "
  ./get_jars.sh $WORKDIR/eclipse/dropins/plugins
else
  echo "Executing find_jars.sh (P2_REPO_DIR: $P2_REPO_DIR)..."
  filename=doc_plugin_list.txt
  ./find_jars.sh $P2_REPO_DIR
  while read line; do
    cp $line $WORKDIR/eclipse/dropins/plugins
  done < $filename
fi

PORT=8086

# Create start script
echo "Create start and stop scripts..."
echo "java -Dhelp.lucene.tokenizer=standard -Dorg.eclipse.equinox.http.jetty.context.sessioninactiveinterval=60 -classpath eclipse/plugins/org.eclipse.help.base_$HELP_BASE_VERSION.jar org.eclipse.help.standalone.Infocenter -clean -command start -eclipsehome eclipse -port $PORT -nl en -locales en -plugincustomization eclipse/plugin_customization.ini -vmargs -Xmx1024m -XX:+HeapDumpOnOutOfMemoryError &" > $WORKDIR/startInfoCenter.sh

# Create stop script
echo "java -classpath eclipse/plugins/org.eclipse.help.base_$HELP_BASE_VERSION.jar org.eclipse.help.standalone.Infocenter -clean -command shutdown -eclipsehome eclipse -port $PORT 2>&1" > $WORKDIR/stopInfoCenter.sh

chmod +x $WORKDIR/*InfoCenter.sh

# Create tar.gz
if [ -f info-center-$RELEASE_NAME.tar.gz ]; then
  rm info-center-$RELEASE_NAME.tar.gz
fi
echo "Creating info center archive..."
tar czf info-center-$RELEASE_NAME.tar.gz $WORKDIR


printf "Done.\n"