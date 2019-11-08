#!/bin/sh

# Make sure the directory for individual app logs exists
mkdir -p /var/log/shiny-server
chown shiny.shiny /var/log/shiny-server

if[ "$DISCOVER_PACKAGES" = "false" ];
then
    echo "DISCOVER_PACKAGES = false, Using preinstalled packages only"
else
    # scan files in /02_code for required libraries and install missing packages
    Rscript /etc/shiny-server/install_discovered_packages.R
fi

if [ "$APPLICATION_LOGS_TO_STDOUT" = "false" ];
then
    exec shiny-server 2>&1
else
    # start shiny server in detached mode
    exec shiny-server 2>&1 &

    # push the "real" application logs to stdout with xtail
    exec xtail /var/log/shiny-server/
fi
