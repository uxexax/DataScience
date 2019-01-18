# This script plots the total PM2.5 emissions per type of source across in Baltimore City in
# 1999, 2002, 2005, 2008, using the EPA National Emissions Inventory.
# Dataset source: https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip

library(ggplot2)
library(dplyr)

if (!("NEI" %in% ls())) 
  NEI <- readRDS("summarySCC_PM25.rds")

total.emissions <- NEI %>% 
  filter(fips == "24510") %>%
  group_by(type, year) %>% 
  summarize(Emissions = sum(Emissions))

g <- ggplot(total.emissions, aes(year, Emissions)) +
     facet_grid(cols = vars(type)) + 
     geom_point() +
     scale_x_continuous(breaks = unique(total.emissions$year)) +
     theme(panel.spacing.x = unit(15, units = "pt")) +
     labs(title = "Total emissions in Baltimore City per type of source",
          caption = "based on the EPA National Emissions Inventory")

print(g)

dev.copy(png, "plot3.png", width = 1200, height = 300)
dev.off()
