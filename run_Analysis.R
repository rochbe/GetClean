# run_analysis() downloads smart phone accelerometer data
# and saves averaged values to file for further processing.

run_analysis <- function()
{
    # Create data folder if it doesn't exist,
    # and download zip file.
    zipfile <- ".\\data\\HAR.zip"
    if (!file.exists("data"))
    {
        print("Downloading zip file...")
        dir.create("data")
        fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileUrl,zipfile)
        dateDownloaded <- date()
    }

    # Create test data frame.
    x_file <- "UCI HAR Dataset/test/X_test.txt"
    y_file <- "UCI HAR Dataset/test/y_test.txt"
    subject_file <- "UCI HAR Dataset/test/subject_test.txt"
    test <- get_data(x_file, y_file, subject_file)

    # Create train data frame.
    x_file <- "UCI HAR Dataset/train/X_train.txt"
    y_file <- "UCI HAR Dataset/train/y_train.txt"
    subject_file <- "UCI HAR Dataset/train/subject_train.txt"
    train <- get_data(x_file, y_file, subject_file)

    # Create combined data frame in Subject order & save as csv file
    har <- rbind(test, train)
    har <- har[order(har$Subject),]
    #write.table(har, file = ".\\Data\\HAR.csv", row.name=FALSE, sep=",")
    write.table(har, file = ".\\Data\\HAR.txt", row.name=FALSE)

    # Create summary of har data frame, averaging each variable
    # by Subject & Activity. Save as csv file.
    require(reshape2)
    molten <- melt(har, id = c("Subject", "Activity"), measure.var=3:ncol(har))
    har_mean<-dcast(molten, Subject + Activity ~ variable, mean)
    #write.table(har_mean, file = ".\\Data\\HAR_mean.csv", row.name=FALSE, sep=",")
    write.table(har_mean, file = ".\\Data\\HAR_mean.txt", row.name=FALSE)
}


# get_data(x_file, y_file, subject_file) gets data from zip file
# for either the test data or the training data.
# Arguments: -
# x_file: path to X_file.txt in zip file.
# y_file: path to y_file.txt in zip file.
# subject_file: path to subject_file.txt in zip file.
# Value: -
# Returns a data frame containing the tidied data.

get_data <- function(x_file, y_file, subject_file)
{
    # Path to zip file.
    zipfile <- ".\\data\\HAR.zip"

    # Get variable names.
    featuresfile <- "UCI HAR Dataset/features.txt"
    features <- read.table(unz(zipfile, featuresfile), sep = " ")

    # Get activity catagories.
    actcatfile <- "UCI HAR Dataset/activity_labels.txt"
    actcat <- read.table(unz(zipfile, actcatfile))

    # Get x, y & subject data.
    x <- read.table(unz(zipfile, x_file))
    y <- read.table(unz(zipfile, y_file))
    subject <- read.table(unz(zipfile, subject_file))

    # Add variable names to x.
    names(x) <- features[,2]

    # Replace activity catagories with names in y.
    y$Activity <- actcat[y[,1],2]
    y$V1 <- NULL

    # Add variable name to subject.
    names(subject) <- "Subject"

    # Filter x to columns with names containing 'mean()' or 'std()'.
    ismean <- grepl("mean()", names(x), fixed = TRUE)
    isstd  <- grepl("std()",  names(x), fixed = TRUE)
    keep <- (ismean | isstd)
    x <- x[,keep]

    # Join into single data frame.
    df <- cbind(subject, y, x)

    return(df)
}
