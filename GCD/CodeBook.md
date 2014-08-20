---
title   : Tidying data for Getting and Cleaning Data course project
output  : html_document
---
This code book describes the data, the variables, and any transformations that were performed to clean up the data.

The data is acquired from Smartlab - Non Linear Complex Systems Laboratory on their experiments entitled "Human Activity Recognition Using Smartphones Dataset".

- - -

The data is available from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You do not need to download the zip file in order to tidy it, and the script provided in run_analysis.R unzips it in a temporary file.

```
temp <- tempfile()
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, temp, method = "curl")
data <- unzip(temp)
```

The zip file contains 28 files.
The relevant files that shall be used during the process are:
```
data
 [1] "./UCI HAR Dataset/activity_labels.txt"                         
 [2] "./UCI HAR Dataset/features.txt"                                
...  
[14] "./UCI HAR Dataset/test/subject_test.txt"                       
[15] "./UCI HAR Dataset/test/X_test.txt"                             
[16] "./UCI HAR Dataset/test/y_test.txt"                             
...
[26] "./UCI HAR Dataset/train/subject_train.txt"                     
[27] "./UCI HAR Dataset/train/X_train.txt"                           
[28] "./UCI HAR Dataset/train/y_train.txt"
```

####1. Merging the data set

In order to create one data set the relevant files shall be merged with the `cbind` and `rbind` commands.

- [14] contains information on the different subjects of the experiment in the **test** set. 30% of the subjects (9 volunteers) were selected. Values: `2  4  9 10 12 13 18 20 24`.
- [15] contains 561 variables of different measurements in the **test** set.
- [16] contains information on the different activities performed by the subjects in the **test** set. Values: `1 2 3 4 5 6`.
- [26] contains information on the different subjects of the experiment in the **training** set. 70% of the subjects (21 volunteers) were selected. Values: `1  3  5  6  7  8 11 14 15 16 17 19 21 22 23 25 26 27 28 29 30`.
- [27] contains 561 variables of different measurements in the **training** set.
- [28] contains information on the different activities performed by the subjects in the **training** set. Values: `1 2 3 4 5 6`.

The tables were bound in a particular order that the largest files ([15], and [27]) were placed at the beginning in order to ease extracting later.

```
data_test <- cbind((read.table(data[15])), (read.table(data[16])), (read.table(data[14]))) #Merging the test files
data_train <- cbind((read.table(data[27])), (read.table(data[28])), (read.table(data[26]))) #Merging the training files
```
The two sets shall be joined by `rbind` to create one complete set of data.
```
data_complete <- rbind(data_test, data_train) #Combining the test and training files
```
The complete data set (data_complete) consists of 10299 rows and 563 columns.

####2. Extracting only the measurements on the mean and standard deviation for each measurement

In order to identify the necessary columns to extract, [2] is used from the zip file. [2] contains the labels for the 561 variables.
```
column_names <- read.table(data[2]) #Reading in file containing features
```

Since the column names consist of upper and lower case characters, first all characters shall be transformed into lower case characters in order to enhance better matching in the next step.
```
column_names[,2] <- tolower(column_names[,2])
```

All column names that has the expression *mean* or *std* shall be subsetted.
```
mstd <- column_names[grepl("mean|std", column_names[,2]),]
```

mstd consists of 86 values.

From the same file [2] the corresponding column numbers shall be extracted and transform from list into integer in order to add further column numbers.
```
var <- c(mstd[1]) #Creating a vector from the subset
var <- unlist(var)
```

Two additional columns shall be added to the variables for *activity* and *subject*.
```
var_all <- c(var, 562:563)
```

All necessary columns shall be extracted from the complete data set.
```
data_extract <- data_complete[, var_all]
```
The extracted data set consists of 10299 rows and 88 columns

####3. Using descriptive activity names
File [1] consists of the names of each activity. There are 6 names, which are matched the corresponding numbers in column 87 of the extracted data set.
```
data_extract[,87] <- activity[match(data_extract[,87], activity[,1]), 2] #Matching activity labels in column
```

####4. Adding more descriptive labels for columns
The labels of the two newly added columns (activity, and subject) shall be added to list of names.
```
names <- c(mstd[2]) #Creating a vector of subset with names for columns
names <- unlist(names)
names <- as.character(names)
names_all <- c(names, "activity", "subject") #Adding names for the two additional columns
```
The labels of all columns shall be changed using the names_all vector.
```
names(data_extract) <- names_all #Changing labels for all columns
```
All labels (column names) have already been transformed into lower case strings. Therefore, all punctuation charachters shall be removed
```
names(data_extract) <- gsub("[[:punct:]]","", names(data_extract)) #removing punctuation characters
```

####5. Tidy data set
A separate data set is created which comprises the average of each variable for each subject and each activity.

Using the `reshape2` package, the extracted data set shall be melted by subjects and activities. Finally, the extracted data set shall be cast so that it provides the means of each variables relating to the subjects together with the activities they performed.
```
library(reshape2)
data_extract_melt <- melt(data_extract, id=c("subject", "activity"))
tidy_data <- acast(data_extract_melt, subject + activity ~ variable, mean)
```

Data
====

