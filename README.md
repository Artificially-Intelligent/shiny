# [Artificially-Intelligent/shiny](https://github.com/Artificially-Intelligent/shiny)

## Description
rocker/rbase docker image with a selection of packages preinstalled geared to support R-Shiny based webapps. Also come with option to install additional packages at cotainer startup for packages refrenced by a library('package') statment within any *.R file copied/mounted into container.  

## Usage

Here are some example snippets to help you get started creating a container.

## docker

docker create \
  --name=myshinyapp \
  -p 3838:3838 \
  -v path/to/data/source:/01_input \
  -v path to code:/02_code \
  -v path/to/data/output:/04_output \
  --restart unless-stopped \
  slink42/rbase_shiny

## docker-compose

Compatible with docker-compose v2 schemas.

---
version: "2"
services:
  radarr:
    image: slink42/rbase_shiny
    container_name: myshinyapp
    volumes:
      - path/to/data/source:/01_input
      - path to code:/02_code
      - path/to/data/output:/04_output
    ports:
      - 3838:3838
    restart: unless-stopped

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 3838` | Http port |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Europe/London` | Specify a timezone to use EG Europe/London. |
| `-e DISCOVER_PACKAGES=true` | If set to false, missing package discovery and nstallation is disabled. |
| `-v /01_input` | Placeholder folder for source data mapping. R-Shiny apps can map to this location using ../01_input|
| `-v /02_code` | The web root for shiny. R shiny code reside here. |
| `-v /04_output` | Placeholder folder for output data storage. R-Shiny apps can map to this location using ../04_output|
| `-v /05_logs` | Placeholder folder for log file output. R-Shiny apps can map to this location using ../05_logs|


## Preinstalled Packages

see [preinstalled_packages.csv](https://github.com/Artificially-Intelligent/shiny/blob/master/preinstalled_packages.csv) for full list

* aws.s3
* caret
* data.table
* DataExplorer
* DBI
* devtools
* dotenv
* dplyr
* DT
* dygraphs 
* forcats
* formattable
* glue
* googleAuthR
* highcharter
* httr
* ipred
* janitor
* jsonlite
* leaflet
* leaflet.extras
* lubridate
* magick
* magrittr
* Metrics
* plotly
* pool
* purrr
* randomForest
* rattle
* readr
* readxl
* RMySQL
* rpart
* rpart.plot
* scales #
* sf
* shiny
* shinycssloaders
* shinycssloaders
* shinydashboard
* shinydashboardPlus
* shinyjs
* shinyWidgets
* skimr
* slackr
* summarytools
* tcltk
* tibbletime
* tidyverse
* timevis
* tmaptools
* vtreat
* wkb
* writexl
* xgboost
* xts

## Troubleshooting

Run package, start shiny-server and view logs
 docker run -it -p 3838:3838 -e PORT=3838 --name shiny artificiallyintelligent/shiny:latest /bin/bash
 setsid /usr/bin/shiny-server.sh >/dev/null 2>&1 < /dev/null &
 cat /var/log/shiny-server/code-shiny-*

Check disc space available for temp files
 df -h /tmp