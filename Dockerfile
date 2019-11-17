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
	gosu \
	# for R package  magick
	libmagick++-dev \
	# for R package summarytools
	libudunits2-dev libgdal-dev tcl8.6-dev tk8.6-dev \ 
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
 	&& rm -r /srv/shiny-server

## install R packages from REQUIRED_PACKAGES and default_install_packages.csv
ARG REQUIRED_PACKAGES
COPY install_discovered_packages.R /etc/shiny-server/install_discovered_packages.R
COPY default_install_packages.csv /etc/shiny-server/default_install_packages.csv
RUN Rscript -e "source('/etc/shiny-server/install_discovered_packages.R'); discover_and_install(default_packages_csv = '/etc/shiny-server/default_install_packages.csv');" \
	&& rm -rf /tmp/*

## install rstudion/httpuv to enable compatibility with google cloud run https://github.com/rstudio/shiny/issues/2455
RUN R -e "remotes::install_github(c('rstudio/httpuv'))" \
	&& rm -rf /tmp/*

## copy shiny config and start script
COPY shiny-server.conf.tmpl /etc/shiny-server/shiny-server.conf.tmpl
COPY shiny-server.sh /usr/bin/shiny-server.sh
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/shiny-server.sh 
RUN chmod +x /usr/bin/entrypoint.sh 

## create directories for mounting shiny app code / data
ARG PARENT_DIR=/svr/shiny
ARG DATA_DIR=${PARENT_DIR}/data
ARG WWW_DIR=${PARENT_DIR}/www
ARG TEMP_DIR=${PARENT_DIR}/staging
ARG OUTPUT_DIR=${PARENT_DIR}/output
ARG LOG_DIR=/var/log/shiny-server

RUN mkdir -p $PARENT_DIR \
	&& mkdir -p $DATA_DIR \
 	&& mkdir -p $WWW_DIR \
 	&& ln -s /tmp $TEMP_DIR \
 	&& mkdir -p $OUTPUT_DIR \
 	&& mkdir -p $LOG_DIR \
	&& chown $PUID.$PGID -R $PARENT_DIR 



## start shiny server
ENV REQUIRED_PACKAGES ${REQUIRED_PACKAGES}

ENV DATA_DIR ${DATA_DIR}
ENV WWW_DIR ${WWW_DIR}
ENV TEMP_DIR ${TEMP_DIR}
ENV OUTPUT_DIR ${OUTPUT_DIR}
ENV LOG_DIR ${LOG_DIR} 

#ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/usr/bin/shiny-server.sh"]
