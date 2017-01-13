## ----setup, echo=FALSE, error=FALSE, message=FALSE, warning=FALSE, comment=NA----
# Set options for knitr
library(knitr)
knitr::opts_chunk$set(comment=NA, warning=FALSE, echo=TRUE,
                      error=FALSE, message=FALSE, fig.align='center')
options(width=80)

## ----unevaluatedExample, eval=FALSE, echo=TRUE---------------------------
## # keep only observations if 8th grade math score is not missing
## stutest %<>% filter(!is.na(test_math_8))
## 
## # check to see if the file is unique by student id
## nrow(stutest) == n_distinct(stutest$sid)
## 

## ----loadRequiredPackages------------------------------------------------
#  Load the packages and prepare your R environment
library(tidyverse) # main suite of R packages to ease data analysis
library(magrittr) # allows for some easier pipelines of data

# Read in some R functions that are useful for toolkit tasks, see SDP R Glossary
# for details
source("R/functions.R")
library(haven) # required for importing .dta files

## ----readPriorAchievement------------------------------------------------
# To read data from a zip file we create a connection to the path of the 
# zip file
tmpfileName <- "clean/Prior_Achievement.dta"
con <- unz(description = "data/clean.zip", filename = tmpfileName, 
           open = "rb")
stuach <- read_stata(con) # read data in the data subdirectory
close(con)

## ----renameg8Vars--------------------------------------------------------
stuach %<>% rename( 
       test_math_8_raw = raw_score_math,
       test_ela_8_raw = raw_score_ela,
       test_math_8 = scaled_score_math,
       test_ela_8 = scaled_score_ela,
       test_composite_8 = scaled_score_composite,
       test_math_8_std = scaled_math_std,
       test_ela_8_std = scaled_ela_std, 
       test_composite_8_std = scaled_score_composite_std)

## ----defineQuartiles-----------------------------------------------------
stuach %<>% group_by(school_year) %>% 
  mutate(qrt_8_math = ntile(test_math_8, 4), 
         qrt_8_ela = ntile(test_ela_8, 4), 
         qrt_8_composite = ntile(test_composite_8, 4))

## ----loadSchoolData------------------------------------------------------
# To read data from a zip file we create a connection to the path of the 
# zip file
tmpfileName <- "clean/School.dta"
con <- unz(description = "data/clean.zip", filename = tmpfileName, 
           open = "rb")
schl <- read_stata(con) # read data in the data subdirectory
close(con)

## ----distinctSchools-----------------------------------------------------
# keep only the school code and school name
schl <- select(schl, school_name, school_code)
# keep school_code school_name
# duplicates drop
schl <- distinct(schl)
# // check that the file is unique by school_code
# isid school_code
length(unique(schl$school_code)) == nrow(schl)


## ----genSchoolRenameVars-------------------------------------------------
# creates first / last / longest hs id variables
schl$first_hs_code <- schl$school_code
schl$last_hs_code <- schl$school_code
schl$longest_hs_code <- schl$school_code

## ----loadStudentAttributes-----------------------------------------------
# To read data from a zip file we create a connection to the path of the 
# zip file
tmpfileName <- "clean/Student_Attributes.dta"
con <- unz(description = "data/clean.zip", filename = tmpfileName, 
           open = "rb")
stuatt <- read_stata(con) # read data in the data subdirectory
close(con)

## ----mergeonStudentSchYear-----------------------------------------------
tmpfileName <- "clean/Student_School_Year_Ninth.dta"
con <- unz(description = "data/clean.zip", filename = tmpfileName, 
           open = "rb")
stusy <- read_stata(con)
close(con)

# Data checks
# Is data unique by sid and school year
nrow(stusy) == length(unique(paste0(stusy$sid, stusy$school_year)))

# How many unique grades exist?
table(stusy$grade_level)

# Does first 9th school year exist?
"first_9th_school_year_observed" %in% names(stusy)

# Optional: Get data dimensions for both frames for checking
nrow_stusy <- nrow(stusy)
nstu_stusy <- n_distinct(stusy$sid)
nrow_stuatt <- nrow(stuatt)
nstu_stuatt <- n_distinct(stuatt$sid)

# Merge
stusy <- inner_join(stusy, stuatt, by = "sid")

## ----checkStuSchYearMerge------------------------------------------------
# check the number and percentage of students appearing in both files

# Check for perfect merge
nrow(stusy) == nrow_stusy
nstu_stusy == n_distinct(stusy$sid)
nstu_stuatt == n_distinct(stusy$sid)

# Check merge percentage
nrow(stusy) / nrow_stusy
nstu_stusy / n_distinct(stusy$sid)
nstu_stuatt / n_distinct(stusy$sid)

stusy <- arrange(stusy, sid)
length(unique(stusy$sid)) == length(unique(stuatt$sid))

## ----genProgramPartVars--------------------------------------------------
# In R this is an easy way to go by just using group_by and mutate
tmp <- filter(stusy, (grade_level >= 9 & grade_level <= 12)) %>% 
               group_by(sid) %>% 
  summarize(frpl_ever_hs = ifelse(max(frpl) > 0, 1, 0), 
         iep_ever_hs = max(iep), 
         ell_ever_hs = max(ell), 
         gifted_ever_hs = max(gifted))

stusy <- inner_join(stusy, tmp, by = "sid")
stusy <- arrange(stusy, sid)

stusy %<>% group_by(sid) %>% 
  mutate(frpl_ever = ifelse(max(frpl) > 0, 1, 0), 
         iep_ever = max(iep), 
         ell_ever = max(ell), 
         gifted_ever = max(gifted))

rm(tmp)

## ----loadAndMergeEnrollment----------------------------------------------
tmpfileName <- "clean/Student_School_Enrollment_Clean.dta"
con <- unz(description = "data/clean.zip", filename = tmpfileName, 
           open = "rb")
stuschl <- read_stata(con)
close(con)

# Optional - get dimensions for comparing merge
nstu_stusy <- n_distinct(stusy$sid)
nstu_stuschl <- n_distinct(stuschl$sid)
nrow_stusy <- nrow(stusy)

stusy <- inner_join(stusy, stuschl, by = c("sid", "school_year"))

## ----checkStuSchlMerge---------------------------------------------------
# Check percentage of students and rows merged
n_distinct(stusy$sid) / nstu_stusy 
n_distinct(stusy$sid) / nstu_stuschl
nrow(stusy) / nrow_stusy  

# Above 0.95 so we can proceed

## ----selectHSonly--------------------------------------------------------
stusy %<>% filter(grade_level >= 9 & !is.na(grade_level) & 
                    grade_level <= 12)


## ----dropZeroDayAttend---------------------------------------------------
stusy %<>% filter(days_enrolled > 0)

## ----assignFirstHS-------------------------------------------------------
stusy %<>% arrange(sid, school_year, enrollment_date, desc(days_enrolled))

