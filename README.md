# [Artificially-Intelligent/shiny](https://github.com/Artificially-Intelligent/shiny)

## Description
rocker/r-ver docker image with a selection of packages preinstalled geared to support R-Shiny based webapps. Also come with option to install additional packages at container startup for packages refrenced by a library('package') statment within any *.R file copied/mounted into container, or specified by environment variable REQUIRED_PACKAGES.  

## Usage

Here are some example snippets to help you get started creating a container.

## docker

```
docker create \
  --name=myshinyapp \
  -p 8080:8080 \
  -e DISCOVER_PACKAGES=true \
  -e REQUIRED_PACKAGES=shiny,readr \
  -e SHINYCODE_GITHUB_REPO=https://github.com/rstudio/shiny-examples \
  -v path/to/data_source:/01_input \
  -v path/to/code:/02_code \
  -v path/to/data_output:/04_output \
  --restart unless-stopped \
  artificiallyintelligent/shiny
```

## docker-compose

Compatible with docker-compose v2 schemas.

```
---
version: "2"
services:
  shiny:
    image: artificiallyintelligent/shiny
    container_name: myshinyapp
    environment:
      - DISCOVER_PACKAGES=true
      - APP_IDLE_TIMEOUT=5
      - APP_INIT_TIMEOUT=60
      - PORT=8080
      - SHINYCODE_GITHUB_REPO=https://github.com/rstudio/shiny-examples
    volumes:
      - path/to/data_source:/srv/shiny-server/data
      - path/to/code:/srv/shiny-server/www
      - path/to/data_output:/srv/shiny-server/output
    ports:
      - 3838:8080
    restart: unless-stopped
```

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 3838:8080` | Specify a port mapping from container to host for shiny server web ui. Port value after the : should match that defined by PORT environment variable or the default value 8080 |
| `-e PORT=8080` | Specify a port for shiny to use inside the container. Included to support deployment to google cloud run. If not set default value is 8080 |
| `-e SHINYCODE_GITHUB_REPO=https://github.com/rstudio/shiny-examples` | Specifiy a url for a github repo to copy to code directory at container runtime. Note only supports https, not ssh. Private repo can be added by including an access token in the url eg. https://myaccesstoken@github.com/mygithubuser/mygithubrepo.git | 
| `-e PRIVILEGED=false` | Set true to run shiny-server as root user  |
| `-e DISCOVER_PACKAGES=true` | Set true to have  *.R files in /code & /02_code directories + subdirectories scanned for library(package) entries. Missing R packages will be installed as part of container startup. |
| `-e REQUIRED_PACKAGES=packages,to,install` | Specify a csv list of R package names to look for ensure are installed irrespective of if package discovery is on and/or finds a library() refrence for them. |
| `-v ../data:/srv/shiny-server/data` | Placeholder folder for source data mapping. R-Shiny apps can map to this location using ../data |
| `-e DATA_DIR=/srv/shiny-server/data` | Specify a custom location for data directory inside container. | 
| `-v .:/srv/shiny-server/www` | The web root for shiny. R shiny code resides here. |
| `-e WWW_DIR=/srv/shiny-server/www` | Specify a custom location for shiny www root directory inside container. | 
| `-v ../data:/srv/shiny-server/output` | Placeholder folder for output data storage. R-Shiny apps can map to this location using ../output |
| `-e OUTPUT_DIR=/srv/shiny-server/output` | Specify a custom location for data output directory inside container. | 
| `-e APP_IDLE_TIMEOUT=5` | Specify a app_idle_timeout to use when starting shiny server. Default value is 5, boosting to 1800 helps prevent session disconnects |
| `-e APP_INIT_TIMEOUT=60` | Specify a app_init_timeout to use when starting shiny server. Default value is 60, boosting to 1800 helps prevent session disconnects | 

## Preinstalled Packages
### Packages plus suggested dependencies
tidyverse,dplyr,devtools,formatR,remotes,selectr,caTools,BiocManager

### Packages plus required dependencies
purrr,rattle,dotenv,magrittr,DataExplorer,aws.s3,DBI,httr,pool,readr,readxl,RMySQL,slackr,writexl,DT,dygraphs,formattable,highcharter,plotly,rmarkdown,scales,skimr,styler,timevis,tmaptools,data.table,forcats,glue,janitor,jsonlite,lubridate,magick,sf,summarytools,tibbletime,wkb,xts,protolite,V8,jqr,geojson,geojsonio,auth0,googleAuthR,leaflet,leaflet.extras,shiny,shinyAce,shinycssloaders,shinycssloaders,shinydashboard,shinydashboardPlus,shinyEffects,shinyjqui,shinyjs,shinyWidgets

## Deploying to Google Cloud Run
Look at instructions here for the general process of how to:
+ Deloy container image to Google Container Registry: https://cloud.google.com/run/docs/deploying
+ Deloy Container Registry image as a Google Cloud Run service: https://cloud.google.com/run/docs/deploying

## Troubleshooting

Run package, start shiny-server and view logs
  ```
  docker run -it -p 3838:3838 -e PORT=3838 --name shiny artificiallyintelligent/shiny:latest /bin/bash
  ```
  ```
  setsid /usr/bin/srv/shiny-server.sh >/dev/null 2>&1 < /dev/null &
  cat /var/log/srv/shiny-server/code-shiny-*
  ```

Check if there is sufficient disc space available for temp files
  ```
  df -h /tmp
  ```
