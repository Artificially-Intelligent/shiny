#!/bin/sh

# Make sure the directory for individual app logs exists
mkdir -p /var/log/shiny-server
chown shiny.shiny /var/log/shiny-server

if [ -z "${PORT}" ]; then
  echo "PORT not specified, using default value 3838"
  export PORT=3838
fi

#Substitute ENV variable values into shiny-server.conf
envsubst < /etc/shiny-server/shiny-server.conf.tmpl >  /etc/shiny-server/shiny-server.conf

if [ "$DISCOVER_PACKAGES" = "true" ];
then
    # scan files in /02_code for required libraries and install missing packages
    ## install R-packages
    #Rscript -e "source('/etc/shiny-server/install_discovered_packages.R'); discover_and_install(preinstalled_packages_csv = '/etc/shiny-server/preinstalled_packages.csv',r_search_root = '/02_code'); "
	Rscript -e "source('/etc/shiny-server/install_discovered_packages.R'); discover_and_install(default_packages_csv = '/etc/shiny-server/default_install_packages.csv', discovery_directory_root = '/02_code', discovery = TRUE);"
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
