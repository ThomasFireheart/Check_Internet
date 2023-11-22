#!/bin/bash

# Default server to ping
PING_SERVER="8.8.8.8"

# Default mode is testing
is_test_run="testing"

# Get the hostname of the system
HOSTNAME=$(hostname)

# Display help message
display_help() {
    echo "Usage: $0 [mode] [ping_server]"
    echo "  mode        - Operation mode: 'testing' or 'production'. Default is 'testing'."
    echo "  ping_server - The server to ping. Default is '8.8.8.8'."
    echo
    echo "Example: $0 testing 1.1.1.1"
    echo "         This will run the script in testing mode and ping the server 1.1.1.1."
}

# Check command line arguments
if [ "$#" -eq 0 ]; then
    display_help
    exit 0
elif [ "$#" -ge 1 ]; then
    if [ "$1" = "testing" ] || [ "$1" = "production" ]; then
        is_test_run="$1"
    else
        echo "Error: First argument must be 'testing' or 'production'."
        display_help
        exit 1
    fi
fi

if [ "$#" -eq 2 ]; then
    PING_SERVER="$2"
fi

# Function to log message to syslog with hostname
log_to_syslog() {
    logger -s "$HOSTNAME: Internet Check Script: $1"
}

# Function to check internet access
check_internet_access() {
    log_to_syslog "Starting internet access check to $PING_SERVER."

    # Ping the server to check for internet access
    if ping -c 4 $PING_SERVER > /dev/null; then
        # Internet is accessible
        log_to_syslog "Internet access is available."
    else
        # Internet is not accessible
        if [ "$is_test_run" = "production" ]; then
            # Production run, initiate reboot
            log_to_syslog "Internet access is not available, initiating reboot."
            /sbin/reboot
        else
            # Test run, skipping reboot
            log_to_syslog "Internet access is not available, but this is a test run, so skipping reboot."
        fi
    fi

    log_to_syslog "Internet access check completed."
}

# Check internet access
check_internet_access
