
## @knitr unnamed-chunk-1
#preliminaries
setwd("C:/Users/Jared/Dropbox/GIS Data REL/SDP")
options(width=80)


## @knitr loadData
# Read in Stata
library(foreign) # required for .dta files
stuatt<-read.dta('data/Student_Attributes.dta') # read data in the data subdirectory
# We can also convert to .csv and import


## @knitr unnamed-chunk-2
str(stuatt)


## @knitr unnamed-chunk-3
head(stuatt)


## @knitr unnamed-chunk-4
stuatt$race_num<-NA # Create variable race_num 
                    #  in data frame stuatt
unique(stuatt$race_ethnicity) #check current values

# Generate numeric race code using conditional 
# expressions in R (in brackets)

stuatt$race_num[stuatt$race_ethnicity=='B']<-1
stuatt$race_num[stuatt$race_ethnicity=='A']<-2
stuatt$race_num[stuatt$race_ethnicity=='H']<-3
stuatt$race_num[stuatt$race_ethnicity=='NA']<-4
stuatt$race_num[stuatt$race_ethnicity=='W']<-5
stuatt$race_num[stuatt$race_ethnicity=='M/O']<-6
unique(stuatt$race_num)


## @knitr unnamed-chunk-5
# In R categorical variables are best represented as factors
# Factors can have values, and labels
# Create a labeled factor for the new race_num variable

stuatt$race_num2<-factor(stuatt$race_num,labels=c('Black','Asian','Hispanic',
                                            'Native American','White','MultipleOther'))

# Compare them to check using a cross-tabulation
table(stuatt$race_ethnicity,stuatt$race_num2)

# Replace them
stuatt$race_num<-NULL
stuatt$race_ethnicity<-stuatt$race_num2
stuatt$race_num2<-NULL

table(stuatt$race_ethnicity) # counts
prop.table(table(stuatt$race_ethnicity))*100 #percentages


## @knitr unnamed-chunk-6
library(xtable) #beautify our output
print(xtable(prop.table(table(stuatt$race_ethnicity))*100),
      include.colnames=FALSE,floating=FALSE,hline.after=NULL)
print(xtable(table(stuatt$race_ethnicity)*100,digits=0),
      include.colnames=FALSE,floating=FALSE,hline.after=NULL)


## @knitr unnamed-chunk-7
library(xtable) #beautify our output
print(xtable(prop.table(table(stuatt$race_ethnicity))*100),
      include.colnames=FALSE,floating=FALSE,hline.after=NULL)


## @knitr unnamed-chunk-8
print(xtable(table(stuatt$race_ethnicity)*100,digits=0),
      include.colnames=FALSE,floating=FALSE,hline.after=NULL)


## @knitr unnamed-chunk-9
library(ggplot2)
qplot(stuatt$race_ethnicity,geom='bar')+theme_bw()+xlab('Race/Ethnicity')+ylab('Count')


## @knitr benchmark
library(microbenchmark)
library(plyr)
res<-microbenchmark(tapply(stuatt$race_ethnicity,stuatt$sid,function(x)length(unique(x))),times=2)
nvals<-tapply(stuatt$race_ethnicity,stuatt$sid,function(x)length(unique(x)))
res2<-microbenchmark(ddply(stuatt,.(sid),summarize,nvals=length(unique(race_ethnicity))),times=2)
nvals<-ddply(stuatt,.(sid),summarize,nvals=length(unique(race_ethnicity)))


## @knitr unnamed-chunk-10
#Get number of unique values by sid
nvals<-tapply(stuatt$race_ethnicity,stuatt$sid,function(x)length(unique(x))) 
table(nvals)


## @knitr unnamed-chunk-11
library(ggplot2)
qplot(as.factor(nvals),geom='bar')+theme_bw()+xlab('Unique Race Codes')+ylab('Count')


## @knitr unnamed-chunk-12
# First we need to create a 'mode' function in R that mimics Stata
# statamode creates a list of the modal values and assigns "."
# If more than one mode exists
statamode <- function(x) {
  z <- table(as.vector(x))
  m<-names(z)[z == max(z)]
  if(length(m)==1){
    return(m)
  }
  return(".")
}

# Create new data frame for individual student
# Create nvals while we are at it
library(plyr) # convenience functions for summarizing data in R
modes<-ddply(stuatt,.(sid),summarize,race_temp=statamode(race_ethnicity),
             nvals=length(unique(race_ethnicity)))
tab1<-table(modes$race_temp,modes$nvals)
addmargins(tab1,FUN=list(Total=sum),quiet=TRUE)


