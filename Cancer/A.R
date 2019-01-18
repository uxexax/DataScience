library(dplyr)
library(tidyr)
library(ggplot2)
library(gridExtra)

source("dataIO.R")
source("dataEA.R")

if (!(dir.exists("figures")))
  dir.create("figures")

# It is assumed that the datasets described in datasets.csv are already downloaded
# to the 'datasets' directory in the workspace. Note: the 'URL' column contains the
# links to the datasets' original place, and the 'Date' column specifies the version
# of the dataset.

# ----- Dataset descriptor table; consists of dataset descriptor records
dataset.info <- read.csv("datasets/datasets.csv", stringsAsFactors = FALSE)

# ----- Load datasets specified in 'use.these'. If an object with the same name is 
#       already in the environment, then the corresponding dataset is not read.
used.datasets <- c("miRNA") #, "RPPA", "RNAseq.read", "RNAseq.rpkm", "miRNA", "DNAmet.1kb", "DNAmet.cpg")
read.datasets <- used.datasets[!(used.datasets %in% ls())]
for (o in read.datasets)
{
  assign(o, read.data(dataset.info %>% filter(Object == o)))
}

# ----- Some post-shaping of the datasets
post.shape(read.datasets)

for (o in used.datasets)
{
  DS.inf <- dataset.info %>% filter(Object == o)
  
  SVD.PCA(DS.inf, "Column")
  SVD.PCA(DS.inf, "Row")
}
err

# ----- Some basic and quantile statistics 
basics <- list()
for (o in used.datasets)
{
  message(paste("Analysing dataset:", dataset.info$Description[dataset.info$Object == o]))

  DS.inf <- dataset.info %>% filter(Object == o)

  message(paste("--", "Basic statistics"))
  basics[[o]] <- explore.basics(DS.inf)
  
  for (direction in c("Column", "Row"))
  {
    # ----- Calculate basic statistics of the datasets, and plot create simple plots
    message(paste("--", direction, "basics plot"))
    plot.basics(basics[[o]], direction = direction)
  
    # ----- Plot different quantiles of the datasets' columns/rows
    message(paste("--", direction, "quantiles plot"))
    plot.quantiles(c(0, 1),
                   c(0, 0.5, 1),
                   c(0, 0.25, 0.50, 0.75, 1),
                   c(0.25, 0.5, 0.75),
                   seq(0.125, 0.875, by = 0.125),
                   DS.inf = DS.inf,
                   direction = direction)
  }
}
