# ----------------------------------------------------------------------------------------------
# This function takes a dataset information record, and creates a list of dataframes
# which describes the corresponding dataset's basic characteristics.
# ----------------------------------------------------------------------------------------------
explore.basics <- function(DS.inf)
{
  DS <- get(DS.inf$Object)

  results <- list()
  
  results$Dataset.name <- DS.inf$Description

  results$Row <- data.frame(ID = 1:nrow(DS), row.names = rownames(DS))
  results$Row$Minimum = apply(DS, 1, min, na.rm = TRUE)
  results$Row$Maximum <- apply(DS, 1, max, na.rm = TRUE)
  results$Row$Mean <- rowMeans(DS, na.rm = TRUE)
  results$Row$Standard.deviation <- apply(DS, 1, sd, na.rm = TRUE)
  results$Row$Maxmin.difference <- apply(DS, 1, function(F) diff(range(F, na.rm = TRUE)))
  results$Row$NA.count <- apply(DS, 1, function (X) sum(is.na(X)))
  results$Row <-
    cbind(results$Row, t(apply(DS, 1, quantile, probs = c(0.25, 0.5, 0.75), na.rm = TRUE)))
  
  results$Column <- data.frame(ID = 1:ncol(DS), row.names = colnames(DS))
  results$Column$Minimum = apply(DS, 2, min, na.rm = TRUE)
  results$Column$Maximum <- apply(DS, 2, max, na.rm = TRUE)
  results$Column$Mean <- colMeans(DS, na.rm = TRUE)
  results$Column$Standard.deviation <- apply(DS, 2, sd, na.rm = TRUE)
  results$Column$Maxmin.difference <- apply(DS, 2, function(F) diff(range(F, na.rm = TRUE)))
  results$Column$NA.count <- apply(DS, 2, function (X) sum(is.na(X)))
  results$Column <-
    cbind(results$Column, t(apply(DS, 2, quantile, probs = c(0.25, 0.5, 0.75), na.rm = TRUE)))
  
  results$Total <- list(Minimum = NULL, `25%` = NULL, Median = NULL, `75%` = NULL, Maximum = NULL)
  results$Total[1:5] <- quantile(as.matrix(DS), na.rm = TRUE)
  results$Total$Mean <- mean(as.matrix(DS), na.rm = TRUE)
  results$Total$NRows <- nrow(DS)
  results$Total$NCols <- ncol(DS)
  
  measures <- c("Dataset size (RxC)", names(results$Total[1:6]))
  values <- append(paste(results$Total$NRows, "x", results$Total$NCols), 
                   lapply(results$Total[1:6], round, 4))

  results$Summaries$Essentials <- data.frame(Measure = measures, Value = as.character(values))

  return(results)
}

