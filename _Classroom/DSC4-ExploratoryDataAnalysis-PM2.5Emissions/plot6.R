# This script creats three plots using the EPA National Emissions Inventory:
# (1) Total PM2.5 emissions from motor vehicle sources in Los Angeles County and
#     Baltimore City in years 1999, 2002, 2005 and 2008.
# (2) Difference between maximum and minimum values on (1) per region.
# (3) Difference between 2008 and 1999 totals per region.
# Dataset source: https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip

# ----- Load required packages and datasets
library(dplyr)
library(ggplot2)
library(gridExtra)

if (!("NEI" %in% ls())) 
  NEI <- readRDS("summarySCC_PM25.rds")

if (!("SCC" %in% ls()))
  SCC <- readRDS("Source_Classification_Code.rds")

regionlabs <- c("L.A. County", "Baltimore City")

# ----- Filter data and calculate final data
SCC.highwayVehicles <- SCC %>% 
  filter(SCC.Level.Two == "Highway Vehicles - Gasoline" | 
           SCC.Level.Two == "Highway Vehicles - Diesel")

total.emissions <- NEI %>% 
  filter(fips == "24510" | fips == "06037") %>%
  filter(SCC %in% SCC.highwayVehicles$SCC) %>%
  group_by(fips, year) %>% 
  summarize(Emissions.SUM = sum(Emissions)) %>%
  rename(Region = fips)

conclusions <- total.emissions %>% 
  summarize(Emissions.RANGEDIFF = max(Emissions.SUM) - min(Emissions.SUM))

conclusions <- total.emissions %>% 
  filter(year == 2008 | year == 1999) %>% 
  summarize(Emissions.YEARDIFF = diff(Emissions.SUM)) %>%
  right_join(conclusions, by = "Region")

total.emissions$Region <- factor(total.emissions$Region, labels = regionlabs)
conclusions$Region <- factor(conclusions$Region, labels = regionlabs)

# ----- Plot data
windows(width = 1000, height = 400)

g.yearly <- ggplot(total.emissions, aes(year, Emissions.SUM)) +
            geom_col(aes(fill = Region), width = 1.2, position = "dodge") +
            scale_x_continuous(breaks = unique(total.emissions$year)) +
            labs(title = "Total PM2.5 emissions from motor vehicle sources",
                 x = "Year", y = "Total emission (tons)",
                 caption = "based on the EPA National Emissions Inventory")

g.rndiff <- ggplot(conclusions, aes(Region, Emissions.RANGEDIFF)) + 
            geom_col(width = 0.25, aes(fill=Region), show.legend = FALSE) +
            labs(title = "Range diffs. of totals (max-min)",
                 y = "Differences (tons)",
                 caption = "based on the EPA National Emissions Inventory")

g.yrdiff <- ggplot(conclusions, aes(Region, Emissions.YEARDIFF)) +
            geom_col(width = 0.25, aes(fill=Region), show.legend = FALSE) +
            geom_abline(slope = 0, color = "black") +
            coord_cartesian(ylim = c(-300, 300)) +
            labs(title = "Year diffs. of totals (2008-1999)",
                 y = "Differences (tons)",
                 caption = "based on the EPA National Emissions Inventory")

grid.arrange(g.yearly, g.rndiff, g.yrdiff, nrow = 1, widths = c(2,1,1))

dev.copy(png, "plot6.png", width = 1000, height = 400)
dev.off()
