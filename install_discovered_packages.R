library(readr); 

discover_and_install <- function(preinstalled_packages_csv, r_search_root = '/02_code'){
  
  new_packages_csv <- sub('preinstalled_packages.csv','runtime_installed_packages.csv',preinstalled_packages_csv)
  if(file.exists(new_packages_csv)){
    new_packages_already_installed <- read_csv(new_packages_csv)[["packages"]]
  }else{
    new_packages_already_installed <- c()
  }
  
  preinstalled_packages <- unique(c(read_csv(preinstalled_packages_csv)[["packages"]],new_packages_already_installed))
  
  root_folders <- list.files(path = r_search_root)
  code_folders <- root_folders 
  #code_folders <-  root_folders[grepl("\\S*code\\S*", root_folders)]
  
  r_files <- list.files(path = file.path(r_search_root,code_folders), pattern = "*.R$", recursive = TRUE,full.names = TRUE)
  
  print(paste("Scanning", length(r_files), "*.R files found in code directories"))
  discovered_packages <- c()
  i <- 0
  for(file in r_files){
    i = i + 1
    file <- r_files[i]
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
  
  if(length(discovered_packages)>0){
    new_packages <- setdiff(discovered_packages, preinstalled_packages)
    print(paste("Packages discovered in *.R files: (", paste(discovered_packages, collapse = ",") , ")",sep = ""))
    print(paste("Packages not in preinstalled packages (", paste(new_packages, collapse = ",")   , ")" ,sep = ""))
    for(package_name in new_packages){
      try(
        {
          print(paste("Installing package: ", package_name ,sep = ""))
          install.packages(package_name, dependencies = c("Depends", "Imports"), quiet = TRUE)
          write.table(package_name, file=new_packages_csv, row.names=FALSE, col.names=FALSE, sep=",", append = TRUE)
        },FALSE
      )
    }
  }else{
    print("No package references discovered in scanned R files")
  }
}  