# ----------------------------------------------------------------------------------------------
# This function creats a grid of plots of column/row minima, maxima, means, standard deviations,
# maxmin differences, NA counts and quartiles.
# The function takes:
# * basics: the dataframe list returned by explore.basics()
# * direction: one of "Column", "Row" or "Both" telling what statistics to display
# ----------------------------------------------------------------------------------------------
plot.basics <- function(basics, direction = "Column")
{
  old.theme <- theme_set(theme_light() +
                           theme(axis.title.x = element_blank(),
                                 axis.ticks.x = element_blank(),
                                 axis.text.x = element_blank(),
                                 axis.title.y = element_blank(),
                                 axis.ticks.y = element_blank()))
  
  if (!(direction %in% c("Column", "Row"))) 
    direction <- "Both"
  
  g <- list()
  
  simple.plot.names <- 
    c("Minimum", "Maximum", "Mean", "Standard.deviation", "Maxmin.difference", "NA.count")
  
  # ----- Simple plots created for basic column statistics like min, max, mean
  g$Column <- lapply(basics$Column[simple.plot.names],
                     function (Q)
                       qplot(1:basics$Total$NCols, Q, color = I("steelblue"), alpha = I(0.7)))
  
  names(g$Column) <- simple.plot.names
  
  g$Column <- lapply(simple.plot.names,
                     function (N) 
                       g$Column[[N]] + labs(title = sub("\\.", " ", N)))
  
  # ----- Similar simple plots created for basic row statistics
  g$Row <- lapply(basics$Row[simple.plot.names],
                  function (Q)
                    qplot(1:basics$Total$NRows, Q, color = I("steelblue"), alpha = I(0.7)))
  
  names(g$Row) <- simple.plot.names
  
  g$Row <- lapply(simple.plot.names,
                  function (N) 
                    g$Row[[N]] + labs(title = sub("\\.", " ", N)))
  
  # ----- Column quartile plot
  Column.Q4 <- basics$Column %>% 
    select(ID, Minimum, `25%`, `50%`, `75%`, Maximum) %>%
    gather(Quantile, Q.Value, -ID) %>%
    mutate(Quantile = factor(Quantile, c("Maximum", "75%", "50%", "25%", "Minimum")))
  
  g$Column$Quartile <- ggplot(Column.Q4, aes(ID, Q.Value, color = Quantile, alpha = I(0.7))) +
    geom_point() + labs(title = "Quartiles")
  
  # ----- Row quartile plot
  Row.Q4 <- basics$Row %>% 
    select(ID, Minimum, `25%`, `50%`, `75%`, Maximum) %>%
    gather(Quantile, Q.Value, -ID) %>%
    mutate(Quantile = factor(Quantile, c("Maximum", "75%", "50%", "25%", "Minimum")))
  
  g$Row$Quartile <- ggplot(Row.Q4, aes(ID, Q.Value, color = Quantile, alpha = I(0.7))) +
    geom_point() + labs(title = "Quartiles")
  
  # ----- Glob for essential dataset statistics
  g$Column$Info.sheet <- g$Row$Info.sheet <- 
    tableGrob(t(basics$Summaries$Essentials), cols = NULL, rows = NULL)
  
  # ----- A device is created with size and name/title appropriate for the plot grid
  dev.width <- ifelse(direction == "Both", 1600, 800)
  dev.height <- 800
  dev.name <- ifelse(direction == "Both", "Column and row basics", paste(direction, "basics"))
  dev.name <- paste(basics$Dataset.name, dev.name, sep = " - ")
  file.name <- paste0("figures/", dev.name, ".png")
  
  png(file.name, dev.width, dev.height)
  
  # ----- Helper function for plot grid creation
  make.grid <- function(direction, title)
  {
    grid.arrange(grobs = g[[direction]],
                 top = title,
                 nrow = 4, ncol = 3,
                 heights = c(0.5,1,1,1),
                 layout_matrix = rbind(c(8, 8, 8),
                                       c(1, 2, 6),
                                       c(3, 4, 5),
                                       c(7, 7, 7)))
  }

  # ----- Plot grid created and printed onto the device
  grid.title <- sub("-", "\n", dev.name)
  if (direction != "Both")
  {
    final.grid <- make.grid(direction, grid.title)
  }
  else
  {
    col.grid <- make.grid("Column", "Column basics")
    row.grid <- make.grid("Row", "Row basics")
    
    final.grid <- grid.arrange(grobs = list(col.grid, row.grid), ncol = 2, top = grid.title)
  }
  
  dev.off()

  theme_set(old.theme)
  
  return(NULL)
}

