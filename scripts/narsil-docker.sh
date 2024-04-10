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

    DOCKER_CE_REPO=${DOCKER_CE_REPO:-'https://mirrors.cloud.tencent.com/docker-ce'}
    DOCKER_HUB_MIRRORS=${DOCKER_HUB_MIRRORS:-'https://hub.c.163.com'}
    DOCKER_CE_MIRROR=${DOCKER_CE_MIRROR:-'mirrors.cloud.tencent.com'}
    VERIFY=${VERIFY:-'Y'}
    METADATA=${METADATA:-'Y'}

    if [[ ${METADATA^^} == 'Y' ]]; then
        if [ -n "$(wget -qO- -t1 -T2 metadata.tencentyun.com)" ]; then
            DOCKER_CE_REPO='https://mirrors.cloud.tencent.com/docker-ce'
            DOCKER_HUB_MIRRORS='https://mirror.ccs.tencentyun.com'
        elif [ -n "$(wget -qO- -t1 -T2 100.100.100.200)" ]; then
            DOCKER_CE_REPO='http://mirrors.cloud.aliyuncs.com/docker-ce'
            DOCKER_HUB_MIRRORS='https://narsil.mirror.aliyuncs.com'
        fi
    fi

    # Uninstall Docker Engine
    dnf remove -y docker* containerd.io podman* runc >/dev/null 2>&1

    # Install Dependencies
    dnf config-manager --add-repo "${DOCKER_CE_REPO}"/linux/centos/docker-ce.repo
    sed -i "s|download.docker.com|${DOCKER_CE_MIRROR}/docker-ce|g" /etc/yum.repos.d/docker-ce.repo

    # Install Docker
    dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    mkdir -p /etc/docker

    {
        echo '{'
        echo '  "registry-mirrors": ['
        echo "    \"${DOCKER_HUB_MIRRORS}\""
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
