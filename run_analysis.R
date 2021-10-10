
library(dplyr)

#download the file

filePath <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
dest <- "data.zip"
download.file(filePath, destfile = dest)
unzip("data.zip")

#create the necessary data tables

dFeat <- read.table("UCI HAR Dataset/features.txt", col.names = c("n","functions"))
dActivities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
dSubTest <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
dXTest <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = dFeat$functions)
dYTest <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
dSubTrain <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
dXTrain <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = dFeat$functions)
dYTrain <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")

#merge the various tables into the combined table

dMerged <- cbind(rbind(dSubTrain, dSubTest), rbind(dYTrain, dYTest), rbind(dXTrain, dXTest))

#create a new table containing only the mean and standard deviation variables

dTidy <- select(dMerged, subject, code, contains("mean"), contains("std"))

#reassign the numerical values in the code variable to descriptive values

dTidy$code <- dActivities[dTidy$code, 2]

#replace the names with ones that are more descriptive

names(dTidy)[2] = "activity"
names(dTidy)<-gsub("Acc", "Accelerometer", names(dTidy))
names(dTidy)<-gsub("Gyro", "Gyroscope", names(dTidy))
names(dTidy)<-gsub("BodyBody", "Body", names(dTidy))
names(dTidy)<-gsub("Mag", "Magnitude", names(dTidy))
names(dTidy)<-gsub("^t", "Time", names(dTidy))
names(dTidy)<-gsub("^f", "Frequency", names(dTidy))
names(dTidy)<-gsub("tBody", "TimeBody", names(dTidy))
names(dTidy)<-gsub("-mean()", "Mean", names(dTidy), ignore.case = TRUE)
names(dTidy)<-gsub("-std()", "STD", names(dTidy), ignore.case = TRUE)
names(dTidy)<-gsub("-freq()", "Frequency", names(dTidy), ignore.case = TRUE)
names(dTidy)<-gsub("angle", "Angle", names(dTidy))
names(dTidy)<-gsub("gravity", "Gravity", names(dTidy))

#create a final table with the means of each variable for each subject

dFinal <- group_by(dTidy, subject, activity)
dFinal <- summarize_all(dFinal, funs(mean))

#creates a file for the final data table

write.table(dFinal, "Tidy Data Means.txt", row.name=FALSE)