##Downloading and unziping the file
temp <- tempfile() #Create a temp file, because there is no need to download the entire zip file.
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, temp, method = "curl")
data <- unzip(temp)

##Merging the dataset
data_test <- cbind((read.table(data[15])), (read.table(data[16])), (read.table(data[14]))) #Merging the test files
data_train <- cbind((read.table(data[27])), (read.table(data[28])), (read.table(data[26]))) #Merging the training files
data_complete <- rbind(data_test, data_train) #Combining the test and training files

##Extracting only the measurements on the mean and standard deviation for each measurement
#Identifying the necessary columns for extracting
column_names <- read.table(data[2]) #Reading in file containing features
column_names[,2] <- tolower(column_names[,2]) #Changing all names into lowercase
mstd <- column_names[grepl("mean|std", column_names[,2]),] #Subsetting only values that contain "mean" or "std"

#Identifying the number of columns necessary for extracting
var <- c(mstd[1]) #Creating a vector from the subset
var <- unlist(var)
var_all <- c(var, 562:563) #Adding two columns where data on subject and activity
data_extract <- data_complete[, var_all] #Extracting the necessary columns

##Using descriptive activity names
activity <- read.table(data[1]) #Reading in file containing activity labels
data_extract[,87] <- activity[match(data_extract[,87], activity[,1]), 2] #Matching activity labels in column

##Modifying labels to be more descriptive
#Changing labels of columns
names <- c(mstd[2]) #Creating a vector of subset with names for columns
names <- unlist(names)
names <- as.character(names)
names_all <- c(names, "activity", "subject") #Adding names for the two additional columns
names(data_extract) <- names_all #Changing labels for all columns

#More descriptive names for columns

names(data_extract) <- gsub("[[:punct:]]","", names(data_extract)) #removing punctuation characters

##Second data set
library(reshape2)
data_extract_melt <- melt(data_extract, id=c("subject", "activity"))
tidy_data <- acast(data_extract_melt, subject + activity ~ variable, mean)
#End