# ----------------------------------------------------------------------------------------------
# This function creates a grid of plots showing different quantiles.
# Takes:
# * ...: the requested quantiles as a list of numeric vectors; quantiles must be
#   in the 0 to 1 range, other values are coerced to 0 or 1
# * DS.inf: a dataset information record
# * direction: one of "Column", "Row" or "Both" telling what statistics to display
# ----------------------------------------------------------------------------------------------
plot.quantiles <- function(..., DS.inf, direction = "Column")
{
  old.theme <- theme_set(theme_light() +
                           theme(axis.title.x = element_blank(),
                                 axis.ticks.x = element_blank(),
                                 axis.text.x = element_blank(),
                                 axis.title.y = element_blank(),
                                 axis.ticks.y = element_blank()))

  if (!(direction %in% c("Column", "Row"))) 
    direction <- "Both"
  
  dataset <- get(DS.inf$Object)
  
  args <- list(...)
  quants.needed <- lapply(args, sapply, function (X) max(min(X, 1), 0))
  quants.needed <- lapply(quants.needed, function (X) sort(unique(X)))

  g <- list()
  
  # ----- Helper function for quantile plot creation
  create.plot <- function(L, direction)
  {
    # Q like quantiles
    Q <- apply(dataset, ifelse(direction == "Column", 2, 1), quantile, L, na.rm = TRUE)
    Q <- data.frame(t(Q), check.names = FALSE)

    colnames(Q)[colnames(Q) == "0%"] <- "Minimum"
    colnames(Q)[colnames(Q) == "50%"] <- "Median"
    colnames(Q)[colnames(Q) == "100%"] <- "Maximum"

    factor.levels <- rev(colnames(Q))
    Q <- Q %>%
      mutate(ID = seq(1, ifelse(direction == "Column", ncol(dataset), nrow(dataset)))) %>%
      gather(Quantile, Q.value, -ID) %>%
      mutate(Quantile = factor(Quantile, factor.levels))

    ggplot(Q, aes(ID, Q.value, color = Quantile)) + geom_point(alpha = 0.7)
  }

  # ----- A device is created with size and name/title appropriate for the plot grid
  dev.width <- 1600 #ifelse(direction == "Both", 1600, 800)
  dev.height <- 800
  dev.name <- ifelse(direction == "Both", "Column and row quantiles", paste(direction, "quantiles"))
  dev.name <- paste(DS.inf$Description, dev.name, sep = " - ")
  file.name <- paste0("figures/", dev.name, ".png")
  
  png(file.name, dev.width, dev.height)
  
  # ----- Plot grid created and printed onto the device
  grid.title <- sub("-", "\n", dev.name)
  if (direction != "Both")
  {
    g <- lapply(quants.needed,
                function (Q) create.plot(Q, direction))

    grid.arrange(grobs = g, nrow = min(length(quants.needed), 5), top = grid.title)
  }
  else
  {
    g <- lapply(quants.needed,
                function (Q) create.plot(Q, "Column"))
    col.grid <- grid.arrange(grobs = g, nrow = min(length(quants.needed), 5))

    g <- lapply(quants.needed,
                function (Q) create.plot(Q, "Row"))
    row.grid <- grid.arrange(grobs = g, nrow = min(length(quants.needed), 5))

    grid.arrange(grobs = list(col.grid, row.grid), ncol = 2)
  }
  
  dev.off()
    
  theme_set(old.theme)
  
  return(NULL)
}

#
#
#
SVD.PCA <- function(DS.inf, direction = "Column")
{
  dataset <- get(DS.inf$Object)
  
  M <- 1
  N <- 10
  nvar <- N - M + 1
  
  subsetMN <- dataset[,M:N]
  
  SVD <- svd(subsetMN)
  PCA <- prcomp(subsetMN)
  
  dev.name <- paste0("figures/",
                     DS.inf$Description, 
                     " - ",
                     direction,
                     " subset ",
                     paste0(M, "-", N),
                     " SVD.png")
  png(dev.name, width = 1000, height = N*500)
  par(mfcol = c(N,1))
  if (direction == "Column")
  {
    for (i in 1:nvar) plot(SVD$v[,i], pch = 19, cex = 2, col = "steelblue")
  }
  else if (direction == "Row")
  {
    for (i in 1:nvar) plot(SVD$u[,i], pch = 19, cex = 2, col = "steelblue")
  }
  dev.off()
  
  return(NULL)
}