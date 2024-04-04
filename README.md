# Zimbra FOSS Builder

## About

**MALDUA'S Zimbra FOSS Builder** brought to you by [BTACTIC, open source & cloud solutions](https://www.btactic.com).

## Download

Check our [Zimbra FOSS Downloads / Zimbra OSE Downloads page](https://maldua.github.io/zimbra-foss-builder/downloads.html) if you are just interested for the generated binaries (tgz installers for Zimbra) from this project.

## Introduction

This project aims to ease the build of Zimbra FOSS.

Main features:

- Ubuntu support
- Specific tag support

Roadmap:

- Automate Zimbra FOSS builds thanks to Github Actions.

## Requisites

### Introduction

In order to ease the Zimbra build this build method uses Docker under the hood. You will find instructions on how to setup your build user to use Docker. This only needs to be done once. These Docker instructions are meant for Ubuntu 20.04 but any other generic Docker setup instructions for your OS should be ok.

### Choose a build user

These builds are done not thanks to the `root` user but thanks to a regular user from your distro which will be part of the `docker` group.
This documentation will be using: `zbuilder` for such an user.

*Note for advanced users only: If you really need to use root user in order to use Docker reading github Dockerfiles can give you a hint on how to rewrite the current smart Dockerfiles.*

### Docker setup

*Note: The commands for this Docker setup need to be run as either root user or a user that it's part of the sudo group, usually the admin user.*

#### Install docker prerequisites

```
sudo apt-get update
sudo apt-get remove docker docker-engine docker.io
sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
```
#### Set up docker's apt repository

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo tee /etc/apt/sources.list.d/docker.list <<EOM
deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable
EOM

sudo apt-get update
```

#### Install docker

```
sudo apt-get install docker-ce
```

### Docker user

```
sudo usermod -a -G docker zbuilder
```

### Git ssh keys

*Note: The commands below need to be run as the `zbuilder` user.*

You need to run the command below in order to create a key.

```
ssh-keygen -t rsa -b 4096 -C "zimbra-builder@domain.com"
```

the email address needs to be the one used for your GitHub account.

Then upload the `id_rsa.pub` key to your GitHub profile: [https://github.com/settings/keys](https://github.com/settings/keys).

Note: I personally only use an additional Github account because you cannot set this SSH key as a read-only one. You are supposed to use a deploy key but those are attached to a single repo or organisation.

## About current builds

The current builds are based on Ubuntu and RHEL families Adding new builds based on other distributions should not be very difficult. It's just about adding new Dockerfiles based on [https://github.com/Zimbra/zm-base-os](https://github.com/Zimbra/zm-base-os).

If you don't figure out how to do it please open an issue at: [https://github.com/maldua/zimbra-foss-builder/issues](https://github.com/maldua/zimbra-foss-builder/issues).

If you manage to add a new distribution please open a pull request at: [https://github.com/maldua/zimbra-foss-builder/pulls](https://github.com/maldua/zimbra-foss-builder/pulls).

## Smart build example (Recommended)

This is the recommended build method for newbies.

### Builder setup

*Note: The commands below need to be run as the `zbuilder` user.*

```
git clone https://github.com/maldua/zimbra-foss-builder
cd zimbra-foss-builder
```

```
docker build \
  --build-arg ZIMBRA_BUILDER_UID=$(id -u) \
  --build-arg ZIMBRA_BUILDER_GID=$(id -g) \
  --tag zimbra-smart-ubuntu-20.04-builder . \
  -f Dockerfile-smart-ubuntu-20.04
```

### Smart build

In this example you ask for 10.0.7 version to be built. The smart build will autofill for you:

  * zm-build branch: 10.0.6
  * Git default branch: '10.0.7,10.0.6,10.0.5,10.0.4,10.0.3,10.0.2,10.0.1,10.0.0-GA,10.0.0'

*Note: The commands below need to be run as the `zbuilder` user.*

```
docker run \
  -it \
  --env ZIMBRA_BUILDER_UID=$(id -u) \
  --env ZIMBRA_BUILDER_GID=$(id -g) \
  --env ZM_BUILD_RELEASE_NO='10.0.7' \
  -v ~/.ssh:/home/build/.ssh:ro \
  -v $(pwd):/usr/local/zimbra-foss-builder:ro \
  -v $(pwd)/BUILDS:/home/build/installer-build/BUILDS:rw \
  zimbra-smart-ubuntu-20.04-builder:latest
```

### Result

*Note: The commands below need to be run as the `zbuilder` user.*

```
find BUILDS
BUILDS
BUILDS/.gitignore
BUILDS/UBUNTU20_64-LIBERTY-1007-20240312142857-FOSS-1000
BUILDS/UBUNTU20_64-LIBERTY-1007-20240312142857-FOSS-1000/zcs-10.0.7_GA_1000.UBUNTU20_64.20240312142857.tgz
BUILDS/UBUNTU20_64-LIBERTY-1007-20240312142857-FOSS-1000/archives
BUILDS/UBUNTU20_64-LIBERTY-1007-20240312142857-FOSS-1000/archive-access-u20.txt
```

Now you could use `zcs-10.0.7_GA_1000.UBUNTU20_64.20240312142857.tgz` in order to install Zimbra FOSS.

## Semi automatic build example

Once you have more experience you will figure out yourself that 10.0.x tags are always almost the same ones and that you can write them on your own. This will save you the initial 5 or 10 minutes that the zimbra-tag-helper will try to figure out the different tags.

### Builder setup

*Note: The commands below need to be run as the `zbuilder` user.*

```
git clone https://github.com/maldua/zimbra-foss-builder
cd zimbra-foss-builder
```

```
docker build \
  --build-arg ZIMBRA_BUILDER_UID=$(id -u) \
  --build-arg ZIMBRA_BUILDER_GID=$(id -g) \
  --tag zimbra-semiauto-ubuntu-20.04-builder . \
  -f Dockerfile-semiauto-ubuntu-20.04
```

### Semi automatic build

    - Release no: 10.0.7
    - zm-build branch: 10.0.6
    - Git default branch: '10.0.7,10.0.6,10.0.5,10.0.4,10.0.3,10.0.2,10.0.1,10.0.0-GA,10.0.0'

*Note: The commands below need to be run as the `zbuilder` user.*

```
docker run \
  -it \
  --env ZIMBRA_BUILDER_UID=$(id -u) \
  --env ZIMBRA_BUILDER_GID=$(id -g) \
  --env ZM_BUILD_RELEASE_NO='10.0.7' \
  --env ZM_BUILD_BRANCH='10.0.6' \
  --env ZM_BUILD_GIT_DEFAULT_TAG='10.0.7,10.0.6,10.0.5,10.0.4,10.0.3,10.0.2,10.0.1,10.0.0-GA,10.0.0' \
  -v ~/.ssh:/home/build/.ssh:ro \
  -v $(pwd):/usr/local/zimbra-foss-builder:ro \
  -v $(pwd)/BUILDS:/home/build/installer-build/BUILDS:rw \
  zimbra-semiauto-ubuntu-20.04-builder:latest
```

### Result

*Note: The commands below need to be run as the `zbuilder` user.*

```
find BUILDS
BUILDS
BUILDS/.gitignore
BUILDS/UBUNTU20_64-LIBERTY-1007-20240312142857-FOSS-1000
BUILDS/UBUNTU20_64-LIBERTY-1007-20240312142857-FOSS-1000/zcs-10.0.7_GA_1000.UBUNTU20_64.20240312142857.tgz
BUILDS/UBUNTU20_64-LIBERTY-1007-20240312142857-FOSS-1000/archives
BUILDS/UBUNTU20_64-LIBERTY-1007-20240312142857-FOSS-1000/archive-access-u20.txt
```

## Manual build example

This build let's you fine tune the actual command that builds everything just in case you need to do it while maintaining all of the Docker advantages as having all of the packages installed for the build to work seamlessly.

### Builder setup

*Note: The commands below need to be run as the `zbuilder` user.*

```
git clone https://github.com/maldua/zimbra-foss-builder
cd zimbra-foss-builder
```

```
docker build \
  --build-arg ZIMBRA_BUILDER_UID=$(id -u) \
  --build-arg ZIMBRA_BUILDER_GID=$(id -g) \
  --tag zimbra-manual-ubuntu-20.04-builder . \
  -f Dockerfile-manual-ubuntu-20.04
```

### Enter onto the zimbra builder

*Note: The commands below need to be run as the `zbuilder` user.*

```
docker run \
  -it \
  --env ZIMBRA_BUILDER_UID=$(id -u) \
  --env ZIMBRA_BUILDER_GID=$(id -g) \
  -v ~/.ssh:/home/build/.ssh:ro \
  -v $(pwd)/BUILDS:/home/build/installer-build/BUILDS:rw \
  zimbra-manual-ubuntu-20.04-builder:latest
```

### Actual build inside of the docker

*Note: Inside of the Docker you are running these commands as the `build` user which has their uid/gid mapped to your `zbuilder` user.*

```
cd installer-build
git clone --depth 1 --branch 10.0.0-GA git@github.com:Zimbra/zm-build.git
cd zm-build
ENV_CACHE_CLEAR_FLAG=true ./build.pl \
  --ant-options \
  -DskipTests=true \
  --git-default-tag=10.0.0-GA,10.0.0 \
  --build-release-no=10.0.0 \
  --build-type=FOSS \
  --build-release=LIBERTY \
  --build-release-candidate=GA \
  --build-thirdparty-server=files.zimbra.com \
  --no-interactive
```

### Result

*Note: The commands below need to be run as the `zbuilder` user.*

```
find BUILDS
BUILDS
BUILDS/UBUNTU20_64-LIBERTY-1000-20240202105200-FOSS-1000
BUILDS/UBUNTU20_64-LIBERTY-1000-20240202105200-FOSS-1000/zcs-10.0.0_GA_1000.UBUNTU20_64.20240202105200.tgz
BUILDS/UBUNTU20_64-LIBERTY-1000-20240202105200-FOSS-1000/archives
BUILDS/UBUNTU20_64-LIBERTY-1000-20240202105200-FOSS-1000/archive-access-u20.txt
BUILDS/.gitignore
```

### 10.0.6 build example

*Note: Inside of the Docker you are running these commands as the `build` user which has their uid/gid mapped to your `zbuilder` user.*

```
cd installer-build
git clone --depth 1 --branch 10.0.6 git@github.com:Zimbra/zm-build.git
cd zm-build
ENV_CACHE_CLEAR_FLAG=true ./build.pl \
  --ant-options \
  -DskipTests=true \
  --git-default-tag=10.0.6,10.0.5,10.0.4,10.0.3,10.0.2,10.0.1,10.0.0-GA,10.0.0 \
  --build-release-no=10.0.6 \
  --build-type=FOSS \
  --build-release=LIBERTY \
  --build-release-candidate=GA \
  --build-thirdparty-server=files.zimbra.com \
  --no-interactive
```

## Additional documentation

If you want to take over this project these are the documentation files that you should be reading:

- [Build Zimbra tgz installers thanks to Github Actions](BUILD-GITHUB-ACTION.md)
- [Generate downloads page from Releases data thanks to Github Actions](DOWNLOADS-GITHUB-ACTION.md)
- [Release instructions for the project maintainer](MAINTAINER-RELEASE.md)

## Similar projects

- [ianw1974's zimbra-build-scripts](https://github.com/ianw1974/zimbra-build-scripts)
- [KontextWork's zimbra-builder](https://github.com/KontextWork/zimbra-builder)
