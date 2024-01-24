#!/usr/bin/env bash
#
# Narsil (Rocky Linux) - Security hardening tool
# Seaton Jiang <hi@seatonjiang.com>
#
# The latest version of Narsil can be found at:
# https://github.com/seatonjiang/narsil-rockylinux
#
# Licensed under the MIT license:
# https://github.com/seatonjiang/narsil-rockylinux/blob/main/LICENSE
#

function narsil_docker()
{
    msg_notic '\n%s\n\n' "Docker Engine is installing, please wait..."

    local DOCKER_CE
    local DOCKER_MIRRORS
    local DOCKER_HUB

    DOCKER_CE='https://mirrors.cloud.tencent.com/docker-ce/linux/centos/docker-ce.repo'
    DOCKER_MIRRORS='mirrors.cloud.tencent.com'
    DOCKER_HUB='https://hub.c.163.com'

    if [ "${DOCKER_CE}" != "${DOCKER_CE_REPO}" ]; then
        DOCKER_CE=${DOCKER_CE_REPO}
    fi

    if [ "${DOCKER_MIRRORS}" != "${DOCKER_CE_MIRROR}" ]; then
        DOCKER_MIRRORS=${DOCKER_CE_MIRROR}
    fi

    if [ "${DOCKER_HUB}" != "${DOCKER_HUB_MIRRORS}" ]; then
        DOCKER_HUB=${DOCKER_HUB_MIRRORS}
    fi

    if [[ ${METADATA^^} == 'Y' ]]; then
        if [ -n "$(wget -qO- -t1 -T2 metadata.tencentyun.com)" ]; then
            DOCKER_HUB='https://mirror.ccs.tencentyun.com'
        fi
    fi

    # Uninstall Docker Engine
    dnf remove -y docker* containerd.io podman* runc >/dev/null 2>&1

    # Install Dependencies
    dnf config-manager --add-repo "${DOCKER_CE}"
    sed -i "s|download.docker.com|${DOCKER_MIRRORS}/docker-ce|g" /etc/yum.repos.d/docker-ce.repo

    # Install Docker
    dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    mkdir -p /etc/docker

    {
        echo '{'
        echo '  "registry-mirrors": ['
        echo "    \"${DOCKER_HUB}\""
        echo '  ],'
        echo '  "log-driver": "json-file",'
        echo '  "log-opts": {'
        echo '    "max-size": "50m",'
        echo '    "max-file": "7"'
        echo '  }'
        echo '}'
    } > /etc/docker/daemon.json

    systemctl restart docker.service
    systemctl enable docker.service

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• Docker version"
        docker version
        msg_notic '\n%s\n' "• Docker compose version"
        docker compose version
    fi

    printf '\n%s%s\n%s%s\n\n' "$(tput setaf 4)$(tput bold)" \
    "Complete! Please use \"docker run hello-world\" to test." \
    "The log of this execution can be found at ${LOGFILE}" \
    "$(tput sgr0)" >&3
}
