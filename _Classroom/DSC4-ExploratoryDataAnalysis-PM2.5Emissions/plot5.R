# This script plots the total PM2.5 emissions from motor vehicle sources in Baltimore
# City in years 1999, 2002, 2005, 2008, using the EPA National Emissions Inventory.
# Dataset source: https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip

library(dplyr)

if (!("NEI" %in% ls())) 
  NEI <- readRDS("summarySCC_PM25.rds")

if (!("SCC" %in% ls()))
  SCC <- readRDS("Source_Classification_Code.rds")

SCC.highwayVehicles <- SCC %>% 
  filter(SCC.Level.Two == "Highway Vehicles - Gasoline" | 
           SCC.Level.Two == "Highway Vehicles - Diesel")

NEI.filtered <- NEI %>% 
  filter(fips == "24510") %>%
  filter(SCC %in% SCC.highwayVehicles$SCC)

total.emissions <- data.frame(year = c("1999", "2002", "2005", "2008"),
                              tot.e = tapply(NEI.filtered$Emissions, NEI.filtered$year, sum))

plot(total.emissions, main = "Total PM2.5 em. in Baltimore City from motor vehicles",
     xlab = "Year", ylab = "Total emission (tons)")

dev.copy(png, "plot5.png")
dev.off()
