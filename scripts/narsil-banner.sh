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

function narsil_banner()
{
    msg_info '\n%s\n' "[${STATS}] Add login banner (system info, disk usage and docker status)"

    PROD_TIPS=${PROD_TIPS:-'Y'}
    METADATA=${METADATA:-'Y'}

    if [[ ${METADATA^^} == 'Y' ]]; then
        if [ -n "$(wget -qO- -t1 -T2 100.100.100.200)" ]; then
            find /etc/motd -type f -delete
        fi
    fi

    mkdir -p /etc/banner

    cp ./config/banner.sh /etc/profile.d/narsil-banner.sh
    chmod +x /etc/profile.d/narsil-banner.sh

    cp ./config/banner/*-narsil-* /etc/banner/
    chmod +x /etc/banner/*-narsil-*

    if [[ "${PROD_TIPS^^}" == 'Y' ]]; then
        echo '/etc/banner/20-narsil-footer' >> /etc/profile.d/narsil-banner.sh
    fi

    msg_succ '%s\n' "Complete!"

    sleep 1

    ((STATS++))
}
