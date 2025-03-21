#!/bin/bash

ZM_BUILD_RELEASE_NO_WITH_PATCH="$1" # E.g. 10.0.7p0
ZM_BUILD_BRANCH="$2" # E.g. 10.0.6
ZM_BUILD_GIT_DEFAULT_TAG="$3" # E.g. '10.0.7,10.0.6,10.0.5,10.0.4,10.0.3,10.0.2,10.0.1,10.0.0-GA,10.0.0'
ZM_BUILDER_ID_ARG="$4" # E.g. '430'
ZM_BUILD_PIMBRA_ENABLED="$5" # E.g. 'pimbra-enabled'

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

function get_build_no() {

  _ZM_BUILD_RELEASE_NO_WITH_PATCH="$1"
  _ZM_BUILDER_ID_ARG="$2"
  _ZM_BUILDER_ID=$((_ZM_BUILDER_ID_ARG))

  _PATCH_LEVEL_STR=""

  if [[ "${_ZM_BUILD_RELEASE_NO_WITH_PATCH}" =~ ^.*.[pP].*$ ]] ; then
    _PATCH_LEVEL_STR="${_ZM_BUILD_RELEASE_NO_WITH_PATCH##*.[pP]}"
  fi

  if [ "x" == "x${_PATCH_LEVEL_STR}" ] ; then
    _PATCH_LEVEL_STR="0"
  fi

  if ! [[ "${_PATCH_LEVEL_STR}" =~ ^[0-9]+$ ]] ; then
    echo "FATAL. At this point the patch level (${_PATCH_LEVEL_STR}) must be a number."
    exit 1
  fi

  _PATCH_LEVEL=$((_PATCH_LEVEL_STR))

  _BUILD_NO_TMP1=$((_ZM_BUILDER_ID * 10000))   # E.g. 4200000
  _BUILD_NO=$((_BUILD_NO_TMP1 + _PATCH_LEVEL)) # E.g. 4200039

  echo ${_BUILD_NO}

}

BUILD_RELEASE_CANDIDATE="$(get_build_release_candidate ${ZM_BUILD_RELEASE_NO_WITH_PATCH})"

ZM_BUILD_RELEASE_NO_TMP1="${ZM_BUILD_RELEASE_NO_WITH_PATCH%.[pP]*}"
ZM_BUILD_RELEASE_NO="${ZM_BUILD_RELEASE_NO_TMP1%.[bB][eE][tT][aA]}"

BUILD_NO="$(get_build_no ${ZM_BUILD_RELEASE_NO_WITH_PATCH} ${ZM_BUILDER_ID})"

cd installer-build

cat << EOF > BUILDS/zimbra-builder-commands.txt
git clone --depth 1 --branch ${ZM_BUILD_BRANCH} git@github.com:Zimbra/zm-build.git
cd zm-build
ENV_CACHE_CLEAR_FLAG=true ./build.pl --ant-options -DskipTests=true --git-default-tag=${ZM_BUILD_GIT_DEFAULT_TAG} --build-release-no=${ZM_BUILD_RELEASE_NO} --build-type=FOSS --build-release=LIBERTY --build-release-candidate=${BUILD_RELEASE_CANDIDATE} --build-no ${BUILD_NO} --build-thirdparty-server=files.zimbra.com --no-interactive
EOF

if [ "pimbra-enabled" == "${ZM_BUILD_PIMBRA_ENABLED}" ] ; then
  wget 'https://github.com/maldua-pimbra/maldua-pimbra-config/raw/refs/tags/'"${ZM_BUILD_RELEASE_NO}"'/config.build'
  if [[ $? -ne 0 ]] ; then
    echo "ERROR: Pimbra config file cannot be downloaded for ${ZM_BUILD_RELEASE_NO} version !"
    echo "Aborting !!!"
    exit 2
  fi
fi

if [ "pimbra-enabled" == "${ZM_BUILD_PIMBRA_ENABLED}" ] ; then
  cat << EOF >> BUILDS/zimbra-builder-commands.txt
# config.build contents:
EOF
  cat config.build >> BUILDS/zimbra-builder-commands.txt
fi

git clone --depth 1 --branch ${ZM_BUILD_BRANCH} git@github.com:Zimbra/zm-build.git
cd zm-build
ENV_CACHE_CLEAR_FLAG=true ./build.pl --ant-options -DskipTests=true --git-default-tag=${ZM_BUILD_GIT_DEFAULT_TAG} --build-release-no=${ZM_BUILD_RELEASE_NO} --build-type=FOSS --build-release=LIBERTY --build-release-candidate=${BUILD_RELEASE_CANDIDATE} --build-no ${BUILD_NO} --build-thirdparty-server=files.zimbra.com --no-interactive
