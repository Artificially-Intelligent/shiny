library(readr); 

preinstalled_packages_csv <- "/etc/shiny-server/preinstalled_packages.csv"
preinstalled_packages <- read_csv(preinstalled_packages_csv)[["packages"]]

root_folders <- list.files()
code_folders <-  root_folders[grepl("\\S*code\\S*", root_folders)]

r_files <- list.files(path = code_folders, pattern = "*.R$", recursive = TRUE,full.names = TRUE)

print(paste("Scanning", length(r_files), "*.R files found in code directories"))
discovered_packages <- c()
i <- 0
for(file in r_files){
  i = i + 1
  print(paste("Scanning", file , "(", i, "/", length(r_files), ")"))
  file <- file.path(".",file)
  lines <- read_delim(file,  delim = '^#^', skip_empty_rows = TRUE, col_names = FALSE)
  if(length(lines)>0){
    libraries <- gsub(' ','',lines[[1]][grepl('^library\\(',gsub(' ','',lines[[1]]))])
    libraries <- unlist(strsplit(libraries, split="[()]"))
    libraries <- unique(libraries[!grepl('library|;',libraries)])
  }
  
  #  packages <- lines[[1]][grepl('package',lines[[1]])]
  
  discovered_packages <- unique(c(libraries,discovered_packages))
}

if(length(discovered_packages)>0){
  new_packages <- setdiff(discovered_packages, preinstalled_packages)
  print(paste("Packages discovered in *.R files: (", paste(discovered_packages, collapse = ",") , ")",sep = ""))
  print(paste("Packages not in preinstalled packages (", paste(new_packages, collapse = ",")   , ")" ,sep = ""))
  lapply(new_packages, install.packages, character.only = TRUE)
}else{
  print("No package references discovered in scanned R files")
}
new_packages_csv <- sub('preinstalled_packages.csv','runtime_installed_packages.csv',preinstalled_packages_csv)

write.table(new_packages, file=new_packages_csv, row.names=FALSE, col.names=FALSE, sep=",")
