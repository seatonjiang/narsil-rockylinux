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

function narsil_clearlogs()
{
    msg_notic '\n%s\n\n' "Clearing all syslog files, please wait..."

    find /var/log -type f -regex '.*\.[0-9]$' -delete
    find /var/log -type f -regex '.*-[0-9]*$' -delete
    find /var/log -type f -regex '.*\.gz$' -delete

    while IFS= read -r -d '' LOGFILES
    do
        true > "${LOGFILES}"
    done < <(find /var/log/ -type f ! -name 'narsil-*' -print0)

    dnf clean all >/dev/null 2>&1
    history -c
    history -w

    msg_succ '%s\n\n' "All syslog files have been cleaned!"
}
