## ---- echo=FALSE, error=FALSE, message=FALSE, warning=FALSE, comment=NA----
# Set options for knitr
library(knitr)
knitr::opts_chunk$set(comment=NA, warning=FALSE, echo=TRUE,
                      error=FALSE, message=FALSE, fig.align='center')
options(width=80)

## ----unevaluatedExample, eval=FALSE, echo=TRUE---------------------------
# keep only observations if 8th grade math score is not missing
stutest %<>% filter(!is.na(test_math_8))

# check to see if the file is unique by student id
nrow(stutest) == nvals(stutest$sid)


## ---- loadRequiredPackages-----------------------------------------------
## Load the packages and prepare your R environment
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
nstu_stusy <- nvals(stusy$sid)
nrow_stuatt <- nrow(stuatt)
nstu_stuatt <- nvals(stuatt$sid)

# Merge
stusy <- inner_join(stusy, stuatt, by = "sid")

## ----checkStuSchYearMerge------------------------------------------------
# check the number and percentage of students appearing in both files

# Check for perfect merge
nrow(stusy) == nrow_stusy
nstu_stusy == nvals(stusy$sid)
nstu_stuatt == nvals(stusy$sid)

# Check merge percentage
nrow(stusy) / nrow_stusy
nstu_stusy / nvals(stusy$sid)
nstu_stuatt / nvals(stusy$sid)

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

## ----echo=TRUE-----------------------------------------------------------
tmpfileName <- "clean/Student_School_Enrollment_Clean.dta"
con <- unz(description = "data/clean.zip", filename = tmpfileName, 
           open = "rb")
stuschl <- read_stata(con)
close(con)

# Optional - get dimensions for comparing merge
nstu_stusy <- nvals(stusy$sid)
nstu_stuschl <- nvals(stuschl$sid)
nrow_stusy <- nrow(stusy)

stusy <- inner_join(stusy, stuschl, by = c("sid", "school_year"))

## ----checkStuSchlMerge---------------------------------------------------
# Check percentage of students and rows merged
nvals(stusy$sid) / nstu_stusy 
nvals(stusy$sid) / nstu_stuschl
nrow(stusy) / nrow_stusy  

# Above 0.95 so we can proceed

## ----selectHSonly--------------------------------------------------------
stusy %<>% filter(grade_level >= 9 & !is.na(grade_level) & 
                    grade_level <= 12)

# TODO: Why is grade level > 12 sometimes?

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
  mutate(longest_hs_code = unique(school_code[total_days_enrolled_in_school_max == total_days_enrolled_in_school])[1])


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

## ----reviewVarNames------------------------------------------------------
names(stusy)

## ----joinNSCData---------------------------------------------------------
tmpfileName <- "clean/Student_NSC_Enrollment_Indicators.dta"
con <- unz(description = "data/clean.zip", filename = tmpfileName, 
           open = "rb")
stunsc <- read_stata(con)
close(con)

# merge on variables needed from Student_College_Going to a temp file
tmp <- select(stusy, sid, hs_diploma_date, hs_diploma, chrt_grad, chrt_ninth)
# Use inner_join to only keep students in both
stunsc <- inner_join(tmp, stunsc, by = c("sid")); rm(tmp)

## ----genTwoYearEnrollment------------------------------------------------
## create and indicator to show if the student enrolled within two years 
## of HS graduation

stunsc$enrl_ever_w2_grad <- ifelse(stunsc$first_enrl_date_any < 
                                     (stunsc$hs_diploma_date + (365*2)) &
                                     !is.na(stunsc$hs_diploma_date) & 
                                     !is.na(stunsc$first_enrl_date_any), 
                                   1, 0)

## ----genEnrollForOntimeGrad----------------------------------------------
stunsc$ontime_yr <- stunsc$chrt_ninth + 3
stunsc$ontime_date <- mdy(paste0("09", "01", stunsc$ontime_yr))

## create and indicator to show if the student enrolled within two years of 
## expected HS graduation
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

