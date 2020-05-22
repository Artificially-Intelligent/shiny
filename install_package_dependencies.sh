#!/bin/bash 
R_PACKAGES=$1,$2,$3,$4,$5,$6,$7,$8,$9

if [[ $R_PACKAGES == *"protolite"* ]] ; then  
    PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libprotobuf-dev protobuf-compiler "
    echo "adding dependencies for protolite"
fi
if [[ $R_PACKAGES == *"magick"* ]] ; then 
    PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libmagick++-dev "
    echo "adding dependencies for magick"
fi;
if [[ $R_PACKAGES == *"V8"* ]] ; then 
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libv8-dev "
    echo "adding dependencies for V8"
fi 
if [[ $R_PACKAGES == *"summarytools"* ]] ; then 
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libudunits2-dev libgdal-dev tcl8.6-dev tk8.6-dev "
    echo "adding dependencies for summarytools"
fi
if [[ $R_PACKAGES == *"jqr"* ]] ; then 
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libjq-dev "
    echo "adding dependencies for jqr"
fi
if [[ $R_PACKAGES == *"redux"* ]] ; then 
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libhiredis-dev "; 
    echo "adding dependencies for redux"
fi 
if [[ $R_PACKAGES == *"xml2"* ]] || [[ $R_PACKAGES == *"tidyverse"* ]] ; then 
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libxml2-dev "; 
    echo "adding dependencies for xml2"
fi
if [[ $R_PACKAGES == *"zzzzz"* ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libsqlite3-dev "; 
    echo "adding dependencies for tba"
fi
if [[ $R_PACKAGES == *"zzzzz"* ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libmariadbd-dev "; 
    echo "adding dependencies for tba"
fi
if [[ $R_PACKAGES == *"zzzzz"* ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libpq-dev "; 
    echo "adding dependencies for tba"
fi
if [[ $R_PACKAGES == *"zzzzz"* ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libssh2-1-dev "; 
    echo "adding dependencies for tba"
fi
if [[ $R_PACKAGES == *"zzzzz"* ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES unixodbc-dev "; 
    echo "adding dependencies for tba"
fi
if [[ $R_PACKAGES == *"zzzzz"* ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libcurl4-openssl-dev "; 
    echo "adding dependencies for tba"
fi
if [[ $R_PACKAGES == *"shiny"* ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libssl-dev "; 
    echo "adding dependencies for shiny"
fi
if [[ $R_PACKAGES == *"sf"* ]] ; then
   PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES libudunits2-dev libgdal-dev gdal-bin libproj-dev proj-data proj-bin libgeos-dev libmariadbclient-dev default-libmysqlclient-dev libmysqlclient-dev "; 
    echo "sf"
fi


echo "installing package dependencies: $PACKAGE_DEPENDENCIES"

## install dependecies for R_PACKAGES and R_PACKAGES_PLUS
apt-get update -qq && apt-get -y --no-install-recommends install \
    $PACKAGE_DEPENDENCIES \
	#libxml2-dev \
	#libsqlite3-dev \
	#libmariadbd-dev \
	#ibpq-dev \
	#libssh2-1-dev \
	#unixodbc-dev \
	#libcurl4-openssl-dev \
	##libssl-dev \

## clean up install files
cd /
rm -rf /tmp/*
apt-get remove --purge -y $BUILDDEPS
apt-get autoremove -y
apt-get autoclean -y
rm -rf /var/lib/apt/lists/* 
