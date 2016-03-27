#! /bin/bash -x

# Adding user task to run server
useradd -U -m -s /bin/bash task

# Installing necessary package to build
apt-get update \
    && apt-get upgrade -y -o Dpkg::Options::="--force-confold"
apt-get install curl uuid-dev make cmake gcc g++ libgnutls-dev

# Taskd build
curl -O https://taskwarrior.org/download/taskd-1.1.0.tar.gz \
    && tar xzf taskd-1.1.0.tar.gz \
    && cd taskd-1.1.0 \
    || exit 1

cmake -DCMAKE_BUILD_TYPE=release . \
    && make \
    && make install

mkdir -p /etc/service/taskd
mv ./run.sh /etc/service/taskd/run
chmod u+x /etc/service/taskd/run
