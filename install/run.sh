#! /bin/bash -x

# Retrieve container environement
source /install/default_env
source /install/functions.src.sh

# First run configuration
if [ "$INIT" != "Done" ]; then
    mkdir -p ${TASKD_HOME}/{data,log,run,server_certs,client_certs}
    mkdir -p ${TASKD_BACKUP_DIR}

    echo "BITS=${BITS}" > ${TASKD_INSTALL_DIR}/pki/vars
    echo "EXPIRATION_DAYS=${EXPIRATION_DAYS}" >> ${TASKD_INSTALL_DIR}/pki/vars
    echo "ORGANIZATION=${ORGANIZATION}" >> ${TASKD_INSTALL_DIR}/pki/vars
    echo "CN=${CN}" >> ${TASKD_INSTALL_DIR}/pki/vars
    echo "COUNTRY=${COUNTRY}}" >> ${TASKD_INSTALL_DIR}/pki/vars
    echo "STATE=${STATE}" >> ${TASKD_INSTALL_DIR}/pki/vars
    echo "LOCALITY=${LOCALITY}" >> ${TASKD_INSTALL_DIR}/pki/vars

    #Generate initial certificates
    cd ${TASKD_INSTALL_DIR}/pki/ \
        && ./generate.ca \
        && ./generate.server \
        && ./generate.crl \
        && ./generate.client ${TASKD_DEFAULT_USER}
    mv ${TASKD_INSTALL_DIR}/pki/*.pem ${TASKD_CERTS_DIR}
    mv ${TASKD_CERTS_DIR}/${TASKD_DEFAULT_USER}.*.pem ${TASKD_CLIENTS_DIR}

    chown -R ${TASKD_USER}:${TASKD_USER} ${TASKD_HOME}
    # Configure paths & certificates
    exec_as taskd init --data ${TASKD_DATA_DIR}
    exec_as taskd config --data ${TASKD_DATA_DIR} server.cert ${TASKD_CERTS_DIR}/server.cert.pem
    exec_as taskd config --data ${TASKD_DATA_DIR} server.key ${TASKD_CERTS_DIR}/server.key.pem
    exec_as taskd config --data ${TASKD_DATA_DIR} server.crl ${TASKD_CERTS_DIR}/server.crl.pem
    exec_as taskd config --data ${TASKD_DATA_DIR} client.cert ${TASKD_CLIENTS_DIR}/client.cert.pem
    exec_as taskd config --data ${TASKD_DATA_DIR} client.key ${TASKD_CLIENTS_DIR}/client.key.pem
    exec_as taskd config --data ${TASKD_DATA_DIR} ca.cert ${TASKD_CERTS_DIR}/ca.cert.pem
    exec_as taskd config --data ${TASKD_DATA_DIR} server ${TASKD_SERVER}:${TASKD_PORT}
    exec_as taskd config --data ${TASKD_DATA_DIR} log ${TASKD_LOG_DIR}/taskd.log
    exec_as taskd config --data ${TASKD_DATA_DIR} pid.file ${TASKD_RUNTIME_DIR}/pid.file

    exec_as taskd add --data ${TASKD_DATA_DIR} org "${TASKD_DEFAULT_ORG}"
    exec_as taskd add --data ${TASKD_DATA_DIR} group "${TASKD_DEFAULT_ORG}" "${TASKD_DEFAULT_GROUP}"
    exec_as taskd add --data ${TASKD_DATA_DIR} user "${TASKD_DEFAULT_ORG}" "${TASKD_DEFAULT_USER}"


    # No init next time
    echo "INIT=Done" >> ${TASKD_INSTALL_DIR}/default_env
fi


case $1 in
    backup)
        tar cvjf "${TASKD_BACKUP_DIR}/taskd.$(date +"%Y%m%d_%H%M%S").tar.bz2" "${TASKD_DATA_DIR}"
        ;;
    add_client)
        shift
        exec_as ${TASKD_INSTALL_DIR}/pki/generate.client $1
        exec_as taskd add user "$@"
        ;;
    regenerate)
        exec_as ${TASKD_INSTALL_DIR}/pki/generate.server
        exec_as ${TASKD_INSTALL_DIR}/pki/generate.cr
        ;;
    start)
        taskd server --data ${TASKD_DATA_DIR} --daemon --debug
        ;;
    *)
        cmd=${1:-taskd status}
        shift
        exec_as $cmd "$@"
        ;;
esac


