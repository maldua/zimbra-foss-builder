#!/bin/bash

ZM_BUILD_RELEASE_NO="$1" # E.g. 10.0.7
ZM_BUILD_BRANCH="$2" # E.g. 10.0.6
ZM_BUILD_GIT_DEFAULT_TAG="$3" # E.g. '10.0.7,10.0.6,10.0.5,10.0.4,10.0.3,10.0.2,10.0.1,10.0.0-GA,10.0.0'

cd installer-build
git clone --depth 1 --branch ${ZM_BUILD_BRANCH} git@github.com:Zimbra/zm-build.git
cd zm-build
ENV_CACHE_CLEAR_FLAG=true ./build.pl --ant-options -DskipTests=true --git-default-tag=${ZM_BUILD_GIT_DEFAULT_TAG} --build-release-no=${ZM_BUILD_RELEASE_NO} --build-type=FOSS --build-release=LIBERTY --build-release-candidate=GA --build-thirdparty-server=files.zimbra.com --no-interactive

