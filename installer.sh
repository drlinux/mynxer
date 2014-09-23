#!/bin/bash

# set default values
tput clear

source mynxer.conf


install_mynxer(){

    sys_check

    cp -f mynxer.conf /etc/mynxer.conf

    cp -f mynxer.sh /sbin/mynxer

    cp -rf index-page-templates/ /usr/share/mynxer/

    cp -rf virtual-host-templates/ /usr/share/mynxer/

    cp README.md /usr/share/mynxer/

    cp LICENSE /usr/share/mynxer/

}

install_mynxer

