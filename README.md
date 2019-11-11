# [Artificially-Intelligent/shiny](https://github.com/Artificially-Intelligent/shiny)

## Description
rocker/rbase docker image with a selection of packages preinstalled geared to support R-Shiny based webapps. Also come with option to install additional packages at cotainer startup for packages refrenced by a library('package') statment within any *.R file copied/mounted into container.  

## Usage

Here are some example snippets to help you get started creating a container.

## docker

docker create \
  --name=myshinyapp \
  -p 3838:3838 \
  -e DISCOVER_PACKAGES=true \
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
    environment:
      - DISCOVER_PACKAGES=true
      - PORT=4848
    volumes:
      - path/to/data/source:/01_input
      - path to code:/02_code
      - path/to/data/output:/04_output
    ports:
      - 4848:4848
    restart: unless-stopped

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 3838:3838` | Specify a port mapping from container to host for shiny server web ui. Port value after the : should match that defined by PORT environment variable or the default value 3838 |
| `-e PORT=3838` | Specify a port for shiny to use inside the container. Included to support deployment to google cloud run. If not set default value is 3838 |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Europe/London` | Specify a timezone to use EG Europe/London. |
| `-e DISCOVER_PACKAGES=true` | Set true to have  *.R files in /code & /02_code directories + subdirectories scanned for library(package) entries. Missing package will be installed as part of contrianer startup. |
| `-v /01_input` | Placeholder folder for source data mapping. R-Shiny apps can map to this location using ../01_input |
| `-v /02_code` | The web root for shiny. R shiny code reside here. |
| `-v /04_output` | Placeholder folder for output data storage. R-Shiny apps can map to this location using ../04_output |
| `-v /05_logs` | Placeholder folder for log file output. R-Shiny apps can map to this location using ../05_logs |

## Preinstalled Packages

See [default_install_packages.csv](https://github.com/Artificially-Intelligent/shiny/blob/master/default_install_packages.csv) for full list of packages currently included by default.

## Troubleshooting

Run package, start shiny-server and view logs
 docker run -it -p 3838:3838 -e PORT=3838 --name shiny artificiallyintelligent/shiny:latest /bin/bash
 setsid /usr/bin/shiny-server.sh >/dev/null 2>&1 < /dev/null &
 cat /var/log/shiny-server/code-shiny-*

Check disc space available for temp files
 df -h /tmp