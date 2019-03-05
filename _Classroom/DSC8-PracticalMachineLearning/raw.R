# Sandbox for the Rmd.

library(caret)
library(ggplot2)
library(reshape2)
library(gridExtra)
library(gbm)
library(randomForest)
library(kableExtra)

if (!dir.exists("data")) {
  dir.create("data")
}
download.file(url = "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv",
              destfile = "data/pml-training.csv")
download.file(url = "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv",
              destfile = "data/pml-testing.csv")

training <- read.csv("data/pml-training.csv")
testing <- read.csv("data/pml-testing.csv")


# ---------- check and remove all-NA variables

allna.col.tr <- sapply(training, function (X) all(is.na(X)))
allna.col.tst <- sapply(testing, function (X) all(is.na(X)))

print(paste("Number of all-NA columns in the training set:", sum(allna.col.tr)))
print(paste("Number of all-NA columns in the test set:", sum(allna.col.tst)))

na.colnames.tst <- names(training)[allna.col.tst]
print(paste("All-NA variables are also variables of training set:",
            all(na.colnames.tst %in% names(training))))

tr.reduced <- training[,!(names(training) %in% na.colnames.tst)]
tst.reduced <- testing[,!(names(testing) %in% na.colnames.tst)]

# ---------- check and handle partial-NA variables

parna.col.tr <- sapply(tr.reduced, function (X) any(is.na(X)))
parna.col.tst <- sapply(tst.reduced, function (X) any(is.na(X)))

print(paste("Number of partial-NA columns in the training set:", sum(parna.col.tr)))
print(paste("Number of partial-NA columns in the test set:", sum(parna.col.tst)))

# ---------- remove trash columns

tr.reduced <- tr.reduced[!(names(tr.reduced) %in%
                             c("X", "raw_timestamp_part_1", "raw_timestamp_part_2",
                               "new_window", "num_window", "user_name", "cvtd_timestamp"))]
tst.reduced <- tst.reduced[!(names(tst.reduced) %in%
                               c("X", "raw_timestamp_part_1", "raw_timestamp_part_2",
                                 "new_window", "num_window", "user_name", "problem_id",
                                 "cvtd_timestamp"))]

# ---------- check that same predictors remained in both tr and tst after pre-processing

print(paste("Same predictors in training and test sets after pre-processing:",
            all((names(tr.reduced)[names(tr.reduced) != "classe"] %in% names(tst.reduced)) &
                  (names(tst.reduced) %in% names(tr.reduced)[names(tr.reduced) != "classe"]))))


# ---------- outliers
# assupmtion: there are groups of variables (their name beginning with the same string);
# features belonging to the same group should be of the same magnitude
# groups indentified in the reduces training data set:
#   gyros_*, accel_*, magnet_*, roll_*, pitch_*, yaw_*

draw.boxes <- function(group)
{
  indices <- c("classe", grep(pattern = group, x = names(tr.reduced), value = TRUE))
  molten <- melt(tr.reduced[indices], id.vars = "classe")
  return(
    ggplot(data = molten) +
      theme_light(base_size = 14) +
      labs(x = "Feature name", y = "Feature value", title = paste("Boxplot of feature group", group)) +
      theme(axis.text.x = element_text(angle = 70, hjust = 1)) +
      geom_boxplot(mapping = aes(x = variable, y = value),
                   outlier.color = "orange", outlier.size = 2))
}

groups <- c("gyros_", "accel_", "magnet_", "roll_", "pitch_", "yaw_")
gbx <- list()
for (group in groups) {
  message(paste("Creating boxplot for group", group))
  png(filename = paste("bx", group, "initial.png", sep = "_"),
      width = 1920, height = 1080, res = 150)
  gbx[[group]] <- draw.boxes(group)
  plot(gbx[[group]])
  dev.off()
}
plot(gbx$accel_)

outcome <- "classe"
predictors <- names(tr.reduced)[names(tr.reduced) != outcome]

png(filename = "features_1_original.png", width = 1920, height = 1080)
featurePlot(tr.reduced[,predictors], tr.reduced[,outcome])
dev.off()

