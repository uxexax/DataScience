# This function writes the result datasets into CSV files in directory 'Results'.

writeFiles <- function(df.list) {
  message("Writing files")

  if (!dir.exists("Results")) dir.create("Results")
  
  message("-- tidy_data.txt")
  write.table(df.list$tidy.data, "Results/tidy_data.txt", row.names = FALSE)

  message("-- means_perActivity_perSubject.txt")
  write.table(df.list$means.perA.perS, "Results/means_perActivity_perSubject.txt",
              row.names = FALSE)
}