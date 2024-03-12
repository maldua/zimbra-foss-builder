# Zimbra FOSS Builder

## About

**MALDUA'S Zimbra FOSS Builder** brought to you by [BTACTIC, open source & cloud solutions](https://www.btactic.com).

## Introduction

This project aims to ease the build of Zimbra FOSS.

Main features:

- Ubuntu support
- Specific tag support

Roadmap:

- Automate Zimbra FOSS builds thanks to Github Actions.

## Warning

**WARNING: The development stage is in ALPHA QUALITY and it is not ready for production deployment.**

## Documentation

### Docker setup

* Install docker prerequisites

```
sudo apt-get update
sudo apt-get remove docker docker-engine docker.io
sudo apt-get install linux-image-extra-$(uname -r) linux-image-extra-virtual
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
```
* Set up docker's apt repository

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo tee /etc/apt/sources.list.d/docker.list <<EOM
deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable
EOM

sudo apt-get update
```

* Install docker

```
sudo apt-get install docker-ce
```

### Docker user

```
sudo usermod -a -G docker myuser
```

### Git ssh keys

In your build machine you can create a key by doing this:

```
ssh-keygen -t rsa -b 4096 -C "zimbra-builder@domain.com"
```

the email address needs to be the one used for your GitHub account.

Then upload the `id_rsa.pub` key to your GitHub profile: [https://github.com/settings/keys](https://github.com/settings/keys).

Note: I personally only use an additional Github account because you cannot set this SSH key as a read-only one. You are supposed to use a deploy key but those are attached to a single repo or organisation.

### Manual build example

* Builder setup

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

* Enter onto the zimbra builder

```
docker run \
  -it \
  --env ZIMBRA_BUILDER_UID=$(id -u) \
  --env ZIMBRA_BUILDER_GID=$(id -g) \
  -v ~/.ssh:/home/build/.ssh:ro \
  -v $(pwd)/BUILDS:/home/build/installer-build/BUILDS:rw \
  zimbra-manual-ubuntu-20.04-builder:latest
```

* Actual build inside of the docker

```
cd installer-build
git clone --depth 1 --branch 10.0.0-GA git@github.com:Zimbra/zm-build.git
cd zm-build
ENV_CACHE_CLEAR_FLAG=true ./build.pl --ant-options -DskipTests=true --git-default-tag=10.0.0-GA,10.0.0 --build-release-no=10.0.0 --build-type=FOSS --build-release=LIBERTY --build-release-candidate=GA --build-thirdparty-server=files.zimbra.com --no-interactive
```

* Result

```
find BUILDS
BUILDS
BUILDS/UBUNTU20_64-LIBERTY-1000-20240202105200-FOSS-1000
BUILDS/UBUNTU20_64-LIBERTY-1000-20240202105200-FOSS-1000/zcs-10.0.0_GA_1000.UBUNTU20_64.20240202105200.tgz
BUILDS/UBUNTU20_64-LIBERTY-1000-20240202105200-FOSS-1000/archives
BUILDS/UBUNTU20_64-LIBERTY-1000-20240202105200-FOSS-1000/archive-access-u20.txt
BUILDS/.gitignore
```

* 10.0.6 build example

```
cd installer-build
git clone --depth 1 --branch 10.0.6 git@github.com:Zimbra/zm-build.git
cd zm-build
ENV_CACHE_CLEAR_FLAG=true ./build.pl --ant-options -DskipTests=true --git-default-tag=10.0.6,10.0.5,10.0.4,10.0.3,10.0.2,10.0.1,10.0.0-GA,10.0.0 --build-release-no=10.0.6 --build-type=FOSS --build-release=LIBERTY --build-release-candidate=GA --build-thirdparty-server=files.zimbra.com --no-interactive
```

### Semi automatic build example

* Builder setup

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

* Semi automatic build

- Release no: 10.0.7
- zm-build branch: 10.0.6
- Git default branch: '10.0.7,10.0.6,10.0.5,10.0.4,10.0.3,10.0.2,10.0.1,10.0.0-GA,10.0.0'

```
docker run \
  -it \
  --env ZIMBRA_BUILDER_UID=$(id -u) \
  --env ZIMBRA_BUILDER_GID=$(id -g) \
  --env ARG ZM_BUILD_RELEASE_NO='10.0.7' \
  --env ARG ZM_BUILD_BRANCH='10.0.6' \
  --env ARG ZM_BUILD_GIT_DEFAULT_TAG='10.0.7,10.0.6,10.0.5,10.0.4,10.0.3,10.0.2,10.0.1,10.0.0-GA,10.0.0' \
  -v ~/.ssh:/home/build/.ssh:ro \
  -v $(pwd):/usr/local/zimbra-foss-builder:ro \
  -v $(pwd)/BUILDS:/home/build/installer-build/BUILDS:rw \
  zimbra-semiauto-ubuntu-20.04-builder:latest
```

## Similar projects

- [ianw1974's zimbra-build-scripts](https://github.com/ianw1974/zimbra-build-scripts)
- [KontextWork's zimbra-builder](https://github.com/KontextWork/zimbra-builder)
