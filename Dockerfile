# Base image https://hub.docker.com/u/rocker/
FROM rocker/shiny

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
	# for R package summarytools
	tcl8.6-dev tk8.6-dev \ 
	# for R package V8
	libv8-dev \
	# for R package jqr
	libjq-dev \
	# for R package jqr
	libprotobuf-dev \
	# for R package protolite
	libprotobuf-dev protobuf-compiler \
	# for envsubst
	gettext-base \
	# for git clone
	git \
 	&& cd / \
	&& apt-get clean all \
	&& rm -rf /tmp/* \
	&& apt-get remove --purge -y $BUILDDEPS \
	&& apt-get autoremove -y \
	&& apt-get autoclean -y \
	&& rm -rf /var/lib/apt/lists/* \
 	&& rm -r /srv/shiny-server \
## create directories for mounting code / data
 	&& mkdir -p /data \
 	&& mkdir -p /01_input \
 	&& mkdir -p /code \
 	&& mkdir -p /02_code \
 	&& ln -s /tmp /03_staging \
 	&& mkdir -p /04_output \
 	&& mkdir -p /var/log/shiny-server \
 	&& ln -s /var/log/shiny-server /05_logs

## copy config files
COPY install_discovered_packages.R /etc/shiny-server/install_discovered_packages.R
COPY default_install_packages.csv /etc/shiny-server/default_install_packages.csv
COPY shiny-server.conf.tmpl /etc/shiny-server/shiny-server.conf.tmpl
COPY shiny-server.sh /usr/bin/shiny-server.sh

## install R-packages
RUN Rscript -e "source('/etc/shiny-server/install_discovered_packages.R'); discover_and_install(default_packages_csv = '/etc/shiny-server/default_install_packages.csv', discovery_directory_root = '/02_code', discovery = FALSE);" \
&& rm -rf /tmp/*
	
	
## start shiny server
RUN chmod +x /usr/bin/shiny-server.sh 
CMD ["/usr/bin/shiny-server.sh"]
