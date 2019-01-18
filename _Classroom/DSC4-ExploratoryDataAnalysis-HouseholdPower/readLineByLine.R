# Reads the dataset file block by block, filters out data from 1-Feb-2007 and
# 2-Feb-2007, and creates a data frame from that.

readLineByLine <- function()
{
  dataset.file <- "household_power_consumption.txt"
  block.size <- 10000   # number of lines read in one step
  print.point <- 100000   # read status is printed per this number of lines
  total.blocks <- round(2075259/block.size)
  L <- ""  # used to store one block
  filtered.data <- character()  # stores the relevant lines from the file
  DF <- data.frame()  # the result data frame

  message(paste0("Reading file ", dataset.file))
  message(paste0("Block size: ", block.size, " lines"))
  
  connection <- file(dataset.file, open = "r")
  
  filtered.data <- readLines(connection, n = 1) # dataset header
  
  L <- readLines(connection, n = block.size)
  
  block.count <- 0
  while(!is.na(L[1]))
  {
    block.count <- block.count + 1
    if (block.count %% (print.point / block.size) == 0)
      message(paste0("  reading block ", block.count, " of ", total.blocks))
  
    L.filtered <- grep("^(1/2/2007|2/2/2007)", L, value = TRUE)
    filtered.data <- c(filtered.data, L.filtered)
    L <- readLines(connection, n = block.size)
  }
  
  close(connection)
  
  DF <- read.table(text = filtered.data, header = TRUE, sep = ";", na.strings = "?",
                    colClasses = c("character", "character", "numeric", "numeric",
                                   "numeric", "numeric", "numeric", "numeric", "numeric"),
                    comment.char = "")
  
  DF$DateTime <- strptime(paste(DF$Date, DF$Time, sep = "|"), format = "%d/%m/%Y|%T")

  invisible(DF)
}

# 5-round system.time average results:
#
# with block.size == 100
# user time:    22.43 seconds
# system time:  1.55 seconds
# elapsed time: 35.412 seconds
#
# with block.size == 500
# user time:    11.01 seconds
# system time:  0.608 seconds
# elapsed time: 13.012 seconds
#
# with block.size == 1000
# user time:    8.886 seconds
# system time:  0.542 seconds
# elapsed time: 10.358 seconds
#
# with block.size == 10000
# user time:    8.12 seconds
# system time:  0.44 seconds
# elapsed time: 9.282 seconds
#
# with block.size == 100000
# user time:    7.794 seconds
# system time:  0.478 seconds
# elapsed time: 8.93 seconds

