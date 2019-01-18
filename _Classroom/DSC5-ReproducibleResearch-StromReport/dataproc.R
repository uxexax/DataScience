clean.dollars <- function(dollar.vector, dollar.exp)
{
  valid.exp <- c("", "K", "M", "B")
  
  dollar.vector <- replace(dollar.vector, !(dollar.exp %in% valid.exp), 0)
  dollar.exp <- replace(dollar.exp, !(dollar.exp %in% valid.exp), "")

  dollar.exp <- replace(dollar.exp, dollar.exp == "", "U")

  value.map <- c(U = 1, K = 1e3, M = 1e6, B = 1e9)
  
  for (v in names(value.map))
  {
    dollar.vector[dollar.exp == v] <- 
      dollar.vector[dollar.exp == v] * value.map[v]
  }
  
  return(dollar.vector)
}

multi.events <- function(permitted, present)
{
  event.list <- character()

  for (p in permitted)
  {
    ev.subset <- grep(p, present, value = TRUE)
    
    exclude.list <- character()
    for (q in permitted)
    {
      if (!identical(grep(p, q), integer()) ||
          !identical(grep(q, p), integer()))
      {
        exclude.list <- c(exclude.list, q)
      }
    }
    
    for (r in permitted[!(permitted %in% exclude.list)])
    {
      ev.subset2 <- grep(r, ev.subset, value = TRUE)
      event.list <- c(event.list, ev.subset2)
    }
    
    event.list <- unique(event.list)
  }
  
  return(event.list)
}
