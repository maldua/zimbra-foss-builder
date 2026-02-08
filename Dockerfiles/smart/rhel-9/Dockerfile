FROM rockylinux:9

ARG ZIMBRA_BUILDER_UID
ARG ZIMBRA_BUILDER_GID
ARG ZM_BUILD_RELEASE_NO
ARG ZM_BUILDER_ID
ARG PIMBRA_ENABLED

ENV RELEASE_NO=${ZM_BUILD_RELEASE_NO}
ENV BUILDER_ID=${ZM_BUILDER_ID}
ENV PIMBRA_ENABLED=${PIMBRA_ENABLED}

# Some ideas were taken from: https://github.com/Zimbra/zm-base-os

# SYSTEM
RUN yum clean all
RUN yum upgrade -y
RUN yum install -y wget which
RUN yum install -y sudo

# ENVIRONMENT
RUN yum install -y git perl ruby
RUN yum install -y perl-Data-Dumper perl-IPC-Cmd
RUN yum install -y gcc gcc-c++ make ant ant-junit maven
RUN yum install -y rpm-build createrepo zlib* rsync
RUN curl https://rclone.org/install.sh | sudo bash
# Install OpenJDK 8 and 11
RUN yum install -y java-1.8.0-openjdk-devel java-11-openjdk-devel

# Set up alternatives for Java 8
RUN update-alternatives --install /usr/bin/java java /usr/lib/jvm/java-1.8.0-openjdk/bin/java 1
RUN update-alternatives --set java /usr/lib/jvm/java-1.8.0-openjdk/bin/java
RUN update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/java-1.8.0-openjdk/bin/javac 1
RUN update-alternatives --set javac /usr/lib/jvm/java-1.8.0-openjdk/bin/javac

RUN yum install -y https://vault.centos.org/centos/8/PowerTools/x86_64/os/Packages/xerces-j2-2.11.0-34.module_el8.0.0+30+832da3a1.noarch.rpm \
		   https://vault.centos.org/centos/8/PowerTools/x86_64/os/Packages/xml-commons-resolver-1.2-26.module_el8.0.0+30+832da3a1.noarch.rpm \
		   https://vault.centos.org/centos/8/PowerTools/x86_64/os/Packages/xalan-j2-2.7.1-38.module_el8.0.0+30+832da3a1.noarch.rpm \
		   https://vault.centos.org/centos/8/PowerTools/x86_64/os/Packages/xml-commons-apis-1.4.01-25.module_el8.0.0+30+832da3a1.noarch.rpm \
		   https://vault.centos.org/centos/8/PowerTools/x86_64/os/Packages/ant-contrib-1.0-0.32.b3.module_el8.0.0+30+832da3a1.noarch.rpm

# To enable powertools
# Check - https://wiki.rockylinux.org/rocky/repo/#notes-on-difference-between-x-and-xy-in-mirrors
# And check - https://forums.rockylinux.org/t/how-do-i-install-powertools-on-rocky-linux-9/7427
RUN sudo dnf install -y 'dnf-command(config-manager)'
RUN dnf config-manager --enable crb

# USER
RUN groupadd --gid ${ZIMBRA_BUILDER_GID} build \
    && useradd --uid ${ZIMBRA_BUILDER_UID} --gid ${ZIMBRA_BUILDER_GID} -m build \
    && echo build ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/build \
    && chmod 0440 /etc/sudoers.d/build \
    && mkdir -p /home/build/installer-build \
    && chown -R ${ZIMBRA_BUILDER_UID}:${ZIMBRA_BUILDER_GID} /home/build

USER build
WORKDIR /home/build
CMD ["/usr/local/zimbra-foss-builder/zimbra-smart-builder.sh"]
