# This script plots the total PM2.5 emissions from coal combustion-related sources
# across US in years 1999, 2002, 2005, 2008, using the EPA National Emissions Inventory.
# Dataset source: https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip

library(dplyr)

if (!("NEI" %in% ls())) 
  NEI <- readRDS("summarySCC_PM25.rds")

if (!("SCC" %in% ls()))
  SCC <- readRDS("Source_Classification_Code.rds")

L1.filter <- grep("[Cc]ombustion", SCC$SCC.Level.One, value = TRUE)
L3.filter <- grep("[Cc]oal", SCC$SCC.Level.Three, value = TRUE)

SCC.coalCombustion <- SCC %>% 
  filter(SCC.Level.One %in% L1.filter) %>%
  filter(SCC.Level.Three %in% L3.filter)

NEI.filtered <- NEI %>% filter(SCC %in% SCC.coalCombustion$SCC)

total.emissions <- data.frame(year = c("1999", "2002", "2005", "2008"),
                              tot.e = tapply(NEI.filtered$Emissions, NEI.filtered$year, sum))

plot(total.emissions, main = "Total PM2.5 emissions in the US from coal combustion",
     xlab = "Year", ylab = "Total emission (tons)")

dev.copy(png, "plot4.png")
dev.off()
