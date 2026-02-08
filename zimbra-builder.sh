#!/bin/bash

# Default values (can be overridden by environment)
ZM_BUILD_RELEASE_NO_WITH_PATCH="${RELEASE_NO:-}"
ZM_BUILD_BRANCH="${BUILD_BRANCH:-}"
ZM_BUILD_GIT_DEFAULT_TAG="${GIT_DEFAULT_TAG:-}"
ZM_BUILDER_ID_ARG="${BUILDER_ID:-430}"
ZM_BUILD_PIMBRA_ENABLED="${PIMBRA_ENABLED:-false}"

SCRIPT_NAME="$(basename "$0")"

usage() {
  cat << EOF
Usage:
  ${SCRIPT_NAME} \\
    --release-no <release> \\
    --build-branch <branch> \\
    --git-default-tag <tag> \\
    [--builder-id <id>] \\
    [--pimbra-enabled] \\
    [-h|--help]

Environment variables (can be overridden by switches):
  RELEASE_NO            Zimbra release number (e.g. 10.0.7.p39, 10.1.0.beta1)
  BUILD_BRANCH          Git branch to build from
  GIT_DEFAULT_TAG       Default Git tag for the build
  BUILDER_ID            Numeric builder ID (100–999). Default: 430
  PIMBRA_ENABLED        Enable Pimbra build (true/false)

Required options:
  --release-no           Zimbra release number (e.g. 10.0.7.p39, 10.1.0.beta1)
  --build-branch         Git branch to build from
  --git-default-tag      Default Git tag for the build

Optional options:
  --builder-id           Numeric builder ID (100–999). Default: ${ZM_BUILDER_ID_ARG}
  --pimbra-enabled       Enable Pimbra build (uses maldua-pimbra repo)
  -h, --help              Show this help and exit

Examples:
  ${SCRIPT_NAME} --release-no 10.1.9 --build-branch 10.1.8 --git-default-tag 10.1.9,10.1.8,10.1.7,10.1.6,10.1.5,10.1.4,10.1.3,10.1.2,10.1.1,10.1.0
  ${SCRIPT_NAME} --release-no 10.1.13 --build-branch 10.1.13 --git-default-tag 10.1.13,10.1.12,10.1.10,10.1.9,10.1.8,10.1.7,10.1.6,10.1.5,10.1.4,10.1.3,10.1.2,10.1.1,10.1.0 --builder-id 450
  ${SCRIPT_NAME} --release-no 10.1.15.p1 --build-branch 10.1.14 --git-default-tag 10.1.15.p1,10.1.15,10.1.14,10.1.13,10.1.12,10.1.10,10.1.9,10.1.8,10.1.7,10.1.6,10.1.5,10.1.4,10.1.3,10.1.2,10.1.1,10.1.0 --pimbra-enabled
EOF
}

# Parse arguments using getopt (long options)
TEMP=$(getopt -o 'h' \
    --long release-no:,build-branch:,git-default-tag:,builder-id:,pimbra-enabled,help \
    -n "${SCRIPT_NAME}" -- "$@")

if [ $? != 0 ] ; then
  echo "Error parsing arguments."
  usage
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
    -h|--help)
      usage
      exit 0 ;;
    --)
      shift; break ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1 ;;
  esac
done

# Validate required arguments
if [ -z "$ZM_BUILD_RELEASE_NO_WITH_PATCH" ] ; then
  echo "ZM_BUILD_RELEASE_NO_WITH_PATCH is not defined."
  usage
  exit 1
fi

if [ -z "$ZM_BUILD_BRANCH" ] ; then
  echo "ZM_BUILD_BRANCH is not defined."
  usage
  exit 1
fi

if [ -z "$ZM_BUILD_GIT_DEFAULT_TAG" ] ; then
  echo "ZM_BUILD_GIT_DEFAULT_TAG is not defined."
  usage
  exit 1
fi

# Validate builder ID
if ! [[ "$ZM_BUILDER_ID_ARG" =~ ^[0-9]+$ ]] ; then
  echo "ZM_BUILDER_ID must be a number."
  usage
  exit 1
fi

ZM_BUILDER_ID=$((ZM_BUILDER_ID_ARG))
if (( ZM_BUILDER_ID < 100 || ZM_BUILDER_ID > 999 )); then
  echo "ZM_BUILDER_ID must be between 100 and 999."
  usage
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

  _BUILD_NO_TMP1=$((_ZM_BUILDER_ID * 10000))
  _BUILD_NO=$((_BUILD_NO_TMP1 + _PATCH_LEVEL))

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
