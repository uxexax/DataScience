readAllInOneStep <- function()
{
  dataset.file <- "household_power_consumption.txt"
  
  message(paste0("Reading dataset file '", dataset.file, "' and subsetting it"))
  HPC <- read.table(file = dataset.file, header = TRUE,
                    sep = ";", na.strings = "?",
                    colClasses = c("character", "character", "numeric", "numeric", "numeric",
                                   "numeric", "numeric", "numeric", "numeric"),
                    nrows = 2075259, comment.char = "")
  
  HPC <- subset(HPC, Date %in% c("1/2/2007", "2/2/2007"))

  HPC$DateTime <- strptime(paste(HPC$Date, HPC$Time, sep = "|"), format = "%d/%m/%Y|%T")

  invisible(HPC)
}

# 5-round system.time average results:
# user time:    11.26 seconds
# system time:  0.71 seconds
# elapsed time: 12.826 seconds
#
# user time:    11.93 seconds
# system time:  1.01 seconds
# elapsed time: 15.19 seconds