stusy %<>% group_by(sid) %>%
  arrange(sid, school_year, enrollment_date, desc(days_enrolled)) %>% 
  mutate(first_hs_code = first(school_code), 
         last_hs_code = last(school_code))


## ----genLastHSCode-------------------------------------------------------
stusy %<>% group_by(sid) %>%
  arrange(sid, desc(school_year), desc(withdrawal_date), desc(days_enrolled)) %>% 
  mutate(last_hs_code = last(school_code)) %>%
  ungroup

## ----defineLongestHS-----------------------------------------------------
stusy %<>% group_by(sid, school_code) %>% 
  mutate(total_days_enrolled_in_school = sum(days_enrolled))

stusy %<>% group_by(sid) %>% 
  mutate(total_days_enrolled_in_school_max = max(total_days_enrolled_in_school))

stusy %>% select(sid, school_code, enrollment_date, total_days_enrolled_in_school, 
                 days_enrolled, first_hs_code) %>% 
  head

stusy %<>% group_by(sid) %>% 
  mutate(longest_hs_code = unique(school_code[total_days_enrolled_in_school_max ==
                                                total_days_enrolled_in_school])[1])


stusy %>% select(sid, school_code, enrollment_date, total_days_enrolled_in_school, 
                 days_enrolled, first_hs_code, longest_hs_code) %>% 
  head

# Drop temporary variables
stusy$total_day_enrolled_in_school <- NULL
stusy$total_days_enrolled_in_school <- NULL
stusy$total_days_enrolled_in_school_max <- NULL

## ----mergeSchoolNames----------------------------------------------------

stusy <- left_join(stusy, schl[, c("school_name", "first_hs_code")], 
                   by = c("first_hs_code"))

stusy %<>% rename(school_name_first_hs = school_name)

stusy <- left_join(stusy, schl[, c("school_name", "last_hs_code")], 
                   by = c("last_hs_code"))

stusy %<>% rename(school_name_last_hs = school_name)

stusy <- left_join(stusy, schl[, c("school_name", "longest_hs_code")], 
                   by = c("longest_hs_code"))

stusy %<>% rename(school_name_longest_hs = school_name)

## ----cleanupMerge--------------------------------------------------------

stusy %<>% filter(!is.na(school_name_longest_hs))
stusy %<>% filter(!is.na(school_name_first_hs) & !is.na(school_name_last_hs))


## ----renameChrtNinghtVar-------------------------------------------------
# define ninth grade cohort
# rename first_9th_school_year_observed chrt_ninth
stusy %<>% rename(chrt_ninth = first_9th_school_year_observed)

## ----defineChrtGrad------------------------------------------------------
# define graduation cohort
stusy$chrt_grad <- NULL
library(lubridate)
# Use lubridate package to find months and years easily
head(year(stusy$hs_diploma_date))
head(month(stusy$hs_diploma_date))

stusy$chrt_grad <- ifelse(month(stusy$hs_diploma_date) < 9, 
                          year(stusy$hs_diploma_date), 
                            year(stusy$hs_diploma_date) + 1)


## ----checkResultsChrtGrad------------------------------------------------
stusy %>% filter(sid %in% c(16305, 16306, 16307)) %>% 
  select(sid, hs_diploma_date, chrt_ninth, chrt_grad) %>% 
  distinct(.keep_all=TRUE) 

## ----checkWithdrawalCodes------------------------------------------------
stusy %>% arrange(sid) %>% 
  summarize(last_withdrawal = last(last_withdrawal_reason)) %>% 
  select(last_withdrawal) %>% unlist %>% table


## ----recodeWithdrawalCodes-----------------------------------------------
stusy$last_wd_group <- NA
stusy$last_wd_group[stusy$last_withdrawal_reason %in% c("Home School", 
                                                        "Other Transfer", 
                                                        "Transfer Out of District", 
                                                        "Death")] <- 2
stusy$last_wd_group[stusy$last_withdrawal_reason %in% c("Absenteeism", 
                                                        "No Show", 
                                                        "Expulsion")] <- 3
stusy$last_wd_group[stusy$hs_diploma == 1] <- 1
stusy$last_wd_group[is.na(stusy$last_wd_group)] <- 4
table(is.na(stusy$last_wd_group))

## ----defineGradTypes-----------------------------------------------------
# define on-time graduates
stusy$ontime_grad <- ifelse(stusy$chrt_ninth >= stusy$chrt_grad -3 & 
                        !is.na(stusy$chrt_ninth) & 
                        !is.na(stusy$chrt_grad) & 
                        stusy$hs_diploma == 1 , 1, 0)

# define late graduates
stusy$late_grad <- ifelse(stusy$ontime_grad == 0 & 
                        !is.na(stusy$chrt_ninth) & 
                        !is.na(stusy$chrt_grad) & 
                        stusy$hs_diploma == 1 , 1, 0)
all(stusy$late_grad + stusy$ontime_grad == stusy$hs_diploma)

## ----hsOutcomesNonGrads--------------------------------------------------
# still enrolled

maxDataYear <- max(stusy$school_year)
stusy %<>% group_by(sid) %>% 
  mutate(still_enrl = ifelse(max(school_year) == maxDataYear & 
                               hs_diploma != 1, 1, 0))
# transfer out

stusy$transferout <- ifelse(stusy$last_wd_group == 2 & 
                              stusy$hs_diploma!=1 & 
                              stusy$still_enrl != 1, 1, 0)
# drop out
stusy$dropout <- ifelse(stusy$last_wd_group == 3 & 
                              stusy$hs_diploma!=1 & 
                              stusy$still_enrl != 1 & 
                              stusy$transferout != 1, 1, 0)
# disappear
stusy$disappear <- ifelse(stusy$dropout != 1 & 
                              stusy$hs_diploma!=1 & 
                              stusy$still_enrl != 1 & 
                              stusy$transferout != 1, 1, 0)


## ----keepTimeInvariantVars-----------------------------------------------
# // keep time-invariant variables
stusy %<>% ungroup %>% 
  select(sid, male, race_ethnicity, 
         last_wd_group, still_enrl, transferout, 
         dropout, disappear,
         matches("hs_diploma|_ever|_hs_code|school_name|chrt|_grad"))

stusy %<>% distinct(.keep_all = TRUE)

# // make sure the file is unique by sid
nrow(stusy) == length(unique(stusy$sid))


## ----MergePriorAchievement-----------------------------------------------
stusy <- left_join(stusy, stuach, by = "sid")

## ----checkPriorAchieveMerge----------------------------------------------
table(is.na(stusy$qrt_8_math))

