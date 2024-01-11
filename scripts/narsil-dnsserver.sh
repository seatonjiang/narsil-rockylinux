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

function narsil_dnsserver()
{
    msg_info '\n%s\n' "[${STATS}] Change DNS Server"

    local NEW_DNSSERVER

    NEW_DNSSERVER='119.29.29.29 223.5.5.5'

    if [ "${NEW_DNSSERVER}" != "${DNS_SERVER}" ]; then
        NEW_DNSSERVER=${DNS_SERVER}
    fi

    if [[ ${METADATA^^} == 'Y' ]]; then
        if [ -n "$(wget -qO- -t1 -T2 metadata.tencentyun.com)" ]; then
            NEW_DNSSERVER='183.60.83.19 183.60.82.98'
        fi
    fi

    if [ -f /etc/cloud/cloud.cfg ]; then
        sed -i '/resolv_conf/d' /etc/cloud/cloud.cfg
    fi

    nmcli con mod "System eth0" ipv4.dns "${NEW_DNSSERVER}" >/dev/null 2>&1
    nmcli con mod "eth0" ipv4.dns "${NEW_DNSSERVER}" >/dev/null 2>&1

    sed -i '/PEERDNS=/d' /etc/sysconfig/network-scripts/ifcfg-eth0
    echo "PEERDNS=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0

    systemctl restart NetworkManager.service

    if [[ ${VERIFY^^} == 'Y' ]]; then
        msg_notic '\n%s\n' "• File Content: /etc/resolv.conf"
        grep -Ev '^#|^$' /etc/resolv.conf | uniq
    else
        msg_succ '%s\n' "Complete!"
    fi

    sleep 1

    ((STATS++))
}
