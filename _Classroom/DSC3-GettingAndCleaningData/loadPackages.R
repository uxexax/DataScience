# This function loads the packages specified in paramter required.packages.
# Packages not installed are first downloaded and set up.

loadPackages <- function(required.packages) {
  message("Loading packages")
  
  not.installed <- !(required.packages %in% installed.packages())
  
  if (any(not.installed) == TRUE)
    install.packages(required.packages[not.installed])
  
  for (p in required.packages) library(p, character.only = TRUE)
}