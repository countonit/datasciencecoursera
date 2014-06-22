README
========================================================

Below are the steps that I took to clean the data and produce the tidy data sets.

# Download the data

```r
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","UCI.zip")
```

```
## Error: unsupported URL scheme
```

```r
unzip("UCI.zip")
```

After an initial analysis it appears that the data we need is scattered across several files. Our goal is to create a tidy data frame, so we will have to be able to combine these files correctly. 

# Opening the files

Each relevant file was then opened and added as a table


```r
ytest=read.table("UCI HAR Dataset\\test\\y_test.txt", header=FALSE)
xtest=read.table("UCI HAR Dataset\\test\\x_test.txt", header=FALSE)
ytrain=read.table("UCI HAR Dataset\\train\\y_train.txt", header=FALSE)
xtrain=read.table("UCI HAR Dataset\\train\\x_train.txt", header=FALSE)
subtest=read.table("UCI HAR Dataset\\test\\subject_test.txt", header=FALSE)
subtrain=read.table("UCI HAR Dataset\\train\\subject_train.txt", header=FALSE)

featurenames=read.table("UCI HAR Dataset\\features.txt", header=FALSE)
activitylabels=read.table("UCI HAR Dataset\\activity_labels.txt", header=FALSE)
```

# Transforming the data to create a tidy data set

When the data is loaded the Feature names and Activity labels are factor variables. I added new columns that are character variables so that I can use them later on.

```r
featurenames$names=as.character(featurenames$V2)
activitylabels$names=as.character(activitylabels$V2)
```

I also wanted to seperate out a column that provided the number that coresponds to the factor in the activity labels data. This will be used to do a merge later on.

```r
activitylabels$code=as.numeric(activitylabels$V2)
```

Now that all of the data has been loaded I need to start combining it to create the tidy data set.

The first step was to combine the X (the sensor data) in the test and train set into one.

```r
X=rbind(xtest, xtrain)
```

When the data was loaded the variable names were not given so default variable names were assigned. The "featurenames" table contains the values that we want to use for these columns. The following code set the columns names:

```r
colnames(X)=featurenames$names
```
Now to combine the Y (The "Activity" variable) from the test and train sets into one:

```r
Y=rbind(ytest, ytrain)
```

After I have combined these two it is still just the code, what we want is the actual Activity name so I did a left join with the activitylabels table that we made earlier so that we can match these values with the name. To make it easier to combine them I first changed the column name in the "Y" table so that it matched the activitylabel column that we are merging on.

```r
colnames(Y)="code"

Act=merge(Y, activitylabels, by="code", all.x=TRUE)
```

Next I combined the Subject test and train tables, I will also change the column name to be more relevant

```r
SUB=rbind(subtest, subtrain)
colnames(SUB)="Subject"
```

Now we have our list of subjects, list of activities, and sensor data, they now must be combined into a single data frame.

```r
data=cbind(SUB, Act$names, X)
```

after combining these three the second column name must be adjusted so that it is more readable

```r
colnames(data)[2]="Activity"
```


Now we have one large data frame with all our data. One of the requirements of the assignment was that we look at just those variables that have to deal with means and standard deviations from the sensors. To determine which columns are relevant we can scan through the feature names to find ones that contain "mean" or "std".

```r
MeanSTD=subset(featurenames, grepl("mean", featurenames$names)|grepl("std", featurenames$names))
```

Now create a vector of the columns that I would like to have in my final tiny data set.

```r
cols=c("Subject", "Activity", MeanSTD$names)
```

Finally subset the larger data set to just include the columns that we identified above.

```r
LimitedData=data[,cols]
```

In the assignment we were asked to created a second tidy data set that contained just the average of each variable for each activity and each subject. To do that we can use the aggregate function and aggregate on both the "Subject" and "Activity" variables.

```r
averages=aggregate(.~Subject+Activity, data=LimitedData, FUN=mean)
```

Last but not least export our new tidy data set to be uploaded to Coursera!

```r
write.table(averages, file="tidydata.txt")
```
