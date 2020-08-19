---
title: "Codebook"
output: html_document
---

## Source data
The source data are saved in the data folder. 

The source data include the training set and test set. Each set includes three files:

1. **subject_train.txt / subject_test.txt**: Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

2. **X_train.txt / X_test.txt**: Each row is a 561-feature vector with time and frequency domain variables.

3. **y_train.txt / y_test.txt**: Each row is an activity ID, raning from 1 to 6. 

The two sets in combination provide 10,299 total observations. 

Additional source data include:

- **activity_labels.txt**: Links the activity IDs with their activity name.
- **features.txt**: List of all 561 features.(See data/features_info.txt for details of each feature.)

See data/README.txt for details of the source dataset from UCI. 

## Output data
The output data are saved in the output folder. 

To read the output data sets back into R, use the code below:

        first_output <- read.table("output/first_output.txt", header = TRUE)
        second_output <- read.table("output/second_output.txt", header = TRUE)
- **first_output.txt**: this is the first dataset after the first four required steps:
  - Merges the training and the test sets to create one data set.
  - Extracts only the measurements on the mean and standard deviation for each measurement.
  - Uses descriptive activity names to name the activities in the data set
  - Appropriately labels the data set with descriptive variable names.

- **second_output.txt**: this is the second dataset after the fifth required step:
  - From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

### first_output.txt
This dataset comes with 10299 observations of 82 variables.The variables are as follows:

- activityId: IDs that correspond to six different activities (raning from 1 to 6).
- subjectId: IDs that correspond to 30 participants (ranging from 1 to 30).
- _Columns 3 to 81_: features that had "mean" or "std" in their names were extracted fro the 561 features as specified in the data/features.txt file. 
- activityName: names of the six different activities
  - 1 WALKING
  - 2 WALKING_UPSTAIRS
  - 3 WALKING_DOWNSTAIRS
  - 4 SITTING
  - 5 STANDING
  - 6 LAYING
  
  
### second_output.txt
This dataset comes with 180 observations of 81 variables.The variables are as follows:

- subjectId: IDs that correspond to 30 participants (ranging from 1 to 30).
- activityName: names of the six different activities
  - 1 WALKING
  - 2 WALKING_UPSTAIRS
  - 3 WALKING_DOWNSTAIRS
  - 4 SITTING
  - 5 STANDING
  - 6 LAYING
 - _Columns 3 to 81_: from Columns 3 to 81 in the first_output.txt, calculated the **average** of each variable for each activity and each subject.
 
 
## Data Transformation Steps

1. read in training set and test set
_no need for the inertial signals folder because we only need the variables about mean and sd from the 561-feature vector. Please note that the X_test.txt and X_train.txt files are not uploaded to GitHub due to size limit_

        train_subject <- read.table("data/train/subject_train.txt")
        train_X <- read.table("data/train/X_train.txt")
        train_Y <- read.table("data/train/y_train.txt")
        test_subject <- read.table("data/test/subject_test.txt")
        test_X <- read.table("data/test/X_test.txt")
        test_Y <- read.table("data/test/y_test.txt")

2. read activity and feature labels

        label_activity <- read.table("data/activity_labels.txt")
        label_feature <- read.table("data/features.txt")


3. combine the sets (i.e. assignment requirement #1)

        train_set <- cbind(train_subject, train_Y, train_X)
        test_set <- cbind(test_subject, test_Y, test_X)
        full_set <- rbind(train_set, test_set)

4. add descriptive names to the variables (i.e. assignment requirement #4)

        colnames(full_set) <- c("subjectId", "activityId", as.character(label_feature$V2))

5. extract only the mean and the standard deviation columns. (i.e. assignment requirement #2)

        extract_set <- cbind(full_set[,1:2], 
                             full_set[, grep("mean", colnames(full_set))],
                             full_set[, grep("std", colnames(full_set))])

6. join activity labels (i.e. assignment requirement #3)
      
        first_output <- merge(extract_set, label_activity, by.x = "activityId",  by.y = "V1")
        colnames(first_output)[82] <- "activityName"

7. calculate average of each variable for each activity and each subject (i.e. assignment requirement #5)
        
        split_set <- split(first_output, list(first_output$subjectId, first_output$activityName))
        average_set <- t(sapply(split_set, function(x) colMeans(x[, 3:81], na.rm = TRUE)))
        average_set <- data.frame(average_set)

8. convert the row.names into two separate columns.

        second_output <- cbind(V1 = row.names(average_set), average_set)
        second_output <- separate(second_output, V1, into = c("subjectId", "activityName"), sep = "\\.")

9. add the prefix "Avg" to each of the columns with the average numbers. 
        
        colnames(second_output)[3:81] <- paste("Avg", colnames(second_output)[3:81] , sep = "_")

10. export both datasets

        write.table(first_output, "output/first_output.txt", row.name=FALSE)
        write.table(second_output, "output/second_output.txt", row.name=FALSE)


[End of document]
