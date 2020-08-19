library(dplyr)
library(tidyr)

#read training set 
#Not readig in the inertial signals folder because we only need the variables about mean and sd from the 561-feature vector.
train_subject <- read.table("data/train/subject_train.txt")
train_X <- read.table("data/train/X_train.txt")
train_Y <- read.table("data/train/y_train.txt")

#read test set
#Not readig in the inertial signals folder because we only need the variables about mean and sd from the 561-feature vector.
test_subject <- read.table("data/test/subject_test.txt")
test_X <- read.table("data/test/X_test.txt")
test_Y <- read.table("data/test/y_test.txt")

#read activity and feature labels
label_activity <- read.table("data/activity_labels.txt")
label_feature <- read.table("data/features.txt")

#combine the sets (i.e. assignment requirement #1)
train_set <- cbind(train_subject, train_Y, train_X)
test_set <- cbind(test_subject, test_Y, test_X)
full_set <- rbind(train_set, test_set)

#add descriptive names to the variables (i.e. assignment requirement #4)
colnames(full_set) <- c("subjectId", "activityId", as.character(label_feature$V2))

#extract only the mean and the standard deviation columns. (i.e. assignment requirement #2)
extract_set <- cbind(full_set[,1:2], 
                     full_set[, grep("mean", colnames(full_set))],
                     full_set[, grep("std", colnames(full_set))])

#join activity labels (i.e. assignment requirement #3)
first_output <- merge(extract_set, label_activity, by.x = "activityId",  by.y = "V1")
colnames(first_output)[82] <- "activityName"

#calculate average of each variable for each activity and each subject (i.e. assignment requirement #5)
split_set <- split(first_output, list(first_output$subjectId, first_output$activityName))
average_set <- t(sapply(split_set, function(x) colMeans(x[, 3:81], na.rm = TRUE)))
average_set <- data.frame(average_set)

#convert the row.names into two separate columns.
second_output <- cbind(V1 = row.names(average_set), average_set)
second_output <- separate(second_output, V1, into = c("subjectId", "activityName"), sep = "\\.")

#add the prefix "Avg" to each of the columns with the average numbers. 
colnames(second_output)[3:81] <- paste("Avg", colnames(second_output)[3:81] , sep = "_")

#export both datasets
write.table(first_output, "output/first_output.txt", row.name=FALSE)
write.table(second_output, "output/second_output.txt", row.name=FALSE)



