# This script plots the total PM2.5 emissions in the Unites States in years
# 1999, 2002, 2005, 2008, using the EPA National Emissions Inventory.
# Dataset source: https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip

if (!("NEI" %in% ls())) 
  NEI <- readRDS("summarySCC_PM25.rds")

total.emissions <- data.frame(year = c("1999", "2002", "2005", "2008"),
                              tot.e = tapply(NEI$Emissions, NEI$year, sum))

plot(total.emissions, main = "Total PM2.5 emissions in the United States",
     xlab = "Year", ylab = "Total emission (tons)")

dev.copy(png, "plot1.png")
dev.off()
