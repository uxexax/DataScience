best <- function(requested.state, outcome, filename = "outcome-of-care-measures.csv") {

  if (!any(outcome == c("Heart.Attack", "Heart.Failure", "Pneumonia"))) {
    stop("Argument 'outcome' has invalid value")
  }
  
  D <- read.csv(filename, na.strings = "Not Available", stringsAsFactors = FALSE)
  var.name <- paste0("Hospital.30.Day.Death..Mortality..Rates.from.", outcome)
  
  if (!any(requested.state == unique(D$State))) {
    stop("Argument 'requested.state' has invalid value")
  }
  
  # state.data <- split(D,    D$State)$requested.state
  state.data <- D[D$State == requested.state, ]
  # state.data[[var.name]] <- as.numeric(state.data[[var.name]])
  best.hospitals <- state.data[state.data[[var.name]] == min(state.data[[var.name]],
                                                             na.rm = TRUE), ]$Hospital.Name
  # best.hospitals <- as.character(best.hospitals)
  head(sort(best.hospitals), 1)
}

rankhospital <- function(requested.state, outcome, ranking = 1, ranking.to = ranking,
                         filename = "outcome-of-care-measures.csv") {

  if (!any(outcome == c("Heart.Attack", "Heart.Failure", "Pneumonia"))) {
    stop("Argument 'outcome' has invalid value")
  }
  
  D <- read.csv(filename, na.strings = "Not Available", stringsAsFactors = FALSE)
  var.name <- paste0("Hospital.30.Day.Death..Mortality..Rates.from.", outcome)
  
  if (!any(requested.state == unique(D$State))) {
    stop("Argument 'requested.state' has invalid value")
  }
  
  state.data <- D[D$State == requested.state, ]
  ordered.data <- state.data[order(
    state.data[[var.name]], state.data$Hospital.Name, na.last = NA), ]

  if (ranking == "best") ranking <- ranking.to <- 1
  if (ranking == "worst") ranking <- ranking.to <- nrow(ordered.data)
  
  ordered.data[ranking:ranking.to, ]$Hospital.Name
}

rankall <- function(outcome, ranking = 1, 
                    filename = "outcome-of-care-measures.csv") {
  
  if (!any(outcome == c("Heart.Attack", "Heart.Failure", "Pneumonia"))) {
    stop("Argument 'outcome' has invalid value")
  }
  
  D <- read.csv(filename, na.strings = "Not Available", stringsAsFactors = FALSE)
  var.name <- paste0("Hospital.30.Day.Death..Mortality..Rates.from.", outcome)
  
  split.data <- split(D, D$State)
  ordered.data <- lapply(split.data, 
                         function (x) x[order(x[[var.name]], x$Hospital.Name, na.last = NA), ])
  
  maxnrow <- max(sapply(ordered.data, function (x) nrow(x)))
  if (ranking == "best") ranking <- ranking.to <- 1

  if (ranking == "worst") {
    rank.data <- lapply(ordered.data, function (x) x[nrow(x), ])
  } else {
    rank.data <- lapply(ordered.data, function (x) x[ranking, ])
  }
  hospital <- as.character(0)
  state <- as.character(0)
  for (i in 1:length(rank.data)) {
    hospital <- c(hospital, as.character(rank.data[[i]][[2]]))
    state <- c(state, as.character(rank.data[[i]][[7]]))
  }
  rank.data <- data.frame(hospital = hospital, state = state)
  rank.data
}