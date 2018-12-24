FROM alpine:3.7
MAINTAINER frenchbeard <frenchbeard@frenchbeardsec.info>

ENV TASKD_VERSION=1.1.0 \
    TASKD_USER="task" \
    TASKD_HOME="/home/task"

ENV TASKD_INSTALL_DIR="/install" \
    TASKD_RUNTIME_DIR="${TASKD_HOME}/run" \
    TASKD_DATA_DIR="$TASKD_DATA_DIR" \
    TASKD_BACKUP_DIR="/backup"

RUN apk update \
    && apk add --no-cache taskd gnutls-utils bash sudo \
    && adduser -h ${TASKD_HOME} -D -s /bin/bash ${TASKD_USER}

ADD install/ ${TASKD_INSTALL_DIR}

WORKDIR ${TASKD_RUNTIME_DIR}
VOLUME ${TASKD_HOME}

EXPOSE 53589
ENTRYPOINT ["/install/run.sh"]
CMD ["start"]
