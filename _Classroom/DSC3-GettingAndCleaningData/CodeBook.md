## The original dataset
This project uses a part of the **Human Activity Recognition Using Smartphones Data Set**, see http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The actual data was downloaded from here: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

The following data is used from this dataset:
- **activity_labels.txt:** resolution of activity codes to activity names
- **features.txt:** name of activity measurement variables (feature names)
- Training dataset:
  - **train/subject_train.txt:** subject identifiers corresponding to the measurements
  - **train/X_train.txt:** activity measurement features
  - **train/Y_train.txt:** activity labels
- Test dataset:
  - **test/subject_test.txt:** subject identifiers corresponding to the measurements
  - **test/X_test.txt:** activity measurement features
  - **test/Y_test.txt:** activity labels

In the *training* and *test* datasets, each row corresponds to one measurement.

## Clean data
The scripts provided in this project create two datasets from the original dataset:
- tidy.data
- means.perA.perS

**Note that** both of these datasets contain both *training* and *test* data (i.e. *training* and *test* data are joined).

### tidy.data
This is a dataset of 68 variables and 10299 measurements, which contains a subset of the original measurement dataset.

Column number | Variable name | Description
--- | --- | ---
1 | subjectID | An integer number which identifies the subject.
2 | activity | Activity label, one of the following strings: "laying", "sitting", "standing", "walking", "walking downstairs", "walking upstairs".
3 - 68 | tBodyAccMeanX, tBodyAccMeanY, tBodyAccMeanZ, tBodyAccStdX, tBodyAccStdY, tBodyAccStdZ, tGravityAccMeanX, tGravityAccMeanY, tGravityAccMeanZ, tGravityAccStdX, tGravityAccStdY, tGravityAccStdZ, tBodyAccJerkMeanX, tBodyAccJerkMeanY, tBodyAccJerkMeanZ, tBodyAccJerkStdX, tBodyAccJerkStdY, tBodyAccJerkStdZ, tBodyGyroMeanX, tBodyGyroMeanY, tBodyGyroMeanZ, tBodyGyroStdX, tBodyGyroStdY, tBodyGyroStdZ, tBodyGyroJerkMeanX, tBodyGyroJerkMeanY, tBodyGyroJerkMeanZ, tBodyGyroJerkStdX, tBodyGyroJerkStdY, tBodyGyroJerkStdZ, tBodyAccMagMean, tBodyAccMagStd, tGravityAccMagMean, tGravityAccMagStd, tBodyAccJerkMagMean, tBodyAccJerkMagStd, tBodyGyroMagMean, tBodyGyroMagStd, tBodyGyroJerkMagMean, tBodyGyroJerkMagStd, fBodyAccMeanX, fBodyAccMeanY, fBodyAccMeanZ, fBodyAccStdX, fBodyAccStdY, fBodyAccStdZ, fBodyAccJerkMeanX, fBodyAccJerkMeanY, fBodyAccJerkMeanZ, fBodyAccJerkStdX, fBodyAccJerkStdY, fBodyAccJerkStdZ, fBodyGyroMeanX, fBodyGyroMeanY, fBodyGyroMeanZ, fBodyGyroStdX, fBodyGyroStdY, fBodyGyroStdZ, fBodyAccMagMean, fBodyAccMagStd, fBodyBodyAccJerkMagMean, fBodyBodyAccJerkMagStd, fBodyBodyGyroMagMean, fBodyBodyGyroMagStd, fBodyBodyGyroJerkMagMean, fBodyBodyGyroJerkMagStd | A subset of the original dataset variables: mean and standard deviation variables. Original values are not changed.

### means.perA.perS
This dataset is based on the *tidy.data* dataset, and contains the average of variables per activity per subject, where the means are calculated on *tidy.data* grouped first by *activity* and then by *subjectID*.

The dataset has 68 variables and 180 rows.

Column number | Variable name | Description
--- | --- | ---
1 | activity | Activity label, one of the following strings: "laying", "sitting", "standing", "walking", "walking downstairs", "walking upstairs".
2 | subjectID | An integer number which identifies the subject.
3 - 68 | Variable names of *tidy.data* columns 3-68, each with the following postfix: **'_mean'**. | Mean measurement values for each activity for each subject.

## Overview of the data transformation process
The following steps are taken to transform the *UCI HAR Dataset* into *tidy.data*, and to calculate *means.perA.perS*.

Step | Activity | Done by
--- | --- | ---
First | Download data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip | getData()
Second | Unzip the datafile into the workspace. | getData()
Third | Read the pieces of data from the files specified in section *The original dataset* into data.frame objects. One data frame corresponds to one file. Variable names and classes are specified in this step. Original values are not altered in any way. | readData()
Fourth | Bind separate parts of *training* data together. Bind separate parts of *test* data together. Bind training and test data together. Select the required variables (note: this is done prior to binding for both training and test data). | restructureData()
Fifth | Clean variable names: capitalize 'mean' and 'std' which are between dots, then remove all the dots introduced by *read.table()* within *readData()* in the third step. For example: *fBodyAcc.mean...X* --> *fBodyAccMeanX*. | restructureData()
Sixth | Replace activity IDs with human readable activity names in the *activity* variable. The data read from *activity_labels.txt* is used for the mapping, enhanced with a few modifications: '_' is removed from the activity labels and the strings are set to lower case. | restructureData()
Seventh | Store the result in the *tidy.data* data.frame object. | PA()
Eighth | Calculate the average of mean and standard deviation variables of *tidy.data* grouped by activity and subject. Postfix measurement variable names with *'_mean'* to distinguish from variable names of *tidy.data*. | meanActivityData()
Ninth | Store the result in the *means.perA.perS* data.frame object. | PA()
Tenth | Write the result data frames into text files. (Optional step.) | writeFiles() 
