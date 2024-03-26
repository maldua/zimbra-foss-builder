#!/usr/bin/env python3

import os
import shutil
import re
import requests
from subprocess import run, PIPE

# Please run from docs folder

downloads_md='downloads-PRUEBA-DE-CONCEPTO.md'
templatesDir='templates'
imagesDir="images"
repoReleasesTagUrl="https://github.com/maldua/zimbra-foss-builder/releases/tag"

GITHUB_TOKEN = os.getenv('GITHUB_TOKEN')

def append_files(file1_path, file2_path):
    with open(file1_path, 'r') as file1:
        with open(file2_path, 'a') as file2:
            shutil.copyfileobj(file1, file2)

def getIconField(prefixTag):
  if ("ubuntu" in prefixTag):
    iconField = f"![Ubuntu icon]({imagesDir}/ubuntu.png)"
  elif ("rhel" in prefixTag):
    iconField = f"![RedHat icon]({imagesDir}/redhat.png)"
  else:
    iconField = ""

  return (iconField)

def get_download_table_top (versionTag, shortName):
  return (
    f"### {versionTag} ({shortName})\n"
    '| | Platform | Download 64-BIT | Build Date | More details |\n'
    '| | --- | --- | --- | --- |'
  )

def get_download_row (prefixTag, versionTag, distroLongName, tgzDownloadUrl, buildDate):
  icon = getIconField(prefixTag)
  md5DownloadUrl = tgzDownloadUrl + ".md5"
  sha256DownloadUrl = tgzDownloadUrl + ".sha256"
  moreInformationUrl = repoReleasesTagUrl + "/" + prefixTag + "%2F" + versionTag
  # TODO: Use the release url directly instead of crafting it ourselves.
  download_row = f"|{icon} | {distroLongName} | [64bit x86]({tgzDownloadUrl}) [(MD5)]({md5DownloadUrl}) [(SHA 256)]({sha256DownloadUrl}) | {buildDate} | [Build/Release details]({moreInformationUrl}) |"
  return (download_row)

## Main loop

# Get info from releases based on previous tag matrix (releasesMatrix)
# Keep only tags that start with: 'zimbra-foss-build-'
# - tag: zimbra-foss-build-ubuntu-20.04/9.0.0.p39
# - buildDate
# - prefixTag: zimbra-foss-build-ubuntu-20.04
# - versionTag: 9.0.0.p39
# - distroLongName: Ubuntu 20.04 based on release title
# - tgzDownloadUrl: https://...tgz based on assets which start with 'zcs-' and end in 'tgz'
# - category: 'stable, beta, experimental, other' based on draft, pre-release values (use a helper function)

response = requests.get("https://api.github.com/repos/maldua/zimbra-foss-builder/releases", headers={"Accept":"application/vnd.github+json", "Authorization":f"Bearer {GITHUB_TOKEN}", "X-GitHub-Api-Version":"2022-11-28"})
responseJson = response.json()

wantedTagRegex = re.compile('^zimbra-foss-build-.*$')
prefixTagRegex = re.compile('(.*)/.*')
versionTagRegex = re.compile('.*/(.*)')
distroLongNameRegex =re.compile('.* \( (.*) \)')
tgzRegex = re.compile('^zcs-.*tgz$')

releasesMatrix = []

for nJson in responseJson:
  tag = nJson["tag_name"]
  # print (nJson)
  # print ("")
  if re.match(wantedTagRegex, tag):

    prefixTag = re.findall(prefixTagRegex, tag)[0]
    versionTag = re.findall(versionTagRegex, tag)[0]
    distroLongName = re.findall(distroLongNameRegex, nJson["name"])[0]

    tagsItem = {}
    tagsItem["tag"] = tag
    tagsItem["buildDate"] = nJson["created_at"]
    tagsItem["prefixTag"] = prefixTag
    tagsItem["versionTag"] = versionTag
    tagsItem["distroLongName"] = distroLongName

    if ( (nJson["prerelease"] == False) and (nJson["draft"] == False) ):
      tagsItem["category"] = "stable"
    elif ( (nJson["prerelease"] == True) and (nJson["draft"] == False) ):
      tagsItem["category"] = "beta"
    elif ( (nJson["prerelease"] == True) and (nJson["draft"] == True) ):
      tagsItem["category"] = "experimental"
    else:
      tagsItem["category"] = "other"

    for nAsset in nJson["assets"]:
      if re.match(tgzRegex, nAsset["name"]):
        tagsItem["tgzDownloadUrl"] = nAsset["browser_download_url"]
        break

    releasesMatrix.append(tagsItem)

# print(releasesMatrix)

def filterByCategory(matrix, category):
  newMatrix = []
  for nRow in matrix:
    if (nRow["category"] == category):
      newMatrix.append(nRow)
  return (newMatrix)

