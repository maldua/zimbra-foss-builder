#!/bin/bash

usage() {
  cat << EOF
Usage:
  $0 --git-default-tag <tags> --zm-build-branch-file <file> [--verbose] [--pimbra-enabled]

Options:
  --git-default-tag        Comma-separated list of git tags to search (required)
  --zm-build-branch-file   Output file to write the found branch/tag (required)
  --pimbra-enabled         Use maldua-pimbra/zm-build instead of Zimbra/zm-build
  --verbose                Show more information
  -h, --help               Show this help message

Examples:
  $0 --git-default-tag '10.0.2,10.0.1,10.0.0-GA,10.0.0' --zm-build-branch-file zm-build-branch.txt
  $0 --verbose --git-default-tag '10.0.2,10.0.1,10.0.0-GA,10.0.0' --zm-build-branch-file zm-build-branch.txt
  $0 --pimbra-enabled --git-default-tag '10.1.15.p1,10.0.2,10.0.1' --zm-build-branch-file zm-build-branch.txt
EOF
}

GIT_QUIET="--quiet"
PIMBRA_ENABLED=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --git-default-tag)
      ZM_BUILD_GIT_DEFAULT_TAG="$2"
      shift 2
      ;;
    --zm-build-branch-file)
      ZM_BUILD_BRANCH_FILE="$2"
      shift 2
      ;;
    --pimbra-enabled)
      PIMBRA_ENABLED=true
      shift
      ;;
    --verbose)
      GIT_QUIET=""
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

# Check required arguments
if [[ -z "$ZM_BUILD_GIT_DEFAULT_TAG" || -z "$ZM_BUILD_BRANCH_FILE" ]]; then
  echo "Error: Both --git-default-tag and --zm-build-branch-file are required."
  usage
  exit 1
fi

# Select repository based on PIMBRA_ENABLED
if $PIMBRA_ENABLED; then
  ZM_BUILD_REPO="https://github.com/maldua-pimbra/zm-build"
else
  ZM_BUILD_REPO="https://github.com/Zimbra/zm-build"
fi

# Clone repo
git clone ${GIT_QUIET} ${ZM_BUILD_REPO} zm-build-find-branch

cd zm-build-find-branch

found_version=""
OLD_IFS="$IFS"
IFS=","
for ntag in ${ZM_BUILD_GIT_DEFAULT_TAG} ; do
    if [ "$(git tag -l "$ntag")" ]; then
        git checkout ${GIT_QUIET} "$ntag"
        found_version="$ntag"
        break
    fi
done
IFS="${OLD_IFS}"

echo "${found_version}" > ../${ZM_BUILD_BRANCH_FILE}

cd ..