# ---------- pre-processing
limit.feature <- function(DS, feature, limit.lower, limit.upper, create.plot = FALSE) {
  G <- NULL
  if (create.plot) DS.copy <- DS
  
  outliers <- which((DS[[feature]] < limit.lower) | (DS[[feature]] > limit.upper))
  o.table <- data.frame(index = outliers, value = DS[[feature]][outliers])
  if (length(outliers) != 0) DS <- DS[-outliers,]
  
  if (create.plot) {
    g.before <-
      qplot(1:nrow(DS.copy), DS.copy[[feature]], color = I("steelblue"),
            xlab = "Sample", ylab = feature, main = "Before") +
      theme_light()
    
    g.after <- g.before
    if (length(outliers) != 0) {
      g.after <-
        qplot(1:nrow(DS), DS[[feature]], color = I("steelblue"),
              xlab = "Sample", ylab = feature, main = "After") +
        theme_light()
    }
    
    G <- arrangeGrob(grobs = list(g.before, g.after), ncol = 2)
  }
  
  return(list(DS = DS, G = G, o.table = o.table))
}

limit.group <- function(DS, feature.group, limit.lower, limit.upper) {
  features <- 
    grep(pattern = feature.group, x = names(tr.reduced), value = TRUE)
  
  nrow.before <- nrow(DS)
  for (f in features) {
    message(f)
    L <- limit.feature(DS, f, limit.lower, limit.upper)
    DS <- L$DS
  }
  message(paste("== Removed", nrow.before - nrow(DS), "samples =="))
  return(DS)
}

tr.reduced <- limit.group(tr.reduced, "accel_", -750, 750)
tr.reduced <- limit.group(tr.reduced, "gyros_", -7, 7)
tr.reduced <- limit.group(tr.reduced, "magnet_", -1600, 1600)

# replot
groups <- c("gyros_", "accel_", "magnet_")
gbx <- list()
for (group in groups) {
  message(paste("Creating boxplot for group", group))
  png(filename = paste("bx", group, "outl_removed.png", sep = "_"),
      width = 1920, height = 1080, res = 150)
  gbx[[group]] <- draw.boxes(group)
  plot(gbx[[group]])
  dev.off()
}
plot(gbx$accel_)

png(filename = "features_2_outliers_removed.png", width = 1920, height = 1080)
featurePlot(tr.reduced[,predictors], tr.reduced[,outcome])
dev.off()

tr2 <- scale(tr.reduced[,predictors], center = TRUE, scale = TRUE)

tr.means <- sapply(tr.reduced[,predictors], mean)
tr.sds <- sapply(tr.reduced[,predictors], sd)
# tr.reduced[,predictors] <- (tr.reduced[,predictors] - tr.means) / tr.sds

for (p in predictors) {
  tr.reduced[,p] <- (tr.reduced[,p] - tr.means[[p]]) / tr.sds[[p]]
}

png(filename = "features_3_scaled.png", width = 1920, height = 1080)
featurePlot(tr.reduced[,predictors], tr.reduced[,outcome])
dev.off()

sapply(predictors, function (X) {
  png(filename = paste0("feature_3_", X, ".png"), width = 1920, height = 1080)
  featurePlot(tr.reduced[,X], tr.reduced[,outcome])
  dev.off()
})

for (i in 1:length(predictors)) {
  message(predictors[[i]])
  #  png(filename = paste0("feature_3_", predictors[[i]], ".png"), width = 1920, height = 1080)
  featurePlot(tr.reduced[,predictors[[i]]], tr.reduced[,outcome])
  dev.copy(device = png, filename = paste0("feature_3_", predictors[[i]], ".png"), width = 1920, height = 1080)
}

for (p in predictors) {
  message(p)
  png(filename = paste0("feature_3_", p, ".png"), width = 1920, height = 1080)
  g <- featurePlot(tr.reduced[,p], tr.reduced[,outcome])
  plot(g)
  dev.off()
}

F <- tr.reduced[sample(1:nrow(tr.reduced), size = 1000, replace = FALSE),]
#P <- preProcess(tr.reduced[!(names(tr.reduced)=="classe")], method = "scale")

featurePlot(F[predictors], F$classe)
featurePlot(tr.reduced[predictors], tr.reduced$classe)

# ---------- training

tr.indices <- createDataPartition(tr.reduced$classe, p = 0.7, list = FALSE)
validation <- tr.reduced[-tr.indices,]
tr.reduced <- tr.reduced[tr.indices,]
val.folds <- createFolds(validation$classe, k = 8)

