#!/bin/bash
set +xv
echo "
date      : `date`
hostname  : `hostname`
pwd       : `pwd`

--------------------------
 Jenkins build parameters
 --------------------------
 BRANCH_TO_BUILD   : ${BRANCH_TO_BUILD}
 RELEASE_TO_BUILD  : ${RELEASE_TO_BUILD}
 INRIA_FORGE_LOGIN : ${INRIA_FORGE_LOGIN}
 TEST_VARIABLE     : ${TEST_VARIABLE}
 DEBUG             : ${DEBUG}
 "

 [ "$DEBUG" != "true" ] && { set -e ; } || { echo "DEBUG mode, the script will NOT stop..." ; }
 set -xv

 ################################################################
 #                       COMPILATION                            #
 ################################################################

 gcc --version
 g++ --version
 sw_vers -productVersion

 JENKINS_TASK=finalize-release-macos
 ROOT_DIR=/builds/workspace/$JENKINS_TASK/

 rm -rf $ROOT_DIR
 mkdir -p $ROOT_DIR

 cd $ROOT_DIR
 git clone git+ssh://${INRIA_FORGE_LOGIN}@scm.gforge.inria.fr/gitroot/gatb-core/gatb-core.git 
 cd gatb-core
 git checkout $BRANCH_TO_BUILD
 cd gatb-core   # this level should be removed soon


 MAJOR="`echo $RELEASE_TO_BUILD |cut -d. -f1`"
 MINOR="`echo $RELEASE_TO_BUILD |cut -d. -f2`"
 PATCH="`echo $RELEASE_TO_BUILD |cut -d. -f3`"

 #----------
 # upload below only perform tasks 1, 2, and 5 (see make_official_release.sh -h):
 #     1 . compile the library on the hosted system using curent source code
 #     2 . package library within a tar.gz file
 #    (3). tag Inria Forge using release number
 #    (4). create a corresponding Github release
 #     5 . upload the library binary on Github

 /bin/bash -xv ./scripts/make_official_release.sh -s -M $MAJOR -m $MINOR -p $PATCH -c upload
