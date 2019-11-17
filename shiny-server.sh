#!/bin/sh

if [ -z "${PORT}" ]; then
    echo "PORT not specified, using default value: 8080"
    export PORT=8080
fi

export SHINY_USER=shiny
export SHINY_GROUP=shiny

#if [ -z "${PUID}" ]; then
#    echo "PUID not specified, shiny server run as default value: 1000"
#    export PUID=1000
#fi

#if [ -z "${PGID}" ]; then
#    echo "PGID not specified, shiny server run as default value: 1000"
#    export PGID=1000
#fi

## Create non root user to run shinyserver 
#groupadd -r --gid $PGID shinyserver && useradd --no-log-init -r -g $PGID -u $PUID shinyserver

if [ -z "${DATA_DIR}" ]; then
    echo "DATA_DIR not specified, shiny server run as default value: /01_data"
    export DATA_DIR=/shiny-server/data
fi
mkdir -p $DATA_DIR
chown $SHINY_USER.$SHINY_GROUP -R $DATA_DIR

if [ -z "${CODE_DIR}" ]; then
    echo "CODE_DIR not specified, shiny server run as default value: /02_code"
    export CODE_DIR=/shiny-server/www
fi
mkdir -p $CODE_DIR
chown $SHINY_USER.$SHINY_GROUP -R $CODE_DIR

if [ -z "${OUTPUT_DIR}" ]; then
    echo "OUTPUT_DIR not specified, shiny server run as default value: /04_output"
    export OUTPUT_DIR=/shiny-server/output
fi
mkdir -p $OUTPUT_DIR
chown $SHINY_USER.$SHINY_GROUP -R $OUTPUT_DIR

if [ -z "${LOG_DIR}" ]; then
    echo "LOG_DIR not specified, shiny server run as default value: /var/log/shiny-server"
    export LOG_DIR=/var/log/shiny-server
fi
mkdir -p $LOG_DIR
chown $SHINY_USER.$SHINY_GROUP -R $LOG_DIR

# Copy container ENV variables to .Reviron so they will be available to shiny
RENV=/home/shiny/.Renviron
printenv > $RENV

if [ ! -z "${SHINYCODE_GITHUB_REPO}" ];
then
    echo "Copying contentes of github repo $SHINYCODE_GITHUB_REPO to $CODE_DIR"
    git clone $SHINYCODE_GITHUB_REPO $CODE_DIR
    chown $SHINY_USER.$SHINY_GROUP -R $CODE_DIR
fi

if [ "$DISCOVER_PACKAGES" = "true" ];
then
    # install packages specified by /etc/shiny-server/default_install_packages.csv or REQUIRED_PACKAGES
    # or those discovered  by a scan of files in $CODE_DIR looking for library('packagename') entries
	Rscript -e "source('/etc/shiny-server/install_discovered_packages.R'); discover_and_install(default_packages_csv = '/etc/shiny-server/default_install_packages.csv', discovery_directory_root = '$CODE_DIR', discovery = TRUE);"
else
    # install packages specified by /etc/shiny-server/default_install_packages.csv or REQUIRED_PACKAGES
	Rscript -e "source('/etc/shiny-server/install_discovered_packages.R'); discover_and_install(default_packages_csv = '/etc/shiny-server/default_install_packages.csv', discovery_directory_root = '$CODE_DIR', discovery = FALSE);"
fi

#Substitute ENV variable values into shiny-server.conf
envsubst < /etc/shiny-server/shiny-server.conf.tmpl >  /etc/shiny-server/shiny-server.conf

if [ "$PRIVILEGED" = "true" ];
then
    if [ "$APPLICATION_LOGS_TO_STDOUT" = "false" ];
    then
        exec shiny-server 2>&1
    else
        exec shiny-server 2>&1 &
        xtail /var/log/shiny-server/
    fi
else
    if [ "$APPLICATION_LOGS_TO_STDOUT" = "false" ];
    then
        exec gosu $SHINY_USER shiny-server 2>&1
    else
        exec gosu $SHINY_USER shiny-server 2>&1 &
        xtail /var/log/shiny-server/
    fi
fi