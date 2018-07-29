# load libs

library(dplyr)
library(tidyr)

# set the working directory
setwd("C:/users/rakesh.sharma/downloads/")

# downloading the file

if(!file.exists('./data/')) {
  dir.create("./data")
}

download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = "./data/dataset.zip")
unzip("./data/dataset.zip")

# loading activity
activities <- read.csv(file = "./data/dataset/UCI HAR Dataset/activity_labels.txt", header = F, sep=" ")
activities[, 2] <- as.character(activities[, 2])

# loading features
features <- read.csv(file = "./data/dataset/UCI HAR Dataset/features.txt", header = F, sep = " ")
feature_indices <- grep("mean|std", features[, 2], ignore.case = F)
feature_names <- features[feature_indices, 2]
feature_names <- tolower(feature_names)
feature_names <- gsub(pattern = "\\(\\)", "", feature_names)
feature_names <- gsub(pattern = "-", "_", feature_names)

# loading training data
X_train <- read.table(file = "./data/dataset/UCI HAR Dataset/train/X_train.txt")
X_train <- X_train[, feature_indices]
y_train <- read.table(file = "./data/dataset/UCI HAR Dataset/train/y_train.txt")

# loading subject
subject_train <- read.table(file = "./data/dataset/UCI HAR Dataset/train/subject_train.txt")

train <- cbind(subject_train, y_train, X_train)
names(train) <- c("subject_id", "target_value", feature_names)


# loading test data
X_test <- read.table(file = "./data/dataset/UCI HAR Dataset/test/X_test.txt")
X_test <- X_test[, feature_indices]
y_test <- read.table(file = "./data/dataset/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table(file = "./data/dataset/UCI HAR Dataset/test/subject_test.txt")
test <- cbind(subject_test, y_test, X_test)
names(test) <- c("subject_id", "target_value", feature_names)

# combining data
combined_data <- rbind(train, test)

# replacing the activities
combined_data$target_value <- factor(combined_data$target_value, levels = activities[, 1], labels = activities[, 2])

# the average of the each can be found by the either of the 2 methods
tidy_data <- combined_data %>% group_by(subject_id, target_value) %>% summarise_each(funs(mean))
tidy_data1 <- aggregate(.~subject_id+target_value , combined_data, mean )

# write to the tidy_data file 
write.table(tidy_data1, "./data/dataset/tidy.txt", row.names = F, quote = F)

