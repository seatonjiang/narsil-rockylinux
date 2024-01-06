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

function narsil_ntpserver()
{
    msg_info '\n%s\n' "[${STATS}] Change NTP Server"

    timedatectl set-ntp true

    dnf install -y chrony >/dev/null 2>&1

    cp ./config/chrony.conf /etc/chrony.conf

    ntpserver='ntp1.tencent.com ntp2.tencent.com ntp3.tencent.com ntp4.tencent.com ntp5.tencent.com'

    if [ "${ntpserver}" != "${NTP_SERVER}" ]; then
        ntpserver=${NTP_SERVER}
    fi

    if [[ ${METADATA^^} == "Y" ]]; then
        if [ -n "$(wget -qO- -t1 -T2 metadata.tencentyun.com)" ]; then
            ntpserver='time1.tencentyun.com time2.tencentyun.com time3.tencentyun.com time4.tencentyun.com time5.tencentyun.com'
        fi
    fi

    local server

    for server in ${ntpserver}; do
        echo "server ${server} iburst" >> /etc/chrony.conf
    done

    systemctl restart chronyd.service

    if [[ ${VERIFY} == "Y" ]]; then
        msg_notic '\n%s\n' "• NTP synchronization status"
        chronyc tracking
        msg_notic '\n%s\n' "• NTP pools"
        chronyc sources
        msg_notic '\n%s\n' "• File Content: /etc/chrony.conf"
        grep -Ev '^#|^$' /etc/chrony.conf | uniq
    else
        msg_succ '%s\n' "Complete!"
    fi

    sleep 1

    ((STATS++))
}
