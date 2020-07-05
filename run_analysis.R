###SCRIPT Getting and Cleaning Data Course Project
  ##Where am I?
getwd()

  ##Required libraries
library(dplyr)
library(tidyverse)
library(stringr)

  ##Creating working directory
if (!file.exists(("data"))){ dir.create("data")}

  ##Download data
fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
download.file(fileUrl, destfile = "DataSet.zip", method = "libcurl")

  ##set download date
DataSetEj4<-Sys.Date()

  ##Unzip downloaded data
unzip("./data/DataSet.zip", exdir = "./data")

  ##read tables
TrainSet<-read.table("./data/UCI HAR Dataset/train/X_train.txt", stringsAsFactors = FALSE)
TestSet<-read.table("./data/UCI HAR Dataset/test/X_test.txt", stringsAsFactors = FALSE)
Features<-read.table("./data/UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)
Act_TrainSet<-read.table("./data/UCI HAR Dataset/train/y_train.txt", stringsAsFactors = FALSE)
Act_TestSet<-read.table("./data/UCI HAR Dataset/test/y_test.txt", stringsAsFactors = FALSE)
Subject_Train<-read.table("./data/UCI HAR Dataset/train/subject_train.txt", stringsAsFactors = FALSE)
Subject_Test<-read.table("./data/UCI HAR Dataset/test/subject_test.txt", stringsAsFactors = FALSE)
Activities<-read.table("./data/UCI HAR Dataset/activity_labels.txt", stringsAsFactors = FALSE)


  ##extract column names and assign it to Train and Test Sets
colnamesTS<-Features[ , 2]
colnames(TestSet)<-colnamesTS
colnames(TrainSet)<-colnamesTS
colnames(Subject_Test)<-c("Subject")
colnames(Subject_Train)<-c("Subject")


  ##Merge sets 
TrainSet<-cbind(TrainSet, Act_TrainSet, Subject_Train)
TestSet<-cbind(TestSet, Act_TestSet, Subject_Test)
TotaSet<-rbind(TrainSet, TestSet)

  ##create vector for subsetting
mean_std<-c("\\bmean()\\b", "std()", "V1", "Subject")
matches<-unique(grep(paste(mean_std, collapse = "|"), colnames(TotaSet), value = TRUE))

    ##subset merged sets by mean and std
mergedsets_subsetted<-TotaSet[matches]

    ##add activities names to merged dataset
mergedsets_subsetted<-merge(mergedsets_subsetted, Activities)

  ##Give appropriate names to colnames
colnames(mergedsets_subsetted)<-gsub("[[:punct:]]", " ", colnames(mergedsets_subsetted))
colnames(mergedsets_subsetted)<-str_replace_all(colnames(mergedsets_subsetted), c("tBody" = "TimeBody", "tGravity" = "TimeGravity", "fBody" = "FastFourierBody", "V2" = "Activity", " mean   " = "AVG", " std  " = "STD"))

  ##Independent dataset with variables averaged for activity and subject
grouped<-group_by(mergedsets_subsetted, Activity, Subject)%>%
  summarize_at(vars(TimeBodyAccAVGX:FastFourierBodyBodyGyroJerkMagSTD), mean)

  ##create a text file from tidy dataset
write.table(grouped, file = "./data/UCI HAR Dataset/grouped.txt", row.name = FALSE)

  ##Remove accesory datasets
rm(list = c("Act_TestSet", "Act_TrainSet", "Activities", "Features", "Subject_Test", "Subject_Train", "TestSet", "TotaSet", "TrainSet"))





