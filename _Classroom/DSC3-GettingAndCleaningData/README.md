## Project description
This project is a solution to the programming assignment of the *Getting and Cleaning Data* course on Coursera. The assignment requires one to "create one R script called run_analysis.R that does the following.
1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject."

The complete description of the programming assignment is [here](https://www.coursera.org/learn/data-cleaning/peer/FIZtT/getting-and-cleaning-data-course-project).

## Function descriptions
### FUNCTION *PA(write.files = FALSE, measure.time = FALSE)*
This is the main function of the project, which does the analysis using helper functions. PA() calls:
- *loadPackages* which loads the necessary R packages (*utils*, *dplyr* and *rlang*)
- *getData* which downloads the dataset and unzips it
- *readData* which reads the data from the original dataset files
- *restructureData* which selects out variables from the dataset and reshapes the dataset
- *meanActivityData* which calculates, on the dataset returned by *restructureData*, the averages of variables per activity per subject
- *writeFiles* which, if requested with the *write.files* argument, writes the results into text files

Furthermore, if requested with the *measure.time* argument, PA() prints out run times of *readData()*, *restructureData()* and *meanActivityData()*. This uses *system.time()*.

#### Takes
PA() has two optional arguments, which can be used to switch on helper functionalities. It should be noted that none of these affect the data transformation process from original dataset into output datasets.

Argument | Description
--- | ---
write.files | *TRUE* requests the script to write the resulting datasets into text files, while *FALSE* runs the script without writing any files.
measure.time | *TRUE* requests the script to measure the running time of data read, data transformation, mean calculation and data write, using the system.time() function, while *FALSE* runs the script without time measurement.

#### Returns
PA() returns a list of two *data.frame* objects.

Output name | Class | Description
--- | --- | ---
tidy.data | data.frame | A subset of the original data, which is also cleaned and restructured; contains a *subjectID* and *activity* variable, followed by mean and standard deviation variables selected from the original dataset.
means.perA.perS | data.frame | Means calculated on *tidy.data* grouped first by *activity* and then by *subjectID*.

For more details on the output datasets refer to the [Code Book](https://github.com/uxexax/DS-getnclean/blob/master/CodeBook.md).

### FUNCTION *loadPackages(required.packages)*
Loads packages. If a package is not installed, then it attempts to download and install it.

#### Takes
Argument | Description
--- | ---
required.packages | A vector of character strings which specify the name of packages to be loaded.

#### Returns
Nothing.

### FUNCTION *getData(dataset.source, dataset.name, unzip.file = FALSE)*
Downloads a file and unzips it if requested.

#### Takes
Argument | Description
--- | ---
dataset.source | A character string specifying the URL of the data file.
dataset.name | A character string which specifies what should be the name of the downloaded file in the local workspace.
unzip.file | If *TRUE*, the script attempts to unzip the downloaded file into the local workspace.

#### Returns
Nothing.

### FUNCTION *readData()*
Reads the necessary pieces of data from the *UCI HAR Dataset*, and returns them in a list of data.frame objects. This function does not do any data processing, except for variable naming and variable class specification.

#### Takes
Nothing.

#### Returns
readData() returns a list of data.frame objects, which contain the raw data read from the different data files of *UCI HAR Dataset*. The returned data is used by restructureData().

### FUNCTION *restructureData(original)*
Assembles a dataset which satisfies the following conditions:
- *Training* and *test* datasets are joined into one dataset.
- The dataset contains variables which identify the subject of the measurement and the type of measurement. The latter uses human readable labels.
- The dataset is furthermore a subset of the original *UCI HAR Dataset*, takes the mean and standard deviation measurement variables from there.
- The dataset is a single data frame.
- Variable names are clean.

#### Takes
Argument | Description
--- | ---
original | A list of data.frame objects returned by *readData()*, which contain the original pieces of data read from the individual *UCI HAR Dataset* files.

#### Returns
A data.frame object with the following variables: *subjectID* and *activity* followed by the mean and standard deviation variables taken from the *UCI HAR Dataset*. In practice, this data frame is the *tidy.data* dataset returned by the main function *PA()*. For more details on this dataset refer to the [Code Book](https://github.com/uxexax/DS-getnclean/blob/master/CodeBook.md).

### FUNCTION *meanActivityData(original)*
Uses the data frame returned by *restructureData()* to calculate the means of mean and standard deviation variables grouped by the *activity* and *subjectID* variables.

#### Takes
Argument | Description
--- | ---
original | The cleaned data.frame object returned by *restructureData()*.

#### Returns
A data.frame object with the means of mean and standard deviation variables per activity per subject. In practice, this is the *means.perA.perS* dataset returned by the main function *PA()*. For more details on this dataset refer to the [Code Book](https://github.com/uxexax/DS-getnclean/blob/master/CodeBook.md).

### FUNCTION *writeFiles(df.list)*
Writes *tidy.data* and *means.perA.perS* datasets into individual text files in directory 'Results'.

#### Takes
Argument | Description
--- | ---
df.list | A named list of the *tidy.data* and *means.perA.perS* data.frame objects.

#### Returns
Nothing.

This function creates the following files:

From dataset | To file
--- | ---
tidy.data | Results/tidy_data.txt
means.perA.perS | Results/means_perActivity_perSubject.txt
