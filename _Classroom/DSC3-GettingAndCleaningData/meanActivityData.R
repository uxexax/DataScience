# This function calculates the means of means and standard deviations of activity
# data per subject for every activity type. The data passed in the 'original'
# argument is expected to be a data.frame returned by restructureData().

meanActivityData <- function(original) {
  message("Calculating means")
  
  D <- 
    original %>% 
    group_by(activity, subjectID) %>% 
    summarize_all(mean) %>%
    rename_at(3:68, function (x) paste0(x, "_mean"))
  
  D
}