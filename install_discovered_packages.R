install.packages('readr',quite = TRUE);
library(readr); 

discover_and_install <- function(default_packages_csv, discovery_directory_root = '/02_code', discovery = FALSE){
  
  default_packages <- unique(read_csv(default_packages_csv)[["packages"]])
  
  default_packages_csv_path <- strsplit(default_packages_csv, "/")
  default_packages_csv_filename <- default_packages_csv_path[[1]][length(default_packages_csv_path[[1]])]
  
  installed_packages_csv <- sub(default_packages_csv_filename,'installed_packages.csv',default_packages_csv)
  if(file.exists(installed_packages_csv)){
    previously_installed_packages <- unique(read_csv(installed_packages_csv)[["packages"]])
  }else{
    previously_installed_packages <- c()
  }
  
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
        libraries <- gsub(' ','',lines[[1]][grepl('^library\\(',gsub(' ','',lines[[1]]))])
        libraries <- unlist(strsplit(libraries, split="[()]"))
        libraries <- unique(libraries[!grepl('library|;',libraries)])
      }
      
      if(length(libraries)>0){
        print(paste("Packages found in", file , "(", paste(libraries, collapse = ",") , ")"))
        discovered_packages <- unique(c(libraries,discovered_packages))
      }
    }
    print(paste("Packages discovered in *.R files: (", paste(discovered_packages, collapse = ",") , ")",sep = ""))
  }
  
  packages_to_install <- unique(setdiff(c(default_packages, discovered_packages), previously_installed_packages))
  
  if(length(packages_to_install)>0){
    print(paste("Packages to be installed (", paste(packages_to_install, collapse = ",")   , ")" ,sep = ""))
    for(package_name in packages_to_install){
      try(
        {
          print(paste("Installing package: ", package_name ,sep = ""))
          install.packages(package_name, 
                          # dependencies = c("Depends", "Imports"),
                           quiet = TRUE)
          write.table(package_name, file=installed_packages_csv, row.names=FALSE, col.names=FALSE, sep=",", append = TRUE)
        },FALSE
      )
    }
  }else{
    print("There are no packages to be installed")
  }
}

