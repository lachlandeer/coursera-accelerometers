#=
#   Final Assignment for Getting and Cleaning Data    
#=

## Load required libraries


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

# Load activity labels + features
activityLabels  <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
featureNames    <- read.table("./data/UCI HAR Dataset/features.txt")

