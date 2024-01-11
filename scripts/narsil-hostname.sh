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

function narsil_hostname()
{
    local NEW_HOSTNAME

    if [[ ${METADATA^^} == 'Y' ]]; then
        if [ -n "$(wget -qO- -t1 -T2 metadata.tencentyun.com)" ]; then
            NEW_HOSTNAME=$(wget -qO- -t1 -T2 metadata.tencentyun.com/latest/meta-data/instance-name)
        fi
    fi

    if [ "${NEW_HOSTNAME}" == "未命名" ]; then
        NEW_HOSTNAME='RockyLinux'
    fi

    if [ 'RockyLinux' != "${HOSTNAME}" ]; then
        NEW_HOSTNAME=${HOSTNAME}
    fi

    msg_notic '\n%s' "Please enter new hostname [Default: ${NEW_HOSTNAME}]: "

    while :; do
        read -r GET_HOSTNAME
        GET_HOSTNAME=${GET_HOSTNAME:-"${NEW_HOSTNAME}"}
        break
    done

    hostnamectl set-hostname --static "${GET_HOSTNAME}"
    sed -i '/update_hostname/d' /etc/cloud/cloud.cfg

    msg_succ '\n%s\n\n' "Hostname has been changed successfully!"

    exit 0
}