## ----organizeColumns-----------------------------------------------------
stusy %<>% select(sid, male, race_ethnicity, hs_diploma, hs_diploma_type, 
                  hs_diploma_date, frpl_ever, iep_ever, ell_ever, gifted_ever,
                  frpl_ever_hs, iep_ever_hs, ell_ever_hs, gifted_ever_hs,
                  first_hs_code, last_hs_code, longest_hs_code, school_name_first_hs, 
                  school_name_last_hs, school_name_longest_hs, last_wd_group,
                  chrt_ninth, 
                  chrt_grad, ontime_grad, late_grad, still_enrl, transferout,
                  dropout, disappear, test_math_8_raw, test_math_8, 
                  test_math_8_std, test_ela_8_raw, test_ela_8, 
                  test_ela_8_std, test_composite_8, test_composite_8_std, 
                  qrt_8_math, qrt_8_ela, qrt_8_composite)

# Save as college going
stuCG <- stusy; rm(stusy)

## ----reviewVarNames------------------------------------------------------
names(stuCG)

## ----joinNSCData---------------------------------------------------------
tmpfileName <- "clean/Student_NSC_Enrollment_Indicators.dta"
con <- unz(description = "data/clean.zip", filename = tmpfileName, 
           open = "rb")
stunsc <- read_stata(con)
close(con)

# merge on variables needed from Student_College_Going to a temp file
tmp <- select(stuCG, sid, hs_diploma_date, hs_diploma, chrt_grad, chrt_ninth)
# Use inner_join to only keep students in both
stunsc <- inner_join(tmp, stunsc, by = c("sid")); rm(tmp)

## ----genTwoYearEnrollment------------------------------------------------
# create and indicator to show if the student enrolled within two years 
# of HS graduation

stunsc$enrl_ever_w2_grad <- ifelse(stunsc$first_enrl_date_any < 
                                     (stunsc$hs_diploma_date + (365*2)) &
                                     !is.na(stunsc$hs_diploma_date) & 
                                     !is.na(stunsc$first_enrl_date_any), 
                                   1, 0)

## ----genEnrollForOntimeGrad----------------------------------------------
stunsc$ontime_yr <- stunsc$chrt_ninth + 3
stunsc$ontime_date <- mdy(paste0("09", "01", stunsc$ontime_yr))

# create and indicator to show if the student enrolled within two years of 
# expected HS graduation
stunsc$enrl_ever_w2_ninth <- ifelse(stunsc$first_enrl_date_any < 
                                      (stunsc$ontime_date + (365*2)) & 
                                      !is.na(stunsc$ontime_date) &
                                      !is.na(stunsc$first_enrl_date_any), 
                                    1, 0)


## ----checkCodingNSC------------------------------------------------------

stunsc %>% filter(sid %in% c(15647,15656,15658)) %>% 
  select(sid, chrt_ninth, chrt_grad, hs_diploma_date, first_enrl_date_any, 
         enrl_ever_w2_grad, ontime_yr, ontime_date, enrl_ever_w2_ninth) %>% 
  distinct(.keep_all=TRUE) %>% 
  as.data.frame


## ----genPlaceholderYearVars----------------------------------------------
# Create the 4 enrollment outcomes of interest by October 1st

# Create a new data.frame with all variables and merge it onto stunsc

newdf <- data.frame(NA)

for(num in 1:4) {
  eval(parse(text=paste0("newdf$enrl_1oct_grad_yr", num, " <- 0")))
  eval(parse(text=paste0("newdf$enrl_1oct_ninth_yr", num, " <- 0")))
}

# Drop the first empty row
newdf <- newdf[, -1]

# We can use cbind, or column bind, instead of mergin
stunsc <- cbind(stunsc[, 1:35], newdf)

## ----loopPlaceholderValuesNSC--------------------------------------------
stunsc$n_enroll_begin_date[stunsc$sid == 16011]

stunsc %>% filter(sid %in% c(16011, 16016)) %>% 
  select(sid, chrt_grad, hs_diploma_date, first_enrl_date_any, n_enroll_begin_date)

testDF <- stunsc %>% 
  mutate(compDateG = ymd(paste0(chrt_grad, "-10-01")), 
         compDateE = ymd(paste0(chrt_ninth, "-10-01")),
         compInterval = n_enroll_begin_date %--% n_enroll_end_date) %>%
    mutate(enrl_1oct_grad_yr1 = compDateG %within% compInterval, 
           enrl_1oct_grad_yr2 = (compDateG + 365) %within% compInterval,
           enrl_1oct_grad_yr3 = (compDateG + 730) %within% compInterval,
           enrl_1oct_grad_yr4 = (compDateG + 1095) %within% compInterval) %>% 
  mutate(enrl_1oct_grad_yr1 = ifelse(compDateE %within% compInterval, 1,
                                     as.numeric(enrl_1oct_grad_yr1)),
           enrl_1oct_grad_yr2 = ifelse((compDateE + 365) %within% compInterval, 1, 
                                       as.numeric(enrl_1oct_grad_yr2)),
           enrl_1oct_grad_yr3 = ifelse((compDateE + 730) %within% compInterval, 1, 
                                       as.numeric(enrl_1oct_grad_yr3)),
           enrl_1oct_grad_yr4 = ifelse((compDateE + 1095) %within% compInterval, 1, 
         as.numeric(enrl_1oct_grad_yr4)))
  

stunsc %<>% filter(!is.na(stunsc$chrt_grad))

