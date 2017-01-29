#=
#   Final Assignment for Getting and Cleaning Data    
#=

## Load required libraries

library(dplyr)
library(readr)


## 0. Download the data ##
##   Creates directory, downloads data and unzips if its not in the repo

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

## 1.  ##

# if merged data doesnt exist, create and write to disk, create it and load
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
    #featureNames <- gsub("\\(", "", featureNames)
    #featureNames <- gsub("\\)", "", featureNames)
    
    
    names(testData)     <- c("subject", featureNames, "activityID")
    names(trainData)    <- c("subject", featureNames, "activityID")
    
    #merge the data sets
    allData <- rbind(testData, trainData)
    
    # make sure all names are unique
    #validNames <- make.names(names=names(allData), unique=TRUE, allow_ = TRUE)
    #names(allData) <- allData
    
    # Save the data object
    saveRDS(allData, "allData.rds")
    rm(testData, trainData, featureNames, dataName, fileNames, iType, validNames, folder)
}

## 2. ##

## load data if you have removed it
if(!exists("allData")) {
    allData <- readRDS("allData.rds")
}

# select colums of means and stds

meanAndStd <- allData %>% 
    # remove duplicated columns by name
    subset(., select=which(!duplicated(names(.)))) %>% 
    # find row mean() or std() which are the computed estimates from '/data/features_info.txt'
    select( subject, activity, matches("mean\\(\\)|std\\(\\)")) 

saveRDS(allData, "allData.rds")



# Load activity labels + features
activityLabels  <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
names(activityLabels)    <- c("activityID", "activity")

meanAndStd <- merge(meanAndStd, activityLabels, by="activityID")


