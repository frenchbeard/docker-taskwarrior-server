#! /usr/bin/env bash

TASKD_HOME="./taskd_home"
TASK_HOME="./task_home"
VERSION="0.1.0"

echo -en "Resetting container and ${TASKD_HOME}...\r"
if docker ps | grep -q taskd-demo; then
    docker stop taskd-demo;
fi

rm -rf "$(pwd)/${TASKD_HOME:?}"
mkdir -p "$(pwd)/${TASKD_HOME}/run"
echo "Resetting container and ${TASKD_HOME}... Done"
docker ps | grep -q taskd-demo \
    && docker stop taskd-demo \
    || true
docker ps -a | grep -q taskd-demo \
    && docker rm taskd-demo \
    || true
docker run --name='taskd-demo' -d \
    --volume "$(pwd)/${TASKD_HOME}:/home/task" \
    --volume /etc/hosts:/etc/hosts:ro \
    --publish=53589:53589 "$USER/taskd:$VERSION" taskd server --debug --debug.tls=2

echo -ne "Docker container started, waiting for user to be created...\r"
WAIT=0
while ! [ -d ./taskd_home/data/orgs/Default\ organization/users/ ]; do
    sleep 1
    if [ $WAIT -lt 10 ]; then
        WAIT=$((WAIT + 1))
    else
        echo "Docker container started, waiting for user to be created... Aborted"
        echo "Container should have genereated first user by now... stopping everything !!!!"
        docker ps | grep -q taskd-demo && docker stop taskd-demo || echo
        "Container stopped, displaying logs..."
        [ -f Makefile ] && make logs
        unset WAIT
        exit 1
    fi
done
echo "Docker container started, waiting for user to be created... Done"

echo "Retrieving user data :"
user_id="None"

# hack : for allows globbing on userid
for user in ./taskd_home/data/orgs/Default\ organization/users/*;
do
    user_id=${user##*/}
    echo "User id: $user_id"
    echo "User name: $(grep user "$user/config" | cut -d'=' -f2) (should be 'user'"
    # init temporary task data dir
    [ -d "${TASK_HOME}" ] \
        && rm -rf "${TASK_HOME}" \
        || echo "No previous temporary task home, creating one"
    mkdir -p "$TASK_HOME"
    echo "data.location=$(pwd)/${TASK_HOME}" > "${TASK_HOME}"/.taskrc
    cp ${TASKD_HOME}/client_certs/user.*.pem "${TASK_HOME}"/
    echo  "Retrieved user and CA certificates, configuring..."
    TASKRC="${TASK_HOME}/.taskrc"
    export TASKRC
    task config taskd.certificate "${TASK_HOME}"/user.cert.pem
    task config taskd.key -- "${TASK_HOME}"/user.key.pem
    task config taskd.ca -- "${TASKD_HOME}"/server_certs/ca.cert.pem
    task config taskd.server -- task.localhost:53589
    task config taskd.credentials -- "Default organization/user/$user_id"
    task sync init
done

# Make sure some user was created, otherwise exit
[ "$user_id" == "None" ] \
    && echo "Issue, no user created in path ./${TASKD_HOME}/data/orgs/Default\ organization/users/*" \
    && ls -l ./${TASKD_HOME}/data/orgs/Default\ organization/users/ \
    && exit 1

