S <- system.time(NULL)

sourcefile <- "linebyline.R"
rounds <- 5

showResult <- function(timedata, current.round = NULL, rounds = NULL) {
  timedata <- unclass(timedata)
  
  if (!is.null(rounds)) {
    message(paste0(rounds, "-round average results:"))
  } else if (!is.null(current.round)) { 
    message(paste0("Round ", current.round, " results:"))
  } else {
    message("???")
    return()
  }
  message(paste0("  user time:    ", format(timedata['user.self'], digits = 5), " seconds"))
  message(paste0("  system time:  ", format(timedata['sys.self'], digits = 5), " seconds"))
  message(paste0("  elapsed time: ", format(timedata['elapsed'], digits = 5), " seconds\n"))
}

for (r in 1:rounds)
{
  message(paste0("Doing round ", r))
  S.cur <- system.time(source(sourcefile))
  showResult(S.cur, r)
  S <- S + S.cur
}

showResult(S / rounds, rounds = rounds)
