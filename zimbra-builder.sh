#!/bin/bash

# Default values
ZM_BUILDER_ID_ARG="430"
ZM_BUILD_PIMBRA_ENABLED=false

# Parse arguments using getopt (long options)
TEMP=$(getopt -o '' \
    --long release-no:,build-branch:,git-default-tag:,builder-id:,pimbra-enabled \
    -n "$(basename "$0")" -- "$@")

if [ $? != 0 ] ; then
  echo "Error parsing arguments."
  exit 1
fi

eval set -- "$TEMP"

while true; do
  case "$1" in
    --release-no)
      ZM_BUILD_RELEASE_NO_WITH_PATCH="$2"; shift 2 ;;
    --build-branch)
      ZM_BUILD_BRANCH="$2"; shift 2 ;;
    --git-default-tag)
      ZM_BUILD_GIT_DEFAULT_TAG="$2"; shift 2 ;;
    --builder-id)
      ZM_BUILDER_ID_ARG="$2"; shift 2 ;;
    --pimbra-enabled)
      ZM_BUILD_PIMBRA_ENABLED=true; shift ;;
    --)
      shift; break ;;
    *)
      echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Validate required arguments
if [ -z "$ZM_BUILD_RELEASE_NO_WITH_PATCH" ] ; then
  echo "ZM_BUILD_RELEASE_NO_WITH_PATCH is not defined."
  exit 1
fi

if [ -z "$ZM_BUILD_BRANCH" ] ; then
  echo "ZM_BUILD_BRANCH is not defined."
  exit 1
fi

if [ -z "$ZM_BUILD_GIT_DEFAULT_TAG" ] ; then
  echo "ZM_BUILD_GIT_DEFAULT_TAG is not defined."
  exit 1
fi

# Validate builder ID
if ! [[ "$ZM_BUILDER_ID_ARG" =~ ^[0-9]+$ ]] ; then
  echo "ZM_BUILDER_ID must be a number."
  exit 1
fi

ZM_BUILDER_ID=$((ZM_BUILDER_ID_ARG))
if (( ZM_BUILDER_ID < 100 || ZM_BUILDER_ID > 999 )); then
  echo "ZM_BUILDER_ID must be between 100 and 999."
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

ZM_BUILD_REPO_URL="git@github.com:Zimbra/zm-build.git"
if [ "${ZM_BUILD_PIMBRA_ENABLED}" = true ] ; then
  ZM_BUILD_REPO_URL="git@github.com:maldua-pimbra/zm-build.git"
fi

cd installer-build

cat << EOF > BUILDS/zimbra-builder-commands.txt
git clone --depth 1 --branch ${ZM_BUILD_BRANCH} ${ZM_BUILD_REPO_URL}
cd zm-build
ENV_CACHE_CLEAR_FLAG=true ./build.pl --ant-options -DskipTests=true --git-default-tag=${ZM_BUILD_GIT_DEFAULT_TAG} --build-release-no=${ZM_BUILD_RELEASE_NO} --build-type=FOSS --build-release=LIBERTY --build-release-candidate=${BUILD_RELEASE_CANDIDATE} --build-no ${BUILD_NO} --build-thirdparty-server=files.zimbra.com --no-interactive
EOF

git clone --depth 1 --branch ${ZM_BUILD_BRANCH} ${ZM_BUILD_REPO_URL}
cd zm-build

if [ "${ZM_BUILD_PIMBRA_ENABLED}" = true ] ; then
  wget 'https://github.com/maldua-pimbra/maldua-pimbra-config/raw/refs/tags/'"${ZM_BUILD_RELEASE_NO_WITH_PATCH}"'/config.build'
  if [[ $? -ne 0 ]] ; then
    echo "ERROR: Pimbra config file cannot be downloaded for ${ZM_BUILD_RELEASE_NO_WITH_PATCH} version !"
    echo "Aborting !!!"
    exit 2
  fi
fi

if [ "${ZM_BUILD_PIMBRA_ENABLED}" = true ] ; then
  cat << EOF >> ../BUILDS/zimbra-builder-commands.txt
# config.build contents:
EOF
  cat config.build >> ../BUILDS/zimbra-builder-commands.txt
fi

ENV_CACHE_CLEAR_FLAG=true ./build.pl --ant-options -DskipTests=true --git-default-tag=${ZM_BUILD_GIT_DEFAULT_TAG} --build-release-no=${ZM_BUILD_RELEASE_NO} --build-type=FOSS --build-release=LIBERTY --build-release-candidate=${BUILD_RELEASE_CANDIDATE} --build-no ${BUILD_NO} --build-thirdparty-server=files.zimbra.com --no-interactive
