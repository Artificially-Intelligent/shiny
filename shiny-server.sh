#!/bin/sh

# Make sure the directory for individual app logs exists
mkdir -p /var/log/shiny-server
chown shiny.shiny /var/log/shiny-server

if [ -z "${PORT}" ]; then
  echo "PORT not specified, using default value 3838"
  PORT=3838
fi

#Substitute ENV variable values into shiny-server.conf
envsubst < /etc/shiny-server/shiny-server.conf.tmpl >  /etc/shiny-server/shiny-server.conf

if [ "$DISCOVER_PACKAGES" = "true" ];
then
    # scan files in /02_code for required libraries and install missing packages
    exec Rscript /etc/shiny-server/install_discovered_packages.R
else
    echo "DISCOVER_PACKAGES != true, Using preinstalled packages only"
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
