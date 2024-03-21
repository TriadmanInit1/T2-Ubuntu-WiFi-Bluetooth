#!/bin/bash

is_root() {
    [ "$(id -u)" -eq 0 ]
}

is_sudo() {
    [ ! -z "$SUDO_USER" ]
}

setup_firmware() {
    firmware_directory="/lib/firmware/brcm"
    url_for_firmware="https://github.com/ztybigcat/brcm43xx/raw/main/brcm.tar.gz"

    download_tar() {
        curl -o brcm.tar.gz -L "$url_for_firmware"
    }

    extract_tar() {
        tar -xzvf brcm.tar.gz
    }

    copy_tar() {
        source_dir=$(pwd)/brcm
        destination_dir=$firmware_directory

        find "$source_dir" -type f -exec cp -v '{}' "$destination_dir" \;
    }

    reboot_suggest() {
        read -p "A reboot is highly recommended. Reboot now? (y/n)" option
        case "$option" in
            [Yy]* ) reboot ;;
            [Nn]* ) exit ;;
            * ) echo "Invalid input - '$option' not an option."; reboot_suggest ;;
        esac
    }

    download_tar || { echo "Error: Failed to download firmware tarball."; exit 1; }
    extract_tar || { echo "Error: Failed to extract firmware tarball."; exit 1; }
    copy_tar || { echo "Error: Failed to copy firmware files to destination directory."; exit 1; }
    
    echo "Firmware installation completed successfully."
}

main() {
    if ! is_sudo; then
        echo "Error: This script must be run with sudo."
        exit 1
    fi

    echo "Downloading firmware..."
    setup_firmware
}

main
