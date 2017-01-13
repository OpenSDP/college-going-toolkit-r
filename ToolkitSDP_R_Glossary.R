## ----libraries, eval=FALSE-----------------------------------------------
## library(tidyverse)
## install.packages("tidyverse")
## update.packages()

## ----include=FALSE-------------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, message=FALSE, warning=FALSE)

## ----setup---------------------------------------------------------------
library(tidyverse)
library(magrittr)
# Let's load an example dataset
data(mtcars)

## ----comments------------------------------------------------------------
# Commenting one line

#-- Starting a block of comments
#   The spacing makes it clear
#   Being consistent is key

## ----pasteyQuotes, eval=FALSE--------------------------------------------
## eval(parse(text=("summary(mtcars['Valiant', ])")))

## ----stataExample, eval=FALSE--------------------------------------------
## library(haven)
## mydata <- read_stata(file = "MyStataFile.dta")

## ----readrExample, eval=FALSE--------------------------------------------
## library(readr)
## mydata <- read_csv(file = "MyCSVfile.csv")

## ----RODBCexample, eval=FALSE--------------------------------------------
## library(RODBC)
## channel <- odbcConnect(dsn = "mydatasource",
##                        uid="mylogin", pwd="mypassword")
## 
## dat1 <- sqlQuery(channel, "SELECT COLUMN1, COLUMN2, COLUMN3
##                             FROM SCHEMA.TABLE")

## ------------------------------------------------------------------------
mtcars$hp

## ------------------------------------------------------------------------
mtcars$hp[mtcars$carb > 2]

## ------------------------------------------------------------------------
str(mtcars)

## ------------------------------------------------------------------------
summary(mtcars)

## ------------------------------------------------------------------------
head(mtcars)

## ----collapse------------------------------------------------------------
library(dplyr); library(magrittr)

# Let's calculate horsepower by number of cylinders
collapsedData <- mtcars %>% group_by(cyl) %>% 
  summarize(meanHP = mean(hp))

collapsedData

## ----collapseAll---------------------------------------------------------
collapsedData <- mtcars %>% select(cyl, hp, disp, wt, drat, qsec) %>% 
  group_by(cyl) %>% 
  summarize_all(.funs = "mean")

collapsedData

## ------------------------------------------------------------------------
stocks <- data.frame(
  time = as.Date('2009-01-01') + 0:9,
  X = rnorm(10, 0, 1),
  Y = rnorm(10, 0, 2),
  Z = rnorm(10, 0, 4)
)

stocksLong <- reshape(stocks, idvar = "time", 
                      varying = list(2:4),
                      direction = "long", v.names = "price", 
                      times = c("X", "Y", "Z"), timevar = "stock", 
                      new.row.names = 1:30)
head(stocksLong)

## ------------------------------------------------------------------------
library(tidyr)

stocks <- data.frame(
  time = as.Date('2009-01-01') + 0:9,
  X = rnorm(10, 0, 1),
  Y = rnorm(10, 0, 2),
  Z = rnorm(10, 0, 4)
)
head(stocks)

## ------------------------------------------------------------------------
stocksm <- stocks %>% gather(stock, price, -time)
head(stocksm)

## ------------------------------------------------------------------------
stocksm %>% spread(stock, price) %>% head

## ------------------------------------------------------------------------
stocksm %>% spread(time, price) %>% head


## ---- eval=FALSE---------------------------------------------------------
## mtcars$hp
## mtcars[, "hp"]
## mtcars[, 1]

## ---- eval=FALSE---------------------------------------------------------
## mtcars$hp <- NULL
## mtcars[, "hp"] <- NULL
## mtcars <- mtcars[, -4]
## 
## # dplyr
## library(dplyr); library(magrittr)
## dataframe %<>% select(-variable)
## 

## ------------------------------------------------------------------------
names(mtcars) # read column names

## ---- eval=FALSE---------------------------------------------------------
## mtcars <- mtcars[, c(1:3, 8)]
## # equivalent to:
## mtcars <- mtcars[, c("mpg", "cyl", "disp", "vs")]

## ---- eval=FALSE---------------------------------------------------------
## 
## mtcars %<>% select(starts_with("mpg"))
## mtcars %<>% select(ends_with("s"))
## mtcars %<>% select(contains("hp"))
## mtcars %<>% select(matches("*cyl"))
## mtcars %<>% select(one_of(names(mtcars)))
## mtcars %<>% select(everything())
## 

## ------------------------------------------------------------------------
mtcars$mpgPerCyl <- NA # creates an empty vector with missing values
mtcars$mpgPerCyl <- 4 # creates an empty vector and assigns it a constant

