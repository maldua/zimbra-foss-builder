FROM centos:7

ARG ZM_BUILD_RELEASE_NO

# Some ideas were taken from: https://github.com/Zimbra/zm-base-os

# SYSTEM
RUN yum clean all
RUN yum upgrade -y
RUN yum install -y curl wget which
RUN yum install -y sudo

# ENVIRONMENT
RUN yum install -y perl ruby
RUN yum install -y perl-Data-Dumper perl-IPC-Cmd
RUN yum install -y gcc gcc-c++ make
RUN yum install -y java-1.8.0-openjdk ant ant-junit maven
RUN yum install -y rpm-build createrepo rsync
RUN curl https://rclone.org/install.sh | sudo bash
RUN yum install -y install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm
RUN yum install -y git

RUN mkdir -p /home/build/installer-build

WORKDIR /home/build
ENTRYPOINT ["/usr/local/zimbra-foss-builder/zimbra-smart-builder.sh"]
CMD ["10.0.7"]
