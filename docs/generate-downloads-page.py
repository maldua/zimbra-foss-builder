#!/usr/bin/env python

import os
import shutil

# Please run from docs folder

downloads_md='downloads-PRUEBA-DE-CONCEPTO.md'
templatesDir='templates'
imagesDir="images"
repoReleasesTagUrl="https://github.com/maldua/zimbra-foss-builder/releases/tag"

def append_files(file1_path, file2_path):
    with open(file1_path, 'r') as file1:
        with open(file2_path, 'a') as file2:
            shutil.copyfileobj(file1, file2)

getIconField(prefixTag):
  prefixTag=$1
  if ("ubuntu" in $prefixTag):
    iconField = f"![Ubuntu icon]({imagesDir}/ubuntu.png)"
  elif ("rhel" in $prefixTag):
    iconField = f"![RedHat icon]({imagesDir}/redhat.png)"
  else
    iconField = ""
  fi
  return (iconField)

def get_download_table_top (versionTag, shortName):
  return (
    f"### {versionTag} ({shortName})'
    '| | Platform | Download 64-BIT | Build Date | More details |'
    '| | --- | --- | --- | --- |"'
  )

def get_download_row (prefixTag, versionTag, distroLongName, tgzDownloadUrl, buildDate):
  icon = "$(getIconField ${prefixTag})"
  distroLongName = getDistroLongName (prefixTag + "/" + versionTag) # Ubuntu 18.04
  tgzDownloadUrl = getTgzDownloadUrl (prefixTag + "/" + versionTag)
  md5DownloadUrl = tgzDownloadUrl + ".md5"
  sha256DownloadUrl = tgzDownloadUrl + ".sha256"
  buildDate = getbuildDate (prefixTag + "/" + versionTag)
  moreInformationUrl = repoReleasesTagUrl + "/" + prefixTag + "%2F" + versionTag
  download_row = f"|{icon} | {distroLongName} | [64bit x86]({tgzDownloadUrl}) [(MD5)]({md5DownloadUrl}) [(SHA 256)]({sha256DownloadUrl}) | {buildDate} | [Build/Release details]({moreInformationUrl}) |"
  return (download_row)

## Main loop

# Get all of the repo tags (tagsMatrix)
# Keep only tags that start with: 'zimbra-foss-build-'
# Save into a matrix:
# - tag: zimbra-foss-build-ubuntu-20.04/9.0.0.p39
# - buildDate

# Get info from releases based on previous tag matrix (releasesMatrix)
# - tag: zimbra-foss-build-ubuntu-20.04/9.0.0.p39
# - buildDate
# - prefixTag: zimbra-foss-build-ubuntu-20.04
# - versionTag: 9.0.0.p39
# - distroLongName: Ubuntu 20.04 based on release title
# - tgzDownloadUrl: https://...tgz based on assets which start with 'zcs-' and end in 'tgz'
# - category: 'stable, beta, experimental, other' based on draft, pre-release values (use a helper function)

# Create stableReleasesMatrix based on releasesMatrix
# Create betaReleasesMatrix based on releasesMatrix
# Create experimentalReleasesMatrix based on releasesMatrix
# Create otherReleasesMatrix based on releasesMatrix

# Order stableReleasesMatrix
# - 1st: Based on versioning based on versionTag (Higher on the top)
# - 2nd: Based on distroLongName (Higher on the bottom)

# Order betaReleasesMatrix
# - 1st: Based on versioning based on versionTag (Higher on the top)
# - 2nd: Based on distroLongName (Higher on the bottom)

# Order experimentalReleasesMatrix
# - 1st: Based on versioning based on versionTag (Higher on the top)
# - 2nd: Based on distroLongName (Higher on the bottom)

# Order otherReleasesMatrix
# - 1st: Based on versioning based on versionTag (Higher on the top)
# - 2nd: Based on distroLongName (Higher on the bottom)

os.remove(downloads_md)

append_files(templatesDir/downloads-top.md, downloads_md)

append_files(templatesDir/stable-releases-top.md, downloads_md)
append_files(templatesDir/section-top-disclaimers.md, downloads_md)
# getVersionTags from stableReleases
stableVersionTags = getVersionTags(stableReleases)
for nVersionTag in stableVersionTags:
  get_download_table_top (versionTag=nVersionTag, shortName='Stable')
  for nRelease in stableReleases:
    if (nRelease['versionTag'] == nVersionTag): # TODO: Maybe use a filtered matrix to avoid so many loops
      get_download_row (prefixTag=nRelease['prefixTag'], versionTag=nRelease['versionTag'], distroLongName=nRelease['distroLongName'], tgzDownloadUrl=nRelease['tgzDownloadUrl'], buildDate=nRelease['buildDate'])

# Loop stableReleasesMatrix and print different distros with 'Stable' addition

append_files(templatesDir/beta-releases-top.md, downloads_md)
append_files(templatesDir/section-top-disclaimers, downloads_md)
# Loop betaReleasesMatrix and print different distros with 'Beta' addition

append_files(templatesDir/experimental-releases-top.md, downloads_md)
append_files(templatesDir/section-top-disclaimers, downloads_md)
# Loop experimentalReleasesMatrix and print different distros with 'Experimental' addition

append_files(templatesDir/other-releases-top.md, downloads_md)
append_files(templatesDir/section-top-disclaimers, downloads_md)
# Loop otherReleasesMatrix and print different distros with 'Other' addition

append_files(templatesDir/downloads-top.md, downloads_md)
