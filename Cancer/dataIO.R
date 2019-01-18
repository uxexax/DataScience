# ----------------------------------------------------------------------------------------------
# This function reads in a dataset from a file. Both the file name and the object which the
# data is read into are specified in the dataset information record passed to the function
# in the 'DS.inf' parameter.
# ----------------------------------------------------------------------------------------------
read.data <- function(DS.inf)
{
  filename <- paste0("datasets/", DS.inf$Filename)

  message(paste("Reading dataset:", DS.inf$Description))
  message(paste("-- from file:", filename))
  message(paste("-- into object:", DS.inf$Object))
  message("")
  
  colclass.file <- sub("\\..*$", ".csv", paste0("typesof_", DS.inf$Filename))
  colclass.file <- paste0("datasets/", colclass.file)

  if (endsWith(filename, ".csv"))
  {
    DS <- read.csv(filename, na.strings = "NA", check.names = FALSE)
  }
  else if (endsWith(filename, ".txt"))
  {
    DS <- read.txt(filename, colclass.file)
  }
  else if (endsWith(filename, ".gct"))
  {
    DS <- read.gct(filename)
  }
  
  return(DS)
}

# ----------------------------------------------------------------------------------------------
# This is a helper function of read.data(), used to read in all .txt files in a common way.
# Column classes are taken from files with prefix 'typesof_', which were created beforehand.
# ----------------------------------------------------------------------------------------------
read.txt <- function(fname, colclass.file)
{
  columns <- read.csv(colclass.file, header = FALSE, row.names = 1, 
                      col.names = c("column", "class"), stringsAsFactors = FALSE)

  txt.data <- read.table(fname, header = TRUE, sep = "\t",
                         na.strings = c("",  "NA", "NaN", "     NA"),
                         colClasses = columns$class)
  
  return(txt.data)
}

# ----------------------------------------------------------------------------------------------
# This is a helper function of read.data(), used to read all .gct files in a common way.
# Reading is based on the file format specification provided here:
# http://software.broadinstitute.org/cancer/software/genepattern/file-formats-guide
# ----------------------------------------------------------------------------------------------
read.gct <- function(fname)
{
  dataset.size <- read.table(fname, skip = 1, nrows = 1, sep = "\t", 
                             colClasses = c("integer", "integer"), col.names = c("nrows", "ncols"))
  gct.data <- read.table(fname, skip = 2, nrows = dataset.size$nrows, sep = "\t", header = TRUE,
                         colClasses = c("character", "character", rep("numeric", dataset.size$ncols)),
                         comment.char = "")
  return(gct.data)
}

# ----------------------------------------------------------------------------------------------
# This function takes certain post-shaping actions on the in-memory datasets.
# Takes the list of the names of the datasets used in this analysis.
# ----------------------------------------------------------------------------------------------
post.shape <- function(used.datasets)
{
  if ("RPPA" %in% used.datasets)
  {
    rownames(RPPA) <<- RPPA[,1]
    RPPA <<- RPPA[,-1]
  }
  if ("RNAseq.read" %in% used.datasets)
  {
    RNAseq.read <<- RNAseq.read[-(1:2)]
  }
  if ("RNAseq.rpkm" %in% used.datasets)
  {
    RNAseq.rpkm <<- RNAseq.rpkm[-(1:2)]
  }
  if ("miRNA" %in% used.datasets)
  {
    miRNA <<- miRNA[-(1:2)]
  }
  if ("DNAmet.1kb" %in% used.datasets)
  {
    DNAmet.1kb <<- DNAmet.1kb[-(1:7)]
  }
  if ("DNAmet.cpg" %in% used.datasets)
  {
    DNAmet.cpg <<- DNAmet.cpg[-(1:5)]
  }
  
  return(NULL)
}