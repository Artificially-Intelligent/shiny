# Base image https://hub.docker.com/u/rocker/
FROM rocker/r-ver:latest

RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    xtail \
    wget \
 	gosu \
	gettext-base \
	git 

# Download and install shiny server
RUN wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    . /etc/environment && \
    R -e "install.packages(c('shiny', 'rmarkdown'), repos='$MRAN')" && \
    chown shiny:shiny /var/lib/shiny-server && \
	rm -rf /tmp/*

# Download and install R package dependancies
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
	libxml2-dev \
	libsqlite3-dev \
	libmariadbd-dev \
	libpq-dev \
	libssh2-1-dev \
	unixodbc-dev \
	libcurl4-openssl-dev \
	libssl-dev \
	## for R package  magick
	libmagick++-dev \
	## for R package summarytools
	libudunits2-dev libgdal-dev tcl8.6-dev tk8.6-dev \ 
	## for R package V8
	libv8-dev \
	## for R package jqr
	libjq-dev \
	## for R package protolite
	libprotobuf-dev protobuf-compiler \
	## clean up install files
	&& cd / \
	&& rm -rf /tmp/* \
	&& apt-get remove --purge -y $BUILDDEPS \
	&& apt-get autoremove -y \
	&& apt-get autoclean -y \
	&& rm -rf /var/lib/apt/lists/* 

# Download and install R packages and suggested dependencies from csv ENV variable REQUIRED_PACKAGES_PLUS
ARG REQUIRED_PACKAGES_PLUS=
RUN install2.r \
	--error \
    --deps TRUE \
    --skipinstalled \
	--ncpus -1 \
	shiny \
	rmarkdown \
	remotes \
	`echo $REQUIRED_PACKAGES_PLUS |  sed 's/,/ /g'` \
	&& rm -rf /tmp/*

# Download and install R packages from csv ENV variable REQUIRED_PACKAGES
ARG REQUIRED_PACKAGES=


RUN install2.r \
	--error \
	--ncpus -1 \
    --skipinstalled \
	`echo $REQUIRED_PACKAGES |  sed 's/,/ /g'` \
	&& rm -rf /tmp/*

# install rstudion/httpuv to enable compatibility with google cloud run https://github.com/rstudio/shiny/issues/2455
RUN R -e "remotes::install_github(c('rstudio/httpuv'))"

#COPY install_discovered_packages.R /etc/shiny-server/install_discovered_packages.R
#COPY default_install_packages.csv /etc/shiny-server/default_install_packages.csv

 	## install packages from date-locked MRAN snapshot of CRAN
#RUN [ -z "$BUILD_DATE" ] && BUILD_DATE=$(TZ="America/Los_Angeles" date -I) || true \
#  	&& MRAN=https://mran.microsoft.com/snapshot/${BUILD_DATE} \
#  	&& echo MRAN=$MRAN >> /etc/environment \
#  	&& export MRAN=$MRAN \
#  	&& Rscript -e "source('/etc/shiny-server/install_discovered_packages.R'); discover_and_install(default_packages_csv = '/etc/shiny-server/default_install_packages.csv',repos='$MRAN');" 

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
COPY install_discovered_packages.R /etc/shiny-server/install_discovered_packages.R
COPY shiny-server.conf.tmpl /etc/shiny-server/shiny-server.conf.tmpl
COPY shiny-server.sh /usr/bin/shiny-server.sh
RUN chmod +x /usr/bin/shiny-server.sh
#COPY entrypoint.sh /usr/bin/entrypoint.sh
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
ENV REQUIRED_PACKAGES_PLUS ${REQUIRED_PACKAGES_PLUS}

ENV DATA_DIR ${DATA_DIR}
ENV WWW_DIR ${WWW_DIR}
ENV TEMP_DIR ${TEMP_DIR}
ENV OUTPUT_DIR ${OUTPUT_DIR}
ENV LOG_DIR ${LOG_DIR} 

#ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["/usr/bin/shiny-server.sh"]
