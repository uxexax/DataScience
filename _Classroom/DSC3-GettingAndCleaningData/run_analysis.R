# This is the main function of the programming assignment of Getting and
# Cleaning Data course, which is used to call helper funtions and assemble
# the final return data, which is a list of data frames:
#   * tidy.data contains - cleaned dataset as specified by instructions
#   * means.perA.perU - mean values per activities per subjects calculated
#     from tidy.data
# If write.files is TRUE, then the data.frames are written into CSV files.
# If measure.time is TRUE, then function call times are measured and printed.

PA <- function(write.files = FALSE, measure.time = FALSE) {
  message("EVERYTHING STARTS")
  
  files <- c("loadPackages.R", "getData.R", "readData.R", "restructureData.R",
             "meanActivityData.R", "writeFiles.R")
  for (f in files) source(f)
  
  loadPackages(c("utils", "dplyr", "rlang"))
  
  getData("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
          "UCI HAR Dataset.zip", unzip.file = TRUE)

  if (!measure.time)
  {
    activity.data <- readData()
    tidy.data <- restructureData(activity.data)
    means.perA.perS <- meanActivityData(tidy.data)
  } 
  else
  {
    t <- system.time(activity.data <- readData())
    message(sprintf("USER TIME: %.2fs  SYSTEM TIME:%.2fs  ELAPSED TIME: %.2fs",
                    t[[1]], t[[2]], t[[3]]))
    t <- system.time(tidy.data <- restructureData(activity.data))
    message(sprintf("USER TIME: %.2fs  SYSTEM TIME:%.2fs  ELAPSED TIME: %.2fs",
                    t[[1]], t[[2]], t[[3]]))
    t <- system.time(means.perA.perS <- meanActivityData(tidy.data))
    message(sprintf("USER TIME: %.2fs  SYSTEM TIME:%.2fs  ELAPSED TIME: %.2fs",
                    t[[1]], t[[2]], t[[3]]))
  }

  D <- list(tidy.data = tidy.data, means.perA.perS = means.perA.perS)
  
  if (write.files) writeFiles(D)
  
  message("EVERYTHING'S DONE")
  
  invisible(D)
}

