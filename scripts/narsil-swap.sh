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

function narsil_swap()
{
    msg_notic '\n%s\n' "Swap space is being added, please wait..."

    memory=$(free -m | awk '/Mem:/{print $2}')

    if [ "${memory}" -le 1280 ]; then
        memory_level=1G
    elif [ "${memory}" -gt 1280 ] && [ "${memory}" -le 2500 ]; then
        memory_level=2G
    elif [ "${memory}" -gt 2500 ] && [ "${memory}" -le 3500 ]; then
        memory_level=3G
    elif [ "${memory}" -gt 3500 ] && [ "${memory}" -le 4500 ]; then
        memory_level=4G
    elif [ "${memory}" -gt 4500 ] && [ "${memory}" -le  8000 ]; then
        memory_level=6G
    elif [ "${memory}" -gt 8000 ]; then
        memory_level=8G
    fi

    if [ "$(free -m | awk '/Swap:/{print $2}')" == '0' ]; then
        fallocate -l "${memory_level}" /swapfile
        chmod 600 /swapfile
        mkswap /swapfile >/dev/null 2>&1
        swapon /swapfile
        sed -i "/swap/d" /etc/fstab
        echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
    fi

    if ! sysctl -p | grep -q vm.swappiness; then
        {
            echo -e '\n# Setting the swappiness'
            echo "vm.swappiness=10"
        } >> /etc/sysctl.conf
    else
        sed -i "s/^vm.swappiness=.*/vm.swappiness=10/" /etc/sysctl.conf
    fi

    if ! sysctl -p | grep -q vm.vfs_cache_pressure; then
        {
            echo -e '\n# Setting the vfs_cache_pressure'
            echo "vm.vfs_cache_pressure=50"
        } >> /etc/sysctl.conf
    else
        sed -i "s/^vm.vfs_cache_pressure=.*/vm.vfs_cache_pressure=50/" /etc/sysctl.conf
    fi

    sysctl -p >/dev/null 2>&1

    msg_notic '\n%s\n' "[1/3] Check swap space"
    swapon --show
    msg_notic '\n%s\n' "[2/3] Show query memory"
    free -h
    msg_notic '\n%s\n' "[3/3] Show file content: /etc/fstab"
    grep -Ev '^#|^$' /etc/fstab | uniq

    printf '\n%s%s\n%s%s\n\n' "$(tput setaf 4)$(tput bold)" \
    "Done, Swap space has been added!" \
    "The log of this execution can be found at ${LOGFILE}" \
    "$(tput sgr0)" >&3
}
