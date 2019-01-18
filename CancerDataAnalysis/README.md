This project aims to analyse the *Cancer Cell Line* datasets provided by [Broad Institute](https://www.broadinstitute.org "Broad Institute main page"). The datasets come from here: https://portals.broadinstitute.org/ccle/data. For generic information about cancer research at Broad Institute visit https://www.broadinstitute.org/research-highlights-cancer.

This README file covers the following topics:
- Directories [[-->](#directories)]
- Used packages [[-->](#used-packages)]
- Scripts [[-->](#scripts)]
- Functions [[-->](#functions)]

For details about the data used in this project refer to the [codebook](CODEBOOK.md).

# Directories
The following directories are used in this project:
- *. (working directory):* place of the R script and markdown files
- *./datsets:* location of the downloaded original dataset files, the *datasets.csv* file and the *typesof_* files (see the [codebook](CODEBOOK.md))
- *./figures:* the directory where the plots are created (see the [codebook](CODEBOOK.md))

# Used packages
The following packages are used in this project:
- base
- utils
- dplyr
- tidyr
- ggplot2
- gridExtra

# Scripts
The project currently consists of three building blocks as follows.

B. block | Description | Functions within
--- | --- | ---
A.r | The Alpha of everything or at least this project. It is the main script which reads in the necessary datasets and analyse them with the help of helper functions. | -
dataIO.R | Input&Output functions, in the sense that these functions read in the data from the different files, prepare them for analysis, and write some data into files (but there's no such thing in the project yet). | read.data, read.txt, read.gct, post.shape
dataEA.R | Exploration&Analysis functions, which are used to explore the characteristics of the datasets, make some analysis and create plots for these. Currently only basic statistics can be done in this project. | explore.basics, plot.basics, plot.quantiles

# Functions
## A.R
This script does not define any function; it is the main script of the project, and implements the sequence specified in the [codebook](CODEBOOK.md) with the help of functions defined in *dataIO.R* and *dataEA.R*.

## dataIO.R
### FUNCTION *read.data(DS.inf)*
This function reads in a dataset from a file. Both the file name and the object which the data is read into are specified in the *dataset information record* passed to the function in the 'DS.inf' parameter.

There are three types of data files in this project:

File type | Read by | Defined in
--- | --- | ---
comma separated values (CSV) | read.csv() | *utils* package
plain text (TXT) | read.txt() | dataIO.R
gene expression data (GCT) | read.gct() | dataIO.R

There are common dataset characteristics within these file types, which allow for generic reading per file type; in practice *read.data* passes the task of reading the data to helper functions responsible for their own file type as specified by the table above.

#### Takes
Argument | Description
--- | ---
DS.inf | Dataset information record of the dataset to be read.

#### Returns
The read-in dataset as a *data.frame* object.

### FUNCTION *read.txt(fname, colclass.file)*
This is a helper function of *read.data*, used to read in all TXT files in a common way. Column classes are taken from files with prefix *typesof_*, which were created beforehand as described in the [codebook](CODEBOOK.md).

#### Takes
Argument | Description
--- | ---
fname | The relative path of the plain text file which contains the dataset.
colclass.file | The relative path of a CSV file which specifies the column classes of the dataset.

#### Returns
The dataset which has been read in from the plain text file, as a *data.frame* object.

### FUNCTION *read.gct(fname)*
This is a helper function of *read.data*, used to read all GCT files in a common way. Reading is based on the file format specification provided here: http://software.broadinstitute.org/cancer/software/genepattern/file-formats-guide. In general, the following guidelines are taken when GCT files are read:
- A GCT file is basically a tab separated values file
- The first row is always a version number.
- The second row always contains the number of **data rows** followed by the number of **data columns**.
- The data rows always start at the third row.
- The first column of the data rows is always the row identifiers, and the second one is always a description column.
- The data rows always start at the third column.

#### Takes
Argument | Description
--- | ---
fname | The relative path of the plain text file which contains the dataset.

Note: column classes are not taken from a *typesof_* file, as they are quite straightforward from the GCT type specification (i.e. first two columns are character strings, the remaining ones are numeric).

#### Returns
The dataset which has been read in from the gene expression data file, as a *data.frame* object.

### FUNCTION *post.shape(used.datasets)*
This function takes certain post-shaping actions on the in-memory datasets, which have been previously read in with *read.data*. These actions depend on the actual dataset and are the following:

Dataset short name | Post-shaping action
--- | ---
CCLE Reverse Phase Protein Array (RPPA) data | Make the first column the row names.
CCLE RNAseq gene expression data (read count) | Remove the first two non-numeric columns.
CCLE RNAseq gene expression data (RPKM) | Remove the first two non-numeric columns.
CCLE DNA methylation data (promoter 1kb upstream TSS) | Remove the first seven columns.
CCLE DNA methylation data (promoter CpG clusters) | Remove the first five columns.
CCLE miRNA expression data | Remove the first two non-numeric columns.

Datasets not listed here are not post-shaped by this function.

#### Takes
Argument | Description
--- | ---
used.datasets | This is a vector of dataset object names which the function should apply the post-shaping to.

#### Returns
NULL

## dataEA.R
### FUNCTION *explore.basics(DS.inf)*
This function takes a dataset and creates a list of dataframes which describes the corresponding dataset's basic characteristics.

#### Takes
Argument | Description
--- | ---
DS.inf | Dataset information record of the dataset to be explored.

#### Returns
A list of data.frame objects which contain column, row and total basic characteristics. The following items are stored in the data.frame objects:

Dataframe name (list item name) | Stored characteristics
--- | ---
$Column | Column IDs, minima, maxima, means, standard deviations, maxmin differences, NA counts, 25% quantiles, 50% quantiles (medians), 75% quantiles.
$Row | Row IDs, minima, maxima, means, standard deviations, maxmin differences, NA counts, 25% quantiles, 50% quantiles (medians), 75% quantiles.
$Total | Overall minimum, 25% quantile, 50% quantile (median), 75% quantile, maximum and mean of the dataset. Also, the number of rows and columns in the dataset.
$Summaries | *Essentials:* a different view of *$Total* used on the basic characteristic plots.

### FUNCTION *plot.basics(basics, direction = "Column")*
This function creats a grid of plots of column/row minima, maxima, means, standard deviations,
maxmin differences, NA counts and 4-quartiles (minima, 25%'s, medians, 75%'s and maxima).

If *direction* is *Both*, then the behaviour is the same as if the function was called with direction="Column", then direction="Row" and the results were put side-by-side.

#### Takes
Argument | Description
--- | ---
basics | The list of data.frame objects returned by function *explore.basics*.
direction | One of *Column*, *Row* or *Both* telling what statistics to display. The default value is *Column*.

#### Returns
NULL

### FUNCTION *plot.quantiles(..., DS.inf, direction = "Column")*
This function creats a grid of plots of column/row quantiles specified in the function arguments.

If *direction* is *Both*, then the behaviour is the same as if the function was called with direction="Column", then direction="Row" and the results were put side-by-side.

#### Takes
Argument | Description
--- | ---
... | At least one vector of probabilities between 0 and 1, which define which quantiles of the dataset should be plotted.
DS.inf | Dataset information record of the dataset whose quantiles have to be plotted.
direction | One of *Column*, *Row* or *Both* telling what statistics to display. The default value is *Column*.

#### Returns
NULL
