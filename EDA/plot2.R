labels <- read.table("data/household_power_consumption.txt", header = TRUE, sep=";", nrows=1)
names <- c(colnames(labels))

f<-file("data/household_power_consumption.txt","r");
data <- read.table(text = grep("^[1,2]/2/2007",readLines(f),value=TRUE), header=FALSE, sep=";", col.names=names)
close(f)

#adding new column with combined date and time
data$Date_Time <- as.POSIXct(paste(data$Date, data$Time), format = "%d/%m/%Y %H:%M:%S")

plot(data[,10], data[,3], type="l", ylab="Global Active Power (kilowatts)", xlab="")
dev.copy(png, file = "plot2.png")
dev.off()