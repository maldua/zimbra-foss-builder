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

def get_download_row (prefixTag, versionTag):
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
os.remove(downloads_md)

append_files(templatesDir/downloads-top.md, downloads_md)

append_files(templatesDir/stable-releases-top.md, downloads_md)
append_files(templatesDir/section-top-disclaimers.md, downloads_md)

append_files(templatesDir/beta-releases-top.md, downloads_md)
append_files(templatesDir/section-top-disclaimers, downloads_md)

append_files(templatesDir/experimental-releases-top.md, downloads_md)
append_files(templatesDir/section-top-disclaimers, downloads_md)

append_files(templatesDir/other-releases-top.md, downloads_md)
append_files(templatesDir/section-top-disclaimers, downloads_md)

append_files(templatesDir/downloads-top.md, downloads_md)

