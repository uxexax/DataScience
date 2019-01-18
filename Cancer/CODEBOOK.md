This document contains these descriptions:
- Dataset information [[-->](#dataset-information)]
- First glance on the datasets [[-->](#first-glance-on-the-datasets)]
- The *typesof_* files [[-->](#the-typesof_-files)]
- Analysed data [[-->](#analysed-data)]
- In-memory datasets [[-->](#in-memory-datasets)]
- Data analysis procedure [[-->](#data-analysis-procedure)]
- Plots [[-->](#plots)]

# Dataset information
The data used in this project have been downloaded from Broad Institute's **Cancer Cell Line Encyclopedia (CCLE)**, from here: https://portals.broadinstitute.org/ccle/data.

At the time these lines are written, there are a total of eight up-to-date datasets available there. Pieces of information about these datasets have been placed into [datasets.csv](datasets/datasets.csv) in folder *datasets*, which serves as a quick-glance overview of the CCLE data, contains dataset version information, and also serves as a helper for *A.R*.

Filename | Description | Date | Object | URL
--- | --- | --- | --- | ---
CCLE_RPPA_Ab_info_20180123.csv | RPPA antibody information | 24-Jan-2018 | RPPA.antibody | https://data.broadinstitute.org/ccle/CCLE_RPPA_Ab_info_20180123.csv
CCLE_RPPA_20180123.csv | CCLE Reverse Phase Protein Array (RPPA) data | 23-Jan-2018 | RPPA | https://data.broadinstitute.org/ccle/CCLE_RPPA_20180123.csv
CCLE_DepMap_18q3_maf_20180718.txt | Merged mutation calls (coding region; germline filtered) | 18-Jul-2018 | merged.mutation | https://data.broadinstitute.org/ccle/CCLE_DepMap_18q3_maf_20180718.txt
CCLE_DepMap_18q3_RNAseq_reads_20180718.gct | CCLE RNAseq gene expression data (read count) | 18-Jul-2018 | RNAseq.read | https://data.broadinstitute.org/ccle/CCLE_DepMap_18q3_RNAseq_reads_20180718.gct
CCLE_DepMap_18q3_RNAseq_RPKM_20180718.gct | CCLE RNAseq gene expression data (RPKM) | 18-Jul-2018 | RNAseq.rpkm | https://data.broadinstitute.org/ccle/CCLE_DepMap_18q3_RNAseq_RPKM_20180718.gct
CCLE_RRBS_TSS_1kb_20180614.txt | CCLE DNA methylation data (promoter 1kb upstream TSS) | 14-Jun-2018 | DNAmet.1kb | https://data.broadinstitute.org/ccle/CCLE_RRBS_TSS_1kb_20180614.txt
CCLE_RRBS_TSS_CpG_clusters_20180614.txt | CCLE DNA methylation data (promoter CpG clusters) | 14-Jun-2018 | DNAmet.cpg | https://data.broadinstitute.org/ccle/CCLE_RRBS_TSS_CpG_clusters_20180614.txt
CCLE_miRNA_20180525.gct | CCLE miRNA expression data | 14-Jun-2018 | miRNA | https://data.broadinstitute.org/ccle/CCLE_miRNA_20180525.gct

**Filename** is the name of the dataset file as it should be in the working directory's *datasets* sub-directory. 
**Description** is a short description, or rather a verbose title of the dataset.
**Date** tells the version of the dataset.
**Object** is the name of the data.frame object in which the dataset is stored in the memory.
**URL** is the original source of the dataset.

Some of the functions in the project take a so called **dataset information record** instead of a complete dataset. This is in practice the datasets.csv row corresponding to the actual dataset, and is usually used by the function to extract the object name, file name and description of the dataset.

Note: it is assumed that all of these have been downloaded to the directory *datasets* in the working directory prior to running *A.R*.

# First glance on the datasets
Note: I'm not familiar with these datasets or the science behind, and so some of the assertions below come from best-effort Google searching.
### CCLE Reverse Phase Protein Array (RPPA) data
RPPA is an efficient technique that allows a large number of parallel measurements of protein expressions of biologocal samples. This dataset contains measurements for **cell lines** (rows) against **antibodies** (columns).

##### Columns
There are 214 columns of *antibodies*, all numeric, no NA values.
##### Rows
There are 899 rows of *cell lines*.

### RPPA antibody information
This dataset relates to the *CCLE Reverse Phase Protein Array (RPPA) data*, and provides some details on the antibodies.

##### Columns
There are 5 columns in this order: antibody names (character), target genes (character), validation statuses (character), producer companies (character), catalogue numbers (character). No NA values.
##### Rows
There are 214 rows of *antibodies*.

### Merged mutation calls (coding region; germline filtered)
This dataset contains information about cancer related gene mutations.

##### Columns
There are 33 columns; each contains different pieces of information about a gene mutation. Among these are identifiers (HUGO ID, Entrez ID, Broad ID), location information (chromosome, start and end positions on the chromosome), variant information, descriptions how a specific gene's structure and behaviour are changed by the mutation, whether it's a hotspot mutation and other data. Columns contain NAs.
##### Rows
There are a total of 1,203,976 gene mutations described in this dataset.

### CCLE RNAseq gene expression data (read count)
From [Wikipedia](https://en.wikipedia.org/wiki/RNA-Seq): *"RNA-Seq (RNA sequencing), also called whole transcriptome shotgun sequencing (WTSS), uses next-generation sequencing (NGS) to reveal the presence and quantity of RNA in a biological sample at a given moment."*

It is supposed that this dataset contains RNA-seq gene expression data in units of *RPM (Reads per million mapped reads)*, see https://www.biostars.org/p/273537.

##### Columns
Name and Description columns followed by 1156 cell line columns (a total of 1158 columns). Cell line data are integer. Columns contain no NA values.
##### Rows
There are 56,318 rows of *genes*.

### CCLE RNAseq gene expression data (RPKM)
This dataset seems to contain data similar to *CCLE RNAseq gene expression data (read count)*, but instead in units of *RPKM (Reads per kilo base per million mapped reads)*, see https://www.biostars.org/p/273537.

##### Columns
Name and Description columns followed by 1156 cell line columns (a total of 1158 columns). Cell line data are integer. Columns contain no NA values. Column names are identical to column names in *CCLE RNAseq gene expression data (read count)*.
##### Rows
There are 56,318 rows of *genes*. Names and descriptions are identical to names and description in *CCLE RNAseq gene expression data (read count)*.

### CCLE DNA methylation data (promoter 1kb upstream TSS)
From [Wikipedia](https://en.wikipedia.org/wiki/DNA_methylation): *"DNA methylation is a process by which methyl groups are added to the DNA molecule. Methylation can change the activity of a DNA segment without changing the sequence. When located in a gene promoter, DNA methylation typically acts to repress gene transcription. DNA methylation is essential for normal development and is associated with a number of key processes including genomic imprinting, X-chromosome inactivation, repression of transposable elements, aging and carcinogenesis."*

##### Columns
TSS_ID, gene, chr (chromosome), fpos, tpos, strand, avg_covarage, and 843 columns of cell lines (numeric), same as in *CCLE DNA methylation data (promoter CpG clusters)*. Columns contain NA values.
##### Rows
There are 20,192 rows of genes.

### CCLE DNA methylation data (promoter CpG clusters)
##### Columns
cluster_id, gene_name, RefSeq_id, CpG_sites_hg19, avg_coverage, and 843 columns of cell lines (numeric), same as in *CCLE DNA methylation data (promoter 1kb upstream TSS)*. Columns contain NA values.
##### Rows
There are 54,531 rows of gene clusters / genes.

### CCLE miRNA expression data
Micro-RNA expression data.

##### Columns
Name, Description, and 954 columns of cell lines (numeric).
##### Rows
There are 734 rows of micro-RNA samples.

# The *typesof_* files
Every dataset file has a corresponding CSV file with the prefix *typesof_*, which contains column (variable) name and class pairs. For example, *RPPA antibody information* comes from *CCLE_RPPA_Ab_info_20180123.csv* and so there's a file named *typesof_CCLE_RPPA_Ab_info_20180123.csv* which contains the following lines:

    Antibody_Name,factor
    Target_Genes,factor
    Validation_Status,factor
    Company,factor
    Catalog_Number,factor

These files have been created by taking small samples (like first 100 lines) of the dataset files, and identifying the column classes using them. They are dual-purpose:
- they help understand the structure of the datasets
- they can be provided to read.csv / read.table, which can read data more efficiently using these pieces of information

# Analysed data
Not all the data is used in this project, only the following ones:
- CCLE Reverse Phase Protein Array (RPPA) data
- CCLE RNAseq gene expression data (read count)
- CCLE RNAseq gene expression data (RPKM)
- CCLE DNA methylation data (promoter 1kb upstream TSS)
- CCLE DNA methylation data (promoter CpG clusters)
- CCLE miRNA expression data

# In-memory datasets
Note: *RPPA antibody information* and *Merged mutation calls (coding region; germline filtered)* are currently not used.

### RPPA
Contains the complete *CCLE Reverse Phase Protein Array (RPPA) data* dataset which has been read in from *CCLE_RPPA_20180123.csv*.

### RNAseq.read
Contains the *CCLE RNAseq gene expression data (read count)* dataset which has been read in from *CCLE_DepMap_18q3_RNAseq_reads_20180718.gct*, with the following modification: it is prepared to derive basic characteristics, and therefore **the first two non-numeric columns are removed**.

### RNAseq.rpkm
Contains the *CCLE RNAseq gene expression data (RPKM)* dataset which has been read in from *CCLE_DepMap_18q3_RNAseq_RPKM_20180718.gct*, with the following modification: it is prepared to derive basic characteristics, and therefore **the first two non-numeric columns are removed**.

### miRNA
Contains the *CCLE miRNA expression data* dataset which has been read in from *CCLE_miRNA_20180525.gct*, with the following modification: it is prepared to derive basic characteristics, and therefore **the first two non-numeric columns are removed**.

### DNAmet.1kb
Contains the *CCLE DNA methylation data (promoter 1kb upstream TSS)* dataset which has been read in from *CCLE_RRBS_TSS_1kb_20180614.txt*, with the following modification: it is prepared to derive basic characteristics, and therefore **the first seven columns are removed**, namely *TSS_ID, gene, chr, fpos, tpos, strand, avg_covarage*.

### DNAmet.cpg
Contains the *CCLE DNA methylation data (promoter CpG clusters)* dataset which has been read in from *CCLE_RRBS_TSS_CpG_clusters_20180614.txt*, with the following modification: it is prepared to derive basic characteristics, and therefore **the first five columns are removed**, namely *cluster_id, gene_name, RefSeq_id, CpG_sites_hg19, avg_coverage*.

### basics
This is a list which contains the basic characteristics of all the datasets described above, and so it contains the following sub-lists:
- $RPPA
- $RNAseq.read 
- $RNAseq.rpkm 
- $miRNA 
- $DNAmet.1kb 
- $DNAmet.cpg

Each of these sub-lists consist of four items:
- *$Row:* basic row characteristics in a data.frame object
- *$Column:* basic column characteristics in a data.frame object
- *$Total:* overall dataset characteristics in a list object
- *$Summaries$Essentials:* overall dataset characteristics in a data.frame object, prepared to use on plots

**Note:** all the basic characteristics (except of course *NA.count*) are calculated without NA values (i.e. *na.rm = TRUE* used whenever applicable).

##### The $Row table

Column number | Column name | Description
--- | --- | ---
1 | ID | Unique row identifier numbers
2 | Minimum | Minimum of each row of the dataset
3 | Maximum | Maximum of each row of the dataset
4 | Mean | Mean of each row of the dataset
5 | Standard.deviation | Standard deviation of each row of the dataset
6 | Maxmin.difference | Difference between the maximum and the minimum value in each row
7 | NA.count | The number of NA values in each row
8 | 25% | The 25% quantile of each row
9 | 50% | The 50% quantile (i.e. the median) of each row
10 | 75% | The 75% quantile of each row

##### The $Column table

Column number | Column name | Description
--- | --- | ---
1 | ID | Unique column identifier numbers
2 | Minimum | Minimum of each column of the dataset
3 | Maximum | Maximum of each column of the dataset
4 | Mean | Mean of each column of the dataset
5 | Standard.deviation | Standard deviation of each column of the dataset
6 | Maxmin.difference | Difference between the maximum and the minimum value in each column
7 | NA.count | The number of NA values in each column
8 | 25% | The 25% quantile of each column
9 | 50% | The 50% quantile (i.e. the median) of each column
10 | 75% | The 75% quantile of each column

##### The $Total list

List item number | List item name | Description
--- | --- | ---
1 | Minimum | The minimum of the whole dataset
2 | 25% | The 25% quantile of the whole dataset
3 | Median | The 50% quantile (median) of the whole dataset
4 | 75% | The 75% quantile of the whole dataset
5 | Maximum | The maximum of the whole dataset
6 | Mean | The mean of the whole dataset
7 | NRows | The number of rows in the dataset
8 | NCols | The number of columns in the dataset

##### The $Summaries$Essentials table
This data.frame looks like as follows:

Dataset size (RxC) | Minimum | 25% | Median | 75% | Maximum | Mean
--- | --- | --- | --- | --- | --- | ---
<$NRows> x <$NCols> | <$Minimum> | <$\`25%\`> | <$Median> | <$\`75%\`> | <$Maximum> | <$Mean>

All of the values above are taken from *$Total*.

# Data analysis procedure
Currently the following steps are taken in this project to analyse the data.

Step | Description | Done by
--- | --- | ---
1 | Download datasets from https://portals.broadinstitute.org/ccle/data | *Human\**
2 | Create *datasets.csv* which summarizes the datasets | *Human\**
3 | Read the first few hundred lines of the datasets to create the *typesof_* files, and explore the possible NA values (note: with later refinement) | *Human\**
4 | Read the datasets specified in section [Analysed data](#analysed-data) | read.data()
5 | Post-shape the datasets from step 4 as specified in section [In-memory datasets](#in-memory-datasets) | post.shape()
6 | Loop over the datasets from step 5 and for each: |
6.1 | --- Create the *basics* dataset specified in section [In-memory datasets](#in-memory-datasets) | explore.basics()
6.2 | --- Create the *column basics plot* | plot.basics()
6.3 | --- Create the *column quantiles plot* | plot.quantiles()
6.4 | --- Create the *row basics plot* | plot.basics()
6.5 | --- Create the *row quantiles plot* | plot.quantiles()

*\* This means the step is out of the scope of *A.R*.*

# Plots
The project supports the following plots:

- Column basics
- Column quantiles
- Row basics
- Row quantiles
- *Column and row basics (not used)*
- *Column and row quantiles (not used)*

Plots are always placed in the *figures* sub-directory of the working directory.

### Basics (column, row, column and row)
These plots are created by *plot.basics()* and provide a side-by-side visualization of the basic characteristics of a dataset: 
- table of overalls (dataset size, minimum, 25% quantile, median, 75% quantile, maximum and mean)
- plots of the minimum, maximum, NA count, mean, standard deviation, difference between maximum and minimum, and quartiles of each columns, rows or both.

Example:

![Example of a column basics plot](https://raw.githubusercontent.com/uxexax/T/master/figures/CCLE%20Reverse%20Phase%20Protein%20Array%20(RPPA)%20data%20-%20Column%20basics.png "Example of a column basics plot")

Note: a *column and row basics plot* is made simply by placing a *column basics plot* and a *row basics plot* side-by-side.

### Quantiles (column, row, column and row)
These plots are created by *plot.quantiles()* and show different sets of quantiles of each column, row or both of a dataset on a single image. The function can theoretically take any number of arbitrary quantile settings. The current analysis uses these:

    0%, 100%
    0%, 50%, 100%
    0%, 25%, 50%, 75%, 100%
    25%, 50%, 75%
    12.5%, 25%, 37.5%, 50%, 62.5%, 75%, 87.5%

Example:

![Example of a column quantiles plot](https://raw.githubusercontent.com/uxexax/T/master/figures/CCLE%20Reverse%20Phase%20Protein%20Array%20(RPPA)%20data%20-%20Column%20quantiles.png "Example of a column quantiles plot")

Note: a *column and row quantiles plot* is made simply by placing a *column quantiles plot* and a *row quantiles plot* side-by-side.
