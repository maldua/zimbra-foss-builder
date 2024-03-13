#!/bin/bash

ZM_BUILD_RELEASE_NO="$1" # E.g. 10.0.7
ZM_BUILD_BRANCH="10.0.6"
ZM_BUILD_GIT_DEFAULT_TAG="10.0.7,10.0.6,10.0.5,10.0.4,10.0.3,10.0.2,10.0.1,10.0.0-GA,10.0.0"

if [ "x" == "x${ZM_BUILD_RELEASE_NO}" ] ; then
  echo "ZM_BUILD_RELEASE_NO is not defined."
  exit 1
fi

if [ "x" == "x${ZM_BUILD_BRANCH}" ] ; then
  echo "ZM_BUILD_BRANCH is not defined."
  exit 1
fi

if [ "x" == "x${ZM_BUILD_GIT_DEFAULT_TAG}" ] ; then
  echo "ZM_BUILD_GIT_DEFAULT_TAG is not defined."
  exit 1
fi

/usr/local/zimbra-foss-builder/zimbra-builder.sh ${ZM_BUILD_RELEASE_NO} ${ZM_BUILD_BRANCH} ${ZM_BUILD_GIT_DEFAULT_TAG}