The tidy_data is a matrix that consists of 180 rows and 86 variables (columns).
The row names indicate the identification number of the subject (1-30) and the name of actitivity they performed in the following order:

- LAYING
- SITTING
- STANDING
- WALKING
- WALKING_DOWNSTAIRS
- WALKING_UPSTAIRS

The name of the variables:
```
 [1] "tbodyaccmeanx"                    
 [2] "tbodyaccmeany"                    
 [3] "tbodyaccmeanz"                    
 [4] "tbodyaccstdx"                     
 [5] "tbodyaccstdy"                     
 [6] "tbodyaccstdz"                     
 [7] "tgravityaccmeanx"                 
 [8] "tgravityaccmeany"                 
 [9] "tgravityaccmeanz"                 
[10] "tgravityaccstdx"                  
[11] "tgravityaccstdy"                  
[12] "tgravityaccstdz"                  
[13] "tbodyaccjerkmeanx"                
[14] "tbodyaccjerkmeany"                
[15] "tbodyaccjerkmeanz"                
[16] "tbodyaccjerkstdx"                 
[17] "tbodyaccjerkstdy"                 
[18] "tbodyaccjerkstdz"                 
[19] "tbodygyromeanx"                   
[20] "tbodygyromeany"                   
[21] "tbodygyromeanz"                   
[22] "tbodygyrostdx"                    
[23] "tbodygyrostdy"                    
[24] "tbodygyrostdz"                    
[25] "tbodygyrojerkmeanx"               
[26] "tbodygyrojerkmeany"               
[27] "tbodygyrojerkmeanz"               
[28] "tbodygyrojerkstdx"                
[29] "tbodygyrojerkstdy"                
[30] "tbodygyrojerkstdz"                
[31] "tbodyaccmagmean"                  
[32] "tbodyaccmagstd"                   
[33] "tgravityaccmagmean"               
[34] "tgravityaccmagstd"                
[35] "tbodyaccjerkmagmean"              
[36] "tbodyaccjerkmagstd"               
[37] "tbodygyromagmean"                 
[38] "tbodygyromagstd"                  
[39] "tbodygyrojerkmagmean"             
[40] "tbodygyrojerkmagstd"              
[41] "fbodyaccmeanx"                    
[42] "fbodyaccmeany"                    
[43] "fbodyaccmeanz"                    
[44] "fbodyaccstdx"                     
[45] "fbodyaccstdy"                     
[46] "fbodyaccstdz"                     
[47] "fbodyaccmeanfreqx"                
[48] "fbodyaccmeanfreqy"                
[49] "fbodyaccmeanfreqz"                
[50] "fbodyaccjerkmeanx"                
[51] "fbodyaccjerkmeany"                
[52] "fbodyaccjerkmeanz"                
[53] "fbodyaccjerkstdx"                 
[54] "fbodyaccjerkstdy"                 
[55] "fbodyaccjerkstdz"                 
[56] "fbodyaccjerkmeanfreqx"            
[57] "fbodyaccjerkmeanfreqy"            
[58] "fbodyaccjerkmeanfreqz"            
[59] "fbodygyromeanx"                   
[60] "fbodygyromeany"                   
[61] "fbodygyromeanz"                   
[62] "fbodygyrostdx"                    
[63] "fbodygyrostdy"                    
[64] "fbodygyrostdz"                    
[65] "fbodygyromeanfreqx"               
[66] "fbodygyromeanfreqy"               
[67] "fbodygyromeanfreqz"               
[68] "fbodyaccmagmean"                  
[69] "fbodyaccmagstd"                   
[70] "fbodyaccmagmeanfreq"              
[71] "fbodybodyaccjerkmagmean"          
[72] "fbodybodyaccjerkmagstd"           
[73] "fbodybodyaccjerkmagmeanfreq"      
[74] "fbodybodygyromagmean"             
[75] "fbodybodygyromagstd"              
[76] "fbodybodygyromagmeanfreq"         
[77] "fbodybodygyrojerkmagmean"         
[78] "fbodybodygyrojerkmagstd"          
[79] "fbodybodygyrojerkmagmeanfreq"     
[80] "angletbodyaccmeangravity"         
[81] "angletbodyaccjerkmeangravitymean" 
[82] "angletbodygyromeangravitymean"    
[83] "angletbodygyrojerkmeangravitymean"
[84] "anglexgravitymean"                
[85] "angleygravitymean"                
[86] "anglezgravitymean"
```
The parts in the variables' name have the following meanings sorted in alphabetical order *(Source: features_info.txt)*:

- **acc**: accelerometer raw signal
- **angle**: angle between vectors
- **body**: body
- **bodyacc**: body acceleration signal
- **f**: frequency domain signal
- **gravity**: gravity
- **gravityacc**: gravity acceleration signal
- **gyro**: gyroscope raw signal
- **jerk**: jerk signal
- **mag**: magnitude of three-dimensional signal
- **mean**: estimated mean value
- **meanfreq**: weighted average of the frequency components to obtain a mean frequency
- **std**: estimated standard deviation
- **t**: time domain signal
- **x, y, z**: three-axial signal in three directions

Finally, in order to read in the data set, use the following command:
```
data <- read.table("tidy_data.txt")
```