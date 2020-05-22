list.of.packages <- c("readr","stringr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, quiet = TRUE)
library(readr);
library(stringr);


discover_and_install <- function(default_packages_csv = '/no/file/selected', discovery_directory_root = '/srv/shiny-server/www', discovery = FALSE, repos = 'https://cran.rstudio.com/'){
  
  if(file.exists(default_packages_csv)){
    default_packages <- unique(read_csv(default_packages_csv)[["packages"]])
  }else{
    default_packages <- c()
  }
  
  if(nchar(Sys.getenv('REQUIRED_PACKAGES')) > 0){
    required_packages <- unique(str_split(Sys.getenv('REQUIRED_PACKAGES'),",")[[1]])
    print(paste("Adding csv entries from ENV variable REQUIRED_PACKAGES to list of packages to install: (", 
                paste(required_packages, collapse = ",") , ")",sep = ""))
  }else{
    required_packages <- c()
  }
  
  if(nchar(Sys.getenv('FAILED_PACKAGES')) > 0){
    prev_failed_packages <- unique(str_split(Sys.getenv('FAILED_PACKAGES'),",")[[1]])
    print(paste("Adding csv entries from ENV variable FAILED_PACKAGES to list of packages to install: (", 
                paste(prev_failed_packages, collapse = ",") , ")",sep = ""))
  }else{
    prev_failed_packages <- c()
  }
  
  if(nchar(Sys.getenv('REQUIRED_PACKAGES_PLUS')) > 0){
    required_packages <- unique(c(
      required_packages,
      str_split(Sys.getenv('REQUIRED_PACKAGES_PLUS'),",")[[1]]
    ))
    print(paste("Adding csv entries from ENV variable REQUIRED_PACKAGES_PLUS to list of packages to install: (", 
    paste(required_packages, collapse = ",") , ")",sep = ""))
  }

 # default_packages_csv_path <- strsplit(default_packages_csv, "/")
#  default_packages_csv_filename <- default_packages_csv_path[[1]][length(default_packages_csv_path[[1]])]
 # installed_packages_csv <- sub(default_packages_csv_filename,'installed_packages.csv',default_packages_csv)
  
  discovered_packages <- c()
  if(discovery){
    r_files <- list.files(path = discovery_directory_root, pattern = "*.R$", recursive = TRUE,full.names = TRUE)
    
    print(paste("Scanning", length(r_files), "*.R files found in code directories"))
    
    i <- 0
    for(file in r_files){
      i = i + 1
      #file <- r_files[i]
      print(paste("Scanning", file , "(", i, "/", length(r_files), ")"))
      
      lines <- read_lines(file, skip_empty_rows = TRUE)
      if(length(lines)>0){
        
        # find packages referenced via library() command 
        libraries <- gsub(' ','',lines[grepl('^library\\(',gsub(' ','',lines))])
        libraries <- gsub("'",'',gsub('"','',gsub("\\).*","",libraries)))
        libraries <- unlist(strsplit(libraries, split="[()]"))
        libraries <- unique(libraries[!grepl('library|;',libraries)])
        
        # find packages referenced via :: command
        libraries <- c(libraries,
                       gsub("\\::.*","",lines[grepl('::',lines)])
        )
        
        # remove anything prior to a , "' character
        libraries <- unique(
          gsub(".*\\(","",
               gsub(".*,","",
                    gsub(".* ","",
                              libraries
                    )
               )
          )
        )
      }
      
      if(length(libraries)>0){
        print(paste("Packages found in", file , "(", paste(libraries, collapse = ",") , ")"))
        discovered_packages <- unique(c(libraries,discovered_packages))
      }
    }
    print(paste("Packages discovered in *.R files: (", paste(discovered_packages, collapse = ",") , ")",sep = ""))
  }

  packages_to_install <- unique(c(default_packages, required_packages, discovered_packages, prev_failed_packages))
  packages_to_install <- packages_to_install[!(packages_to_install %in% installed.packages()[,"Package"])]

  failed_packages <- c()
  if(length(packages_to_install)>0){
    print(paste("Packages to be installed (", paste(packages_to_install, collapse = ",")   , ")" ,sep = ""))
    for(package_name in packages_to_install){
      tryCatch(
        {
          if(length(package_name[!(package_name %in% installed.packages()[,"Package"])]) > 0){
            print(paste("Installing package: ", package_name ,sep = ""))
            install.packages(package_name, 
                             dependencies = TRUE,
                             repos = repos, 
                        #     method='wget',
                             quiet = TRUE)
            #write.table(package_name, file=installed_packages_csv, row.names=FALSE, col.names=FALSE, sep=",", append = TRUE)
          }else{
            print(paste("Skipping previously installed package: ", package_name ,sep = ""))
          }
        }, 
        error=function(cond) {
          failed_packages <- c(failed_packages,package_name)
          message(paste("Failed to install:", package_name))
          message("Here's the original error message:")
          message(cond)
        }
        
      )
    }
  }else{
    print("There are no packages to be installed")
  }
  print(paste("Installed packages:",paste(installed.packages()[,"Package"],collapse = ",")))
  if(length(failed_packages) > 0){
    print(paste("Packages that failed to install:",paste(failed_packages,collapse = ",")))
    # Write falied package list to env variable
    Sys.setenv(FAILED_PACKAGES = paste( unique(failed_packages),collapse = ","))
  }
}