# If your replacement is not length 1 or length of the vector, it will not 
# work
# mtcars$mpgPerCyl <- c(1, 5, 8) 


## ---- eval=FALSE---------------------------------------------------------
## mtcars$mpgBinary <- NA
## mtcars$mpgBinary[mtcars$mpg > 25] <- 1
## mtcars$mpgBinary[mtcars$mpg <= 25] <- 0
## 
## #  Alternatively you can use the ifelse function for simple assignments
## 
## mtcars$mpgBinary <- ifelse(mtcars$mpg > 25, 1, 0)
## 

## ------------------------------------------------------------------------
mtcars$mpgMean <- mean(mtcars$mpg) 
# the single mean(mpg) will be repeated the length of mtcars$mpg


## ---- eval=FALSE---------------------------------------------------------
## mtcars$mpgPerCyl <- mtcars$mpg / mtcars$cyl # creates vector with values right away
## mtcars$gearsAndCarbs <- mtcars$gear + mtcars$carb
## 
## # Be careful of order of operations
## mtcars$ComplexVar <- mtcars$qsec^2 / (mtcars$disp - mtcars$hp)

## ------------------------------------------------------------------------
mydata <- data.frame(var1 = NA, var2 = NA)


## ---- eval=FALSE---------------------------------------------------------
## mtcars$ComplexVar <- mtcars$qsec^2 / (2 * mtcars$disp - mtcars$hp)

## ------------------------------------------------------------------------
duplicated(iris)
# If you only want a summary
table(duplicated(iris))


## ------------------------------------------------------------------------
# Duplicates across two columns
table(duplicated(iris[, 1:2]))
# Duplicates across first three columns, fewer
table(duplicated(iris[, 1:3]))

## ------------------------------------------------------------------------
nrow(iris)
iris <- iris[duplicated(iris), ]
nrow(iris)

## ------------------------------------------------------------------------
iris %<>% distinct(.keep_all = TRUE)
#.keep_all tells R you want to return all columns, not just those that are distinct

## ------------------------------------------------------------------------
is.numeric(mtcars$hp)
is.integer(mtcars$cyl)
class(mtcars$carb)

## ------------------------------------------------------------------------
class(mtcars$hp)
mtcars$hp <- as.integer(mtcars$hp)
class(mtcars$hp) <- "integer"
class(mtcars$hp)

## ------------------------------------------------------------------------
summary(mtcars$carb)
summary(mtcars)
summary(iris)


## ------------------------------------------------------------------------
str(iris$Species)
str(iris)


## ----eval=FALSE----------------------------------------------------------
## View(mtcars)
## View(mtcars[mtcars$hp = 110, ])
## 

## ------------------------------------------------------------------------
table(iris$species)

## ------------------------------------------------------------------------
iris$SepalWidthInt <- round(iris$Sepal.Width, digits = 0)
table(iris$SepalWidthInt, iris$Species)

## ------------------------------------------------------------------------
ProblematicVector <- c("A", "B", "C", "A", "B", "D", NA, NA, NA, NA, "A", "C", "C", 
                       "C", "C", "C")
N <- length(ProblematicVector)
table(ProblematicVector)
sum(table(ProblematicVector))
N

## ------------------------------------------------------------------------
length(mtcars$cyl)
length(mtcars$hp[mtcars$hp > 140])
table(mtcars$hp > 140)

## ------------------------------------------------------------------------
length(mtcars)
# use nrow to get the length of individual vectors
nrow(mtcars)

## ------------------------------------------------------------------------
unique(mtcars$carb)


## ------------------------------------------------------------------------
length(unique(mtcars$carb))

## ----eval=FALSE----------------------------------------------------------
## mtcars <- mtcars[order(mtcars$disp, mtcars$cyl), ]
## 
## # To reverse the order
## mtcars <- mtcars[order(-mtcars$disp, -mtcars$cyl), ]
## 

## ------------------------------------------------------------------------
mtcars <- arrange(mtcars, cyl, disp)
# The %<>% operator saves some typing
mtcars %<>% arrange(cyl, disp)

# use desc() to order descending
mtcars <- arrange(mtcars, desc(cyl))
mtcars %<>% arrange(desc(cyl))

## ------------------------------------------------------------------------
mtcars %<>% group_by(gear) %>% 
  mutate(meanHPbyGear = mean(hp))

mtcars %<>% group_by(vs, am) %>% 
  mutate(countVSAM = n())

## ------------------------------------------------------------------------
names(mtcars)
mtcars <- mtcars[, c(1, 3, 2, 5:9, 4, 10, 11)]
# Anything not indexed will be dropped!
names(mtcars)