## @knitr dotplot
df<-as.data.frame(tab1)
qplot(Var1,Var2,geom='point',size=log(Freq),data=df)+theme_bw()+xlab('Nvals')+ylab('Modal Race')


## @knitr unnamed-chunk-13
source('functions.R') # Read in the functions we have written
# All functions are available in the Appendix
a<-nvals(df="stuatt",id="sid",year="school_year",var="race_ethnicity")
# Here we pass R some characters to tell it which variables we care about
# This allows us to generalize beyond the race variable in the future
# df = data frame, id= student id, year= school year, and var= our variable of interest
head(a)
rm(a)


## @knitr unnamed-chunk-14
# Create a variable indicating the latest school year
modes<-ddply(stuatt,.(sid),summarize,race_temp=statamode(race_ethnicity),
             nvals=length(unique(race_ethnicity)),most_recent_year=max(school_year),
              most_recent_race=tail(race_ethnicity,1))
modes$race2[modes$race_temp!="."]<-modes$race_temp[modes$race_temp!="."]
modes$race2[modes$race_temp=="."]<-as.character(modes$most_recent_race[modes$race_temp=="."])
head(modes)
# Delete old vars on stuatt
stuatt<-subset(stuatt,select=c('sid','school_year','race_ethnicity'))
# Assign the value associated with the most recent year as the permanent race_ethnicity for the students with missing race
stuatt<-merge(stuatt,modes)
rm(modes)
stuatt$race_ethnicity<-stuatt$race2
stuatt<-subset(stuatt,select=c('sid','school_year','race_ethnicity'))
head(stuatt,n=20)


## @knitr histogramfinal
qplot(race_ethnicity,data=stuatt,geom='histogram')+theme_bw()+ stat_bin(geom="text", aes(label=..count.., vjust=-.5))


## @knitr unnamed-chunk-15
# The Task 1 function starts with our raw data
# It performs all the tasks above
# And gives us back cleaned data that just needs variable
# renaming.
a<-task1(df="stuatt",id="sid",year="school_year",var="race_ethnicity")
head(a)


## @knitr unnamed-chunk-16
# This time read from a .csv file
stuyear<-read.csv('data/Student_School_Year.csv')
# Note that in RStudio we can click "Import Dataset" in the Workspaces View


## @knitr unnamed-chunk-17
str(stuyear)


## @knitr unnamed-chunk-18
head(stuyear,n=12)


## @knitr unnamed-chunk-19
stuyear$frpl_num<-0 # create new variable
stuyear$frpl_num[stuyear$frpl=='R']<-1 #recode
stuyear$frpl_num[stuyear$frpl=='F']<-1
stuyear$frpl<-stuyear$frpl_num # Replace frpl with new variable
stuyear$frpl_num<-NULL # Drop
head(stuyear,n=6)


## @knitr unnamed-chunk-20
addmargins(table(stuyear$frpl))


## @knitr unnamed-chunk-21
stu<-ddply(stuyear,.(sid),summarize,ever_frpl=max(frpl)) # Create variable by student
stuyear<-merge(stuyear,stu) # merge back


## @knitr unnamed-chunk-22
addmargins(table(stu$ever_frpl))


## @knitr unnamed-chunk-23
stuyear$dupes<-dedupe(stuyear[,1:2]) # Create indicator for all duplicated rows
table(stuyear$dupes) # count them, TRUE is a duplicated element


## @knitr unnamed-chunk-24
# In R it is faster to subset out the duplicated elements, fix them, and merge them back in
dupes<-subset(stuyear,dupes==TRUE)
for(i in dupes$sid){
  dupes$grade_level[dupes$sid==i]<-max(dupes$grade_level[dupes$sid==i])
}
stuyear<-rbind(dupes,subset(stuyear,dupes==FALSE))
stuyear<-stuyear[with(stuyear, order(as.numeric(row.names(stuyear)))),]
head(stuyear)


## @knitr unnamed-chunk-25
stuyear$dupes<-duplicated(stuyear[,1:2]) # Create new dupe indicator for 
                                         # one duplicate value

table(stuyear$dupes)
stuyear<-subset(stuyear,dupes==FALSE) # drop all duplicated terms
stuyear$dupes<-NULL # Indicator not needed
head(stuyear,n=10)


## @knitr unnamed-chunk-26
# Not run
# write.csv(stuyear,file='data/Student_School_Year_Intermediate.csv') # CSV
# write.dta(stuyear,file='data/Student_School_Year_Intermediate.dta') # STATA


