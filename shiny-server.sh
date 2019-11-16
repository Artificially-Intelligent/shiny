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

if [ "$DISCOVER_PACKAGES" = "true" ];
then
    # scan files in $CODE_DIR for required libraries and install missing packages
    ## install R-packages    
	Rscript -e "source('/etc/shiny-server/install_discovered_packages.R'); discover_and_install(default_packages_csv = '/etc/shiny-server/default_install_packages.csv', discovery_directory_root = '$CODE_DIR', discovery = TRUE);"
else
    echo "DISCOVER_PACKAGES != true, Using preinstalled packages only"
fi

if [ -z "${PUID}" ]; then
   echo "PUID not specified, shiny server run as default value: shiny"
  export PUID=shiny
fi

chown -R /data $PUID
chown -R /code $PUID
chown -R /01_input $PUID
chown -R /02_code $PUID
chown -R /04_output $PUID
chown -R /var/log/shiny-server $PUID

if [ ! -z "${SHINYCODE_GITHUB_REPO}" ];
then
    echo "Copying contentes of github repo $SHINYCODE_GITHUB_REPO to $CODE_DIR"
    /bin/su -c "git clone $SHINYCODE_GITHUB_REPO $CODE_DIR"  -  $PUID
fi

#Substitute ENV variable values into shiny-server.conf
envsubst < /etc/shiny-server/shiny-server.conf.tmpl >  /etc/shiny-server/shiny-server.conf

if [ "$APPLICATION_LOGS_TO_STDOUT" = "false" ];
then
    #exec shiny-server 2>&1 using user $PUID
    exec /bin/su -c "shiny-server 2>&1" -  $PUID
else
    # start shiny server in detached mode using user $PUID
    #exec shiny-server 2>&1 &
    exec /bin/su -c "shiny-server 2>&1" -  $PUID &

    # push the "real" application logs to stdout with xtail
    exec xtail /var/log/shiny-server/
fi
