#Project #1 
#Download zip file
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","UCI.zip")
unzip("UCI.zip")

#Open each of the relevant fies
ytest=read.table("UCI HAR Dataset\\test\\y_test.txt", header=FALSE)
xtest=read.table("UCI HAR Dataset\\test\\x_test.txt", header=FALSE)
ytrain=read.table("UCI HAR Dataset\\train\\y_train.txt", header=FALSE)
xtrain=read.table("UCI HAR Dataset\\train\\x_train.txt", header=FALSE)
subtest=read.table("UCI HAR Dataset\\test\\subject_test.txt", header=FALSE)
subtrain=read.table("UCI HAR Dataset\\train\\subject_train.txt", header=FALSE)

featurenames=read.table("UCI HAR Dataset\\features.txt", header=FALSE)
activitylabels=read.table("UCI HAR Dataset\\activity_labels.txt", header=FALSE)

#Add a column to return text instead of the factor for feature names and activity names
featurenames$names=as.character(featurenames$V2)
activitylabels$names=as.character(activitylabels$V2)
#Add a "code" variable for activity to be used later to merge with
activitylabels$code=as.numeric(activitylabels$V2)

#Combine X test and train and name the columns
X=rbind(xtest, xtrain)
colnames(X)=featurenames$names

#Combine Y test and train
Y=rbind(ytest, ytrain)

#Left join the Activity labels dataframe in order to get the activity names instead of just the number
colnames(Y)="code"
Act=merge(Y, activitylabels, by="code", all.x=TRUE)

#Combine the subject list and give the column a title
SUB=rbind(subtest, subtrain)
colnames(SUB)="Subject"

#Combine the Subjects Activities, and X data
data=cbind(SUB, Act$names, X)
#rename the second column
colnames(data)[2]="Activity"

#Subset for just the feature names that relate to Mean and STD
MeanSTD=subset(featurenames, grepl("mean", featurenames$names)|grepl("std", featurenames$names))
#create a vector of the columns I want for my final data set
cols=c("Subject", "Activity", MeanSTD$names)
#subset the full data set for just the columns I want
LimitedData=data[,cols]

#Create the second tidy data set with the average of each variable for each activity and each subject
averages=aggregate(.~Subject+Activity, data=LimitedData, FUN=mean)
#Export the dataset
write.table(averages, file="tidydata.txt")