# [stunsc$chrt_grad ==", i, "] 
for(i in as.numeric(na.omit(unique(stunsc$chrt_grad)))){
  for(j in 1:4){
    eval(parse(text=paste0("stunsc$enrl_1oct_grad_yr", j," <- ifelse((
                       (stunsc$enrl_1oct_grad_yr", j," == 0) &
                           (stunsc$n_enroll_begin_date <=
                       ymd(paste0(", i, "+", j-1, ",'-10-01')) & 
                      ymd(paste0(", i, "+", j-1, ",'-05-01')) <= 
                      stunsc$n_enroll_end_date) &
                      (year(stunsc$hs_diploma_date) == ", i, " &
                      month(stunsc$hs_diploma_date) <=9) | 
                    (year(stunsc$hs_diploma_date) == ", i-1, "& 
                      month(stunsc$hs_diploma_date)>9)), 1, 
                    stunsc$enrl_1oct_grad_yr", j,")")))
    
  }
}

table(stunsc$enrl_1oct_grad_yr1)
table(stunsc$enrl_1oct_grad_yr2)
table(stunsc$enrl_1oct_grad_yr3)
table(stunsc$enrl_1oct_grad_yr4)

stunsc %>% filter(sid %in% c(16011, 16016)) %>% 
  select(sid, chrt_grad, hs_diploma_date, first_enrl_date_any,
         n_enroll_begin_date, n_enroll_end_date,
         enrl_1oct_grad_yr1, enrl_1oct_grad_yr2, 
         enrl_1oct_grad_yr3, enrl_1oct_grad_yr4) %>% 
  as.data.frame

for(i in as.numeric(unique(stunsc$ontime_yr))){
  for(j in 1:4){
    eval(parse(text=paste0("stunsc$enrl_1oct_ninth_yr", j," <- ifelse((
                       (stunsc$enrl_1oct_ninth_yr", j," == 0) &
                           (stunsc$n_enroll_begin_date <=
                       ymd(paste0(", i, "+", j-1, ",'-10-01')) & 
                      ymd(paste0(", i, "+", j-1, ",'-05-01')) <=
                  stunsc$n_enroll_end_date) & (stunsc$chrt_ninth == ", i - 3, ")),
                        1, stunsc$enrl_1oct_ninth_yr", j,")")))
    
  }
}
table(stunsc$enrl_1oct_ninth_yr1)
table(stunsc$enrl_1oct_ninth_yr2)
table(stunsc$enrl_1oct_ninth_yr3)
table(stunsc$enrl_1oct_ninth_yr4)


## ----makeNSCuniqueSID----------------------------------------------------
stunsc$type <- NA
stunsc$type[stunsc$n_college_2yr == 0 & stunsc$n_college_4yr == 0] <- "_none"
stunsc$type[stunsc$n_college_2yr == 1] <- "_2yr"
stunsc$type[stunsc$n_college_4yr == 1] <- "_4yr"

## ----collapsetoSIDonly---------------------------------------------------
# We do not need variables that refer to no college, so we can drop those.
stunsc <- stunsc %>% 
  select(sid, chrt_grad, chrt_ninth, hs_diploma_date,
         type, matches("enrl_|first_college")) %>% 
  group_by(sid, type) %>%
  summarize_all(.funs = "max") %>% 
  filter(type !="_none")

tmp <- stunsc %>% select(matches("_any|_2yr|_4yr"))
stunsc <- stunsc %>% select(-matches("_any|_2yr|_4yr"))


tmp %<>% distinct(sid, .keep_all = TRUE)

## ----reshapeNSCDataWide--------------------------------------------------

stunsc <- as.data.frame(stunsc)
stunsc <- reshape(stunsc, 
                  timevar = "type", 
                  idvar = c("sid", "chrt_grad", "chrt_ninth", 
                            "hs_diploma_date"),
                  direction = "wide", 
                  sep="")
stunsc <- inner_join(stunsc, tmp, by = c("sid" = "sid"))

stunsc %>% filter(sid == 41) %>% 
  select(sid, enrl_ever_w2_ninth_2yr, 
         enrl_1oct_grad_yr1_2yr, enrl_1oct_ninth_yr2_2yr,
         enrl_1oct_ninth_yr3_2yr, enrl_1oct_ninth_yr4_2yr,
         enrl_ever_w2_ninth_4yr, 
         enrl_1oct_grad_yr1_4yr, enrl_1oct_ninth_yr2_4yr,
         enrl_1oct_ninth_yr3_4yr, enrl_1oct_ninth_yr4_4yr)


## ----checkDimensions-----------------------------------------------------
nrow(stunsc) == length(unique(stunsc$sid))
# isid sid

## ----checkCollegeTypeExclusivity-----------------------------------------
varList <- c(paste0("enrl_ever_w2_", c("grad", "ninth")),
             as.vector(outer(c("enrl_1oct_grad_", "enrl_1oct_ninth_"), 
                c("yr1", "yr2", "yr3", "yr4"), paste, sep="")))

for(i in varList){
  var2yr <- paste0(i, "_2yr")
  var4yr <- paste0(i, "_4yr")
  stunsc[, var2yr] <- ifelse(stunsc[, var2yr] == 0 & stunsc[, var4yr] ==1, 
                             0, stunsc[, var2yr])
}

stunsc$enrl_ever_w2_grad_2yr <- ifelse(is.na(stunsc$enrl_ever_w2_grad_2yr), 
                                       0, stunsc$enrl_ever_w2_grad_2yr)
stunsc$enrl_ever_w2_grad_4yr <- ifelse(is.na(stunsc$enrl_ever_w2_grad_4yr), 
                                       0, stunsc$enrl_ever_w2_grad_4yr)
stunsc$enrl_ever_w2_ninth_2yr <- ifelse(is.na(stunsc$enrl_ever_w2_ninth_2yr), 
                                       0, stunsc$enrl_ever_w2_ninth_2yr)
stunsc$enrl_ever_w2_ninth_4yr <- ifelse(is.na(stunsc$enrl_ever_w2_ninth_4yr), 
                                       0, stunsc$enrl_ever_w2_ninth_4yr)

## ----createAnyCollegeVar-------------------------------------------------

varList <- c(grep("enrl_1oct", names(stunsc), value = TRUE), 
             grep("enrl_ever", names(stunsc), value = TRUE))

# as.vector(outer(as.vector(outer(c("grad", "ninth"), 
#                                 paste0("yr", 1:4), paste, sep="_")),
#                 c("2yr", "4yr"), paste, sep = "_"))

# iterator
stubs <- as.vector(outer(c("grad", "ninth"), 
                                 paste0("yr", 1:4), paste, sep="_"))

for(i in stubs){
  tmp <- grep(i, varList, value = TRUE)
  newVar <- paste0(gsub("_2yr", "", tmp[1]), "_any")
  stunsc[, newVar] <- rowSums(zeroNA(stunsc[, tmp]))
}

stunsc$enrl_ever_w2_grad_any <- rowSums(zeroNA(stunsc[, c("enrl_ever_w2_grad_2yr",
                                                          "enrl_ever_w2_grad_4yr")]))
stunsc$enrl_ever_w2_ninth_any <- rowSums(zeroNA(stunsc[, c("enrl_ever_w2_ninth_2yr",
                                                          "enrl_ever_w2_ninth_4yr")]))

## ----createPersistenceVar------------------------------------------------
# This is a very un-R way to do this, but it works within the data structure 
# specified by the toolkit

for(chrt in c("ninth", "grad")){
  for(type in c("2yr", "4yr", "any")){
    newVar <- paste0("enrl_1oct_", chrt, "_persist_", type)
    var1 <- paste0("enrl_1oct_", chrt, "_yr1_", type)
    var2 <- paste0("enrl_1oct_", chrt, "_yr1_any")
    var3 <- paste0("chrt_", chrt)
      
    stunsc[, newVar] <- ifelse(stunsc[, var1] == 1 & 
                                 stunsc[, var2] == 1 & 
                                 !is.na(stunsc[, var3]), 
                               1, 0)
    stunsc[, newVar] <- zeroNA(stunsc[, newVar])
    # Persistence all 4 years
    newVar <- paste0("enrl_1oct_", chrt, "_all4_", type)
    vList <- paste("enrl_1oct", chrt, 
                        c("yr1", "yr2", "yr3", "yr4"), type, sep = "_")
    var5 <- paste0("chrt_", chrt)
    stunsc[, newVar] <- ifelse(stunsc[, vList[1]] == 1 & 
                                 stunsc[, vList[2]] == 1 & 
                                 stunsc[, vList[3]] == 1 & 
                                 stunsc[, vList[4]] == 1 & 
                                 !is.na(stunsc[, var5]), 
                               1, 0)
    stunsc[, newVar] <- zeroNA(stunsc[, newVar])
  }
}

## ----mergeTogether-------------------------------------------------------
out <- left_join(stuCG, stunsc, by = "sid")
out %<>% filter(transferout != 1)
cg_analysis <- out
# Save the current file as CG_Analysis.rda
# Create a analysis directory
# dir.create("analysis")
# save(out, file = "analysis/CG_Analysis.rda")
# Or if you want to save the Stata file
# write_dta(out, file = "analysis/CG_Analysis.dta")

# Save the current file as Student_CollegeGoing.rda
# Create a analysis directory
# dir.create("clean")
# save(stuCG, file = "clean/Student_CollegeGoing.rda")
# Or if you want to save the Stata file
# write_dta(stuCG, file = "clean/Student_CollegeGoing.dta")
# cleanup
rm(list = ls()[ls() != "cg_analysis"])

## ----globalSchYear-------------------------------------------------------
current_schyr <- 2010

## ----reloadWorkspace-----------------------------------------------------
# Load the packages and prepare your R environment
library(tidyverse) # main suite of R packages to ease data analysis
library(magrittr) # allows for some easier pipelines of data

# Read in some R functions that are useful for toolkit tasks, see SDP R Glossary
# for details
source("R/functions.R")
library(haven) # required for importing .dta files

## ----readinOTdata--------------------------------------------------------
# Read in file 1
tmpfileName <- "clean/Student_School_Year_Ninth.dta"
con <- unz(description = "data/clean.zip", filename = tmpfileName, 
           open = "rb")
stusy <- read_stata(con)
close(con)
# Read in file 2
tmpfileName <- "clean/Student_School_Enrollment_Clean.dta"
con <- unz(description = "data/clean.zip", filename = tmpfileName, 
           open = "rb")
stuschl <- read_stata(con)
close(con)

stuOT <- left_join(stuschl, stusy[, 1:3], by = c("sid", "school_year"))
rm(stusy, stuschl); gc()


## ----withdrawalCodeTable-------------------------------------------------
table(stuOT$withdrawal_code_desc)

## ----identifyTransferout-------------------------------------------------
# Create a list of values that indicate a transfer out

transferCodes <- c("Home School", "Left District", "Other Transfer", 
                   "Transfer Out of District", 
                   "Death")

# Group by sid and test whether any withdrawal_code_desc for a student appear 
# in the transferCodes list, this gives TRUE/FALSE
# Convert this to numeric

stuOT %<>% group_by(sid) %>% 
  mutate(ever_transferout = any(withdrawal_code_desc %in% transferCodes)) %>% 
  mutate(ever_transferout = as.numeric(ever_transferout))


## ----filterTransferout---------------------------------------------------
stuOT %<>% filter(ever_transferout == 0)
stuOT %<>% select(-ever_transferout)


## ----filterSaveSortStuOT-------------------------------------------------
# Keep only relevant variables and drop duplicates
stusy <- stuOT %>% select(sid, school_year, grade_level) %>% 
  # Select only one unique row by sid, school_year, and grade_level
  distinct(school_year, grade_level)
# Confirm uniqueness of rows
n_distinct(paste0(stusy$sid, stusy$school_year)) == nrow(stusy)
# Clean up
rm(stuOT)

## ----readStuCGStuEnroll--------------------------------------------------
# Read in file 1
tmpfileName <- "clean/Student_Class_Enrollment_Merged.dta"
con <- unz(description = "data/clean.zip", filename = tmpfileName, 
           open = "rb")
stuenrl <- read_stata(con)
close(con)
# Read in file 2
tmpfileName <- "analysis/Student_CollegeGoing.dta"
con <- unz(description = "data/analysis.zip", filename = tmpfileName, 
           open = "rb")
stuCG <- read_stata(con)
close(con)

# We can only assess if a student is on track if we have course information for 
# them. Keep only records that appear in both files using inner_join

stuOT <- inner_join(stuenrl, stuCG, by = c("sid"))
rm(stuenrl, stuCG); gc()

## ----mergeStusyOn--------------------------------------------------------
# Use right_join to keep only sids found in stusy
stuOT <- inner_join(stuOT, stusy, by = c("sid", "school_year"))
# rm(stusy)

## ----filterLateHSStudents------------------------------------------------
markList <- c("YL", "S1", "Q1")

stuOT %<>% group_by(sid) %>% 
  mutate(any_grade_9 = any(grade_level == 9)) %>% 
  mutate(enrolled_grade_9 = any(marking_period[any_grade_9] %in% markList)) %>% 
  ungroup %>% 
  select(-any_grade_9)

stuOT %<>% filter(enrolled_grade_9) %>% 
  select(-enrolled_grade_9)


## ----restrictCohorts-----------------------------------------------------
stuOT %<>% filter(chrt_ninth <= current_schyr - 4)

## ----nonLinEnrollPattern-------------------------------------------------

nonlin <- stuOT %>% select(sid, school_year) %>% 
  distinct() %>% arrange(sid, school_year) %>% 
  group_by(sid) %>% 
  mutate(syLag = lag(school_year)) %>% ungroup %>% 
  mutate(syDiff = school_year - syLag)

nonlin$nonlin_enrl <- ifelse(nonlin$syDiff > 1 & !is.na(nonlin$syDiff), 1, 0)
nonlin %<>%  select(sid, nonlin_enrl) %>% group_by(sid) %>% 
  mutate(nonlin_enrl = max(nonlin_enrl, na.rm=TRUE)) %>% 
  distinct(.keep_all = TRUE)


## ----mergeanddropNonlinEnroll--------------------------------------------

stuOT <- inner_join(stuOT, nonlin, by = "sid")

stuOT %<>% filter(stuOT$nonlin_enrl < 1) %>% 
  select(-nonlin_enrl)

## ----confirmCleanedCredits-----------------------------------------------
all(!is.na(stuOT$credits_possible))
all(!is.na(stuOT$credits_earned))

table(stuOT$credits_possible,stuOT$credits_earned)

## ----gradeCreditTables---------------------------------------------------
# stuOT %>% filter(credits_possible == 0 & credits_earned != 0) %>% 
#   with(., table(final_grade_mark))

stuOT %>% filter(credits_possible == 0 & credits_earned != 0) %>% 
  with(., table(final_grade_mark, credits_earned))

## ----recodeGrades--------------------------------------------------------

for(gl in c("A", "B", "C", "D", "E")){
  stuOT$credits_possible[stuOT$credits_possible == 0 & 
                           !is.na(stuOT$credits_earned !=0) & 
                           grepl(gl, stuOT$final_grade_mark) & 
                           stuOT$final_grade_mark != "NGPA"] <- 
    stuOT$credits_earned[stuOT$credits_possible == 0 & 
                           !is.na(stuOT$credits_earned !=0) & 
                           grepl(gl, stuOT$final_grade_mark) & 
                           stuOT$final_grade_mark != "NGPA"]
  
}



## ----checkGradesandCredits-----------------------------------------------
table(stuOT$final_grade_mark, stuOT$credits_earned)

## ----replaceFailingGrades------------------------------------------------
stuOT$credits_earned <- ifelse(stuOT$final_grade_mark == "F" | 
                                 stuOT$final_grade_mark == "NGPA", 0,
                               stuOT$credits_earned)

## ----reviewEdgeCases-----------------------------------------------------
table(stuOT$final_grade_mark[stuOT$credits_earned == 0])
table(stuOT$final_grade_mark[stuOT$credits_earned == 0],
      stuOT$credits_possible[stuOT$credits_earned == 0])


## ----assignCredits-------------------------------------------------------
with(stuOT, credits_earned[credits_earned == 0 & 
                       credits_possible != 0  & 
                         grepl("A|B|C|D|E", final_grade_mark) & 
                         final_grade_mark!="NGPA"] <- 
       credits_possible[credits_earned == 0 & 
                       credits_possible != 0  & 
                         grepl("A|B|C|D|E", final_grade_mark) & 
                         final_grade_mark!="NGPA"]
     )

## ----calculateModalCourseGrades------------------------------------------
stuOT %<>% group_by(cid) %>% 
  mutate(credits_earned_mode = statamode(credits_earned)) %>% 
  ungroup

with(stuOT, credits_earned[credits_earned == 0 & 
                             !is.na(credits_earned_mode) & 
                              grepl("A|B|C|D|E", final_grade_mark) & 
                             final_grade_mark != "NGPA"] <- 
       credits_earned_mode[credits_earned == 0 & 
                             !is.na(credits_earned_mode) & 
                              grepl("A|B|C|D|E", final_grade_mark) & 
                             final_grade_mark != "NGPA"])


## ----checkGrade0CreditsTable---------------------------------------------

stuOT %>% select(final_grade_mark, credits_earned, credits_possible) %>% 
  filter(credits_earned == 0 & final_grade_mark %in% c("A", "B", "C", "D", "E")) %>% 
  with(., table(final_grade_mark, credits_possible))


## ----checkCreditsEarnedandPossible---------------------------------------
stuOT %>%  filter(final_grade_mark %in% c("A", "B", "C", "D", "E", "F") & 
                    credits_earned > credits_possible) %>% 
  with(., table(credits_earned, credits_possible))


## ----adjustCreditsEarned-------------------------------------------------
with(stuOT, credits_earned[credits_possible == 0 & 
                             credits_earned!= 0  & 
                             credits_earned > credits_possible & 
                             grepl("A|B|C|D|E", final_grade_mark) & 
                             final_grade_mark != "NGPA"] <- 
       credits_earned[credits_possible == 0 & 
                             credits_earned!= 0  & 
                             credits_earned > credits_possible & 
                             grepl("A|B|C|D|E", final_grade_mark) & 
                             final_grade_mark != "NGPA"])

## ----useCourseModeCredits------------------------------------------------
stuOT$replace_credits <- ifelse(stuOT$credits_possible > 0 &
                           stuOT$credits_earned > stuOT$credits_possible & 
                           grepl("A|B|C|D|E", stuOT$final_grade_mark) &
                           stuOT$final_grade_mark != "NGPA", 1, 0)

stuOT$credits_earned[stuOT$replace_credits == 1 & 
                       !is.na(stuOT$credits_earned_mode)] <- 
  stuOT$credits_earned_mode[stuOT$replace_credits == 1 & 
                              !is.na(stuOT$credits_earned_mode)]

stuOT$credits_possible[stuOT$replace_credits == 1 & 
                       !is.na(stuOT$credits_earned_mode)] <- 
  stuOT$credits_earned_mode[stuOT$replace_credits == 1 & 
                              !is.na(stuOT$credits_earned_mode)]

## ----filterFinalMissingMarks---------------------------------------------
stuOT %>% filter(!credits_earned > credits_possible & 
                    (grepl("A|B|C|D|E", final_grade_mark) &
                    stuOT$final_grade_mark != "NGPA")) %>% nrow

stuOT %>%  filter(credits_earned != credits_possible & replace_credits == 1) %>% 
  with(., table(credits_earned, credits_possible))

## ----tableofCreditsandGrade, results='hide'------------------------------
table(stuOT$credits_possible, stuOT$credits_earned, stuOT$final_grade_mark)

## ----checkMissingnessCredits---------------------------------------------
all(!is.na(stuOT$credits_possible))
all(!is.na(stuOT$credits_earned))

## ----calcYearsinHS-------------------------------------------------------

num_yrs <- stuOT %>% select(sid, school_year, grade_level) %>%
  distinct(.keep_all=TRUE) %>% 
  arrange(sid, school_year, grade_level) %>% 
  group_by(sid) %>% 
  mutate(year_in_hs = n())

stuOT <- inner_join(stuOT, num_yrs[, c(1, 4)], by = "sid")

table(stuOT$chrt_ninth, stuOT$chrt_grad)

## ----saveStuOTData-------------------------------------------------------
# Save the current file as Student_OnTrack_Sample.dta
# Create a analysis directory
# dir.create("analysis")
# save(stuOT, file = "analysis/Student_OnTrack_Sample.rda")
# Or if you want to save the Stata file
# write_dta(stuOT, file = "analysis/Student_OnTrack_Sample.dta")

## ----readStuOTdataIn-----------------------------------------------------
# Read in file 1
tmpfileName <- "analysis/Student_OnTrack_Sample.dta"
con <- unz(description = "data/analysis.zip", filename = tmpfileName, 
           open = "rb")
stuOT <- read_stata(con)
close(con)

## ----calcCreditsEarnedYear-----------------------------------------------
# Cumulative credits within years
stuOT %<>% group_by(sid, year_in_hs) %>% 
  mutate(cum_credits_yr = cumsum(credits_earned)) %>% 
  mutate(cum_credits_yr = max(cum_credits_yr))

# Cumulative credits across years
tmp <- stuOT %>% select(sid, year_in_hs, cum_credits_yr) %>% 
  distinct(sid, year_in_hs, .keep_all = TRUE)

tmp %<>% group_by(sid) %>% arrange(year_in_hs) %>% 
  mutate(cum_credits = cumsum(cum_credits_yr)) %>% arrange(sid, year_in_hs) %>% 
  select(-cum_credits_yr)
  ungroup

stuOT <- inner_join(stuOT, tmp, by = c("sid", "year_in_hs"))
rm(tmp)


## ----creditsbySubject----------------------------------------------------
stuOT %<>% group_by(sid, year_in_hs) %>% 
  mutate(cum_credits_yr_math = sum(credits_earned[math_flag == 1]), 
         cum_credits_yr_ela = sum(credits_earned[ela_flag == 1])) %>% 
  ungroup()

# Cumulative credits across years
tmp <- stuOT %>% select(sid, year_in_hs, cum_credits_yr_math, cum_credits_yr_ela) %>% 
  distinct(sid, year_in_hs, .keep_all = TRUE)


tmp %<>% group_by(sid) %>% arrange(year_in_hs) %>% 
  mutate(cum_credits_math = cumsum(cum_credits_yr_math),
         cum_credits_ela = cumsum(cum_credits_yr_ela)) %>% arrange(sid, year_in_hs) %>% 
  select(-cum_credits_yr_ela, -cum_credits_yr_math)
  ungroup

stuOT <- inner_join(stuOT, tmp, by = c("sid", "year_in_hs"))
rm(tmp)

# stuOT %>% filter(sid == 10585) %>% 
#  select(sid, year_in_hs, credits_earned, 
#         math_flag, cum_credits_math, cum_credits_ela) %>% 
#   as.data.frame %>% head(40)

stuOT %<>% select(-cum_credits_yr_ela, -cum_credits_yr_math, 
                  -cum_credits_yr)

## ----onTrackFlags--------------------------------------------------------
stuOT %<>% group_by(sid, year_in_hs) %>%
  mutate(ontrack_endyr = ifelse(cum_credits >= (first(year_in_hs) * 5) & 
           cum_credits_math >= (ceiling(first(year_in_hs)^2 / 6)) & 
           cum_credits_ela >= first(year_in_hs), 1, 0)) %>% ungroup

## ----simplifyOTdata------------------------------------------------------
stuOT %<>% select(sid, school_year, starts_with("hs_diploma"), 
                        last_wd_group, starts_with("chrt_"), 
                        ontime_grad, late_grad, still_enrl, 
                        transferout, dropout, disappear, year_in_hs, 
                        starts_with("cum_credits"), starts_with("ontrack_"))

stuOT %<>% distinct(sid, school_year, .keep_all=TRUE)


## ----codeEOYoutcomes-----------------------------------------------------
stuOT %<>% group_by(sid, year_in_hs) %>% 
  mutate(status_eoy = ifelse(ontrack_endyr == 1, 1, 2)) %>%
  mutate(status_eoy = ifelse(dropout == 1, 3, status_eoy)) %>%
  mutate(status_eoy = ifelse(disappear == 1, 4, status_eoy)) %>%
  ungroup()

sum(table(stuOT$status_eoy)) == nrow(stuOT)

## ----defineStatus--------------------------------------------------------
tmp <- stuOT %>% filter(year_in_hs == 4)  %>% 
  group_by(sid) %>% 
  mutate(status_eoy_yr4 = ifelse(ontime_grad == 1 & !is.na(chrt_grad), 1, 0)) %>%
  mutate(status_eoy_yr4 = ifelse(still_enrl == 1 | late_grad ==1, 2, status_eoy)) %>%
  mutate(status_eoy_yr4 = ifelse(is.na(hs_diploma_date) & is.na(status_eoy) & 
                                   disappear == 1, 4, status_eoy)) %>%
  ungroup() %>% 
  select(sid, status_eoy_yr4)

stuOT <- left_join(stuOT, tmp, by = "sid")

# Replace
stuOT$status_eoy[stuOT$year_in_hs == 4] <- stuOT$status_eoy_yr4[stuOT$year_in_hs == 4]
stuOT$status_eoy_yr4 <- NULL


## ----reshapeOTwide-------------------------------------------------------
stuOT$status_after <- stuOT$status_eoy; stuOT$status_eoy <- NULL
stuOT$school_year <- NULL
stuOT %<>% filter(year_in_hs < 5)
# Reshape
stuOT <- as.data.frame(stuOT)
stuOT <- reshape(stuOT, idvar = names(stuOT)[1:13], 
               timevar = "year_in_hs", 
               direction = "wide", sep = "_yr")
stuOT$ontrack_hsgrad_sample <- 1


## ----saveOTsample--------------------------------------------------------
# Save the current file as Student_OnTrack_Variables.dta
# Create a analysis directory
# dir.create("analysis")
# save(stuOT, file = "analysis/Student_OnTrack_Variables.rda")
# Or if you want to save the Stata file
# write_dta(stuOT, file = "analysis/Student_OnTrack_Variables.dta")

## ----loadDataOTagain-----------------------------------------------------
# Read in file 1
tmpfileName <- "analysis/Student_OnTrack_Sample.dta"
con <- unz(description = "data/analysis.zip", filename = tmpfileName, 
           open = "rb")
stuOT <- read_stata(con)
close(con)

## ----inspectGradeTable---------------------------------------------------
table(stuOT$final_grade_mark, stuOT$final_grade_mark_num)

## ----excludeSomeGrades---------------------------------------------------
stuOT$credits_possible[stuOT$final_grade_mark %in% c("P", "NGPA")] <- 0
stuOT$final_grade_mark_num[stuOT$final_grade_mark %in% c("P", "NGPA")] <- 0


## ----GPAcalc1------------------------------------------------------------
stuOT %<>% mutate(gpa_points = final_grade_mark_num * credits_possible)

## ----checkGPAwork--------------------------------------------------------
all(!is.na(stuOT$credits_possible), !is.na(stuOT$gpa_points))
all(stuOT$gpa_points[stuOT$final_grade_mark %in% c("P", "NGPA")]==0)

## ----gpaEarned-----------------------------------------------------------
stuOT %<>% group_by(sid, school_year) %>%
  mutate(tot_gpa_points_yr = sum(gpa_points), 
         tot_gpa_credits_yr = sum(credits_possible)) %>% 
  mutate(gpa_year = tot_gpa_points_yr/tot_gpa_credits_yr) %>% ungroup

## ----keepOnlyGPAvars-----------------------------------------------------
stuOT %<>% select(sid, school_year, starts_with("tot_gpa"), gpa_year)
stuOT %<>% distinct(sid, school_year, .keep_all=TRUE)
stuOT %<>% filter(!is.na(gpa_year))
nrow(stuOT) == n_distinct(paste0(stuOT$sid, stuOT$school_year))


## ----cumGPAPoints--------------------------------------------------------
stuOT %<>% group_by(sid) %>% arrange(school_year) %>% 
  mutate(total_points = cumsum(tot_gpa_points_yr), 
         total_credits = cumsum(tot_gpa_credits_yr)) %>% ungroup

## ----calcCumGPAandDropVars-----------------------------------------------
stuOT$cum_gpa_yr <- stuOT$total_points/stuOT$total_credits
sum(stuOT$cum_gpa_yr)
stuOT %<>% select(-total_points, tot_gpa_credits_yr, -tot_gpa_points_yr, 
                  -total_credits)

## ----finalGPACum---------------------------------------------------------

stuOT %<>% group_by(sid) %>% arrange(school_year) %>% 
  mutate(cum_gpa_final = last(cum_gpa_yr))

## ----reshapeWide---------------------------------------------------------
stuOT %<>% select(sid, school_year, cum_gpa_yr, cum_gpa_final) %>% 
  group_by(sid) %>% arrange(school_year) %>% 
  filter(row_number() < 5) %>% 
  mutate(idx = row_number()) %>%
  ungroup %>% arrange(sid, school_year) %>%
  select(-school_year) %>%
  as.data.frame()

# stuOT$cum_gpa_final <- round(stuOT$cum_gpa_final, 3)

tmp <- reshape(stuOT, direction = "wide", 
               idvar = c("sid", "cum_gpa_final"), 
               timevar = "idx")
rm(stuOT)

## ----readMergeCGOT-------------------------------------------------------
# Read in file 1
tmpfileName <- "analysis/Student_OnTrack_Variables.dta"
con <- unz(description = "data/analysis.zip", filename = tmpfileName, 
           open = "rb")
stuOT <- read_stata(con)
close(con)

cg_student <- inner_join(stuOT, tmp, by = "sid")
rm(stuOT, tmp)

## ----loadSATdata---------------------------------------------------------
# Read in file 1
tmpfileName <- "clean/SAT.dta"
con <- unz(description = "data/clean.zip", filename = tmpfileName, 
           open = "rb")
stuSAT <- read_stata(con)
close(con)
# Read in file 1
tmpfileName <- "clean/ACT.dta"
con <- unz(description = "data/clean.zip", filename = tmpfileName, 
           open = "rb")
stuACT <- read_stata(con)
close(con)

cg_student <- left_join(cg_student, stuSAT, by = "sid")
cg_student <- left_join(cg_student, stuACT, by = "sid")
rm(stuSAT, stuACT)

## ----ACTSATconvert-------------------------------------------------------
cg_student$sat_act_temp <- ACTtoSAT(cg_student$act_composite_score)


## ----convertACTSATConcordance--------------------------------------------
cg_student$sat_act_concordance <- NA

cg_student$sat_act_concordance[!is.na(cg_student$sat_total_score) & 
                                 is.na(cg_student$act_composite_score)] <-
  cg_student$sat_total_score[!is.na(cg_student$sat_total_score) & 
                                 is.na(cg_student$act_composite_score)]

cg_student$sat_act_mean <- (cg_student$sat_total_score + cg_student$sat_act_temp) /2

cg_student$sat_act_concordance[!is.na(cg_student$act_composite_score) |
                          !is.na(cg_student$sat_total_score)] <- 
  cg_student$sat_act_mean[!is.na(cg_student$act_composite_score) |
                          !is.na(cg_student$sat_total_score)] 

cg_student$sat_act_concordance[is.na(cg_student$sat_total_score) & 
                           !is.na(cg_student$act_composite_score)] <- 
  cg_student$sat_act_temp[is.na(cg_student$sat_total_score) & 
                           !is.na(cg_student$act_composite_score)] 


## ----checkACTSATWORK-----------------------------------------------------
all(with(cg_student, 
     table(is.na(sat_act_concordance[!is.na(sat_total_score) | 
                                             !is.na(act_composite_score)]))
           ))

all(with(cg_student, 
     table(!is.na(sat_act_concordance[is.na(sat_total_score) | 
                                             is.na(act_composite_score)]))
           ))


## ----encodeHighlyQualified-----------------------------------------------

cg_student$highly_qualified <- NA



cg_student$highly_qualified[!is.na(cg_student$chrt_grad) & 
                              cg_student$cum_gpa_final >= 3.7 & 
                          !is.na(cg_student$cum_gpa_final) & 
                            cg_student$sat_act_concordance >= 1100 & 
                            !is.na(cg_student$sat_act_concordance)] <- 1

cg_student$highly_qualified[!is.na(cg_student$chrt_grad) & 
                              cg_student$cum_gpa_final >= 3.3 & 
                          !is.na(cg_student$cum_gpa_final) & 
                            cg_student$sat_act_concordance >= 1200 & 
                            !is.na(cg_student$sat_act_concordance)] <- 1

cg_student$highly_qualified[!is.na(cg_student$chrt_grad) & 
                              cg_student$cum_gpa_final >= 3.0 & 
                          !is.na(cg_student$cum_gpa_final) & 
                            cg_student$sat_act_concordance >= 1300 & 
                            !is.na(cg_student$sat_act_concordance)] <- 1

cg_student$highly_qualified[!is.na(cg_student$chrt_grad) &
                              is.na(cg_student$highly_qualified)] <- 0

table(is.na(cg_student$highly_qualified[is.na(cg_student$chrt_grad)]))
table(!is.na(cg_student$highly_qualified[!is.na(cg_student$chrt_grad)]))

## ----filterCOhortsOT-----------------------------------------------------
cg_student %<>% filter(chrt_ninth == 2005 | chrt_ninth == 2006)


## ----dropVarsOT----------------------------------------------------------
cg_student %<>% select(sid, starts_with("ontrack_"), 
                       starts_with("cum_credits"), 
                       starts_with("cum_gpa"), 
                       starts_with("status_"), 
                       sat_act_concordance, highly_qualified)
cg_student$ontrack_sample <- 1

## ----combineWithAnalysisFile---------------------------------------------
cg_analysis <- inner_join(cg_analysis, cg_student, by = "sid")
rm(cg_student)
# use "${analysis}/CG_Analysis.dta", clear
# merge 1:1 sid using `ontrack', nogen
# save "${analysis}/CG_Analysis.dta", replace

## ----cleanUpNames, echo=FALSE--------------------------------------------
cg_analysis$hs_diploma_date <- cg_analysis$hs_diploma_date.x
cg_analysis$first_hs_name <- cg_analysis$school_name_first_hs
cg_analysis$longest_hs_name <- cg_analysis$school_name_longest_hs
cg_analysis$last_hs_name <- cg_analysis$school_name_last_hs
cg_analysis$chrt_ninth <- cg_analysis$chrt_ninth.x
cg_analysis$chrt_grad <- cg_analysis$chrt_grad.x

cg_analysis %<>% select(sid, male, race_ethnicity, hs_diploma, hs_diploma_type, 
                        hs_diploma_date, frpl_ever, iep_ever, ell_ever, 
                        gifted_ever, frpl_ever_hs, iep_ever_hs, ell_ever_hs,
                        gifted_ever_hs, first_hs_code, first_hs_name, 
                        last_hs_code, last_hs_name, longest_hs_code, 
                        longest_hs_name, last_wd_group, chrt_ninth, chrt_grad, 
                        ontime_grad, late_grad, still_enrl, transferout, 
                        dropout, disappear, test_math_8_raw, test_math_8, 
                        test_math_8_std, test_ela_8, test_ela_8_std, 
                        test_composite_8, test_composite_8_std, 
                        qrt_8_math, qrt_8_ela, qrt_8_composite,
                      matches("first_college_opeid|enrl_1oct_grad_|enrl_ever_w2|enrl_grad_|enrl_1oct_ninth_|cum_credits_yr|ontrack_endyr|status_after_yr|cum_gpa_yr"), 
                        ontrack_hsgrad_sample,
                        cum_gpa_final,
                        sat_act_concordance,
                        highly_qualified,
                        ontrack_sample)

## ----columnNamesend------------------------------------------------------
names(cg_analysis)

