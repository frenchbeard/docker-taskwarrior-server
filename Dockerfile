FROM alpine:3.6
MAINTAINER frenchbead <frenchbeard@protonmail.com>

ENV TASKD_VERSION=1.1.0 \
    TASKD_USER="task" \
    TASKD_HOME="/home/task"

ENV TASKD_DATA_DIR="${TASKD_HOME}/data" \
    TASKD_LOG_DIR="${TASKD_HOME}/log" \
    TASKD_INSTALL_DIR="${TASKD_HOME}/install" \
    TASKD_CACHE_DIR="${TASKD_HOME}/cache" \
    TASKD_RUNTIME_DIR="${TASKD_HOME}/run/"

RUN apk add --no-cache taskd taskd-pki bash

ADD install/ ${TASKD_INSTALL_DIR}
RUN ${TASKD_INSTALL_DIR}/build.sh

WORKDIR ${TASKD_HOME}
VOLUME ${TASKD_HOME}

EXPOSE 53589
ENTRYPOINT ["${TASKD_RUNTIME_DIR}/run.sh"]
CMD ["start"]