## ----eval=FALSE----------------------------------------------------------
## mtcars %<>% select(mpg, cyl, disp, hp, drat, wt)
## # Anything not selected will be dropped

## ------------------------------------------------------------------------
names(mtcars)[7] <- "engconfig"
names(mtcars)

## ----eval=FALSE----------------------------------------------------------
## names(iris) <- tolower(names(iris)) # lowercase
## names(iris) <- toupper(names(iris)) # uppercase
## names(iris) <- chartr("m", "M", names(iris)) # capitalize all m values
## 
## # prefix
## names(mtcars)[3:8] <- paste("prefix", names(mtcars)[3:8], sep = "_")
## # suffix
## names(mtcars)[3:8] <- paste(names(mtcars)[3:8], "suffix", sep = "_")
## # substitute character pattern with another pattern in names
## # here replace "zzz", with empty ""
## names(mtcars) <- gsub("zzz", "", names(mtcars))

## ------------------------------------------------------------------------
N <- nrow(mydata)
N

## ----functions-----------------------------------------------------------
# create a function that counts distinct values of a variable
nvals <- function(x){
  length(unique(x))
}

nvals(mtcars$carb)


## ------------------------------------------------------------------------
dplyr::ntile

## ----eval=FALSE----------------------------------------------------------
## 
## source("path/to/mySuperCoolFunctions.R")
## 

## ------------------------------------------------------------------------
# Return only the column positions that match
grep("cyl", names(mtcars))
# use in subset
mtcars[, grep("mpg", names(mtcars))]


## ------------------------------------------------------------------------
grepl("cyl", names(mtcars))

## ------------------------------------------------------------------------
data(mtcars)
row.names(mtcars)

gsub("Maserati", "!!!!MASERATI!!!", row.names(mtcars))


## ------------------------------------------------------------------------
mtcars$hp[8] <- NA # add a missing value to demo
mean(mtcars$hp)
mean(mtcars$hp, na.rm=TRUE)
min(mtcars$hp)
max(mtcars$hp)
median(mtcars$hp)
min(mtcars$hp, na.rm=TRUE)
max(mtcars$hp, na.rm=TRUE)
median(mtcars$hp, na.rm=TRUE)

## ------------------------------------------------------------------------
eeptools::statamode(mtcars$cyl)


## ------------------------------------------------------------------------
data(mtcars)
# regular
summary(mtcars$hp)
# center
summary(scale(mtcars$hp, scale = FALSE))
# scale
summary(scale(mtcars$hp, center = FALSE))
# scale and center
summary(scale(mtcars$hp))

## ------------------------------------------------------------------------
# scale and center
mtcars$hp_scaled <- scale(mtcars$hp)

# mean
attr(mtcars$hp_scaled, "scaled:center")
# sd
attr(mtcars$hp_scaled, "scaled:scale")

## ------------------------------------------------------------------------
# Create example data, 25 draws from a random normal distribution
xvar <- rnorm(25)
ntile(xvar, 3)
table(ntile(xvar, 3))

## ------------------------------------------------------------------------
library(lubridate)
# Convert string to date
coolDay <- mdy("05-25-1986")
# Get month
month(coolDay)
# Get year
year(coolDay)
# Get day
day(coolDay)
# Get week
week(coolDay)
# Day of the week
wday(coolDay, label = TRUE, abbr = FALSE)

