FROM ubuntu:24.04

ARG ZIMBRA_BUILDER_UID
ARG ZIMBRA_BUILDER_GID
ARG ZM_BUILD_RELEASE_NO
ARG ZM_BUILD_BRANCH
ARG ZM_BUILD_GIT_DEFAULT_TAG
ARG PIMBRA_ENABLED

ENV DEBIAN_FRONTEND=noninteractive

# Some ideas were taken from: https://github.com/Zimbra/zm-base-os

# SYSTEM
RUN apt-get -qq update
RUN apt-get -qq dist-upgrade -y
RUN apt-get -qq autoremove -y
RUN apt-get -qq install -y apt-utils
RUN apt-get -qq install -y ca-certificates tzdata
RUN apt-get -qq install -y curl wget
RUN apt-get -qq install -y software-properties-common
RUN apt-get -qq install -y apt-transport-https
RUN apt-get -qq install -y sudo

# ENVIRONMENT
RUN apt-get -qq install -y git perl ruby pkg-config libidn11-dev libwww-perl libz-dev libaio-dev libncurses-dev libexpat-dev libpcre3-dev libperl-dev libpopt-dev libbz2-dev libtest-simple-perl libsocket6-perl libtest-inter-perl libtest-warn-perl libtest-deep-perl debhelper
RUN apt-get update && apt-get -qq install -y lib32z1-dev libz-dev build-essential zlib*
RUN apt-get -qq install -y openjdk-8-jdk ant ant-optional maven rsync
RUN apt-get -qq install -y locales locales-all
RUN curl https://rclone.org/install.sh | sudo bash
RUN locale-gen en_US.UTF-8

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# USER
RUN \
    if id -u 1000 >/dev/null 2>&1; then userdel -r $(id -un 1000); fi && \
    if id -g 1000 >/dev/null 2>&1; then groupdel $(id -gn 1000); fi && \
    groupadd --gid 1000 build \
    && useradd --uid 1000 --gid 1000 -m build \
    && echo build ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/build \
    && chmod 0440 /etc/sudoers.d/build \
    && chown -R 1000:1000 /home/build

USER build
WORKDIR /home/build
CMD ["/usr/local/zimbra-foss-builder/zimbra-builder.sh", "${ZM_BUILD_RELEASE_NO}", "${ZM_BUILD_BRANCH}", "${ZM_BUILD_GIT_DEFAULT_TAG}", "${PIMBRA_ENABLED}"]
