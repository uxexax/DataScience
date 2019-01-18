# This function downloads a file from 'dataset.source' to the workspace directory,
# names it as specified by 'dataset.name' and unzips it if this is requested with
# 'unzip.file = TRUE'.

getData <- function(dataset.source, dataset.name, unzip.file = FALSE) {
  if (file.exists(dataset.name)) return()
  
  message("Getting data")
  message("-- downloading")
  download.file(dataset.source, dataset.name)
  
  if (unzip.file) {
    message("-- unzipping")
    unzip(dataset.name)
  }
}