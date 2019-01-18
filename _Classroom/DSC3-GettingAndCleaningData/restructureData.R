# This function selects and restructures UCI HAR data according to assignment
# instructions.

restructureData <- function(original) {
  message("Restructuring")
  
  # Creating a data frame with only the necessary information
  required.features <- grep("mean\\.{2,}|std\\.{2,}",
                            colnames(original$training.features), value = TRUE)
  
  D <- 
    tbl_df(original$training.subjects) %>%
    bind_cols(original$training.labels) %>%
    bind_cols(
      select(original$training.features, required.features))

  D <- D %>% bind_rows(
    tbl_df(original$test.subjects) %>%
    bind_cols(original$test.labels) %>%
    bind_cols(
      select(original$test.features, required.features))
  )
  
  # Renaming variables in the new data frame:
  #   - "mean" and "std" are capitalized
  #   - dots are removed
  
  clean.fnames <- old.fnames <- required.features
  clean.fnames <- sub(".mean.", ".Mean.", clean.fnames, fixed = TRUE)
  clean.fnames <- sub(".std.", ".Std.", clean.fnames, fixed = TRUE)
  clean.fnames <- gsub(".", "", clean.fnames, fixed = TRUE)
  
  names(old.fnames) <- clean.fnames

  D <- D %>% rename(!!old.fnames)

  # Replacing activity IDs with full activity names
  
  activities <- gsub("_", " ", original$activity.types$activityName, fixed = TRUE)
  
  for (a in 1:length(original$activity.types$activityID)) {
    D$activity <- gsub(original$activity.types$activityID[[a]], 
                       tolower(activities[[a]]),
                       D$activity, fixed = TRUE) }
  
  D
}