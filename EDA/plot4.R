labels <- read.table("data/household_power_consumption.txt", header = TRUE, sep=";", nrows=1)
names <- c(colnames(labels))

f<-file("data/household_power_consumption.txt","r");
data <- read.table(text = grep("^[1,2]/2/2007",readLines(f),value=TRUE), header=FALSE, sep=";", col.names=names)
close(f)

#adding new column with combined date and time
data$datetime <- as.POSIXct(paste(data$Date, data$Time), format = "%d/%m/%Y %H:%M:%S")

x11(width=10, height=8, bg="white")
par(mfcol = c(2, 2))
plot(data[,10], data[,3], type="l", ylab="Global Active Power (kilowatts)", xlab="")

plot(data$datetime, data$Sub_metering_1, type="l", ylab="Energy sub metering", xlab="")
lines(data$datetime, data$Sub_metering_2, type="l", col="red")
lines(data$datetime, data$Sub_metering_3, type="l", col="blue")
legend("topright", lty=1, col = c("black", "blue", "red"), legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), text.width = 55000, y.intersp = 1.5, cex=0.6)

plot(data$datetime, data$Voltage, type="l", xlab="datetime", ylab="Voltage")

plot(data$datetime, data$Global_reactive_power, type="l", xlab="datetime", ylab="Global_reactive_power")

dev.copy(png, file = "plot4.png")
dev.off()