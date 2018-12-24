#! /bin/sh -x
set -e

# Adding user task to run server
adduser -h ${TASKD_HOME} -D -s /bin/bash ${TASKD_USER}

# Installing necessary package to run
apk update
apk add --no-cache taskd taskd-pki

mdkdir -p ${TASKD_HOME}/{install,data,log,cache,run}
mv ./run.sh ${TASKD_RUNTIME_DIR}/
chmod 700 ${TASKD_RUNTIME_DIR}/run.sh
