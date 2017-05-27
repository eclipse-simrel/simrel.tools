#!/usr/bin/env bash

# In this example utility, we make use of the "fetchAndbuild.xml" file.
# It would likely need some "adjustment" to some variables 
# for others to use from their own command line. 

export BUILD_HOME=${PWD}/BUILDAREA
mkdir -p ${BUILD_HOME}
# This is there we will "tee" the output of the ant command.
buildOutput=${BUILD_HOME}/buildoutput$( date +%Y%m%d-%H%M).log.txt

# Assuming nothing else, we start by getting one file which
# can bootstrap the whole process. getSimRelTools.sh will either
# clone or pull the "org.eclipse.simrel.tools" project which 
# then contains the other utilities and files needed to do the 
# aggregation build from the command line.

# set getTools to false if tools already exists, with local modifications
getTools=${getTools:-"true"}
if [[ ${getTools} == "true" ]]
then
  wget --no-verbose -O ${BUILD_HOME}/getSimRelTools.sh http://git.eclipse.org/c/simrel/org.eclipse.simrel.tools.git/plain/bootstrapScript/getSimRelTools.sh 2>&1
  RC=$?
  if [[ $RC != 0 ]]
  then
    printf "\n[ERROR] wget returned non-zero return code: $RC. Exiting"
    exit 1
  fi
  chmod +x ${BUILD_HOME}/getSimRelTools.sh
  RC=$?
  if [[ $RC != 0 ]]
  then
    printf "\n[ERROR] chmod returned non-zero return code: $RC. Exiting"
    exit 1
  fi
  ${BUILD_HOME}/getSimRelTools.sh
  RC=$?
  if [[ $RC != 0 ]]
  then
    printf "\n[ERROR] getSimRelTools.sh returned non-zero return code: $RC. Exiting"
    exit 1
  fi
else
  printf "\n[INFO] 'getTools' was set to false, so simrel.tools not fetched."
fi

# We require Java to be version 8 and Ant to be at least "1.8".
# (And, for example, the defaults on "build.eclipse.org" are still
# set at Java 6 and Ant 1.7!) These may not be needed if your 
# personal machine has the defaults required.

#export JAVA_HOME=/shared/common/jdk1.8.0_x64-latest
#export ANT_HOME=/shared/common/apache-ant-1.8.2
#export PATH=${JAVA_HOME}/jre/bin:${ANT_HOME}/bin/:$PATH

#
# In addition to using the getModelFromGit target on ant command line, 
#   One of the following "aggregation targets" can be specified.
#   (Actually, if none specified, runAggregatorValidateOnly is the default.)
# runAggregatorValidateOnly
# runAggregatorBuildOnly
# runAggregatorCleanBuild
#
# In addition to the targets, the following are some handy parameters which 
# may be specified to override the defaults.
#  -DplatformLocation=file:///absolutePath/ofLocal/PlatformBinary.tar.gz
#     The scripts must be able to find a standard "Eclipse Platform" to install into.
#     The default is what it would be if running on the Eclipse.org infrastructure, so 
#     if running locally this value (correct location of local version) will need to be provided.
# -Drelease=oxygen
#     The 'release' value is typically required, even if building against 'master',
#     since its "correct" value would change from year to year.
#     While we could "assume" a value, if the value is wrong, it has the potential 
#     to "damage" data in staging repo (i.e. replaces with wrong thing), hence
#     we require it to be explicit.
# -DBUILD_BRANCH=Neon_maintenance
#     'BUILD_BRANCH' is assumed to be "master" unless overridden on command line.
#     The value of 'release' should of course match whatever branch is being built.
# -DinstallEclipseAndTools
#    'installEclipseAndTools' causes Eclipse, the aggregator, wtp releng tools, and the p2repo analyzer tools
#    to be reinstalled, if already present. (They are always installed, if "eclipse" is not
#    installed to begin with.)
# -Dgit_protocol=file://
#    'git_protocol' specifies an alternative way to "get" the git repositories of the 'simrel.build' and 'simrel.tools'. 
#    Can be slightly more efficient and reliable to use direct file access instead
#    of the default of "git://git.eclipse.org".
# -DrewriteRepositoryURLValue=file:///home/data/httpd/download.eclipse.org
#    'rewriteRepositoryURLValue' is, again, a way to specify the file protocol be used, 
#    but in this case is is for the input that comes from the *.aggr* files in 'simrel.build'.
#    Using the parameter assumes, of course, you really do have "file" access, such as if 
#    running on build.eclipse.org, or running against a local mirror of that 'simrel.build' repo.

ant -f ${BUILD_HOME}/org.eclipse.simrel.tools/fetchAndbuild.xml \
  -DBUILD_HOME=${BUILD_HOME} \
  -DplatformLocation=file:///home/data/httpd/archive.eclipse.org/eclipse/downloads/drops4/R-4.6.3-201703010400 \
  -Drelease=oxygen \
  getModelFromGit runAggregatorValidateOnly 2>&1 | tee ${buildOutput}
