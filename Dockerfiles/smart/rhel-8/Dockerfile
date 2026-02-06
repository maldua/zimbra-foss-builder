FROM centos:8

ARG ZIMBRA_BUILDER_UID
ARG ZIMBRA_BUILDER_GID
ARG ZM_BUILD_RELEASE_NO
ARG ZM_BUILDER_ID
ARG PIMBRA_ENABLED

# Some ideas were taken from: https://github.com/Zimbra/zm-base-os

# Update mirrors
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# SYSTEM
RUN yum clean all
RUN yum upgrade -y
RUN yum install -y curl wget which
RUN yum install -y sudo

# ENVIRONMENT
RUN yum install -y git perl ruby
RUN yum install -y perl-Data-Dumper perl-IPC-Cmd
RUN yum install -y gcc gcc-c++ make
RUN yum install -y java-1.8.0-openjdk maven
RUN yum install -y rpm-build createrepo rsync
RUN curl https://rclone.org/install.sh | sudo bash
RUN yum install -y https://vault.centos.org/centos/8/PowerTools/x86_64/os/Packages/hamcrest-core-1.3-23.module_el8.0.0+30+832da3a1.noarch.rpm && \
    yum install -y https://vault.centos.org/centos/8/PowerTools/x86_64/os/Packages/junit-4.12-9.module_el8.0.0+30+832da3a1.noarch.rpm && \
    yum install -y https://vault.centos.org/centos/8/PowerTools/x86_64/os/Packages/ant-lib-1.10.5-1.module_el8.0.0+30+832da3a1.noarch.rpm && \
    yum install -y https://vault.centos.org/centos/8/PowerTools/x86_64/os/Packages/ant-1.10.5-1.module_el8.0.0+30+832da3a1.noarch.rpm && \
    yum install -y https://vault.centos.org/centos/8/PowerTools/x86_64/os/Packages/ant-junit-1.10.5-1.module_el8.0.0+30+832da3a1.noarch.rpm

# USER
RUN groupadd --gid ${ZIMBRA_BUILDER_GID} build \
    && useradd --uid ${ZIMBRA_BUILDER_UID} --gid ${ZIMBRA_BUILDER_GID} -m build \
    && echo build ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/build \
    && chmod 0440 /etc/sudoers.d/build \
    && mkdir -p /home/build/installer-build \
    && chown -R ${ZIMBRA_BUILDER_UID}:${ZIMBRA_BUILDER_GID} /home/build

USER build
WORKDIR /home/build
CMD /usr/local/zimbra-foss-builder/zimbra-smart-builder.sh \
      --release-no "${ZM_BUILD_RELEASE_NO}" \
      ${ZM_BUILDER_ID:+--builder-id "${ZM_BUILDER_ID}"} \
      "$( [ "${PIMBRA_ENABLED}" = "true" ] && echo '--pimbra-enabled' )"
