FROM phusion/baseimage:0.9.18
MAINTAINER frenchbead <frenchbeardsec@gmail.com>

CMD ["/sbin/init"]

ADD install/ /install
WORKDIR /install
RUN build.sh

VOLUME /home/task/data

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /install
