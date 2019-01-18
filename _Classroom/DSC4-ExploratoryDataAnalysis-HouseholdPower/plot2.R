# This script draws the Global Active Power as a function of time from the electric
# power consumption dataset, using the base plotting system. Dataset source:
# https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip
# Only data from 01/Feb/2007-02/Feb/2007 is used.
# Note: this script assumes that the required dataset has been downloaded to the workspace,
# and that it has been unzipped.

source("readLineByLine.R")

# Change locale to US so that day names appear in English on the plot
LC_TIME.original <- Sys.getlocale("LC_TIME")
Sys.setlocale("LC_TIME", "us")

power.consumption <- readLineByLine()

with(power.consumption, plot(DateTime, Global_active_power, xlab = "", 
                             ylab = "Global Active Power (kilowatts)", type = "l"))

dev.copy(png, "plot2.png", width = 480, height = 480)
dev.off()

Sys.setlocale("LC_TIME", LC_TIME.original)
