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

function narsil_sshport()
{
    if [ ! -e "/etc/ssh/sshd_config" ];then
        msg_error '\n%s\n' "Error: Can't find sshd config file!"
        exit 1
    fi

    # Install netstat
    dnf install -y net-tools >/dev/null 2>&1

    old_sshport=$( grep ^Port /etc/ssh/sshd_config | awk '{print $2}' | head -1 )

    if [ -z "${old_sshport}" ];then
        old_sshport='22'
    fi

    msg_notic '\n%s' "[1/2] Please enter SSH port (Range of 10000 to 65535, current is ${old_sshport}): "

    while :; do
        read -r new_sshport
        NPTSTATUS=$( netstat -lnp | grep "${new_sshport}" )
        if [ -n "${NPTSTATUS}" ];then
            msg_error '%s' "The port is already occupied, Please try again (Range of 10000 to 65535): "
        elif [ "${new_sshport}" -lt 10000 ] || [ "${new_sshport}" -gt 65535 ];then
            msg_error '%s' "Please try again (Range of 10000 to 65535): "
        else
            break
        fi
    done

    if [[ "${old_sshport}" != "22" ]]; then
        sed -i "s@^Port.*@Port ${new_sshport}@" /etc/ssh/sshd_config
    else
        sed -i "s@^#Port.*@&\nPort ${new_sshport}@" /etc/ssh/sshd_config
        sed -i "s@^Port.*@Port ${new_sshport}@" /etc/ssh/sshd_config
    fi

    msg_succ '%s\n' "Success, the SSH port modification completed!"
    msg_notic '\n%s\n' "[2/2] Restart the service to take effect"
    systemctl restart sshd.service >/dev/null 2>&1
    msg_succ '%s\n\n' "Success, don't forget to enable [TCP:${new_sshport}] for the security group!"
}