## ----eval=FALSE----------------------------------------------------------
## # Derive the mode in a stata friendly fashion
## statamode <- function(x) {
##   z <- table(as.vector(x))
##   # use suppressMessages to make function quiet in loop and dplyr calls
##   m <- suppressMessages(suppressWarnings(names(z)[z == max(z)]))
##   if(length(m)==1){
##     return(m)
##   }
##   # Ties return the "." character
##   return(".")
## }
## 
## # distinct values function
## nvals <- function(x){
##   length(unique(x))
## }
## 
## # Replace all missing values in a vector with a numeric 0
## zeroNA <- function(x){
##   x[is.na(x)] <- 0
##   return(x) # return the whole vector, not replacements
## }
## 
## # Cluster standard errors
## get_CL_vcov <- function(model, cluster){
##   # cluster is a vector of cluster IDs from data passed to model, same length
##   # as the original data set
##   # model is the lm.fit object returned by model
##   # from: http://rforpublichealth.blogspot.com/2014/10/
##   # easy-clustered-standard-errors-in-r.html
##   require(sandwich, quietly = TRUE)
##   require(lmtest, quietly = TRUE)
##   cluster <- as.character(cluster)
##   # calculate degree of freedom adjustment
##   M <- length(unique(cluster))
##   N <- length(cluster)
##   K <- model$rank
##   dfc <- (M/(M-1))*((N-1)/(N-K))
##   # calculate the uj's
##   uj  <- apply(estfun(model), 2, function(x) tapply(x, cluster, sum))
##   # use sandwich to get the var-covar matrix
##   vcovCL <- dfc*sandwich(model, meat=crossprod(uj)/N)
##   return(vcovCL)
## }
## 
## #
## #
## #
## #
## #
## 
## # Example of a conversion function to avoid hard coding values
## # Convert SATtoACT
## # x is a vector of act scores
## # Function will return vector replaced with SAT equivalents
## ACTtoSAT <- function(x){
##   x[is.na(x)] <- 400
##   x[x  <  11] <- 400
##   x[x == 11] <- 530
##   x[x == 12] <- 590
##   x[x == 13] <- 640
##   x[x == 14] <- 690
##   x[x == 15] <- 740
##   x[x == 16] <- 790
##   x[x == 17] <- 830
##   x[x == 18] <- 870
##   x[x == 19] <- 910
##   x[x == 20] <- 950
##   x[x == 21] <- 990
##   x[x == 22] <- 1030
##   x[x == 23] <- 1070
##   x[x == 24] <- 1110
##   x[x == 25] <- 1150
##   x[x == 26] <- 1190
##   x[x == 27] <- 1220
##   x[x == 28] <- 1260
##   x[x == 29] <- 1300
##   x[x == 30] <- 1340
##   x[x == 31] <- 1340
##   x[x == 32] <- 1420
##   x[x == 33] <- 1460
##   x[x == 34] <- 1510
##   x[x == 35] <- 1560
##   x[x == 36] <- 1600
##   return(x)
## }
## 

## ------------------------------------------------------------------------
table(mtcars$hp > 300)
summary(mtcars[mtcars$hp > 250, ])

## ------------------------------------------------------------------------
mtcars$mpg[row.names(mtcars) == "Valiant"]
summary(mtcars$mpg[row.names(mtcars) != "Valiant"])

## ------------------------------------------------------------------------
mtcars[mtcars$disp > 100 & mtcars$drat < 3,]
mtcars[mtcars$disp > 160 | mtcars$drat < 3.25,]

# You can also nest logical statements

mtcars[(mtcars$disp > 160 | mtcars$drat < 3.25) & 
          mtcars$carb == 3,]

## ------------------------------------------------------------------------
mtcars[row.names(mtcars) %in% grep("Mazda", row.names(mtcars), value=TRUE), ]


## ----eval=FALSE----------------------------------------------------------
## library(tidyverse)
## vignette("manifesto")

## ------------------------------------------------------------------------
data(mtcars)

round(mutate
      (summarize_all(
        group_by(
          filter(mtcars, hp > 100), cyl), 
        .funs=mean), 
        kpl = mpg * 0.4251), 
      digits = 2)

## ------------------------------------------------------------------------

subData <- filter(mtcars, hp > 100)
cylSum <- summarize_all(group_by(subData, cyl), .funs = mean)
cylSum$kpl <- cylSum$mpg * 0.4251
print(round(cylSum, digits = 2))

## ------------------------------------------------------------------------
car_data <- filter(mtcars, hp > 100) %>% 
  group_by(cyl) %>% 
  summarize_all(.funs = mean) %>%
  mutate(kpl = mpg * 0.4251) %>% 
  round(digits = 2)
car_data


## ------------------------------------------------------------------------
library(magrittr) # %<>% is not automatically loaded with dplyr
data(mtcars)
mtcars$mpg
mtcars$mpg %<>% sqrt
mtcars$mpg

## ------------------------------------------------------------------------
library(ggplot2)
data(mtcars)

ggplot(mtcars, aes(x = hp, y = mpg)) + 
  geom_point() + geom_smooth() + 
  scale_x_continuous(limits = c(40, 360), 
                     breaks = seq(40, 360, 60)) +
  scale_y_continuous(limits = c(10, 40), 
                     breaks = seq(10, 40, 5)) +
  theme_classic()

ggplot(mtcars, aes(x = hp, y = mpg)) + 
  geom_point() + geom_smooth(method = "lm") + 
  scale_x_continuous(limits = c(40, 360), 
                     breaks = seq(40, 360, 60)) +
  scale_y_continuous(limits = c(10, 40), 
                     breaks = seq(10, 40, 5)) +
  theme_classic() + facet_wrap(~vs, labeller = "label_both")


## ------------------------------------------------------------------------
print(sessionInfo(),locale = FALSE)