for (p in predictors) {
  tst.reduced[,p] <- (tst.reduced[,p] - tr.means[[p]]) / tr.sds[[p]]
}

# MODELS

evaluate.fit <- function(fit, validation.set, test.set, predictors, method) {
  ACC <- function(real, predicted) {
    return (sum(real==predicted)/length(predicted))
  }
  
  if (method == "rf") {
    val.pred <- predict(fit, validation.set[,predictors])
    tst.pred <- predict(fit, test.set)
  } else if (method == "gbm") {
    val.pred <- predict(fit, validation.set[,predictors], n.trees = fit$n.trees)
    val.pred <- factor(
      apply(val.pred, 1, function (X) which(max(X) == X)),
      labels = c('A', 'B', 'C', 'D', 'E'))
    tst.pred <- factor(
      apply(
        predict(fit, test.set, n.trees = fit$n.trees),
        1,
        function (X) which(max(X) == X)),
      labels = c('A', 'B', 'C', 'D', 'E'))
  } else {
    return()
  }
  
  acc <- ACC(validation.set$classe, val.pred)
  
  return(list(acc = acc, tst.pred = tst.pred))
}

ACC <- function(real, predicted) {
  return (sum(real==predicted)/length(predicted))
}

running.i <- 1

ntree.values <- c(100, 500, 200, 1000)
nodesize.values <- c(30, 100, 5, 5)
E.rf <- data.frame(ModelID = numeric(0),
                   Ntree = numeric(0),
                   Nodesize = numeric(0),
                   Accuracy = numeric(0),
                   Prediction = character(0), stringsAsFactors = FALSE)

for (i in 1:4) {
  ntree <- ntree.values[i]; nodesize <- nodesize.values[i]
  fit <- randomForest(tr.reduced[,predictors], tr.reduced[,outcome],
                      ntree = ntree, nodesize = nodesize)
  eval <- evaluate.fit(fit, validation[val.folds[[running.i]],],
                       tst.reduced, predictors, "rf")
  E.rf <- rbind(E.rf,
                data.frame(ModelID = running.i,
                           Ntree = ntree,
                           Nodesize = nodesize,
                           Accuracy = eval$acc,
                           Prediction = paste(eval$tst.pred, collapse = " ")))
  running.i <- running.i + 1
}

ntree.values <- c(100, 100, 200, 300)
idepth.values <- c(1, 2, 3, 4)
E.gbm <- data.frame(ModelID = numeric(0),
                    N.trees = numeric(0),
                    Interaction.depth = numeric(0),
                    Accuracy = numeric(0),
                    Prediction = character(0), stringsAsFactors = FALSE)

for (i in 1:4) {
  ntrees <- ntree.values[i]; idepth <- idepth.values[i]
  fit <- gbm(classe ~ ., data = tr.reduced, verbose = TRUE,
             n.trees = ntrees, interaction.depth = idepth)
  eval <- evaluate.fit(fit, validation[val.folds[[running.i]],],
                       tst.reduced, predictors, "gbm")
  E.gbm <- rbind(E.gbm,
                 data.frame(ModelID = running.i,
                            N.trees = ntrees,
                            Interaction.depth = idepth,
                            Accuracy = eval$acc,
                            Prediction = paste(eval$tst.pred, collapse = " ")))
  running.i <- running.i + 1
}

fit4 <- gbm(classe ~ ., data = tr.reduced, verbose = TRUE,
            n.trees = 150, interaction.depth = 1)
val4 <- validation[val.folds[[5]],]
pred4 <- predict(fit4, val4[predictors], n.trees = fit4$n.trees)
pred4 <- factor(apply(pred4, 1, function (X) which(max(X) == X)), labels = c('A', 'B', 'C', 'D', 'E'))
ACC(val4$classe, pred4)
# accuracy on validation set: 0.8707483
factor(
  apply(
    predict(fit4, tst.reduced, n.trees = fit4$n.trees),
    1,
    function (X) which(max(X) == X)),
  labels = c('A', 'B', 'C', 'D', 'E'))
# B A A A A E D D A A B C B A E E A B A B
evaluate.fit(fit4, validation[val.folds[[5]],], tst.reduced, predictors, "gbm")

fit4.2 <- gbm(classe ~ ., data = tr.reduced, verbose = TRUE,
              n.trees = 500, interaction.depth = 2)
