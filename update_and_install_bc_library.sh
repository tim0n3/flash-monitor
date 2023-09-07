#!/bin/bash

# Library script for updating APT repositories and installing 'bc' if not already installed.

# Define log file paths
LOG_FILE="/var/log/update_and_install_bc.log"
ERROR_LOG_FILE="/var/log/update_and_install_bc_error.log"

# Enable debugging and redirect stdout and stderr to log files
set -oue pipefail
exec > >(tee -a "$LOG_FILE") 2> >(tee -a "$ERROR_LOG_FILE" >&2)

# Function to update APT repositories
update_apt_repositories() {
    echo "Updating APT repositories..."
    sudo apt update
}

# Function to install 'bc' if not already installed
install_bc() {
    if ! dpkg -l | grep -q "ii  bc "; then
        echo "bc is not installed. Installing..."
        sudo apt install bc -y
        echo "bc has been installed."
    else
        echo "bc is already installed."
    fi
}

# Main function to execute the update and installation tasks
install_bc_main() {
    update_apt_repositories
    install_bc
    echo "Dependancy checks completed."
}

# Only uncomment if running as stand alone script.
# Call the main function to start the script
#install_bc_main "$@"
