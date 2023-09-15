#!/bin/bash

# Check for root or sudo permissions
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root or with sudo."
    exit
fi

source ./update_and_install_bc_library.sh
source ./update_and_install_services_library.sh

install_bc_main

install_or_update_service