val4.2 <- validation[val.folds[[6]],]
pred4.2 <- predict(fit4.2, val4.2[predictors], n.trees = fit4.2$n.trees)
pred4.2 <- factor(
  apply(
    pred4.2, 1, function (X) which(max(X) == X)),
  labels = c('A', 'B', 'C', 'D', 'E'))
acc4.2 <- ACC(val4.2$classe, pred4.2)
# accuracy on validation set: 0.9714286
factor(
  apply(
    predict(fit4.2, tst.reduced, n.trees = fit4.2$n.trees),
    1,
    function (X) which(max(X) == X)),
  labels = c('A', 'B', 'C', 'D', 'E'))
# B A B A A E D B A A B C B A E E A B B B

eval4.2 <- evaluate.fit(fit4.2, validation[val.folds[[6]],], tst.reduced, predictors, "gbm")
eval4.2


fit4.3 <- gbm(classe ~ ., data = tr.reduced2, verbose = TRUE,
              n.trees = 1000, interaction.depth = 2)
# accuracy: 0.974206
# prediction: B C B A A B D B A A B C B A E E A B A B
fit4.4 <- gbm(classe ~ ., data = tr.reduced2, verbose = TRUE,
              n.trees = 1000, interaction.depth = 3)

tst.reduced.orig <- tst.reduced
for (p in predictors) {
  tst.reduced[,p] <- (tst.reduced[,p] - tr.means[[p]]) / tr.sds[[p]]
}

ACC <- function(real, predicted) {
  return (sum(real==predicted)/length(predicted))
}

pred <- predict(fit3$finalModel, newdata = tst.reduced, n.trees = 150)
apply(pred, 1, function (X) which(max(X) == X))

# accuracy: 0.9986746
# prediction: B A B A A E D B A A B C B A E E A B B B

pred4 <- predict(fit4, newdata = tst.reduced, n.trees = 500)
res <- factor(apply(fit4$fit, 1, function (X) which(max(X) == X)), labels = c('A', 'B', 'C', 'D', 'E'))
ACC(tr.reduced$classe, res)
factor(apply(pred4, 1, function (X) which(max(X) == X)), labels = c('A', 'B', 'C', 'D', 'E'))

pred4.2 <- predict(fit4.2, newdata = tst.reduced, n.trees = 150)
res <- factor(apply(fit4.2$fit, 1, function (X) which(max(X) == X)), labels = c('A', 'B', 'C', 'D', 'E'))
ACC(tr.reduced$classe, res)
factor(apply(pred4.2, 1, function (X) which(max(X) == X)), labels = c('A', 'B', 'C', 'D', 'E'))

pred4.3 <- predict(fit4.3, newdata = tst.reduced, n.trees = 1000)
res <- factor(apply(fit4.3$fit, 1, function (X) which(max(X) == X)), labels = c('A', 'B', 'C', 'D', 'E'))
ACC(tr.reduced$classe, res)
factor(apply(pred4.3, 1, function (X) which(max(X) == X)), labels = c('A', 'B', 'C', 'D', 'E'))

pred4.4 <- predict(fit4.4, newdata = tst.reduced, n.trees = 2000)
res <- factor(apply(fit4.4$fit, 1, function (X) which(max(X) == X)), labels = c('A', 'B', 'C', 'D', 'E'))
ACC(tr.reduced$classe, res)
factor(apply(pred4.4, 1, function (X) which(max(X) == X)), labels = c('A', 'B', 'C', 'D', 'E'))


pred2 <- predict(fit2, newdata = tst.reduced)
ACC(tr.reduced$classe, fit2$predicted)

pred2.2 <- predict(fit2.2, newdata = tst.reduced)
ACC(tr.reduced$classe, fit2.2$predicted)

pred2.3 <- predict(fit2.3, newdata = tst.reduced)
ACC(tr.reduced$classe, fit2.3$predicted)

pred2.4 <- predict(fit2.4, newdata = tst.reduced)
ACC(tr.reduced$classe, fit2.4$predicted)

pred2.5 <- predict(fit2.5, newdata = tst.reduced)
ACC(tr.reduced$classe, fit2.5$predicted)

pred2.6 <- predict(fit2.6, newdata = tst.reduced)
ACC(tr.reduced$classe, fit2.6$predicted)

pred2.7 <- predict(fit2.7, newdata = tst.reduced)
ACC(tr.reduced$classe, fit2.7$predicted)
