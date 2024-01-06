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

function narsil_cockpit()
{
    msg_info '\n%s\n' "[${STATS}] Remove cockpit web console"

    dnf remove -y cockpit* >/dev/null 2>&1

    directories=(
        "/run/cockpit"
        "/etc/cockpit"
        "/usr/share/cockpit"
        "/usr/share/doc/cockpit"
        "/var/lib/selinux/targeted/active/modules/100/cockpit"
        "/usr/share/selinux/targeted/default/active/modules/100/cockpit"
    )

    for directory in "${directories[@]}"; do
        rm -rf "$directory"
    done

    msg_succ '%s\n' "Complete!"

    sleep 1

    ((STATS++))
}
