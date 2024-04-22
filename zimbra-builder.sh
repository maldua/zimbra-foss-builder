#!/bin/bash

ZM_BUILD_RELEASE_NO_WITH_PATCH="$1" # E.g. 10.0.7p0
ZM_BUILD_BRANCH="$2" # E.g. 10.0.6
ZM_BUILD_GIT_DEFAULT_TAG="$3" # E.g. '10.0.7,10.0.6,10.0.5,10.0.4,10.0.3,10.0.2,10.0.1,10.0.0-GA,10.0.0'
ZM_BUILDER_ID_ARG="$4" # E.g. '430'

if [ "x" == "x${ZM_BUILD_RELEASE_NO_WITH_PATCH}" ] ; then
  echo "ZM_BUILD_RELEASE_NO_WITH_PATCH is not defined."
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

# Force default manual value (430)
if [ "x" == "x${ZM_BUILDER_ID_ARG}" ] ; then
  ZM_BUILDER_ID_ARG="430"
fi

if ! [[ "${ZM_BUILDER_ID_ARG}" =~ ^[0-9]+$ ]] ; then
  echo "ZM_BUILDER_ID must be a number."
  exit 1
fi

ZM_BUILDER_ID=$((ZM_BUILDER_ID_ARG))

if ! [[ ${ZM_BUILDER_ID} -ge 100 ]] ; then
  echo "ZM_BUILDER_ID must be greater than or equal to 100."
  exit 1
fi

if ! [[ ${ZM_BUILDER_ID} -le 999 ]] ; then
  echo "ZM_BUILDER_ID must be less than or equal to 999."
  exit 1
fi

function get_build_release_candidate() {

  _ZM_BUILD_RELEASE_NO_WITH_PATCH="$1"

  _BUILD_RELEASE_CANDIDATE="GA"
  if echo ${_ZM_BUILD_RELEASE_NO_WITH_PATCH} | grep -i 'beta' > /dev/null 2>&1 ; then
    _BUILD_RELEASE_CANDIDATE="BETA"
  fi

  echo ${_BUILD_RELEASE_CANDIDATE}

}

BUILD_RELEASE_CANDIDATE="$(get_build_release_candidate ${ZM_BUILD_RELEASE_NO_WITH_PATCH})"

ZM_BUILD_RELEASE_NO_TMP1="${ZM_BUILD_RELEASE_NO_WITH_PATCH%.[pP]*}"
ZM_BUILD_RELEASE_NO="${ZM_BUILD_RELEASE_NO_TMP1%.[bB][eE][tT][aA]}"

cd installer-build

cat << EOF > BUILDS/zimbra-builder-commands.txt
git clone --depth 1 --branch ${ZM_BUILD_BRANCH} git@github.com:Zimbra/zm-build.git
cd zm-build
ENV_CACHE_CLEAR_FLAG=true ./build.pl --ant-options -DskipTests=true --git-default-tag=${ZM_BUILD_GIT_DEFAULT_TAG} --build-release-no=${ZM_BUILD_RELEASE_NO} --build-type=FOSS --build-release=LIBERTY --build-release-candidate=${BUILD_RELEASE_CANDIDATE} --build-thirdparty-server=files.zimbra.com --no-interactive
EOF

git clone --depth 1 --branch ${ZM_BUILD_BRANCH} git@github.com:Zimbra/zm-build.git
cd zm-build
ENV_CACHE_CLEAR_FLAG=true ./build.pl --ant-options -DskipTests=true --git-default-tag=${ZM_BUILD_GIT_DEFAULT_TAG} --build-release-no=${ZM_BUILD_RELEASE_NO} --build-type=FOSS --build-release=LIBERTY --build-release-candidate=${BUILD_RELEASE_CANDIDATE} --build-thirdparty-server=files.zimbra.com --no-interactive
