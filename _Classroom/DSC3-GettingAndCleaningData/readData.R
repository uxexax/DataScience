# This function reads the necessary data files from the UCI HAR Dataset, and
# stores them into individual data.frame objects. This function does not do any
# any data processing, except for casting all variables into pre-defined classes.

readData <- function() {
  message("Reading data")
  
  message("-- activity labels and feature names")
  activity.types <- read.table("UCI HAR Dataset/activity_labels.txt", FALSE, "",
                                col.names = c("activityID", "activityName"),
                                colClasses = c("character", "character"))
  features <- read.table("UCI HAR Dataset/features.txt", FALSE,
                              col.names = c("featureID", "featureName"), 
                              colClasses = c("numeric", "character"))
  
  message("-- subject IDs of training data")
  training.subjects <- read.table("UCI HAR Dataset/train/subject_train.txt", FALSE, "",
                              col.names = "subjectID", colClasses = "numeric")

  message("-- features of training data")
  training.features <- read.table("UCI HAR Dataset/train/X_train.txt", FALSE, "",
                        col.names = features$featureName, colClasses = "numeric",
                        comment.char = "")

  message("-- labels of training data")
  training.labels <- read.table("UCI HAR Dataset/train/y_train.txt", FALSE, "",
                        col.names = "activity", colClasses = "character")
  
  message("-- subject IDs of test data")
  test.subjects <- read.table("UCI HAR Dataset/test/subject_test.txt", FALSE, "",
                             col.names = "subjectID", colClasses = "numeric")
  
  message("-- features of test data")
  test.features <- read.table("UCI HAR Dataset/test/X_test.txt", FALSE, "",
                       col.names = features$featureName, colClasses = "numeric",
                       comment.char = "")
  
  message("-- labels of test data")
  test.labels <- read.table("UCI HAR Dataset/test/y_test.txt", FALSE, "",
                       col.names = "activity", colClasses = "character")
  
  list(activity.types = activity.types,
       features = features,
       training.subjects = training.subjects,
       training.features = training.features,
       training.labels = training.labels,
       test.subjects = test.subjects,
       test.features = test.features,
       test.labels = test.labels)
}