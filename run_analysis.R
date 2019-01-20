#Analytical code
course3 <- "UCIHAR.zip"

# Check if archive exists. If not download it.
if (!file.exists(course3)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, course3)
}  
# Check if data set folder exists. If not download it.
if (!file.exists("UCIHAR Dataset")) { 
  unzip(course3) 
}

#Load the deplyr package to be able to manipulate the data frames more easily.
library(dplyr)

# To read the individual data frames
features <- read.table("UCIHAR Dataset/features.txt", col.names = c("n","functions"))
activities <- read.table("UCIHAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test <- read.table("UCIHAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCIHAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("UCIHAR Dataset/test/y_test.txt", col.names = "code")
subject_train <- read.table("UCIHAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCIHAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("UCIHAR Dataset/train/y_train.txt", col.names = "code")

# 1. Merge data sets
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
subject_data <- rbind(subject_train, subject_test)
merged_data <- cbind(subject_data, x_data, y_data)

# 2. Extract only the measurements on the mean and standard deviation
merged_data1 <- merged_data %>% select(subject, code, contains("mean"), contains("std"))

# 3. Use descriptive activity names to name the activities
merged_data1$code <- activities[merged_data1$code, 2]

# 4. Appropriately label the data set with descriptive variable names
names(merged_data1)[2] = "activity"
names(merged_data1)<-gsub("Acc", "Accelerometer", names(merged_data1))
names(merged_data1)<-gsub("Gyro", "Gyroscope", names(merged_data1))
names(merged_data1)<-gsub("BodyBody", "Body", names(merged_data1))
names(merged_data1)<-gsub("Mag", "Magnitude", names(merged_data1))
names(merged_data1)<-gsub("^t", "Time", names(merged_data1))
names(merged_data1)<-gsub("^f", "Frequency", names(merged_data1))
names(merged_data1)<-gsub("tBody", "Time Body", names(merged_data1))
names(merged_data1)<-gsub("-mean()", "Mean", names(merged_data1), ignore.case = TRUE)
names(merged_data1)<-gsub("-std()", "Standard Deviation", names(merged_data1), ignore.case = TRUE)
names(merged_data1)<-gsub("-freq()", "Frequency", names(merged_data1), ignore.case = TRUE)
names(merged_data1)<-gsub("angle", "Angle", names(merged_data1))
names(merged_data1)<-gsub("gravity", "Gravity", names(merged_data1))

# 5. From the data set in step 4, create a second, independent tidy data set with 
#    the average of each variable for each activity and each subject
final_dataset <- merged_data1 %>%
  group_by(subject, activity) %>%
  summarise_all(funs(mean))
write.table(final_dataset, "Final_dataset.txt", row.name=FALSE)
