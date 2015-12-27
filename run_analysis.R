#download and unzip all files

temp <- tempfile()
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",temp)
unzip(temp, files = NULL, list = FALSE, overwrite = TRUE,
      junkpaths = FALSE, exdir = ".", unzip = "internal",
      setTimes = FALSE)
unlink(temp)
#check if the new folder is in working directory

list.files()

#packages to work with

library(plyr)
library(data.table)
library(reshape2)

#read all data

activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
features <- read.table("./UCI HAR Dataset/features.txt")[,2]
X_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
X_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

#add names

names(subject_train) <- "Subject_Name"
names(subject_test) <- "Subject_Name"
names(X_test) <- features
names(X_train) <- features
names(y_train) <- "activity"
names(y_test) <- "activity"


#merge training and test data to create one data set 

x_all <- rbind(X_train, X_test)
y_all <- rbind(y_train, y_test)
subject_all <- rbind(subject_train, subject_test)
all <- cbind(x_all, y_all, subject_all)

#mean and std extract 

mean_std_features <- grep("-(mean|std)\\(\\)", features)
x_all <- x_all[, mean_std_features]

#merge into one fiel data file again

all <- cbind(x_all, y_all, subject_all)

#add descriptive labels into dataset and appropriately label data

all$activity <- factor(all$activity, labels=c("Walking","Walking Upstairs","Walking Downstairs","Sitting", "Standing", "Laying"))

#data with the average of each variable for each activity and each subject

DT <- data.table(all)

TEMP<-DT[,lapply(.SD,mean),by="activity,Subject_Name"]

#create the final tidy data set with write.table
write.table(TEMP,file="tidy.txt",row.names = FALSE)
