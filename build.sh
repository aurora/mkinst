#!/usr/bin/env bash

#
# Script to create installation package.
#
# copyright (c) 2018 by Harald Lapp <harald@octris.org>
#

rm -f dist/mkinst_installer.bin

usr/local/bin/mkinst -i <(cat << INSTALLER
if [ "\$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi 

untar_payload "/"
INSTALLER
) dist/mkinst_installer.bin usr
