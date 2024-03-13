#!/bin/bash

function getGitDefaultTag {
  _VERSION="$1"
  _FILE="$2"
  git clone https://github.com/maldua/zimbra-tag-helper
  cd zimbra-tag-helper
  ./zm-build-tags-arguments.sh ${_VERSION} > ../${_FILE}
  cd ..

}

ZM_BUILD_RELEASE_NO="$1" # E.g. 10.0.7
ZM_BUILD_BRANCH="10.0.6"

ZM_BUILD_GIT_DEFAULT_TAG_FILE="git-default-tag.txt"
getGitDefaultTag ${ZM_BUILD_RELEASE_NO} ${ZM_BUILD_GIT_DEFAULT_TAG_FILE}
ZM_BUILD_GIT_DEFAULT_TAG="$(cat ${ZM_BUILD_GIT_DEFAULT_TAG_FILE})"

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
