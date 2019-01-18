# This script plots for pieces of relationship within the electric power
# consumption dataset, using the base plotting system. Dataset source:
# https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip
# Only data from 01/Feb/2007-02/Feb/2007 is used.
# Note: this script assumes that the required dataset has been downloaded to the workspace,
# and that it has been unzipped.

source("readLineByLine.R")

# Function doing only the plotting
plotThings <- function()
{
  par(mfrow = c(2,2), ps = 12, mar = c(5,4,2,2))
  
  with(power.consumption,
  {
    plot(DateTime, Global_active_power,
         xlab = "", ylab = "Global Active Power (kilowatts)", type = "l")
    
    plot(DateTime, Voltage, type = "l")
    
    plot(DateTime, Sub_metering_1, type = "n", xlab = "", ylab = "Energy sub metering")
    points(DateTime, Sub_metering_1, type = "l")
    points(DateTime, Sub_metering_2, type = "l", col = "red")
    points(DateTime, Sub_metering_3, type = "l", col = "blue")
    legend("topright", bty = "n", y.intersp = 1,
           legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"),
           lty = c("solid", "solid", "solid"), 
           col = c("black", "red", "blue"))
  
    plot(DateTime, Global_reactive_power, type = "l")
  })
}

figure.w <- figure.h <- 480
ppi <- 72

power.consumption <- readLineByLine()

# Change locale to US so that day names appear in English on the plot
LC_TIME.original <- Sys.getlocale("LC_TIME")
Sys.setlocale("LC_TIME", "us")

# Plot onto the screen
windows(width = 2*figure.w/ppi, height = 2*figure.h/ppi, xpinch = ppi, ypinch = ppi, bg = "white")
plotThings()

# Plot into a png file - to avoid scaling issues, everything is re-plotted
png("plot4.png", width = figure.w, height = figure.h, res = ppi)
plotThings()
dev.off()

Sys.setlocale("LC_TIME", LC_TIME.original)