stableReleasesMatrix = filterByCategory(matrix=releasesMatrix, category="stable")
betaReleasesMatrix = filterByCategory(matrix=releasesMatrix, category="beta")
experimentalReleasesMatrix = filterByCategory(matrix=releasesMatrix, category="experimental")
otherReleasesMatrix = filterByCategory(matrix=releasesMatrix, category="other")

# print(betaReleasesMatrix)

def getVersionTags(matrix):
  versionTags = []
  for nRow in matrix:
    versionTags.append(nRow["versionTag"])
  return (versionTags)

def getUniqueList(nonUniqueList):
  uniqueList = []
  for nItem in nonUniqueList:
    if nItem not in uniqueList:
      uniqueList.append(nItem)
  return (uniqueList)

def orderedAndUniqueVersionTags (versionTags):
  # StrictVersion and package.version.parse does not seem to like this tag versions
  # So let's use 'sort -V -r' from the command line instead
  versionTags = getUniqueList (versionTags)
  versionTagsInput = '\n'.join([str(item) for item in versionTags])
  sortVersionProcess = run(['sort', '-V', '-r'], stdout=PIPE, input=versionTagsInput, encoding='ascii')
  versionTagsOrdered=(sortVersionProcess.stdout).rstrip().split('\n')
  return (versionTagsOrdered)

stableVersionTags = getVersionTags (stableReleasesMatrix)
stableVersionTags = orderedAndUniqueVersionTags (stableVersionTags)

betaVersionTags = getVersionTags (betaReleasesMatrix)
betaVersionTags = orderedAndUniqueVersionTags (betaVersionTags)

experimentalVersionTags = getVersionTags (experimentalReleasesMatrix)
experimentalVersionTags = orderedAndUniqueVersionTags (experimentalVersionTags)

otherVersionTags = getVersionTags (otherReleasesMatrix)
otherVersionTags = orderedAndUniqueVersionTags (otherVersionTags)

# print (betaVersionTags)

def filterByVersionTag(matrix, versionTag):
  newMatrix = []
  for nRow in matrix:
    if (nRow["versionTag"] == versionTag):
      newMatrix.append(nRow)
  return (newMatrix)

def outputSection(downloads_md, versionTags, releasesMatrix, shortName):
  for nTagVersion in versionTags:
    filteredMatrix = filterByVersionTag(releasesMatrix, nTagVersion)
    orderedFilteredMatrix = sorted(filteredMatrix, key=lambda d: d['distroLongName'])

    download_table_top = get_download_table_top (versionTag=nTagVersion, shortName=shortName)
    with open(downloads_md, 'a') as outfile:
      outfile.write('\n' + download_table_top + '\n')

    for nRelease in orderedFilteredMatrix:
      download_row = get_download_row (prefixTag=nRelease['prefixTag'], versionTag=nRelease['versionTag'], distroLongName=nRelease['distroLongName'], tgzDownloadUrl=nRelease['tgzDownloadUrl'], buildDate=nRelease['buildDate'])
      with open(downloads_md, 'a') as outfile:
        outfile.write(download_row + '\n')

def outputNewLine(downloads_md):
  with open(downloads_md, 'a') as outfile:
    outfile.write('\n')

if (os.path.isfile(downloads_md)):
  os.remove(downloads_md)
#
append_files(templatesDir + "/" + "downloads-top.md", downloads_md)
append_files(templatesDir + "/" + "downloads-index.md", downloads_md)

outputNewLine(downloads_md)
append_files(templatesDir + "/" + "stable-releases-top.md", downloads_md)
append_files(templatesDir + "/" + "section-top-disclaimers.md", downloads_md)
outputSection(downloads_md=downloads_md, versionTags=stableVersionTags, releasesMatrix=stableReleasesMatrix, shortName='Stable')

outputNewLine(downloads_md)
append_files(templatesDir + "/" + "beta-releases-top.md", downloads_md)
append_files(templatesDir + "/" + "section-top-disclaimers.md", downloads_md)
outputSection(downloads_md=downloads_md, versionTags=betaVersionTags, releasesMatrix=betaReleasesMatrix, shortName='Beta')

outputNewLine(downloads_md)
append_files(templatesDir + "/" + "experimental-releases-top.md", downloads_md)
append_files(templatesDir + "/" + "section-top-disclaimers.md", downloads_md)
outputSection(downloads_md=downloads_md, versionTags=experimentalVersionTags, releasesMatrix=experimentalReleasesMatrix, shortName='Experimental')

outputNewLine(downloads_md)
append_files(templatesDir + "/" + "other-releases-top.md", downloads_md)
append_files(templatesDir + "/" + "section-top-disclaimers.md", downloads_md)
outputSection(downloads_md=downloads_md, versionTags=otherVersionTags, releasesMatrix=otherReleasesMatrix, shortName='Other')

outputNewLine(downloads_md)
append_files(templatesDir + "/" + "downloads-index.md", downloads_md)
