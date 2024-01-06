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
    if [[ ${METADATA^^} == "Y" ]]; then
        if [ -n "$(wget -qO- -t1 -T2 metadata.tencentyun.com)" ]; then
            get_hostname=$(wget -qO- -t1 -T2 metadata.tencentyun.com/latest/meta-data/instance-name)
        fi
    fi

    if [ "${get_hostname}" == "未命名" ]; then
        get_hostname='RockyLinux'
    fi

    if [ 'RockyLinux' != "${HOSTNAME}" ]; then
        get_hostname=${HOSTNAME}
    fi

    msg_notic '\n%s' "Please enter new hostname [Default: ${get_hostname}]: "

    while :; do
        read -r new_hostname
        new_hostname=${new_hostname:-"${get_hostname}"}
        break
    done

    hostnamectl set-hostname --static "${new_hostname}"
    sed -i '/update_hostname/d' /etc/cloud/cloud.cfg

    msg_succ '\n%s\n\n' "Hostname has been changed successfully!"

    exit 0
}
