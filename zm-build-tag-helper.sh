#!/bin/bash

ZM_BUILD_GIT_DEFAULT_TAG="$1" # E.g. '10.0.7,10.0.6,10.0.5,10.0.4,10.0.3,10.0.2,10.0.1,10.0.0-GA,10.0.0'
ZM_BUILD_BRANCH_FILE="$2" # E.g. 'zm-build-branch.txt'

git clone https://github.com/Zimbra/zm-build zm-build-find-branch
cd zm-build-find-branch

found_version=""
IFS="," for ntag in ${ZM_BUILD_GIT_DEFAULT_TAG} ; do

    if [ $(git tag -l "$version") ]; then
        found_version="$ntag"
        break
    fi

done

echo "${found_version}" > ../${ZM_BUILD_BRANCH_FILE}

cd ..