# Big typo in the toolkit here on p. 15, should be 05-01-YYYY for the end date, no 10-01-YYYY
# [stunsc$chrt_grad ==", i, "] 
for(i in as.numeric(na.omit(unique(stunsc$chrt_grad)))){
  for(j in 1:4){
    eval(parse(text=paste0("stunsc$enrl_1oct_grad_yr", j," <- ifelse((
                       (stunsc$enrl_1oct_grad_yr", j," == 0) &
                           (stunsc$n_enroll_begin_date <=
                       ymd(paste0(", i, "+", j-1, ",'-10-01')) & 
                      ymd(paste0(", i, "+", j-1, ",'-05-01')) <= stunsc$n_enroll_end_date) &
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
  select(sid, chrt_grad, hs_diploma_date, first_enrl_date_any, n_enroll_begin_date, 
         n_enroll_end_date,
         enrl_1oct_grad_yr1, enrl_1oct_grad_yr2, enrl_1oct_grad_yr3, enrl_1oct_grad_yr4) %>% as.data.frame


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
# collapse (max) enrl_*, by(sid chrt_grad chrt_ninth hs_diploma_date first_college* type)
zedOut <- stunsc %>% 
  select(sid, chrt_grad, chrt_ninth, hs_diploma_date,
         type, matches("enrl_|first_college")) %>% 
  group_by(sid, type) %>%
  summarize_all(.funs = "max") %>% 
# We do not need variables that refer to no college, so we can drop those.
  filter(type !="_none")

tmp <- zedOut %>% select(matches("_any|_2yr|_4yr"))
zedOut <- zedOut %>% select(-matches("_any|_2yr|_4yr"))


tmp %<>% distinct(sid, .keep_all = TRUE)

## ----reshapeNSCDataWide--------------------------------------------------
# reshape wide enrl* , i(sid chrt_grad chrt_ninth hs_diploma_date first_college*) j(type) string

zedOut <- as.data.frame(zedOut)
zedOut <- reshape(zedOut, 
                  timevar = "type", 
                  idvar = c("sid", "chrt_grad", "chrt_ninth", 
                            "hs_diploma_date"),
                  direction = "wide", 
                  sep="")
zedOut <- inner_join(zedOut, tmp, by = c("sid" = "sid"))

zedOut %>% filter(sid == 41) %>% 
  select(sid, enrl_ever_w2_ninth_2yr, 
         enrl_1oct_grad_yr1_2yr, enrl_1oct_ninth_yr2_2yr,
         enrl_1oct_ninth_yr3_2yr, enrl_1oct_ninth_yr4_2yr,
         enrl_ever_w2_ninth_4yr, 
         enrl_1oct_grad_yr1_4yr, enrl_1oct_ninth_yr2_4yr,
         enrl_1oct_ninth_yr3_4yr, enrl_1oct_ninth_yr4_4yr)


## ----checkDimensions-----------------------------------------------------
nrow(zedOut) == length(unique(zedOut$sid))
# isid sid

## ----checkCollegeTypeExclusivity-----------------------------------------
varList <- c(paste0("enrl_ever_w2_", c("grad", "ninth")),
             as.vector(outer(c("enrl_1oct_grad_", "enrl_1oct_ninth_"), 
                c("yr1", "yr2", "yr3", "yr4"), paste, sep="")))

for(i in varList){
  var2yr <- paste0(i, "_2yr")
  var4yr <- paste0(i, "_4yr")
  zedOut[, var2yr] <- ifelse(zedOut[, var2yr] == 0 & zedOut[, var4yr] ==1, 
                             0, zedOut[, var2yr])
}

zedOut$enrl_ever_w2_grad_2yr <- ifelse(is.na(zedOut$enrl_ever_w2_grad_2yr), 
                                       0, zedOut$enrl_ever_w2_grad_2yr)
zedOut$enrl_ever_w2_grad_4yr <- ifelse(is.na(zedOut$enrl_ever_w2_grad_4yr), 
                                       0, zedOut$enrl_ever_w2_grad_4yr)
zedOut$enrl_ever_w2_ninth_2yr <- ifelse(is.na(zedOut$enrl_ever_w2_ninth_2yr), 
                                       0, zedOut$enrl_ever_w2_ninth_2yr)
zedOut$enrl_ever_w2_ninth_4yr <- ifelse(is.na(zedOut$enrl_ever_w2_ninth_4yr), 
                                       0, zedOut$enrl_ever_w2_ninth_4yr)

## ----createAnyCollegeVar-------------------------------------------------
# // create an any college version of the year-by-year college enrollment outcome
# foreach chrt in grad ninth {
# foreach i of numlist 1/4 {
# egen enrl_1oct_`chrt'_yr`i'_any = rowmax(enrl_1oct_`chrt'_yr`i'_2yr
# enrl_1oct_`chrt'_yr`i'_4yr)
# }
# }
# // create an any college version of the within 2 years enrollment outcome foreach chrt in grad
# ninth {
# egen enrl_ever_w2_`chrt'_any = rowmax(enrl_ever_w2_`chrt'_2yr enrl_ever_w2_`chrt'_4yr)
# }

## ----createPersistenceVar------------------------------------------------
# foreach chrt in grad ninth {
# // create persistence outcomes to the second year of college
# foreach type in 4yr 2yr any {
# gen enrl_`chrt'_persist_`type' = (enrl_1oct_`chrt'_yr1_`type' == 1 &
# enrl_1oct_`chrt'_yr2_any == 1) if !mi(chrt_`chrt')
# // create persistence outcomes that denote continuous enrollment over four
# consecutive years in college
# gen enrl_`chrt'_all4_`type' = (enrl_1oct_`chrt'_yr1_`type' == 1 & ///
# enrl_1oct_`chrt'_yr2_`type' == 1 & ///
# enrl_1oct_`chrt'_yr3_`type' == 1 & ///
# enrl_1oct_`chrt'_yr4_`type' == 1) if !mi(chrt_`chrt')
# }
# }

## ------------------------------------------------------------------------
# tempfile nsc
# save `nsc'

