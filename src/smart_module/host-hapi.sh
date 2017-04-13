#!/bin/bash

# HAPI Project
# Author: Pedro Freitas
# Release: 0.1-alpha (2017)
# Copyright 2017 Maya Culpa, LLC
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Set
# -e : exit on a non-zero return status code
# -u : prevent using undefined variables
set -eu

# Global Variables
# HAPI_HOSTNAME will hold the MQTT Broker we want to connect.
HAPI_HOSTNAME="mqttbroker"

# CONSTANT variable to hold date/hour format
DFORMAT="+%m/%d/%y %H:%M:%S"

# Information control functions.
# They can be updated to write to a log file, such as:
#  | tee -a "$LOG_FILE" >&2
fatal() {
    echo "[FATAL] [$(date "$DFORMAT")] $*"
    exit 1
}

info() {
    echo "[INFO] [$(date "$DFORMAT")] $*"
}

error() {
    echo "[ERROR] [$(date "$DFORMAT")] $*"
}

# Check if we already have a device with the hostname mqttbroker{.local}
# It depends on avahi/bonjour
check_mqttbroker() {
    info "Checking if ${HAPI_HOSTNAME} already exists."
    if ping -W 1 -c 2 -s 1 ${HAPI_HOSTNAME}.local > /dev/null 2>&1 ; then
        info "${HAPI_HOSTNAME} does exist."
        return 0
    else
        info "${HAPI_HOSTNAME} does not exist."
        return 1
    fi
}

main() {
    # Are we root?
    [[ "$EUID" -ne 0 ]] && fatal "Please run as root."

    if check_mqttbroker ; then
        info "Exiting with ${HAPI_HOSTNAME} already on."
        exit 1
    else
        info "Changing hostname to ${HAPI_HOSTNAME}."
        if hostname ${HAPI_HOSTNAME} ; then
            info "Restarting avahi-daemon.service."
            systemctl restart avahi-daemon.service
            info "Exiting..."
            exit 0
        else
            error "Changing hostname not possible."
            exit 1
        fi
    fi
}

# Call the main function
main
