#! /bin/bash -x

# Retrieve container environement
# shellcheck source=./default_env
source "${TASKD_INSTALL_DIR}/default_env"
# shellcheck source=./functions.src.sh
source "${TASKD_INSTALL_DIR}/functions.src.sh"

export TASKDDATA=${TASKD_DATA_DIR}
# First run configuration
if [ "$INIT" != "Done" ]; then
    mkdir -p "${TASKD_HOME}"/{data,log,run,server_certs,client_certs}
    mkdir -p "${TASKD_BACKUP_DIR}"

    {
        echo "BITS=${BITS}"
        echo "EXPIRATION_DAYS=${EXPIRATION_DAYS}"
        echo "ORGANIZATION=${ORGANIZATION}"
        echo "CN=${CN}"
        echo "COUNTRY=${COUNTRY}"
        echo "STATE=${STATE}"
        echo "LOCALITY=${LOCALITY}"
    } > "${TASKD_INSTALL_DIR}/pki/vars"

    #Generate initial certificates
    cd "${TASKD_INSTALL_DIR}/pki/" \
        && ./generate.ca \
        && ./generate.server \
        && ./generate.crl \
        && ./generate.client "${TASKD_DEFAULT_USER}"
    mkdir -p "${TASKD_RUNTIME_DIR}/pki/" \
        && for cert in "${TASKD_INSTALL_DIR}"/pki/*;
        do
            mv "$cert" "${TASKD_RUNTIME_DIR}/pki/"
        done
        mv "${TASKD_RUNTIME_DIR}"/pki/*.pem "${TASKD_CERTS_DIR}"
    mv "${TASKD_CERTS_DIR}/${TASKD_DEFAULT_USER}".*.pem "${TASKD_CLIENTS_DIR}"

    chown -R "${TASKD_USER}:${TASKD_USER}" "${TASKD_HOME}"
    # Configure paths & certificates
    exec_as taskd init
    exec_as taskd config server.cert "${TASKD_CERTS_DIR}/server.cert.pem"
    exec_as taskd config server.key "${TASKD_CERTS_DIR}/server.key.pem"
    exec_as taskd config server.crl "${TASKD_CERTS_DIR}/server.crl.pem"
    exec_as taskd config client.cert "${TASKD_CLIENTS_DIR}/client.cert.pem"
    exec_as taskd config client.key "${TASKD_CLIENTS_DIR}/client.key.pem"
    exec_as taskd config ca.cert "${TASKD_CERTS_DIR}/ca.cert.pem"
    exec_as taskd config server "${TASKD_SERVER}:${TASKD_PORT}"
    exec_as taskd config log "${TASKD_LOG_DIR}/taskd.log"
    exec_as taskd config pid.file "${TASKD_RUNTIME_DIR}/pid.file"
    exec_as taskd config ciphers "${TASKD_CIPHERS}"

    exec_as taskd add org "${TASKD_DEFAULT_ORG}"
    exec_as taskd add group "${TASKD_DEFAULT_ORG}" "${TASKD_DEFAULT_GROUP}"
    exec_as taskd add user "${TASKD_DEFAULT_ORG}" "${TASKD_DEFAULT_USER}"


    # No init next time
    echo "export INIT=Done" >> "${TASKD_HOME}/.profile"
fi


case $1 in
    backup)
        tar cvjf "${TASKD_BACKUP_DIR}/taskd.$(date +"%Y%m%d_%H%M%S").tar.bz2" "${TASKD_DATA_DIR}"
        ;;
    add_client)
        shift # no need for the "add_client" part anymore
        cd "${TASKD_RUNTIME_DIR}/pki" || exit
        exec_as cp "${TASKD_CERTS_DIR}/*.pem" .
        exec_as ./generate.client "$1"
        exec_as taskd add user "$@"
        exec_as tar czf "$1.tgz" "$1".*.pem
        echo "Client certificates availables in $(pwd)/$1.tgz."
        exec_as mv "$1".*.pem "${TASKD_CLIENTS_DIR}"
        rm ./*.pem
        ;;
    regenerate)
        cd "${TASKD_RUNTIME_DIR}/pki" || exit
        exec_as cp "${TASKD_CERTS_DIR}"/ca.*.pem .
        exec_as ./generate.server
        exec_as ./generate.crl
        exec_as mv server.*.pem "${TASKD_CERTS_DIR}"
        rm ./*.pem
        ;;
    start)
        exec taskd server --debug
        ;;
    *)
        cmd=${1:-taskd status}
        shift
        exec_as "$cmd" "$@"
        ;;
esac
