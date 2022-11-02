FROM ubuntu:22.04
ARG DISTRO=UBUNTU

RUN apt-get -yq update
RUN apt-get -yq install supervisor gnupg unzip lsb-release software-properties-common jq curl supervisor liblttng-ust-common1 liblttng-ust-ctl5 libnuma1 liblttng-ust1 git rsync locales htop

COPY docker/supervisor/supervisord.conf /etc/supervisord.conf
COPY docker/src/* /tmp

RUN chmod u+x /tmp/*.sh
RUN /tmp/install_hashicorp.sh
RUN /tmp/install_aws.sh
RUN /tmp/install_docker.sh

ENV RUNNER_ALLOW_RUNASROOT="1"
RUN apt-get clean -y

RUN mkdir -p /tmp/logs/

CMD ["/usr/bin/supervisord"]
