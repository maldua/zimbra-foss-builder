# Zimbra FOSS Builder

## About

**MALDUA'S Zimbra FOSS Builder** brought to you by [BTACTIC, open source & cloud solutions](https://www.btactic.com).

## Download

- Check: [Zimbra FOSS Downloads (from Maldua)](https://maldua.github.io/zimbra-foss/downloads/) page if you are just interested for the generated binaries (tgz installers for Zimbra) from this project.
- You can also check the [Zimbra FOSS (from Maldua)](https://maldua.github.io/zimbra-foss/) page and its [zimbra-foss](https://github.com/maldua/zimbra-foss) Github page.

## Introduction

This project aims to ease the build of Zimbra FOSS.

Main features:

- Ubuntu support
- Rhel support
- Specific tag support
- Zimbra FOSS builds can be automated thanks to Github Actions.

## Requisites

### Introduction

In order to ease the Zimbra build this build method uses Docker under the hood. You will find instructions on how to setup your build user to use Docker. This only needs to be done once. These Docker instructions are meant for Ubuntu 20.04 but any other generic Docker setup instructions for your OS should be ok.

Be aware of RHEL 8 based distributions. Search for a [docker-ce howto](https://computingforgeeks.com/install-docker-and-docker-compose-on-rhel-8-centos-8/). Trying to install docker package directly installs *podman* and *buildah* which **[do not work exactly as docker-ce](https://github.com/maldua/zimbra-foss-builder/issues/2#issuecomment-2043119036)** although they seem to be advertised as such.

### Choose a build user

These builds are done not thanks to the `root` user but thanks to a regular user from your distro which will be part of the `docker` group.
This documentation will be using: `zbuilder` for such an user.

*Note for advanced users only: If you really need to use root user in order to use Docker reading github Dockerfiles (from zimbra-foss project) can give you a hint on how to rewrite the current smart Dockerfiles.*

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

### Docker user - Creation

```
sudo usermod -a -G docker zbuilder
```

### Docker user - Re-login

In order to be able to use Docker properly from `zbuilder` user you might need to logout and then login to your user.
You might find how to enforce the user Docker group rights without logging out if you search enough but most of the times it's easier to just logout and login.

### Docker user - Hello world

Also make sure to run the usual 'Hello world' docker examples under the `zbuilder` user.
These 'Hello world' docker examples are usually explained in most of the docker installation manuals.
If 'Hello world' docker example does not work as expected then building thanks to our Dockerfiles will definitely not work.

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

## About pimbra

This build system does not use [pimbra repos](https://github.com/maldua-pimbra/maldua-pimbra) by default.
Pimbra has been used from time to time since: `10.1.5`, `10.0.13` and `9.0.0.p44` versions.

If you want to build recently released versions with pimbra you might want to wait till pimbra repos are updated for your specific version.
Otherwise the build might fail.

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
  -f Dockerfiles/smart/ubuntu-20.04/Dockerfile
```

### Smart build

This smart build will be branded as '430' by default.

In this example you ask for 10.0.7 version to be built. The smart build will autofill for you:

  * zm-build branch: 10.0.6
  * Git default branch: '10.0.7,10.0.6,10.0.5,10.0.4,10.0.3,10.0.2,10.0.1,10.0.0-GA,10.0.0'

*Note: The commands below need to be run as the `zbuilder` user.*

```
docker run \
  -it \
  --env ZIMBRA_BUILDER_UID=$(id -u) \
  --env ZIMBRA_BUILDER_GID=$(id -g) \
  --env RELEASE_NO='10.0.7' \
  --env PIMBRA_ENABLED='false' \
  -v ~/.ssh:/home/build/.ssh:ro \
  -v $(pwd):/usr/local/zimbra-foss-builder:ro \
  -v $(pwd)/BUILDS:/home/build/installer-build/BUILDS:rw \
  zimbra-smart-ubuntu-20.04-builder:latest
```

**Note**: If you want to apply the [extra pimbra repos patches](https://github.com/maldua-pimbra/maldua-pimbra). Use `--env PIMBRA_ENABLED='true'` instead.

### Smart build (Alternative with acme brand)

This is an example on how you can brand your smart builds with, e.g. 'acme'.
This must be converted into a number between 100 and 999 like 431 or 432.
E.g. acme always means 431.
You can check what the different builder ids are at [Zimbra Foss Builders List - Wiki page](https://wiki.zimbra.com/wiki/ZimbraFossBuildersList).

In this example you ask for 10.0.7 version to be built. The smart build will autofill for you:

  * zm-build branch: 10.0.6
  * Git default branch: '10.0.7,10.0.6,10.0.5,10.0.4,10.0.3,10.0.2,10.0.1,10.0.0-GA,10.0.0'

*Note: The commands below need to be run as the `zbuilder` user.*

```
docker run \
  -it \
  --env ZIMBRA_BUILDER_UID=$(id -u) \
  --env ZIMBRA_BUILDER_GID=$(id -g) \
  --env RELEASE_NO='10.0.7' \
  --env PIMBRA_ENABLED='false' \
  --env BUILDER_ID='431' \
  -v ~/.ssh:/home/build/.ssh:ro \
  -v $(pwd):/usr/local/zimbra-foss-builder:ro \
  -v $(pwd)/BUILDS:/home/build/installer-build/BUILDS:rw \
  zimbra-smart-ubuntu-20.04-builder:latest
```

**Note**: If you want to apply the [extra pimbra repos patches](https://github.com/maldua-pimbra/maldua-pimbra). Use `--env PIMBRA_ENABLED='true'` instead.

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
  -f Dockerfiles/semiauto/ubuntu-20.04/Dockerfile
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
  --env RELEASE_NO='10.0.7' \
  --env BUILD_BRANCH='10.0.6' \
  --env GIT_DEFAULT_TAG='10.0.7,10.0.6,10.0.5,10.0.4,10.0.3,10.0.2,10.0.1,10.0.0-GA,10.0.0' \
  --env PIMBRA_ENABLED='false' \
  -v ~/.ssh:/home/build/.ssh:ro \
  -v $(pwd):/usr/local/zimbra-foss-builder:ro \
  -v $(pwd)/BUILDS:/home/build/installer-build/BUILDS:rw \
  zimbra-semiauto-ubuntu-20.04-builder:latest
```

**Note**: If you want to apply the [extra pimbra repos patches](https://github.com/maldua-pimbra/maldua-pimbra). Use `--env PIMBRA_ENABLED='true'` instead.

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
  -f Dockerfiles/manual/ubuntu-20.04/Dockerfile
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

- [extra pimbra repos patches (Optional)](https://github.com/maldua-pimbra/maldua-pimbra):
```
wget 'https://github.com/maldua-pimbra/maldua-pimbra-config/raw/refs/tags/'"10.0.0"'/config.build'
```

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

- [extra pimbra repos patches (Optional)](https://github.com/maldua-pimbra/maldua-pimbra):
```
wget 'https://github.com/maldua-pimbra/maldua-pimbra-config/raw/refs/tags/'"10.0.6"'/config.build'
```

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

## Similar projects

- [ianw1974's zimbra-build-scripts](https://github.com/ianw1974/zimbra-build-scripts)
- [KontextWork's zimbra-builder](https://github.com/KontextWork/zimbra-builder)
