#!/bin/bash

MALDUA_ZIMBRA_TAG_HELPER_TAG="v0.0.7"

function usage {
  cat << EOF
Usage: $0 --release-no <release> [--builder-id <id>] [--pimbra-enabled] [--verbose] [--help|-h]

Options:
  --release-no       Zimbra release number (required)
  --builder-id       Optional builder ID
  --pimbra-enabled   Enable Pimbra build (boolean flag)
  --verbose          Show more information (environment variable VERBOSE also works)
  -h, --help         Show this help message

Environment variables:
  RELEASE_NO         Default value for --release-no
  BUILDER_ID         Default value for --builder-id
  PIMBRA_ENABLED     Default value for --pimbra-enabled (true/false)
  VERBOSE            Default verbose flag (true/false)

Notes:
  Command-line switches override environment variables.

Examples:
  $0 --release-no 10.1.9
  $0 --release-no 10.1.9 --builder-id 430
  $0 --release-no 10.1.15.p1 --pimbra-enabled
  $0 --release-no 10.1.15.p1 --builder-id 430 --pimbra-enabled --verbose
EOF
}

function getGitDefaultTag {
  _VERSION="$1"
  _FILE="$2"
  _PIMBRA_ENABLED="$3"

  _PIMBRA_ARG=""
  if ${_PIMBRA_ENABLED}; then
    _PIMBRA_ARG="--pimbra-enabled"
  fi

  GIT_QUIET_FLAG="--quiet"
  if [ "${VERBOSE}" = true ]; then
    GIT_QUIET_FLAG=""
  fi

  git clone ${GIT_QUIET_FLAG} https://github.com/maldua/zimbra-tag-helper
  cd zimbra-tag-helper
  git checkout ${GIT_QUIET_FLAG} ${MALDUA_ZIMBRA_TAG_HELPER_TAG}
  ./zm-build-tags-arguments.sh --tag ${_VERSION} ${_PIMBRA_ARG} > ../${_FILE}
  cd ..
}

# Defaults (from environment)
ZM_BUILD_RELEASE_NO="${RELEASE_NO:-}"
ZM_BUILDER_ID="${BUILDER_ID:-}"
PIMBRA_ENABLED="${PIMBRA_ENABLED:-false}"
VERBOSE="${VERBOSE:-false}"

# Parse arguments
TEMP=$(getopt -o h --long release-no:,builder-id:,pimbra-enabled,verbose,help -n "$0" -- "$@")
if [ $? != 0 ]; then
  echo "Invalid arguments."
  usage
  exit 1
fi

eval set -- "$TEMP"

while true; do
  case "$1" in
    --release-no)
      ZM_BUILD_RELEASE_NO="$2"
      shift 2
      ;;
    --builder-id)
      ZM_BUILDER_ID="$2"
      shift 2
      ;;
    --pimbra-enabled)
      PIMBRA_ENABLED=true
      shift
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Invalid argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [ "x" == "x${ZM_BUILD_RELEASE_NO}" ] ; then
  echo "--release-no|RELEASE_NO is not defined."
  usage
  exit 1
fi

ZM_BUILD_GIT_DEFAULT_TAG_FILE="git-default-tag.txt"
getGitDefaultTag ${ZM_BUILD_RELEASE_NO} ${ZM_BUILD_GIT_DEFAULT_TAG_FILE} ${PIMBRA_ENABLED}
ZM_BUILD_GIT_DEFAULT_TAG="$(cat ${ZM_BUILD_GIT_DEFAULT_TAG_FILE})"

ZM_BUILD_BRANCH_FILE="zm-build-branch.txt"

# --- Start ZM_BUILD_TAG_HELPER_CMD array (definition + execution) ---
ZM_BUILD_TAG_HELPER_CMD=(
  /usr/local/zimbra-foss-builder/zm-build-tag-helper.sh
  --git-default-tag "${ZM_BUILD_GIT_DEFAULT_TAG}"
  --zm-build-branch-file "${ZM_BUILD_BRANCH_FILE}"
)

if [ "${PIMBRA_ENABLED}" = true ]; then
  ZM_BUILD_TAG_HELPER_CMD+=(--pimbra-enabled)
fi

"${ZM_BUILD_TAG_HELPER_CMD[@]}"
# --- End ZM_BUILD_TAG_HELPER_CMD array ---

ZM_BUILD_BRANCH="$(cat ${ZM_BUILD_BRANCH_FILE})"

if [ -z "${ZM_BUILD_BRANCH}" ]; then
  echo "ZM_BUILD_BRANCH should be defined by now."
  exit 2
fi

if [ -z "${ZM_BUILD_GIT_DEFAULT_TAG}" ]; then
  echo "ZM_BUILD_GIT_DEFAULT_TAG should be defined by now."
  exit 2
fi

# --- Start ZIMBRA_BUILDER_CMD array (definition + execution) ---
ZIMBRA_BUILDER_CMD=(
  /usr/local/zimbra-foss-builder/zimbra-builder.sh
  --release-no "${ZM_BUILD_RELEASE_NO}"
  --build-branch "${ZM_BUILD_BRANCH}"
  --git-default-tag "${ZM_BUILD_GIT_DEFAULT_TAG}"
)

if [ -n "${ZM_BUILDER_ID}" ]; then
  ZIMBRA_BUILDER_CMD+=(--builder-id "${ZM_BUILDER_ID}")
fi

if [ "${PIMBRA_ENABLED}" = true ]; then
  ZIMBRA_BUILDER_CMD+=(--pimbra-enabled)
fi

if [ "${VERBOSE}" = true ]; then
  ZIMBRA_BUILDER_CMD+=(--verbose)
fi

"${ZIMBRA_BUILDER_CMD[@]}"
# --- End ZIMBRA_BUILDER_CMD array ---
