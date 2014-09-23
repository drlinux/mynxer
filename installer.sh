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

    cp -f README.md /usr/share/mynxer/

    cp -f LICENSE /usr/share/mynxer/

    echo "Mynxer installed. please type to use : sudo mynxer"
}

install_mynxer
domain_check
