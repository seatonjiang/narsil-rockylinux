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

    docker_ce='https://mirrors.cloud.tencent.com/docker-ce/linux/centos/docker-ce.repo'
    docker_mirrors='mirrors.cloud.tencent.com'
    docker_hub='https://hub-mirror.c.163.com'

    if [ "${docker_ce}" != "${DOCKER_CE_REPO}" ]; then
        docker_ce=${DOCKER_CE_REPO}
    fi

    if [ "${docker_mirrors}" != "${DOCKER_CE_MIRROR}" ]; then
        docker_mirrors=${DOCKER_CE_MIRROR}
    fi

    if [ "${docker_hub}" != "${DOCKER_HUB_MIRRORS}" ]; then
        docker_hub=${DOCKER_HUB_MIRRORS}
    fi

    if [[ ${METADATA^^} == "Y" ]]; then
        if [ -n "$(wget -qO- -t1 -T2 metadata.tencentyun.com)" ]; then
            docker_hub='https://mirror.ccs.tencentyun.com'
        fi
    fi

    # Uninstall Docker Engine
    dnf remove -y docker* containerd.io podman* runc >/dev/null 2>&1

    # Install Dependencies
    dnf config-manager --add-repo "${docker_ce}"
    sed -i "s|download.docker.com|${docker_mirrors}/docker-ce|g" /etc/yum.repos.d/docker-ce.repo

    # Install Docker
    dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    mkdir -p /etc/docker
    echo "{\"registry-mirrors\":[\"${docker_hub}\"]}" > /etc/docker/daemon.json

    systemctl restart docker.service
    systemctl enable docker.service

    if [[ ${VERIFY} == "Y" ]]; then
        msg_notic '\n%s\n' "• Docker version"
        docker version
        msg_notic '\n%s\n' "• Docker compose version"
        docker compose version
    fi

    printf '\n%s%s\n%s%s\n\n' "$(tput setaf 4)$(tput bold)" \
    "Complete! Please use \`docker run hello-world\` to test." \
    "The log of this execution can be found at ${LOGFILE}" \
    "$(tput sgr0)" >&3
}
