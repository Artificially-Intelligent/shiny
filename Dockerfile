# Base image https://hub.docker.com/u/rocker/
FROM rocker/r-ver:devel

RUN apt-get update -qq && apt-get -y --no-install-recommends install \
#RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    wget \
	# for changing from root user 
	gosu \
	# for envsubst
	gettext-base \
	# for git clone
	git \
	# for R packages 
	libxml2-dev \
	libsqlite3-dev \
	libmariadbd-dev \
	libpq-dev \
	libssh2-1-dev \
	unixodbc-dev \
	libcurl4-openssl-dev \
	libssl-dev \
	# for R package  magick
	libmagick++-dev \
	# for R package summarytools
	libudunits2-dev libgdal-dev tcl8.6-dev tk8.6-dev \ 
	# for R package V8
	libv8-dev \
	# for R package jqr
	libjq-dev \
	# for R package protolite
	libprotobuf-dev protobuf-compiler \
 	&& cd / \
	&& apt-get clean all \
	&& rm -rf /tmp/* \
	&& apt-get remove --purge -y $BUILDDEPS \
	&& apt-get autoremove -y \
	&& apt-get autoclean -y \
	&& rm -rf /var/lib/apt/lists/*

# Download and install shiny server
# Download and install R packages from REQUIRED_PACKAGES and default_install_packages.csv
ARG REQUIRED_PACKAGES
COPY install_discovered_packages.R /etc/shiny-server/install_discovered_packages.R
COPY default_install_packages.csv /etc/shiny-server/default_install_packages.csv

RUN wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    . /etc/environment && \
	Rscript -e "source('/etc/shiny-server/install_discovered_packages.R'); discover_and_install(default_packages_csv = '/etc/shiny-server/default_install_packages.csv',repos='$MRAN');" \
# install rstudion/httpuv to enable compatibility with google cloud run https://github.com/rstudio/shiny/issues/2455
	R -e "remotes::install_github(c('rstudio/httpuv'))" \
	&& rm -rf /tmp/*

# add image labels
ARG DOCKER_IMAGE=artificiallyintelligent/shiny
ARG BUILD_DATE
ARG VERSION=0.x.x
ARG MAINTAINER=slink42
ARG SOURCE_BRANCH
ARG SOURCE_COMMIT

LABEL build_version="$DOCKER_IMAGE version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL build_source="${SOURCE_BRANCH} - https://github.com/Artificially-Intelligent/shiny/commit/${SOURCE_COMMIT}"
LABEL maintainer="$MAINTAINER"

## copy shiny config and start script
COPY shiny-server.conf.tmpl /etc/shiny-server/shiny-server.conf.tmpl
COPY shiny-server.sh /usr/bin/shiny-server.sh
#COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/shiny-server.sh 
#RUN chmod +x /usr/bin/entrypoint.sh 

## create directories for mounting shiny app code / data
ARG PARENT_DIR=/srv/shiny-server
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
