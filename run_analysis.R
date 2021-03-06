#=
#   Final Assignment for Getting and Cleaning Data 
# 
# contact author: @ldeer
#=

## Load required libraries

library(dplyr)
library(readr)
library(pander)



## 0. Download the data ##
##   Creates directories, downloads data and unzips if its not in the repo

if(!dir.exists("./data")){
    dir.create("./data")
}


if(!file.exists("./data/rawData.zip")){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileUrl,destfile="./data/rawData.zip")
    
    # Unzip dataSet to /data directory
    unzip(zipfile="./data/rawData.zip",exdir="./data")
    rm(fileURL)
}

## 1. Merge Training and Test Data  ##

## if merged data doesnt exist, create and write to disk
if(!file.exists("./allData.rds")) {
    
    for (iType in c('test','train')){
        print(iType)
        
        # specify the folder where the data lies
        folder <- paste("./data/UCI HAR Dataset/", iType, "/", sep="")
        
        # load each data set in that folder storing it in a list
        fileList <- paste( folder, list.files(path= folder, pattern = "txt$"), sep="") %>% 
            lapply(read.table, stringsAsFactors=F, fill=TRUE)
        
        # name the data sets with their original file names
        fileNames <- gsub(pattern = "\\.txt$", "", list.files(path= folder, pattern = "txt$"))
        names(fileList) <- fileNames
        
        # Convert List of data sets into one data set
        ## Name the output Data
        dataName <- paste(iType, "Data", sep="")
        
        ## Assign name to the dataset you create
        assign(dataName, do.call("cbind", fileList))
        rm(fileList)
    }
    
    # These data sets don't have meaningful column names , want to change that
    featureNames    <- read.table("./data/UCI HAR Dataset/features.txt")
    
    featureNames <- t(featureNames[2]) %>% tolower()
    featureNames <- gsub("-", "", featureNames)
    featureNames <- gsub(",", "", featureNames)
    
    names(testData)     <- c("subject", featureNames, "activityID")
    names(trainData)    <- c("subject", featureNames, "activityID")
    
    #merge the data sets
    allData <- rbind(testData, trainData)
    
    # Save the data object
    saveRDS(allData, "allData.rds")
    
    # clean up the workspace
    rm(testData, trainData, featureNames, dataName, fileNames, iType, folder)
}

## 2. Extract Only Means and Std Deviations ##

## load data if you have removed it
if(!exists("allData")) {
    allData <- readRDS("allData.rds")
}

## select colums of means and stds

meanAndStd <- allData %>% 
    # remove duplicated columns by name
    subset(., select=which(!duplicated(names(.)))) %>% 
    # find row mean() or std() which are the computed estimates from '/data/features_info.txt'
    select( subject, activityID, matches("mean\\(\\)|std\\(\\)")) 


## 3. Load activity labels + Merge to data ##
activityLabels  <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
names(activityLabels)    <- c("activityID", "activity")

meanAndStd <- merge(meanAndStd, activityLabels, by="activityID")

## clean up
meanAndStd <- meanAndStd  %>%
    select(subject, activity, everything()) %>%
    select(-activityID) %>%
    arrange(subject, activity)

saveRDS(meanAndStd, "meanAndStd.rds")

## 4. Rename Variables

# rename columns until happy
names(meanAndStd) <- gsub("\\(|\\)", "", names(meanAndStd))

names(meanAndStd) <- gsub("acc", "-accelerator-", names(meanAndStd))
names(meanAndStd) <- gsub("mag", "-magnitude-", names(meanAndStd))
names(meanAndStd) <- gsub('gyrojerk',"-angularAccel-",names(meanAndStd))
names(meanAndStd) <- gsub('gyro',"-AngularSpeed-",names(meanAndStd))
names(meanAndStd) <- gsub("^t", "time-", names(meanAndStd))
names(meanAndStd) <- gsub("^f", "frequency-", names(meanAndStd))
names(meanAndStd) <- gsub("--", "-", names(meanAndStd))

## 5. Generate final Data set

tidyData <- meanAndStd %>%
                group_by(subject, activity) %>%
                summarize_all(.funs= c(Mean="mean"))
names(tidyData) <- gsub("_", "-", names(tidyData))


# export as tab table
write.table(tidyData, file = "tidyData.txt", sep = "\t", row.names = FALSE)

## dump SessionInfo to markdown
pander(sessionInfo(), compact = FALSE)
