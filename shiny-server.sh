#!/bin/sh

# Make sure the directory for individual app logs exists
mkdir -p /var/log/shiny-server
chown shiny.shiny /var/log/shiny-server

CODE_DIR=/02_code

# Copy container ENV variables to .Reviron so they will be available to shiny
RENV=/home/shiny/.Renviron
printenv > $RENV

if [ -z "${PORT}" ]; then
  echo "PORT not specified, using default value: 8080"
  export PORT=8080
fi

if [ -z "${PUID}" ]; then
   echo "PUID not specified, shiny server run as default value: shiny"
  export PUID=shiny
fi

if [ ! -z "${SHINYCODE_GITHUB_REPO}" ];
then
    echo "Copying contentes of github repo $SHINYCODE_GITHUB_REPO to $CODE_DIR"
    git clone $SHINYCODE_GITHUB_REPO $CODE_DIR
fi

#Substitute ENV variable values into shiny-server.conf
envsubst < /etc/shiny-server/shiny-server.conf.tmpl >  /etc/shiny-server/shiny-server.conf

if [ "$DISCOVER_PACKAGES" = "true" ];
then
    # scan files in $CODE_DIR for required libraries and install missing packages
    ## install R-packages
    #Rscript -e "source('/etc/shiny-server/install_discovered_packages.R'); discover_and_install(preinstalled_packages_csv = '/etc/shiny-server/preinstalled_packages.csv',r_search_root = '$CODE_DIR'); "
	Rscript -e "source('/etc/shiny-server/install_discovered_packages.R'); discover_and_install(default_packages_csv = '/etc/shiny-server/default_install_packages.csv', discovery_directory_root = '$CODE_DIR', discovery = TRUE);"
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
