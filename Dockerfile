# Base image https://hub.docker.com/u/rocker/
FROM rocker/shiny

## shiny server port
ARG PORT=3838


## install debian packages
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
	libxml2-dev \
	libcairo2-dev \
	libsqlite3-dev \
	libmariadbd-dev \
	libpq-dev \
	libssh2-1-dev \
	unixodbc-dev \
	libcurl4-openssl-dev \
	libssl-dev \
	libmagick++-dev \
	libudunits2-dev \
	libgdal-dev \
	tcl8.6-dev \
	tk8.6-dev \
	gettext-base


## create directories
RUN mkdir -p /data ; \
    mkdir -p /01_input ; \
    mkdir -p /02_code ; \
	mkdir -p /02_code ; \
	ln -s /tmp /03_staging ; \
	mkdir -p /04_output ; \
	mkdir -p /var/log/shiny-server ;\
	ln -s /var/log/shiny-server /05_logs ;\
	rm -r /srv/shiny-server 


## copy files

COPY install_discovered_packages.R /etc/shiny-server/install_discovered_packages.R
COPY default_install_packages.csv /etc/shiny-server/default_install_packages.csv
COPY shiny-server.conf.tmpl /etc/shiny-server/shiny-server.conf.tmpl
COPY shiny-server.sh /usr/bin/shiny-server.sh


## install R-packages
#RUN Rscript -e "install.packages('readr'); library(readr); lapply(read_csv('/etc/shiny-server/preinstalled_packages.csv')[[1]], install.packages, character.only = TRUE)"
RUN Rscript -e "source('/etc/shiny-server/install_discovered_packages.R'); discover_and_install(default_packages_csv = '/etc/shiny-server/default_install_packages.csv', discovery_directory_root = '/02_code', discovery = FALSE);"

## start shiny server
EXPOSE $PORT
RUN chmod +x /usr/bin/shiny-server.sh 
