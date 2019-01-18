# This script draws the histogram of Global Active Power from the electric
# power consumption dataset, using the base plotting system. Dataset source:
# https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip
# Only data from 01/Feb/2007-02/Feb/2007 is used.
# Note: this script assumes that the required dataset has been downloaded to the workspace,
# and that it has been unzipped.

source("readLineByLine.R")

power.consumption <- readLineByLine()

hist(power.consumption$Global_active_power,
     main = "Global Active Power",
     xlab = "Global Active Power (kilowatts)",
     col = "red")

dev.copy(png, "plot1.png", width = 480, height = 480)
dev.off()
