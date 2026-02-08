FROM ubuntu:24.04

ARG ZIMBRA_BUILDER_UID
ARG ZIMBRA_BUILDER_GID
ARG RELEASE_NO
ARG BUILD_BRANCH
ARG GIT_DEFAULT_TAG
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
    if id -u ${ZIMBRA_BUILDER_UID} >/dev/null 2>&1; then userdel -r $(id -un ${ZIMBRA_BUILDER_UID}); fi && \
    if id -g ${ZIMBRA_BUILDER_GID} >/dev/null 2>&1; then groupdel $(id -gn ${ZIMBRA_BUILDER_GID}); fi && \
    groupadd --gid ${ZIMBRA_BUILDER_GID} build \
    && useradd --uid ${ZIMBRA_BUILDER_UID} --gid ${ZIMBRA_BUILDER_GID} -m build \
    && echo build ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/build \
    && chmod 0440 /etc/sudoers.d/build \
    && mkdir -p /home/build/installer-build \
    && chown -R ${ZIMBRA_BUILDER_UID}:${ZIMBRA_BUILDER_GID} /home/build

USER build
WORKDIR /home/build
CMD ["/usr/local/zimbra-foss-builder/zimbra-builder.sh"]
