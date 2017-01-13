## ----knitrSetup, echo=FALSE, error=FALSE, message=FALSE, warning=FALSE, comment=NA----
# Set options for knitr
library(knitr)
knitr::opts_chunk$set(comment=NA, warning=FALSE, echo=TRUE,
                      error=FALSE, message=FALSE, fig.align='center',
                      fig.width=8, fig.height=6, dpi = 144, 
                      fig.path = "figure/Analyze_")
options(width=80)

## ----preliminaries-------------------------------------------------------
library(tidyverse) # main suite of R packages to ease data analysis
library(magrittr) # allows for some easier pipelines of data
# Read in some R functions that are convenience wrappers
source("R/functions.R")
library(haven) # required for importing .dta files

# Read in global variables for sample restriction
# Agency name
agency_name <- "Agency"

# Ninth grade cohorts you can observe persisting to the second year of college
chrt_ninth_begin_persist_yr2 = 2005
chrt_ninth_end_persist_yr2 = 2005

# Ninth grade cohorts you can observe graduating high school on time
chrt_ninth_begin_grad = 2005
chrt_ninth_end_grad = 2006

# Ninth grade cohorts you can observe graduating high school one year late
chrt_ninth_begin_grad_late = 2005
chrt_ninth_end_grad_late = 2005

# High school graduation cohorts you can observe enrolling in college the 
# fall after graduation
chrt_grad_begin = 2008
chrt_grad_end = 2009

# High school graduation cohorts you can observe enrolling in college 
# two years after hs graduation
chrt_grad_begin_delayed = 2008
chrt_grad_end_delayed = 2008

# In RStudio these variables will appear in the Environment pane under "Values"


## ----loadCGdataAttainment------------------------------------------------
# Step 1: Load the college-going analysis file into Stata
# library(haven) # commented out, we've already read it in above
# To read data from a zip file and unzip it in R we can 
# create a connection to the path of the zip file
tmpfileName <- "analysis/CG_Analysis.dta"
# This assumes analysis is a subfolder from where the file is read, in this 
# case inside the zipfile
con <- unz(description = "data/analysis.zip", filename = tmpfileName, 
           open = "rb")
# The zipfile is located in the subdirectory data, called analysis.zip
cgdata <- read_stata(con) # read data in the data subdirectory
close(con) # close the connection to the zip file, keeps data in memory

## ----Remindersetglobals--------------------------------------------------

# Step 2: Read in global variables if you have not already done so
# Ninth grade cohorts you can observe persisting to the second year of college
chrt_ninth_begin_persist_yr2 = 2005
chrt_ninth_end_persist_yr2 = 2005

# Ninth grade cohorts you can observe graduating high school on time
chrt_ninth_begin_grad = 2005
chrt_ninth_end_grad = 2006

# Ninth grade cohorts you can observe graduating high school one year late
chrt_ninth_begin_grad_late = 2005
chrt_ninth_end_grad_late = 2005

# High school graduation cohorts you can observe enrolling in college the 
# fall after graduation
chrt_grad_begin = 2008
chrt_grad_end = 2009

# High school graduation cohorts you can observe enrolling in college 
# two years after hs graduation
chrt_grad_begin_delayed = 2008
chrt_grad_end_delayed = 2008

# In RStudio these variables will appear in the Environment pane under "Values"

## ----A1filterCalculate---------------------------------------------------
# Step 3: Keep students in ninth grade cohorts you can observe persisting to the 
# second year of college

plotdf <- filter(cgdata, chrt_ninth >= chrt_ninth_begin_persist_yr2 & 
                   chrt_ninth <= chrt_ninth_end_persist_yr2)

# Step 4: Create variables for the outcomes "regular diploma recipients", 
#  "seamless transitioners" and "second year persisters"

plotdf$grad <- ifelse(!is.na(plotdf$chrt_grad) & plotdf$ontime_grad ==1, 1, 0)
plotdf$seamless_transitioners_any <- as.numeric(plotdf$enrl_1oct_ninth_yr1_any == 1 &
                                                 plotdf$ontime_grad == 1)
plotdf$second_year_persisters = as.numeric(plotdf$enrl_1oct_ninth_yr1_any == 1 &
                                             plotdf$enrl_1oct_ninth_yr2_any == 1 &
                                             plotdf$ontime_grad == 1)
# // Step 4: Create agency-level average outcomes

# // 2. Calculate the mean of each outcome variable by agency

agencyData <- plotdf %>%  
  summarize(grad = mean(grad), 
            seamless_transitioners_any = mean(seamless_transitioners_any, na.rm=TRUE), 
            second_year_persisters = mean(second_year_persisters, na.rm=TRUE), 
            N = n())

agencyData$school_name <- "AGENCY AVERAGE"
# // 2. Calculate the mean of each outcome variable by first high school attended
schoolData <- plotdf %>% group_by(first_hs_name) %>% 
  summarize(grad = mean(grad), 
            seamless_transitioners_any = mean(seamless_transitioners_any,
                                               na.rm=TRUE), 
            second_year_persisters = mean(second_year_persisters, na.rm=TRUE), 
            N = n())
# // 1. Create a variable school_name that takes on the value of students’ first 
## high school attended
names(schoolData)[1] <- "school_name"

# // 3. Identify the agency maximum values for each of the three outcome variables
maxSchool <- schoolData %>% summarize_all(.funs = funs("max"))
maxSchool$school_name <- "AGENCY MAX HS"

# // 4. Identify the agency minimum values for each of the three outcome variables
minSchool <- schoolData %>% summarize_all(.funs = funs("min"))
minSchool$school_name <- "AGENCY MIN HS"
# // 5. Append the three tempfiles to the school-level file loaded into R
schoolData <- bind_rows(schoolData, agencyData, 
                        minSchool, maxSchool)
rm(agencyData, minSchool, maxSchool)

## ----A1tidydata----------------------------------------------------------
# // Step 6: Prepare to graph the results
library(tidyr)
schoolData$cohort <- 1
schoolData <- schoolData %>% gather(key = outcome, 
                             value = measure, -N, -school_name)
schoolData$subset <- grepl("AGENCY", schoolData$school_name)
library(ggplot2)
library(scales)

schoolData$outcome[schoolData$outcome == "cohort"] <- "Ninth Graders"
schoolData$outcome[schoolData$outcome == "grad"] <- "On-time Graduates"
schoolData$outcome[schoolData$outcome == "seameless_transitioners_any"] <- 
  "Seamless College Transitioner"
schoolData$outcome[schoolData$outcome == "second_year_persisters"] <- 
  "Second Year Persisters"

## ----A1graph-------------------------------------------------------------
## // Step 7: Graph the results

ggplot(schoolData[schoolData$subset,], 
       aes(x = outcome, y = measure, group = school_name, 
           color = school_name, linetype = school_name)) + 
  geom_line(size = 1.1) + geom_point(aes(group = 1), color = I("black")) +
  geom_text(aes(label = round(measure * 100, 1)), vjust = -0.8, hjust = -0.25, 
            color = I("black")) +
  scale_y_continuous(limits = c(0, 1), label = percent) + 
  theme_bw() + theme(legend.position = c(0.825, 0.825)) + 
  guides(color = guide_legend("", keywidth = 6, 
                              label.theme = element_text(face = "bold", 
                                                         size = 8,
                                                         angle = 0)), 
         linetype = "none") +
  labs(y = "Percent of Ninth Graders", 
       title = "Student Progression from 9th Grade Through College", 
       subtitle = "Agency Average", x = "",
       caption = paste0("Sample: 2004-2005 Agency first-time ninth graders. \n", 
                  "Postsecondary enrollment outcomes from NSC matched records. \n",
                        "All other data from Agency administrative records."))



## ----A2filterCalculate---------------------------------------------------
# // Step 1: Keep students in ninth grade cohorts you can observe persisting to 
## the second year of college

plotdf <- filter(cgdata, chrt_ninth >= chrt_ninth_begin_persist_yr2 & 
                   chrt_ninth <= chrt_ninth_end_persist_yr2)

# // Step 2: Create variables for the outcomes "regular diploma recipients", 
## "seamless transitioners" and "second year persisters"
plotdf$grad <- ifelse(!is.na(plotdf$chrt_grad) & plotdf$ontime_grad ==1, 1, 0)
plotdf$seamless_transitioners_any <- as.numeric(plotdf$enrl_1oct_ninth_yr1_any == 1 &
                                                 plotdf$ontime_grad == 1)
plotdf$second_year_persisters = as.numeric(plotdf$enrl_1oct_ninth_yr1_any == 1 &
                                             plotdf$enrl_1oct_ninth_yr2_any == 1 &
                                             plotdf$ontime_grad == 1)
# // Step 3: Create agency-level average outcomes
progressRace <- plotdf %>% group_by(race_ethnicity) %>% 
  summarize(grad = mean(grad), 
            seameless_transitioners_any = mean(seamless_transitioners_any, na.rm=TRUE), 
            second_year_persisters = mean(second_year_persisters, na.rm=TRUE), 
            N = n())

## ----A2tidyandFormat-----------------------------------------------------
# // Step 4: Reformat the data for plotting
progressRace$cohort <- 1
progressRace <- progressRace %>% gather(key = outcome, 
                             value = measure, -N, -race_ethnicity)

# // Step 5: Recode variables for plot-friendly labels
progressRace$outcome[progressRace$outcome == "cohort"] <- "Ninth Graders"
progressRace$outcome[progressRace$outcome == "grad"] <- "On-time Graduates"
progressRace$outcome[progressRace$outcome == "seameless_transitioners_any"] <- 
  "Seamless College Transitioner"
progressRace$outcome[progressRace$outcome == "second_year_persisters"] <- 
  "Second Year Persisters"

progressRace$subset <- ifelse(progressRace$race_ethnicity %in% c(1, 3, 2, 5), 
                              TRUE, FALSE)
progressRace$race_ethnicity[progressRace$race_ethnicity == 1] <- "Black"
progressRace$race_ethnicity[progressRace$race_ethnicity == 2] <- "Asian"
progressRace$race_ethnicity[progressRace$race_ethnicity == 3] <- "Hispanic"
progressRace$race_ethnicity[progressRace$race_ethnicity == 4] <- "Native American"
progressRace$race_ethnicity[progressRace$race_ethnicity == 5] <- "White"
progressRace$race_ethnicity[progressRace$race_ethnicity == 6] <- "Multiple/Other"
progressRace$race_ethnicity <- as.character(zap_labels(progressRace$race_ethnicity))

## ----A2plot--------------------------------------------------------------
# Step 6: Graph the results
ggplot(progressRace[progressRace$subset,], 
       aes(x = outcome, y = measure, group = race_ethnicity, 
           color = race_ethnicity, linetype = race_ethnicity)) + 
  geom_line(size = 1.1) + geom_point(aes(group = 1), color = I("black")) +
  geom_text(aes(label = round(measure * 100, 1)), vjust = -0.8, hjust = -0.25, 
            color = I("black")) +
  scale_y_continuous(limits = c(0, 1), label = percent) + 
  theme_bw() + theme(legend.position = c(0.825, 0.825)) + 
  guides(color = guide_legend("", keywidth = 6, 
                          label.theme = 
                            element_text(face = "bold", size = 8,
                                         angle = 0)), linetype = "none") +
  labs(y = "Percent of Ninth Graders", 
       title = "Student Progression from 9th Grade Through College", 
       subtitle = "By Student Race/Ethnicity", x = "",
       caption = paste0("Sample: 2004-2005 Agency first-time ninth graders. \n", 
                  "Postsecondary enrollment outcomes from NSC matched records. \n",
                       "All other data from Agency administrative records."))


## ----A3 filterSample-----------------------------------------------------
## Step 1: Keep students in ninth grade cohorts you can observe persisting to 
## the second year of college AND are ever FRPL-eligible

plotdf <- filter(cgdata, chrt_ninth >= chrt_ninth_begin_persist_yr2 & 
                   chrt_ninth <= chrt_ninth_end_persist_yr2) %>% 
  filter(frpl_ever > 0)

# // Step 2: Create variables for the outcomes "regular diploma recipients", 
## "seamless transitioners" and "second year persisters"

plotdf$grad <- ifelse(!is.na(plotdf$chrt_grad) & plotdf$ontime_grad == 1, 1, 0)
plotdf$seamless_transitioners_any <- ifelse(plotdf$enrl_1oct_ninth_yr1_any == 1 &
                                                 plotdf$ontime_grad == 1, 1, 0)
plotdf$second_year_persisters = ifelse(plotdf$enrl_1oct_ninth_yr1_any == 1 &
                                             plotdf$enrl_1oct_ninth_yr2_any == 1 &
                                             plotdf$ontime_grad == 1, 1, 0)

# // Step 4: Create agency-level average outcomes
# // Calculate the mean of each outcome variable by race/ethnicity

progressRaceFRL <- plotdf %>% group_by(race_ethnicity) %>% 
  summarize(grad = mean(grad), 
            seameless_transitioners_any = mean(seamless_transitioners_any, na.rm=TRUE), 
            second_year_persisters = mean(second_year_persisters, na.rm=TRUE), 
            N = n())

# // Step 5: Reformat the data file so that one variable contains all the 
# outcomes of interest

progressRaceFRL %<>% filter(N >= 20)

## ----A3reshapeRecode-----------------------------------------------------

# // Step 6: Prepare to graph the results
## Reshape the data 
progressRaceFRL$cohort <- 1
progressRaceFRL <- progressRaceFRL %>% gather(key = outcome, 
                             value = measure, -N, -race_ethnicity)

## Recode the variables for plot friendly labels

progressRaceFRL$outcome[progressRaceFRL$outcome == "cohort"] <- 
  "Ninth Graders"
progressRaceFRL$outcome[progressRaceFRL$outcome == "grad"] <- 
  "On-time Graduates"
progressRaceFRL$outcome[progressRaceFRL$outcome == "seameless_transitioners_any"] <-
  "Seamless College Transitioner"
progressRaceFRL$outcome[progressRaceFRL$outcome == "second_year_persisters"] <- 
  "Second Year Persisters"

progressRaceFRL$subset <- ifelse(progressRaceFRL$race_ethnicity %in% c(1, 3, 5), 
                              TRUE, FALSE)
progressRaceFRL$race_ethnicity[progressRaceFRL$race_ethnicity == 1] <- "Black"
progressRaceFRL$race_ethnicity[progressRaceFRL$race_ethnicity == 2] <- "Asian"
progressRaceFRL$race_ethnicity[progressRaceFRL$race_ethnicity == 3] <- "Hispanic"
progressRaceFRL$race_ethnicity[progressRaceFRL$race_ethnicity == 4] <- "Native American"
progressRaceFRL$race_ethnicity[progressRaceFRL$race_ethnicity == 5] <- "White"
progressRaceFRL$race_ethnicity[progressRaceFRL$race_ethnicity == 6] <- "Multiple/Other"
progressRaceFRL$race_ethnicity <- as.character(zap_labels(progressRaceFRL$race_ethnicity))

## ----A3plot--------------------------------------------------------------
ggplot(progressRaceFRL[progressRaceFRL$subset,], 
       aes(x = outcome, y = measure, group = race_ethnicity, 
           color = race_ethnicity, linetype = race_ethnicity)) + 
  geom_line(size = 1.1) + geom_point(aes(group = 1), color = I("black")) +
  geom_text(aes(label = round(measure * 100, 1)), vjust = -0.8, hjust = -0.25, 
            color = I("black")) +
  scale_y_continuous(limits = c(0, 1), label = percent) + 
  theme_bw() + theme(legend.position = c(0.825, 0.825)) + 
  guides(color = guide_legend("", keywidth = 6, 
                              label.theme = element_text(face = "bold", 
                                                         size = 8,
                                                         angle = 0)), 
         linetype = "none") +
  labs(y = "Percent of Ninth Graders", 
       title = "Student Progression from 9th Grade Through College", 
       subtitle = paste0(c(
         "Among Students Qualifying for Free or Reduced Price Lunch \n", 
                           "By Student Race/Ethnicity")), 
       x = "",
       caption = paste0("Sample: 2004-2005 Agency first-time ninth graders. \n",
                   "Postsecondary enrollment outcomes from NSC matched records.\n", 
                        "All other data from Agency administrative records."))

## ----A4filterAndSortData-------------------------------------------------

#  // Step 1: Keep students in ninth grade cohorts you can observe persisting 
#  to the second year of college AND are included in the on-track analysis sample

plotdf <- filter(cgdata, chrt_ninth >= chrt_ninth_begin_persist_yr2 & 
                   chrt_ninth <= chrt_ninth_end_persist_yr2) %>% 
  filter(ontrack_sample == 1)

# // Step 2: Create variables for the outcomes "regular diploma recipients", 
# "seamless transitioners" and "second year persisters"

plotdf$grad <- ifelse(!is.na(plotdf$chrt_grad) & plotdf$ontime_grad ==1, 1, 0)
plotdf$seamless_transitioners_any <- as.numeric(plotdf$enrl_1oct_ninth_yr1_any == 1 &
                                                 plotdf$ontime_grad == 1)
plotdf$second_year_persisters = as.numeric(plotdf$enrl_1oct_ninth_yr1_any == 1 &
                                             plotdf$enrl_1oct_ninth_yr2_any == 1 &
                                             plotdf$ontime_grad == 1)

# // Step 3: Generate on track indicators that take into account students’ GPAs 
# upon completion of their first year in high school

plotdf$ot <- NA
plotdf$ot[plotdf$ontrack_endyr1 == 0] <- "Off-Track to Graduate"

# Check for correctness
plotdf$ot[plotdf$ontrack_endyr1 == 1 & plotdf$cum_gpa_yr1 < 3 & 
            !is.na(plotdf$cum_gpa_yr1)] <- "On-Track to Graduate, GPA < 3.0"
plotdf$ot[plotdf$ontrack_endyr1 == 1 & plotdf$cum_gpa_yr1 >= 3 & 
            !is.na(plotdf$cum_gpa_yr1)] <- "On-Track to Graduate, GPA >= 3.0"


## ----A4reshapeAndFormat--------------------------------------------------
#  // Step 4: Calculate aggregates for the Agency by on track status
progressTrack <- plotdf %>% group_by(ot) %>% 
  summarize(grad = mean(grad), 
            seameless_transitioners_any = mean(seamless_transitioners_any, na.rm=TRUE), 
            second_year_persisters = mean(second_year_persisters, na.rm=TRUE), 
            N = n())

# // Step 5: Reformat the data file so that one variable contains all the outcomes 
#  of interest
progressTrack$cohort <- 1
progressTrack <- progressTrack %>% gather(key = outcome, 
                             value = measure, -N, -ot)

progressTrack$outcome[progressTrack$outcome == "cohort"] <- "Ninth Graders"
progressTrack$outcome[progressTrack$outcome == "grad"] <- "On-time Graduates"
progressTrack$outcome[progressTrack$outcome == "seameless_transitioners_any"] <-
  "Seamless College Transitioner"
progressTrack$outcome[progressTrack$outcome == "second_year_persisters"] <- 
  "Second Year Persisters"


## ----A4plot--------------------------------------------------------------
# Annotate for direct labels
ann_txt <- data.frame(outcome = rep("Second Year Persisters", 3), 
                      measure = c(0.22, 0.55, 0.85), 
                      textlabel = c("Off-Track \nto Graduate", 
                                    "On-Track to Graduate,\n GPA < 3.0", 
                                    "On-Track to Graduate,\n GPA >= 3.0"))
ann_txt$ot <- ann_txt$textlabel

ggplot(progressTrack, 
       aes(x = outcome, y = measure, group = ot, 
           color = ot, linetype = ot)) + 
  geom_line(size = 1.1) + geom_point(aes(group = 1), color = I("black")) +
  geom_text(aes(label = round(measure * 100, 1)), vjust = -0.8, hjust = -0.25, 
            color = I("black")) +
  geom_text(data = ann_txt, aes(label = textlabel)) + 
  scale_y_continuous(limits = c(0, 1), label = percent) + 
  theme_bw() + theme(legend.position = c(0.825, 0.825)) + 
  scale_color_brewer(type = "qual", palette = 2) +
  guides(color = "none", 
         linetype = "none") +
  labs(y = "Percent of Ninth Graders", 
       title = "Student Progression from 9th Grade Through College", 
       subtitle = "By Course Credits and GPA after First High School Year", x = "",
       caption = paste0("Sample: 2004-2005 Agency first-time ninth graders. \n",
                "Postsecondary enrollment outcomes from NSC matched records. \n",
                 "All other data from Agency administrative records."))

## ----B1filterAndSort-----------------------------------------------------
#  // Step 1: Keep students in ninth grade cohorts you can observe graduating 
#  high school on time AND are part of the ontrack sample (attended the first 
#  semester of ninth grade and never transferred into or out of the system)

plotdf <- filter(cgdata, chrt_ninth >= chrt_ninth_begin_grad & 
                   chrt_ninth <= chrt_ninth_end_grad) %>% 
  filter(ontrack_sample == 1)

# // Step 2: Create variables for the outcomes "regular diploma recipients", 
#           "seamless transitioners" and "second year persisters"
plotdf$grad <- ifelse(!is.na(plotdf$chrt_grad) & plotdf$ontime_grad ==1, 1, 0)
plotdf$seamless_transitioners_any <- as.numeric(plotdf$enrl_1oct_ninth_yr1_any == 1 &
                                                 plotdf$ontime_grad == 1)
plotdf$second_year_persisters = as.numeric(plotdf$enrl_1oct_ninth_yr1_any == 1 &
                                             plotdf$enrl_1oct_ninth_yr2_any == 1 &
                                             plotdf$ontime_grad == 1)

# // Step 3: Generate on track indicators that take into account students’ GPAs 
# upon completion of their first year in high school

plotdf$ot <- NA
plotdf$ot[plotdf$ontrack_endyr1 == 0] <- "Off-Track to Graduate"
plotdf$ot[plotdf$ontrack_endyr1 == 1 & plotdf$cum_gpa_yr1 < 3 &
            !is.na(plotdf$cum_gpa_yr1)] <- "On-Track to Graduate, GPA < 3.0"
plotdf$ot[plotdf$ontrack_endyr1 == 1 & plotdf$cum_gpa_yr1 >= 3 &
            !is.na(plotdf$cum_gpa_yr1)] <- "On-Track to Graduate, GPA >= 3.0"


## ----B1reshape-----------------------------------------------------------
# // Step 4: Obtain the agency average for the key variables
# and obtain mean rates for each school and append the agency average

progressBars <- bind_rows(
  plotdf %>% group_by(ot) %>% tally() %>% ungroup %>% 
    mutate(count = sum(n), first_hs_name = "Agency Average"), 
  plotdf %>% group_by(first_hs_name, ot) %>% tally() %>% ungroup %>% 
    group_by(first_hs_name) %>%
    mutate(count = sum(n))
)

# replace first_hs_name = subinstr(first_hs_name, " High School", "", .)
progressBars$first_hs_name <- gsub(" High School", "", progressBars$first_hs_name)

# // Step 5: For students who are off-track upon completion of their first year 
#  of high school, convert the values to be negative for ease of 
#  visualization in the graph

progressBars$n[progressBars$ot == "Off-Track to Graduate"] <- 
  -progressBars$n[progressBars$ot == "Off-Track to Graduate"] 

## ----B1plot--------------------------------------------------------------
# // Step 6: Plot
ggplot(progressBars, aes(x = reorder(first_hs_name, n/count), 
                         y = n/count, group = ot)) + 
  geom_bar(aes(fill = ot), stat = 'identity') + 
  geom_text(aes(label = round(100* n/count, 0)), 
            position = position_stack(vjust=0.3)) + 
  theme_bw() + 
  scale_y_continuous(limits = c(-0.8,1), label = percent, 
                    name = "Percent of Ninth Graders", 
                    breaks = seq(-0.8, 1, 0.2)) + 
  scale_fill_brewer(name = "", type = "qual", palette = 6) + 
  theme(axis.text.x = element_text(angle = 30, color = "black", vjust = 0.5), 
        legend.position = c(0.15, 0.875)) +
  labs(title = "Proportion of Students On-Track to Graduate by School", 
       subtitle = "End of Ninth Grade On-Track Status \n By High School", x = "",
       caption = paste0("Sample: 2004-2005 and 2005-20065 Agency first-time ninth
                      graders. \n", 
              "Postsecondary enrollment outcomes from NSC matched records. \n",
                        "All other data from Agency administrative records."))


## ----B2filterAndSort-----------------------------------------------------
# // Step 1: Keep students in ninth grade cohorts you can observe graduating 
# high school on time AND are part of the ontrack sample (attended the first 
# semester of ninth grade and never transferred into or out of the system)

plotdf <- filter(cgdata, chrt_ninth >= chrt_ninth_begin_grad & 
                   chrt_ninth <= chrt_ninth_end_grad) %>% 
   filter(ontrack_sample == 1)

# // Step 2: Create variables for the outcomes "regular diploma recipients", 
#  "seamless transitioners" and "second year persisters"

plotdf$grad <- ifelse(!is.na(plotdf$chrt_grad) & plotdf$ontime_grad ==1, 1, 0)
plotdf$seamless_transitioners_any <- as.numeric(plotdf$enrl_1oct_ninth_yr1_any == 1 &
                                                 plotdf$ontime_grad == 1)
plotdf$second_year_persisters = as.numeric(plotdf$enrl_1oct_ninth_yr1_any == 1 &
                                             plotdf$enrl_1oct_ninth_yr2_any == 1 &
                                             plotdf$ontime_grad == 1)

# // Step 3: Generate on track indicators that take into account students’ GPAs 
# upon completion of their first year in high school

plotdf$ot <- NA
plotdf$ot[plotdf$ontrack_endyr1 == 0] <- "Off-Track to Graduate"
plotdf$ot[plotdf$ontrack_endyr1 == 1 & plotdf$cum_gpa_yr1 < 3 &
            !is.na(plotdf$cum_gpa_yr1)] <- "On-Track, GPA < 3.0"
plotdf$ot[plotdf$ontrack_endyr1 == 1 & plotdf$cum_gpa_yr1 >= 3 &
            !is.na(plotdf$cum_gpa_yr1)] <- "On-Track, GPA >= 3.0"

# // Step 4: Create indicators for students upon completion of their second 
#  year of high school

plotdf$ot_10 <- NA
plotdf$ot_10[plotdf$ontrack_endyr2 == 0] <- "Off-Track to Graduate"
plotdf$ot_10[plotdf$ontrack_endyr2 == 1 & plotdf$cum_gpa_yr2 < 3 &
               !is.na(plotdf$cum_gpa_yr2)] <- "On-Track, GPA < 3.0"
plotdf$ot_10[plotdf$ontrack_endyr2 == 1 & plotdf$cum_gpa_yr2 >= 3 &
               !is.na(plotdf$cum_gpa_yr2)] <- "On-Track, GPA >= 3.0"
plotdf$ot_10[plotdf$status_after_yr2 == 3 | plotdf$status_after_yr2 == 4] <-
  "Dropout/Disappear"

## ----B2reshapeAndFormat--------------------------------------------------
# // Step 5: Obtain mean rates for each school and append the agency average
onTrackBar <- plotdf %>% group_by(ot, ot_10) %>% 
  select(ot) %>% tally() %>% 
  ungroup %>% group_by(ot) %>%
  mutate(count = sum(n))


# // Step 6: For students who are off-track upon completion of their first year 
#  of high school, convert the values to be negative for ease of visualization 
#  in the graph

onTrackBar <- na.omit(onTrackBar) # drop missing
onTrackBar$n[onTrackBar$ot_10 == "Off-Track to Graduate"] <- 
  -onTrackBar$n[onTrackBar$ot_10 == "Off-Track to Graduate"] 
onTrackBar$n[onTrackBar$ot_10 == "Dropout/Disappear"] <- 
  -onTrackBar$n[onTrackBar$ot_10 == "Dropout/Disappear"] 


## ----B2plot--------------------------------------------------------------
ggplot(onTrackBar, aes(x = reorder(ot, n/count), 
                         y = n/count, group = ot_10)) + 
  geom_bar(aes(fill = ot_10), stat = 'identity') + 
  geom_text(aes(label = round(100* n/count, 1)), 
            position = position_stack(vjust=0.3)) + 
  theme_bw() + 
  scale_y_continuous(limits = c(-1, 1), label = percent, 
      name = "Percent of Tenth Grade Students \n by Ninth Grade Status") + 
  scale_fill_brewer(name = "End of Tenth Grade \n On-Track Status", 
                    type = "div", palette = 5) + 
  theme(axis.text.x = element_text(color = "black"), 
        legend.position = c(0.15, 0.825)) +
  labs(title = "Proportion of Students On-Track to Graduate by School", 
       x = "Ninth Grade On-Track Status",
       subtitle = "End of Ninth Grade On-Track Status \n By High School", 
       caption = paste0("Sample: 2004-2005 and 2005-2006 Agency first-time ninth
                        graders. \n", 
              "Postsecondary enrollment outcomes from NSC matched records. \n",
                        "All other data from Agency administrative records."))

## ----C1filterandSort-----------------------------------------------------

# // Step 1: Keep students in ninth grade cohorts you can observe 
#  graduating high school one year late

plotdf <- filter(cgdata, chrt_ninth >= chrt_ninth_begin_grad_late & 
                   chrt_ninth <= chrt_ninth_end_grad_late) 


## ----C1ReshapeCalculate--------------------------------------------------
# // Step 2: Obtain agency level high school and school level graduation 
#  rates

schoolLevel <- bind_rows(
  plotdf %>% group_by(first_hs_name) %>% 
    summarize(ontime_grad = mean(ontime_grad, na.rm=TRUE), 
              late_grad = mean(late_grad, na.rm=TRUE), 
              count = n()), 
  plotdf %>% ungroup %>%  
    summarize(first_hs_name = "Agency AVERAGE",
              ontime_grad = mean(ontime_grad, na.rm=TRUE), 
              late_grad = mean(late_grad, na.rm=TRUE), 
              count = n())
)

#  // Step 3: Reshape the data wide
schoolLevel <- schoolLevel %>% gather(key = outcome, 
                             value = measure, -count, -first_hs_name)
schoolLevel$first_hs_name <- gsub(" High School", "", schoolLevel$first_hs_name)

#  // Step 4: Recode variables for plotting

schoolLevel$outcome[schoolLevel$outcome == "ontime_grad"] <- "On-Time HS Graduate"
schoolLevel$outcome[schoolLevel$outcome == "late_grad"] <- "Graduate in 4+ Years"

## ----C1plot--------------------------------------------------------------
#  // Step 5: Plot
ggplot(schoolLevel, aes(x = reorder(first_hs_name, measure), y = measure, 
                        group = first_hs_name, fill = outcome)) + 
  geom_bar(aes(fill = outcome), stat = 'identity') + 
  geom_text(aes(label = round(100 * measure, 0)), 
            position = position_stack(vjust = 0.8)) + 
  theme_bw() + theme(panel.grid = element_blank(), axis.ticks.x = element_blank()) +
  scale_y_continuous(limits = c(0, 1), label = percent, 
                    name = "Percent of Ninth Graders") + 
  scale_fill_brewer(name = "", 
                    type = "qual", palette = 7) + 
  theme(axis.text.x = element_text(color = "black", angle = 30, vjust = 0.5), 
        legend.position = c(0.15, 0.825)) +
  labs(title = "High School Graduation Rates by High School", 
       x = "",
       caption = paste0("Sample: 2004-2005 Agency first-time ninth graders. \n", 
                        "Data from Agency administrative records."))

## ----C2filterandSort-----------------------------------------------------

# // Step 1: Keep students in ninth grade cohorts you can observe graduating 
# high school AND have non-missing eighth grade math scores

plotdf <- filter(cgdata, chrt_ninth >= chrt_ninth_begin_grad & 
                   chrt_ninth <= chrt_ninth_end_grad) %>% 
  filter(!is.na(test_math_8_std))


## ----C2reshapeandCalculate-----------------------------------------------
# // Step 2: Obtain agency and school level completion and prior achievement 
#  rates

schoolLevel <- bind_rows(
  plotdf %>% group_by(first_hs_name) %>% 
    summarize(ontime_grad = mean(ontime_grad, na.rm=TRUE), 
              std_score = mean(test_math_8_std, na.rm=TRUE), 
              count = n()), 
  plotdf %>% ungroup %>%  
    summarize(first_hs_name = "Agency AVERAGE",
              ontime_grad = mean(ontime_grad, na.rm=TRUE), 
              std_score = mean(test_math_8_std, na.rm=TRUE), 
              count = n())
  )

# // Step 3: Recode HS Name for display
schoolLevel$first_hs_name <- gsub(" High School", "", schoolLevel$first_hs_name)


## ----C2plot--------------------------------------------------------------
# // Step 4: Plot
ggplot(schoolLevel[schoolLevel$first_hs_name != "Agency AVERAGE", ], 
       aes(x = std_score, y = ontime_grad)) + 
  geom_vline(xintercept = as.numeric(schoolLevel[schoolLevel$first_hs_name == 
                                                   "Agency AVERAGE", "std_score"]), 
               linetype = 4, color = I("goldenrod"), size = 1.1) +
  geom_hline(yintercept = as.numeric(schoolLevel[schoolLevel$first_hs_name == 
                                                   "Agency AVERAGE", "ontime_grad"]), 
               linetype = 4, color = I("purple"), size = 1.1) +
  geom_point(size = I(2)) + 
  theme_bw() + theme(panel.grid = element_blank()) +
  coord_cartesian() +
  annotate(geom = "text", x = -.85, y = 0.025, 
           label = "Below average math scores & \n below average graduation rates", 
           size = I(2.5)) +
  annotate(geom = "text", x = .85, y = 0.025, 
           label = "Above average math scores & \n below average graduation rates", 
           size = I(2.5)) +
  annotate(geom = "text", x = .85, y = 0.975, 
           label = "Above average math scores & \n above average graduation rates", 
           size = I(2.5)) +
  annotate(geom = "text", x = -.85, y = 0.975, 
           label = "Below average math scores & \n above average graduation rates", 
           size = I(2.5)) + 
  annotate(geom = "text", x = .205, y = 0.025, 
           label = "Agency Average \n Test Score", 
           size = I(2.5), color = I("goldenrod")) + 
  annotate(geom = "text", x = .85, y = 0.61, 
           label = "Agency Average Graduation Rate", 
           size = I(2.5)) + 
  scale_x_continuous(limits = c(-1, 1), breaks = seq(-1, 1, 0.2)) + 
  scale_y_continuous(limits = c(0, 1), label = percent, 
                     name = "Percent of Ninth Graders", breaks = seq(0, 1, 0.1)) + 
  geom_text(aes(label = first_hs_name), nudge_y = 0.065, vjust = "top", size = I(4), 
            nudge_x = 0.01) +
  labs(title = "High School Graduation Rates by High School", 
       x = "Average 8th Grade Math Standardized Score",
       subtitle = "By Student Achievement Profile Upon High School Entry",
       caption = paste0("Sample: 2004-2005 through 2005-2006 Agency first-time ", 
                        "ninth graders with eighth grade math test scores. \n", 
                        "Data from Agency administrative records."))

## ----C3filterAndSort-----------------------------------------------------
# // Step 1: Keep students in ninth grade cohorts you can observe graduating 
# high school AND have non-missing eighth grade math scores

plotdf <- filter(cgdata, chrt_ninth >= chrt_ninth_begin_grad & 
                   chrt_ninth <= chrt_ninth_end_grad) %>% 
  filter(!is.na(test_math_8_std))


## ----C3reshapeAndRecode--------------------------------------------------
# // Step 2: btain the agency-level and school level high school graduation 
# rates by test score quartile

schoolLevel <- bind_rows(
  plotdf %>% group_by(qrt_8_math, first_hs_name) %>% 
    summarize(ontime_grad = mean(ontime_grad, na.rm=TRUE), 
              count = n()), 
  plotdf %>% ungroup %>% 
    summarize(first_hs_name = "Agency AVERAGE",
              qrt_8_math = 1,
              ontime_grad = mean(ontime_grad, na.rm=TRUE), 
              count = n())
)

# // Step 3: Recode HS Name for display
schoolLevel$first_hs_name <- gsub(" High School", "", schoolLevel$first_hs_name)


## ----C3plot--------------------------------------------------------------
# //  Step 4: Create plot template
#  Load library for arranging multiple plots into one
library(gridExtra); library(grid)

# Create a plot template that you can drop different data elements into
p2 <-  ggplot(schoolLevel[schoolLevel$qrt_8_math == 2 & 
                       schoolLevel$first_hs_name != "Agency AVERAGE", ], 
       aes(x = reorder(first_hs_name, ontime_grad), y = ontime_grad)) +
      geom_hline(yintercept =
                   as.numeric(schoolLevel$ontime_grad[schoolLevel$first_hs_name ==
                                                        "Agency AVERAGE"]),
               linetype = 2, size = I(1.1)) +
  geom_bar(stat = "identity", fill = "lightsteelblue4", color = I("black")) + 
    scale_y_continuous(limits = c(0,1), breaks = seq(0, 1, 0.2), 
                       expand = c(0, 0), label = percent) + 
    theme_bw() + 
    theme(panel.grid = element_blank(),
                       axis.text.x = element_text(angle = 30, color = "black", 
                                                  vjust = 0.5, size = 6),
          axis.ticks = element_blank(),
          axis.text.y = element_blank(), axis.line.y = element_blank(), 
          panel.border = element_blank()) +
    labs(y = "", x = "") + 
    geom_text(aes(label = round(ontime_grad * 100, 0)), vjust = -0.2) +
    expand_limits(y = 0, x = 0)

# Step 5: Create four plots, three using the template above and with the legend, 
# put these in a list

grobList <- list(
  ggplot(schoolLevel[schoolLevel$qrt_8_math == 1 & 
                       schoolLevel$first_hs_name != "Agency AVERAGE", ], 
       aes(x = reorder(first_hs_name, ontime_grad), y = ontime_grad)) + 
        geom_hline(yintercept =
                     schoolLevel$ontime_grad[schoolLevel$first_hs_name ==
                                                          "Agency AVERAGE"],
                   linetype = 2, size = I(1.1)) +
  geom_bar(stat = "identity", fill = "lightsteelblue4", color = I("black")) + 
    scale_y_continuous(limits = c(0,1), breaks = seq(0, 1, 0.2), 
                       expand = c(0, 0), label = percent) + 
    theme_bw() + 
    theme(panel.grid = element_blank(),
                       axis.text.x = element_text(angle = 30, size = 6,
                                                  color = "black", vjust = 0.5),
          axis.line.y = element_line(),
          axis.ticks.x = element_blank(),panel.border = element_blank()) +
    labs(y = "Percent of Ninth Graders", x = "") + 
    annotate(geom = "text", x = 5, 
    y = 0.025 + schoolLevel$ontime_grad[schoolLevel$first_hs_name == "Agency AVERAGE"], 
          label = "Agency Average") +
    geom_text(aes(label = round(ontime_grad * 100, 0)), vjust = -0.2) +
    expand_limits(y = 0, x = 0),
  p2, 
  # Use the %+% argument to pass a different data element to the p2 plot template
  p2 %+% schoolLevel[schoolLevel$qrt_8_math == 3 & 
                       schoolLevel$first_hs_name != "Agency AVERAGE", ],
  p2 %+% schoolLevel[schoolLevel$qrt_8_math == 4 & 
                       schoolLevel$first_hs_name != "Agency AVERAGE", ]
)

# Step 6: Apply a label to the bottom of each plot object
wrap <- mapply(arrangeGrob, grobList, 
               bottom = c("Bottom Quartile", "2nd Quartile", 
                          "3rd Quartile", "Top Quartile"), 
               SIMPLIFY=FALSE)

# Step 7: Draw the plot
grid.arrange(grobs=wrap, nrow=1, 
    top = "On-Time High School Graduation Rates \n by Prior Student Achievement", 
    bottom = textGrob(
      label = paste0("Sample: 2004-2005 through 2005-2006 Agency first-time",
      "ninth graders with eighth grade math test scores. \n",
      "Data from Agency administrative records."), 
      gp=gpar(fontsize=10,lineheight=1), just = 1, x = unit(0.99, "npc")))


## ----C4filterandSort-----------------------------------------------------
# // Step 1: Keep students in ninth grade cohorts you can observe graduating 
# high school AND have non-missing eighth grade math scores

plotdf <- filter(cgdata, chrt_ninth >= chrt_ninth_begin_grad & 
                   chrt_ninth <= chrt_ninth_end_grad) %>% 
  filter(!is.na(test_math_8_std))

plotdf$race <- as_factor(plotdf$race_ethnicity)

## ----C4reshapeRecode-----------------------------------------------------
# // Step 2: Obtain average on-time completion by race for agency
plotOne <- plotdf %>% group_by(race) %>% 
  summarize(ontimeGrad = mean(ontime_grad, na.rm = TRUE), 
            N = n()) %>% ungroup %>% 
  filter(N > 100)

# // Step 3: Obtain average on-time completion by race for agency by 
# math score quartile
plotTwo <- plotdf %>% group_by(race, qrt_8_math) %>% 
  summarize(ontimeGrad = mean(ontime_grad, na.rm=TRUE), 
            N = n()) %>% ungroup %>% 
  filter(race %in% c("Black", "Asian", "Hispanic", "White"))

# // Step 4: Make labels
plotTwo$qrt_label <- NA
plotTwo$qrt_label[plotTwo$qrt_8_math == 1] <- "Bottom Quartile"
plotTwo$qrt_label[plotTwo$qrt_8_math == 2] <- "2nd Quartile"
plotTwo$qrt_label[plotTwo$qrt_8_math == 3] <- "3rd Quartile"
plotTwo$qrt_label[plotTwo$qrt_8_math == 4] <- "Top Quartile"

plotTwo$qrt_label <- factor(plotTwo$qrt_label, 
                            ordered = TRUE, 
                            levels = c("Bottom Quartile", 
                                       "2nd Quartile", 
                                       "3rd Quartile", 
                                       "Top Quartile"))

## ----C4plot--------------------------------------------------------------
# // Step 5: Plot
ggplot(plotOne, aes( x= reorder(race, -N), y = ontimeGrad, fill = race)) + 
  geom_bar(stat = "identity", color = I("black")) + 
  scale_fill_brewer(type = "qual", palette = 4, guide = "none") + 
  geom_text(aes(label = round(ontimeGrad*100, 0)), vjust = -0.4) + 
  theme_bw() + theme(panel.grid = element_blank(), panel.border = element_blank(),
                     axis.line = element_line()) + 
  scale_y_continuous(limits = c(0, 1), expand = c(0, 0), 
                     breaks = seq(0, 1, 0.2), name = "Percent of Ninth Graders", 
                     label = percent) + 
  labs(x = "", title = "On-Time High School Graduation Rates",
       subtitle = "by Race", 
       caption = paste0(
         "Sample: 2004-2005 through 2005-2006 Agency first-time ninth graders. \n", 
         "All data from Agency administrative records."))

ggplot(plotTwo, aes( x = qrt_label, 
                     group= reorder(race, -N), y = ontimeGrad, fill = race)) + 
  geom_bar(stat = "identity", color = I("black"), position = "dodge") + 
  scale_fill_brewer(type = "qual", palette = 4) + 
  guides(fill = guide_legend(nrow=1, title = "", keywidth = 2)) +
  geom_text(aes(label = round(ontimeGrad*100, 0)), position = position_dodge(0.9), vjust = -0.3) + 
  theme_bw() + theme(panel.grid = element_blank(), panel.border = element_blank(),
                     axis.line = element_line(), legend.position = "top") + 
  scale_y_continuous(limits = c(0, 1), expand = c(0, 0), 
                     breaks = seq(0, 1, 0.2), name = "Percent of Ninth Graders", 
                     label = percent) + 
  labs(x = "", title = "On-Time High School Graduation Rates",
       subtitle = "by Race", 
       caption = paste0(
         "Sample: 2004-2005 through 2005-2006 Agency first-time ninth graders. \n ", 
         "All data from Agency administrative records."))

  

## ----C5filterandsort-----------------------------------------------------
# // Step 1: Keep students in ninth grade cohorts you can observe graduating 
# high school AND have non-missing eighth grade math scores AND are part of 
# the on-track sample
plotdf <- filter(cgdata, chrt_ninth >= chrt_ninth_begin_grad & 
                   chrt_ninth <= chrt_ninth_end_grad)  %>% 
  filter(!is.na(cum_gpa_yr1)) %>% 
  filter(ontrack_sample == 1)

# // Step 2: Recode status variables
plotdf$statusVar <- as_factor(plotdf$status_after_yr4)

# // Step 3: Generate on-track indicators that take into account students' 
# GPA upon completion of their first year in high school
plotdf$ontrackStatus <- NA
plotdf$ontrackStatus[plotdf$ontrack_endyr1 == 0] <- "Off-Track to Graduate"
plotdf$ontrackStatus[plotdf$ontrack_endyr1 == 1 & plotdf$cum_gpa_yr1 < 3 &
                       !is.na(plotdf$cum_gpa_yr1)] <- "On-Track, GPA < 3.0"
plotdf$ontrackStatus[plotdf$ontrack_endyr1 == 1 & plotdf$cum_gpa_yr1 >= 3 &
                       !is.na(plotdf$cum_gpa_yr1)] <- "On-Track, GPA >= 3.0"

## ----C5reshape-----------------------------------------------------------
# // Step 4: Create average outcomes by on-track status at the end of ninth grade
plotOne <- plotdf %>% group_by(ontrackStatus, statusVar) %>% 
  summarize(count = n()) %>% ungroup %>%
  group_by(ontrackStatus) %>% 
  mutate(sum = sum(count))

# // Step 5: Recode negative values for dropped out and disappeared

plotOne$count[plotOne$statusVar == "Dropped Out"] <- 
  -plotOne$count[plotOne$statusVar == "Dropped Out"]
plotOne$count[plotOne$statusVar == "Disappeared"] <- 
  -plotOne$count[plotOne$statusVar == "Disappeared"]  
plotOne$statusVar <- ordered(plotOne$statusVar, 
                             c("Graduated On-Time", "Enrolled, Not Graduated", 
                               "Disappeared", "Dropped Out"))

## ----C5plot--------------------------------------------------------------
ggplot(plotOne, aes(x = ontrackStatus, y = count/sum, fill = statusVar, 
                    group = statusVar)) + 
  geom_bar(stat="identity") + 
  geom_text(aes(label = round((count/sum) * 100, digits = 0))) + 
  scale_fill_brewer(type = "div", palette=7, direction = -1) + 
  geom_hline(yintercept = 0, size =1.1) + 
  scale_y_continuous(limits = c(-0.6, 1), label = percent, 
                     breaks = seq(-0.6, 1, 0.2), name = "Percent of Students") + 
  labs(x = "Ninth Grade On-Track Status", fill = "Status After Year Four", 
       title = "Enrollment Status After Four Years in High School", 
       subtitle = "By Course Credits and GPA after First Year of High School", 
       caption = paste0("Sample: 2004-2005 through 2005-2006 Agency", 
                        " first-time ninth graders. \n", 
                        "Students who transferred into or out of the agency are", 
                        " excluded from the sample. \n",
                        "All data from Agency administrative records.")) + 
  theme_classic() + theme(legend.position = c(0.8, 0.2),
                          axis.text = element_text(color = "black")) 

## ----D1filterAndSort-----------------------------------------------------
# // Step 2: Keep students in high school graduation cohorts you can observe 
# enrolling in college the fall after graduation
plotdf <- cgdata %>% filter(chrt_grad >= chrt_grad_begin & 
                              chrt_grad <= chrt_grad_end)

## ----D1reshapeAndRecode--------------------------------------------------
# // Step 3: Obtain the agency-level and school averages for seamless enrollment

chartData <- 
  bind_rows(plotdf %>% select(last_hs_name, enrl_1oct_grad_yr1_2yr,
                              enrl_1oct_grad_yr1_4yr, hs_diploma) %>%
              group_by(last_hs_name) %>% 
              summarize_all(funs(sum), na.rm=TRUE),
  plotdf %>% select(enrl_1oct_grad_yr1_2yr, enrl_1oct_grad_yr1_4yr, 
                               hs_diploma) %>% 
    summarize_all(funs(sum), na.rm=TRUE) %>% 
    mutate(last_hs_name = "Agency AVERAGE")
  )

# // Step 4: Reshape agency data for plotting
chartData <- chartData %>% gather(key = outcome, 
                             value = measure, -last_hs_name, -hs_diploma)

# // Step 5: Calculate rates
chartData %<>% group_by(last_hs_name) %>% 
  mutate(enroll_any = sum(measure) / hs_diploma[1]) %>% 
  ungroup

# // Step 6: Recode variables
chartData$last_hs_name <- gsub("High School", "", chartData$last_hs_name)
# Split levels
chartData$last_hs_name <- gsub(" ", "\n", chartData$last_hs_name)
chartData$outcome[chartData$outcome == "enrl_1oct_grad_yr1_2yr"] <- 
  "2-yr Seamless Enroller"
chartData$outcome[chartData$outcome == "enrl_1oct_grad_yr1_4yr"] <- 
  "4-yr Seamless Enroller"




## ----D1plot--------------------------------------------------------------
ggplot(chartData, aes(x = reorder(last_hs_name, enroll_any), 
                      y = measure/hs_diploma, 
                      fill = outcome, group = outcome)) + 
  geom_bar(stat = "identity", position = "stack", color = I("black")) + 
  geom_text(aes(label = round(100 * measure/hs_diploma)), 
            position = position_stack(vjust = 0.5)) +
  geom_text(aes(label = round(100 * enroll_any), y = enroll_any), 
            vjust = -0.5, color = I("gray60")) +
  theme_classic() + 
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.2), 
                     expand = c(0,0),
                     label = percent) + 
  scale_fill_brewer(name = "", type = "qual", palette = 1) +
  labs(x = "", y = "Percent of High School Graduates", 
       title = "College Enrollment by High School", 
       subtitle = "Seamless Enrollers", 
       caption = paste0(
         "Sample: 2007-2008 through 2008-2009 Agency graduates.",
         "Postsecondary enrollment outcomes from NSC matched records.", 
         "\n All other data from administrative records.")) + 
  theme(axis.text.x = element_text(angle = 30, vjust = 0.8, color = "black"), 
        legend.position = c(0.1, 0.8), axis.ticks.x = element_blank())



## ----D2filterAndSort-----------------------------------------------------
# // Step 1: Keep students in high school graduation cohorts you can observe 
# enrolling in college the fall after graduation

plotdf <- cgdata %>% filter(chrt_grad >= chrt_grad_begin & 
                              chrt_grad <= chrt_grad_end) %>% 
  select(sid, chrt_grad, enrl_1oct_grad_yr1_2yr, enrl_1oct_grad_yr1_4yr,
         enrl_1oct_grad_yr1_any, enrl_ever_w2_grad_2yr, enrl_ever_w2_grad_any,
         enrl_ever_w2_grad_4yr, hs_diploma, last_hs_code, last_hs_name)


## ----D2reshapeAndRecode--------------------------------------------------
# // Step 2: Create binary outcomes for late enrollers
plotdf$late_any <- ifelse(plotdf$enrl_1oct_grad_yr1_any == 0 & 
                            plotdf$enrl_ever_w2_grad_any == 1, 1, 0)
plotdf$late_4yr <- ifelse(plotdf$enrl_1oct_grad_yr1_any == 0 & 
                            plotdf$enrl_ever_w2_grad_4yr == 1, 1, 0)
plotdf$late_2yr <- ifelse(plotdf$enrl_1oct_grad_yr1_any == 0 & 
                            plotdf$enrl_ever_w2_grad_2yr == 1, 1, 0)

# // Step 3: Obtain the agency and school average for seamless and 
# delayed enrollment

chartData <-  bind_rows(
  plotdf %>% select(last_hs_name, enrl_1oct_grad_yr1_2yr, 
                              enrl_1oct_grad_yr1_4yr, late_4yr, late_2yr,
                              hs_diploma) %>%
              group_by(last_hs_name) %>% 
              summarize_all(funs(sum), na.rm=TRUE),
  plotdf %>% select(enrl_1oct_grad_yr1_2yr, 
                              enrl_1oct_grad_yr1_4yr, late_4yr, late_2yr,
                              hs_diploma) %>% 
    summarize_all(funs(sum), na.rm=TRUE) %>% 
    mutate(last_hs_name = "Agency AVERAGE")
  )

# // Step 4: Reshape for plotting

chartData <- chartData %>% gather(key = outcome, 
                             value = measure, -last_hs_name, -hs_diploma)

# // Step 5: Generate percentages of high school grads attending college. 

chartData %<>% group_by(last_hs_name) %>% 
  mutate(enroll_any = sum(measure) / hs_diploma[1]) %>% 
  ungroup

# // Step 6: Recode values for plotting
chartData$last_hs_name <- gsub("High School", "", chartData$last_hs_name)
chartData$last_hs_name <- gsub(" ", "\n", chartData$last_hs_name)
chartData$outcome[chartData$outcome == "enrl_1oct_grad_yr1_2yr"] <- "2-yr Seamless"
chartData$outcome[chartData$outcome == "enrl_1oct_grad_yr1_4yr"] <- "4-yr Seamless"
chartData$outcome[chartData$outcome == "late_2yr"] <- "2-yr Delayed"
chartData$outcome[chartData$outcome == "late_4yr"] <- "4-yr Delayed"


## ----D2Plot--------------------------------------------------------------
# // Step 7: Plot
ggplot(chartData, aes(x = reorder(last_hs_name, enroll_any), 
                      y = measure/hs_diploma, 
                      fill = outcome, group = outcome)) + 
  geom_bar(stat = "identity", position = "stack", color = I("black")) + 
  geom_text(aes(label = round(100 * measure/hs_diploma)), 
            position = position_stack(vjust = 0.5)) +
  geom_text(aes(label = round(100 * enroll_any), y = enroll_any), 
            vjust = -0.5, color = I("gray60")) +
  theme_classic() + 
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.2), 
                     expand = c(0,0),
                     label = percent) + 
  scale_fill_brewer(name = "", type = "seq", palette = "YlGnBu") +
  labs(x = "", y = "Percent of High School Graduates", 
       title = "College Enrollment by High School", 
       subtitle = "Seamless and Delayed Enrollers", 
       caption = paste0("Sample: 2007-2008 through 2008-2009 Agency graduates.",
                        "Postsecondary enrollment outcomes from NSC matched records.", 
                        "\n All other data from administrative records.")) + 
  theme(axis.text.x = element_text(angle = 30, vjust = 0.8, color = "black"), 
        legend.position = c(0.1, 0.8), axis.ticks.x = element_blank())


## ----D3FilterAndSort-----------------------------------------------------
# // Step 2: Keep students in high school graduation cohorts you can observe 
# enrolling in college the fall after graduation AND have non-missing eighth 
# grade math scores

plotdf <- cgdata %>% filter(chrt_grad >= chrt_grad_begin & 
                              chrt_grad <= chrt_grad_end) %>% 
  select(sid, chrt_grad, enrl_1oct_grad_yr1_any, test_math_8_std,
         last_hs_name) %>% 
  filter(!is.na(test_math_8_std))


## ----D3reshapeAndCalculate-----------------------------------------------
# // Step 2: Obtain agency-level college enrollment rate and prior 
# achievement score for dotted lines. Also get position of their labels

AGENCYLEVEL <- plotdf %>% 
  summarize(agency_mean_enroll = mean(enrl_1oct_grad_yr1_any, na.rm=TRUE), 
            agency_mean_test = mean(test_math_8_std)) %>% 
  as.data.frame

# // Step 3: Obtain school-level college enrollment rates and prior 
# achievement scores
chartData <- plotdf %>% group_by(last_hs_name) %>% 
  summarize(math_test = mean(test_math_8_std), 
            enroll_rate = mean(enrl_1oct_grad_yr1_any, na.rm=TRUE), 
            count = n())
# // Step 4: Shorten HS name for plotting
chartData$last_hs_name <- gsub("High School", "", chartData$last_hs_name)
chartData$last_hs_name <- gsub(" ", "\n", chartData$last_hs_name)

## ----D3plot--------------------------------------------------------------

# // Step 5: Plot
ggplot(chartData, aes(x = math_test, y = enroll_rate)) + 
  geom_point() + geom_text(aes(label = last_hs_name), 
                           nudge_x = -0.02, nudge_y= 0.02, angle = 30,
                           check_overlap = FALSE) +
  theme_classic() + 
  geom_hline(yintercept = AGENCYLEVEL$agency_mean_enroll, linetype = 2, 
             size = I(1.1), color = I("slateblue")) +
  geom_vline(xintercept = AGENCYLEVEL$agency_mean_test, linetype = 2, 
             size = I(1.1), color = I("goldenrod")) +
  scale_y_continuous(limits = c(0,1), breaks = seq(0, 1, 0.2), label = percent) + 
  scale_x_continuous(limits = c(-0.8, 1), breaks = seq(-0.8, 1, 0.2)) + 
  annotate(geom = "text", x = -.675, y = 0.025, 
           label = "Below average math scores & \n below average college enrollment", 
           size = I(2.5)) +
  annotate(geom = "text", x = .88, y = 0.025, 
           label = "Above average math scores & \n below average college enrollment", 
           size = I(2.5)) +
  annotate(geom = "text", x = .88, y = 0.975, 
           label = "Above average math scores & \n above average college enrollment", 
           size = I(2.5)) +
  annotate(geom = "text", x = -.675, y = 0.975, 
           label = "Below average math scores & \n above average college enrollment", 
           size = I(2.5)) + 
  annotate(geom = "text", x = .255, y = 0.125, 
           label = "Agency Average \n Test Score", 
           size = I(2.5), color = I("goldenrod")) + 
  annotate(geom = "text", x = -.675, y = 0.71, 
           label = "Agency Average \nCollege Enrollment Rate", 
           size = I(2.5)) + 
  labs(x = "Percent of High School Graduates", 
       y = "Average 8th Grade Math Standardized Score", 
       title = "College Enrollment Rates by Prior Student Achievement",
       subtitle = "Seamless Enrollers", 
       caption = paste0("Sample: 2007-2008 through 2008-2009 Agency graduates. Postsecondary", 
                        " enrollment outcomes from NSC matched records. \n ", 
                        "All other data from administrative records.")) + 
  theme(axis.text = element_text(color="black", size = 12))



## ----D4filterAndSort-----------------------------------------------------
# // Step 1: Keep students in high school graduation cohorts you can observe 
# enrolling in college the fall after graduation AND have non-missing eighth 
# grade math scores

plotdf <- cgdata %>% filter(chrt_grad >= chrt_grad_begin & 
                              chrt_grad <= chrt_grad_end) %>% 
  select(sid, chrt_grad, enrl_1oct_grad_yr1_any, qrt_8_math,
         last_hs_name) %>% 
  filter(!is.na(qrt_8_math))

## ----D4reshapeAndCalculate-----------------------------------------------
# // Step 2: Obtain the overall agency-level high school graduation rate for 
# dotted line along with the position of its label
AGENCYLEVEL <- plotdf %>% 
  summarize(agency_mean_enroll = mean(enrl_1oct_grad_yr1_any, na.rm=TRUE)) %>% 
  as.data.frame

# // Step 5: Obtain school-level and agency level college enrollment rates by 
# test score quartile and append the agency-level enrollment rates 
# by quartile
chartData <- bind_rows(
  plotdf %>% group_by(last_hs_name, qrt_8_math) %>% 
  summarize(enroll_rate = mean(enrl_1oct_grad_yr1_any, na.rm=TRUE), 
            count = n()),
  plotdf %>% group_by(qrt_8_math) %>% 
  summarize(enroll_rate = mean(enrl_1oct_grad_yr1_any, na.rm=TRUE), 
            count = n(), 
            last_hs_name = "Agency AVERAGE")
)

# // Step 6: Recode HS Name for plotting
chartData$last_hs_name <- gsub("High School", "", chartData$last_hs_name)
# chartData$last_hs_name <- gsub(" ", "\n", chartData$last_hs_name)

## ----D4plot--------------------------------------------------------------
# // Step 7: Make plot for first panel with legend and labels

p1 <- ggplot(chartData[chartData$qrt_8_math == 1, ], 
       aes(x = reorder(last_hs_name, enroll_rate), y = enroll_rate)) + 
        geom_hline(yintercept = as.numeric(AGENCYLEVEL$agency_mean_enroll),
               linetype = 2, size = I(1.1)) +
  geom_bar(stat = "identity", fill = "lightsteelblue4", color = I("black")) + 
    scale_y_continuous(limits = c(0,1), breaks = seq(0, 1, 0.2), 
                       expand = c(0, 0), label = percent) + 
    theme_bw() + 
  annotate(geom = "text", x = 6, y = 0.775, label = "Agency Average") +
    theme(panel.grid = element_blank(),
                       axis.text.x = element_text(angle = 30, size=6,
                                                  color = "black", vjust = 0.5),
          axis.line.y = element_line(),  axis.line.x = element_line(),
          axis.ticks.x = element_blank(),panel.border = element_blank()) +
    labs(y = "Percent of Ninth Graders", x = "") + 
    geom_text(aes(label = round(enroll_rate * 100, 0)), vjust = -0.2) +
    expand_limits(y = 0, x = 0)

# // Step 8 : Make Template for following 3 panels with fewer legends and 
# labels

p2 <-  ggplot(chartData[chartData$qrt_8_math == 2, ], 
       aes(x = reorder(last_hs_name, enroll_rate), y = enroll_rate)) +
      geom_hline(yintercept = as.numeric(AGENCYLEVEL$agency_mean_enroll),
               linetype = 2, size = I(1.1)) +
  geom_bar(stat = "identity", fill = "lightsteelblue4", color = I("black")) + 
    scale_y_continuous(limits = c(0,1), breaks = seq(0, 1, 0.2), 
                       expand = c(0, 0), label = percent) + 
    theme_bw() + 
    theme(panel.grid = element_blank(),
                       axis.text.x = element_text(angle = 30, size=6,
                                                  color = "black", vjust = 0.5),
          axis.ticks = element_blank(), axis.line.x = element_line(),
          axis.text.y = element_blank(), axis.line.y = element_blank(), 
          panel.border = element_blank()) +
    labs(y = "", x = "") + 
    geom_text(aes(label = round(enroll_rate * 100, 0)), vjust = -0.2) +
    expand_limits(y = 0, x = 0)

# schoolLevel$order <-

# // Step 9: Combine first plot with template applied to quartiles 2, 3, and 4
# Use %+% operator to replace the data in the plot template with another data
# set
grobList <- list(
  p1,
  p2, 
  p2 %+% chartData[chartData$qrt_8_math == 3, ],
  p2 %+% chartData[chartData$qrt_8_math == 4, ]
)

# // Step 10: Apply quartile labels to each panel
wrap <- mapply(arrangeGrob, grobList, 
               bottom = c("Bottom Quartile", "2nd Quartile", 
                          "3rd Quartile", "Top Quartile"), 
               SIMPLIFY=FALSE)

# // Step 11: Plot with labels
grid.arrange(grobs=wrap, nrow=1, 
             top = paste0("College Enrollment Rates ", 
                          "\n by Prior Student Achievement, Seamless Enrollers Only"), 
             bottom = textGrob(label = paste0(
               "Sample: 2007-2008 through 2008-2009.",
               "Agency graduates with eighth grade math scores. \n", 
               "Postsecondary enrollment outcomes from NSC matched records. \n", 
               "All other data from Agency administrative records."
               ), gp=gpar(fontsize=10,lineheight=1), just = 1, 
               x = unit(0.99, "npc")))

## ----D5filterAndSort-----------------------------------------------------
# // Step 1: Keep students in high school graduation cohorts you can observe 
# enrolling in college the fall after graduation

plotdf <- cgdata %>% filter(chrt_grad >= chrt_grad_begin & 
                              chrt_grad <= chrt_grad_end) %>% 
  select(sid, chrt_grad, race_ethnicity, highly_qualified, 
         enrl_1oct_grad_yr1_any, enrl_1oct_grad_yr1_4yr, enrl_1oct_grad_yr1_2yr)

# Use race_ethnicity as a labeled factor for plotting
plotdf$race_ethnicity <- as_factor(plotdf$race_ethnicity)
# // Step 2: Take total of all students in sample
totalCount <- nrow(plotdf)

## ----D5recodeAndReshape--------------------------------------------------
# // Step 3: Create "undermatch" outcomes
plotdf$no_college <- ifelse(plotdf$enrl_1oct_grad_yr1_any == 0, 1, 0)
plotdf$enrl_2yr <- ifelse(plotdf$enrl_1oct_grad_yr1_2yr == 1, 1, 0)
plotdf$enrl_4yr <- ifelse(plotdf$enrl_1oct_grad_yr1_4yr == 1, 1, 0)

# // Step 3: Create agency-level outcomes for total undermatching rates
agencyLevel <- plotdf %>% filter(highly_qualified == 1) %>% 
  summarize(no_college = mean(no_college, na.rm=TRUE), 
            enrl_2yr = mean(enrl_2yr, na.rm=TRUE), 
            enrl_4yr = mean(enrl_4yr, na.rm=TRUE), 
            total_count = n(), 
            race_ethnicity = "TOTAL")

# // Step 4: Create race/ethnicity-level outcomes for undermatching rates by 
# race/ethnicity
chartData <- plotdf %>% filter(highly_qualified == 1) %>% 
  group_by(race_ethnicity) %>%
  summarize(no_college = mean(no_college, na.rm=TRUE), 
            enrl_2yr = mean(enrl_2yr, na.rm=TRUE), 
            enrl_4yr = mean(enrl_4yr, na.rm=TRUE), 
            total_count = n())

chartData <- bind_rows(chartData, agencyLevel)

# // Step 5: Convert negative outcomes to negative values and reshape 
# data for plotting
chartData$no_college <- -chartData$no_college
chartData$enrl_2yr <- -chartData$enrl_2yr
chartData <- chartData %>% gather(key = outcome, value = measure, 
                                  -race_ethnicity, -total_count)

# // Step 7: Convert to percentages and relabel ethnicities for plot labels
chartData$groupPer <- round(100 * chartData$total_count/totalCount)
chartData$race_ethnicity[chartData$race_ethnicity == "Black"] <- "African American"
chartData$race_ethnicity[chartData$race_ethnicity == "Asian"] <- "Asian American"
chartData$race_ethnicity[chartData$race_ethnicity == "Hispanic"] <- "Hispanic American"
chartData$race_ethnicity[chartData$race_ethnicity == "TOTAL"] <- "Total"

chartData$label <- paste0(chartData$race_ethnicity, "\n ", 
                          chartData$groupPer, "% of Graduates")

chartData %<>% filter(chartData$race_ethnicity != "Multiple/Other")

# // Step 8: Create a label variable to label the outcomes on the plot
chartData$outcomeLabel <- NA
chartData$outcomeLabel[chartData$outcome == "no_college"] <- "Not Enrolled in College"
chartData$outcomeLabel[chartData$outcome == "enrl_2yr"] <- "Enrolled at 2-Yr College"
chartData$outcomeLabel[chartData$outcome == "enrl_4yr"] <- "Enrolled at 4-Yr College"

# // Step 9: Order the factor to plot in the correct order
chartData$outcomeLabel <- factor(chartData$outcomeLabel, 
                                 ordered = TRUE, 
                                 levels = c("Enrolled at 4-Yr College", 
                                            "Not Enrolled in College", 
                                            "Enrolled at 2-Yr College"))


## ----D5plot--------------------------------------------------------------
#// Step 10: Create a caption to put under the figure

myCap <- paste0(
        "Sample: 2007-2008 through 2008-2009 Agency first-time ninth graders. ", 
        "Students who transferred into or out of\nAgency are excluded ", 
        "from the sample. Eligibility to attend a public four-year university ", 
        "is based on students' cumulative GPA\nand ACT/SAT scores. ",
        "Sample includes 30 African American, 82 Asian American students, ",
        "53 Hispanic, \nand 198 White students. ", 
        "Post-secondary enrollment data are from NSC matched records.")

# // Step 11: Plot

ggplot(chartData, aes(x = reorder(label, total_count), y = measure, 
                      group = outcomeLabel, 
                      fill = outcomeLabel)) + 
  geom_bar(position = 'stack', stat = 'identity', color = I("black")) + 
  geom_hline(yintercept = 0) + 
  geom_text(aes(label = round(measure * 100, 0)), 
            position=position_stack(vjust = 0.85)) +
  scale_y_continuous(limits = c(-.25, 1), breaks = seq(-.25, 1, 0.2), 
                     label = percent) +
  theme_classic() + 
  guides(fill = guide_legend(nrow=1, title = "", keywidth = 2)) +
  scale_fill_brewer(type = "qual", palette = 2, direction = -1) + 
  theme(legend.position = "top", axis.text = element_text(color = "black"), 
        plot.caption = element_text(hjust = 0, size = 8), 
        plot.title = element_text(hjust = 0.5), 
        plot.subtitle = element_text(hjust = 0.5)) + 
  labs(x = "", y = "Percent of Highly-Qualified Graduates", 
       title = "Rates of Highly Qualified Students Attending College, by Race", 
       subtitle = "Among Graduates Eligible to Attend Four-Year Universities", 
       caption = myCap)


## ----D6filterAndSort-----------------------------------------------------
# // Step 1: Keep students in high school graduation cohorts you can observe 
# enrolling in college the fall after graduation AND have non-missing eighth 
# grade test scores AND non-missing FRPL status

plotdf <- cgdata %>% filter(chrt_grad >= chrt_grad_begin & 
                              chrt_grad <= chrt_grad_end) %>% 
  select(sid, chrt_grad, race_ethnicity, test_math_8, frpl_ever,
         enrl_1oct_grad_yr1_any, last_hs_code) %>% 
  filter(!is.na(frpl_ever) & !is.na(test_math_8)) %>% 
  filter(race_ethnicity %in% c(1, 3, 5) & !is.na(race_ethnicity)) %>%
  filter(!is.na(enrl_1oct_grad_yr1_any))

# // Step 2: Recode variables and create cluster variable
plotdf$race_ethnicity <- as_factor(plotdf$race_ethnicity)
plotdf$race_ethnicity <- relevel(plotdf$race_ethnicity, ref = "White")
# // Step 3: Create a unique identifier for clustering standard errors 
# at the cohort/school level
plotdf$cluster_var <- paste(plotdf$chrt_grad, plotdf$last_hs_code, sep = "-")

## ----D6modelAndReshape---------------------------------------------------
# Load the broom library to make working with model coefficients simple 
# and uniform
library(broom)

# // Step 4: Estimate the unadjusted and adjusted differences in college 
# enrollment between Latino and white students and between black and white 
# students 

# Estimate unadjusted enrollment gap
#  Fit the model
mod1 <- lm(enrl_1oct_grad_yr1_any ~ race_ethnicity, data = plotdf)
#  Extract the coefficients
betas_unadj <- tidy(mod1)
#  Get the clustered variance-covariance matrix
#  Use the get_CL_vcov function from the functions.R script
clusterSE <- get_CL_vcov(mod1, plotdf$cluster_var)
#  Get the clustered standard errors and combine with the betas
betas_unadj$std.error <- sqrt(diag(clusterSE))
betas_unadj <- betas_unadj[, 1:3]
#  Label
betas_unadj$model <- "Unadjusted enrollment gap"

# Estimate enrollment gap adjusting for prior achievement
mod2 <- lm(enrl_1oct_grad_yr1_any ~ race_ethnicity + test_math_8, data = plotdf)
betas_adj_prior_ach <- tidy(mod2)
clusterSE <- get_CL_vcov(mod2, plotdf$cluster_var)
betas_adj_prior_ach$std.error <- sqrt(diag(clusterSE))
betas_adj_prior_ach <- betas_adj_prior_ach[, 1:3]
betas_adj_prior_ach$model <- "Gap adjusted for prior achievement"

# Estimate enrollment gap adjusting for frpl status
plotdf$frpl_ever <- ifelse(plotdf$frpl_ever > 0, 1, 0)
mod3 <- lm(enrl_1oct_grad_yr1_any ~ race_ethnicity + frpl_ever, data = plotdf)
betas_adj_frpl <- tidy(mod3)
clusterSE <- get_CL_vcov(mod3, plotdf$cluster_var)
betas_adj_frpl$std.error <- sqrt(diag(clusterSE))
betas_adj_frpl <- betas_adj_frpl[, 1:3]
betas_adj_frpl$model <- "Gap adjusted for FRPL status"

# Estimate enrollment gap adjusting for prior achievement and frpl status
mod4 <- lm(enrl_1oct_grad_yr1_any ~ race_ethnicity + frpl_ever + test_math_8, 
           data = plotdf)
betas_adj_frpl_prior <- tidy(mod4)
clusterSE <- get_CL_vcov(mod4, plotdf$cluster_var)
betas_adj_frpl_prior$std.error <- sqrt(diag(clusterSE))
betas_adj_frpl_prior <- betas_adj_frpl_prior[, 1:3]
betas_adj_frpl_prior$model <- "Gap adjusted for prior achievement & FRPL status"

# // Step 5. Transform the regression coefficients to a data object for plotting
chartData <- bind_rows(betas_unadj, betas_adj_frpl, betas_adj_prior_ach, 
                    betas_adj_frpl_prior)
# Cleanup workspace
rm(plotdf, betas_unadj, betas_adj_frpl, betas_adj_frpl_prior, 
   betas_adj_prior_ach)

## ----D6plot--------------------------------------------------------------
# // Step 6. Plot
ggplot(chartData[chartData$term == "race_ethnicityHispanic", ],
       aes(x = model, y = -estimate, fill = model)) + 
  geom_bar(stat = 'identity', color = I("black")) + 
  scale_fill_brewer(type = "seq", palette = 8) +
  geom_hline(yintercept = 0) + 
  guides(fill = guide_legend("", keywidth = 6, nrow = 2)) + 
  geom_text(aes(label = round(100 * -estimate, 0)), vjust = -0.3) +
  scale_y_continuous(limits = c(-0.2, 0.5), breaks = seq(-0.2, 0.5, 0.1), 
                     label = percent, name = "Percentage Points") + 
  theme_classic() + theme(legend.position = "bottom", axis.text.x = element_blank(), 
                          axis.ticks.x = element_blank()) + 
  labs(title = paste0("Differences in Rates of College Enrollment", 
                      " \nBetween Latino and White High School Graduates"), 
       x = "",
       caption = paste0(
                  "Sample: 2007-2008 through 2008-2009 high school graduates. \n",
                  "Postsecondary enrollment outcomes from NSC matched records. \n",
                  "All other data from Agency administrative records.")
       )


## ----D7filterAndSOrt-----------------------------------------------------
# // Step 1: Keep students in high school graduation cohorts you can observe 
# enrolling in college the fall after graduation AND have non-missing eighth 
# grade test scores
plotdf <- cgdata %>% filter(chrt_grad >= chrt_grad_begin & 
                              chrt_grad <= chrt_grad_end) %>% 
  select(sid, chrt_grad, qrt_8_math, hs_diploma,
         enrl_1oct_grad_yr1_any, last_hs_name) %>% 
  filter(!is.na(qrt_8_math)) %>% 
  filter(!is.na(enrl_1oct_grad_yr1_any))

## ----D7reshapeAndCalculate-----------------------------------------------
# // Step 2: Create agency- and school-level average outcomes for each quartile

chartData <- plotdf %>% group_by(last_hs_name, qrt_8_math) %>% 
  summarize(enroll_count = sum(enrl_1oct_grad_yr1_any),
            diploma_count = sum(hs_diploma)) %>% 
  mutate(pct_enrl = enroll_count/diploma_count)

agencyData <- plotdf %>% group_by(qrt_8_math) %>% 
  summarize(enroll_count = sum(enrl_1oct_grad_yr1_any),
            diploma_count = sum(hs_diploma)) %>% 
  mutate(pct_enrl = enroll_count/diploma_count) %>% as.data.frame


## ----D7plot--------------------------------------------------------------
# // Step 3: Plot

ggplot(chartData, aes(x = factor(qrt_8_math), y = pct_enrl)) + 
  geom_point(aes(size = diploma_count), shape = 1) + 
  scale_size(range = c(3, 12), breaks = seq(0, 350, 75)) + 
  geom_point(data=agencyData, aes(x = factor(qrt_8_math), 
                                  y = pct_enrl, size = NULL), 
             color = I("red"), size = I(4)) +
  theme_classic() + 
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.2), 
                     label = percent) +
  labs(y = "Percent of High School Graduates", 
       x = "Quartile of Prior Achievement", 
       title = "College Enrollment Rates Among High School Gradautes", 
       subtitle = "Within Quartile of Prior Achievement, by High School", 
        caption = paste0(
                  "Sample: 2007-2008 through 2008-2009 high school graduates. \n", 
                  "Postsecondary enrollment outcomes from NSC matched records. \n", 
                  "All other data from Agency administrative records.")
       )


## ----D8filterAndSort-----------------------------------------------------
# // Step 1: Keep students in high school graduation cohorts you can observe 
# enrolling in college the fall after graduation AND are highy qualified

plotdf <- cgdata %>% filter(chrt_grad >= chrt_grad_begin & 
                              chrt_grad <= chrt_grad_begin) %>% 
  select(sid, chrt_grad, highly_qualified, first_college_opeid_4yr,
         enrl_1oct_grad_yr1_any, enrl_1oct_grad_yr1_4yr, enrl_1oct_grad_yr1_2yr) %>% 
  filter(!is.na(highly_qualified)) %>% 
  filter(highly_qualified ==1 )

# // Step 2: Link the analysis file with the college selectivity table to obtain 
# the selectivity level for each college. Use this selectivity information to 
# create college enrollment indicator variables for each college selectivity 
# level. This script assumes that there are 5 levels of selectivity, as in 
# Barron’s College Rankings—Most Competitive (1), Highly Competitive (2), 
# Very Competitive (3), Competitive (4), Least Competitive (5)—as well as a 
# category for colleges without assigned selectivity (assumed to be not 
# competitive).

# Read in college selectivity data
tmpfileName <- "analysis/college_selectivity.dta"
con <- unz(description = "data/analysis.zip", filename = tmpfileName, 
           open = "rb")
coll_select <- read_stata(con) # read data in the data subdirectory
close(con)

# Merge on to subset from above
plotdf <- left_join(plotdf, coll_select, 
                    by = c("first_college_opeid_4yr" = "college_id"))
# Filter out
plotdf %<>% filter(!(first_college_opeid_4yr == "" & enrl_1oct_grad_yr1_4yr == 1))

## ----D8recodeAndReshape--------------------------------------------------
# // Step 4. Create the undermatch outcomes
plotdf$rank[is.na(plotdf$rank)] <- 6
plotdf$outcome <- NA
plotdf$outcome[plotdf$enrl_1oct_grad_yr1_any == 0] <- "No college"
plotdf$outcome[plotdf$enrl_1oct_grad_yr1_2yr == 1] <- "Two year college"
plotdf$outcome[is.na(plotdf$outcome) & 
                 plotdf$enrl_1oct_grad_yr1_any == 1 & (plotdf$rank > 4)] <- "Undermatch"
plotdf$outcome[plotdf$enrl_1oct_grad_yr1_any == 1 & plotdf$rank <= 4] <- "Match"

# // Step 5 Create agency-average undermatch outcomes and transform them into % terms
chartData <- plotdf %>% group_by(outcome) %>% 
  summarize(count = n()) %>% ungroup %>% 
  mutate(totalCount = sum(count))


chartData %<>% filter(outcome != "Match") %>% 
  arrange(count)


## ----D8plot--------------------------------------------------------------
# // Step 6: Plot

ggplot(arrange(chartData, -count), 
       aes(x = factor(1), fill = outcome, y = count/totalCount)) +
  geom_bar(stat = 'identity', position = "stack", color = I("black")) +
  scale_fill_brewer(type = "qual", palette= 3, direction=1) +
  guides(fill = guide_legend("", keywidth = 6, nrow = 2)) + 
  geom_text(aes(label = round(100 * count/totalCount, 1)), 
            position = position_stack(vjust = 0.5)) +
  scale_y_continuous(limits = c(0, 0.40), breaks = seq(0, 0.4, 0.1), 
                     label = percent, name = "Percent of High School Graduates") + 
  theme_classic() + theme(legend.position = "bottom", axis.text.x = element_blank(), 
                          axis.ticks.x = element_blank()) + 
  labs(title = "Undermatch Rates by Agency", 
       subtitle = "Among Highly Qualified High School Graduates",
       x = "",
       caption = paste0(
                "Sample: 2007-2008 through 2008-2009 high school graduates. \n",
                 "Postsecondary enrollment outcomes from NSC matched records. \n", 
                "All other data from Agency administrative records."))


## ----E1filterAndSort-----------------------------------------------------
# // Step 1: Keep students in high school graduation cohorts you can observe 
# enrolling in college the fall after graduation

plotdf <- cgdata %>% filter(chrt_grad >= chrt_grad_begin & 
                              chrt_grad <= chrt_grad_end) %>% 
  select(sid, chrt_grad, enrl_1oct_grad_yr1_2yr, enrl_1oct_grad_yr1_4yr,
         enrl_1oct_grad_yr1_any, enrl_grad_persist_any, 
         enrl_grad_persist_2yr, enrl_grad_persist_4yr, last_hs_name, 
         enrl_ever_w2_grad_any) 

# // Step 2: Rename and recode for simplicity
plotdf$groupVar <- NA
plotdf$groupVar[plotdf$enrl_1oct_grad_yr1_2yr == 1] <- "2-year College"
plotdf$groupVar[plotdf$enrl_1oct_grad_yr1_4yr == 1] <- "4-year College"

## ----E1ReshapeandRecode--------------------------------------------------
# // Step 3: Obtain the agency-level average for persistence and enrollment
agencyData <- plotdf %>% group_by(groupVar) %>%
  summarize(persistCount = sum(enrl_grad_persist_any, na.rm=TRUE),
            totalCount = n()) %>% 
  ungroup %>% 
  mutate(total = sum(persistCount)) %>% 
  mutate(persistRate = persistCount / totalCount, 
         last_hs_name = "Agency AVERAGE")

# // Step 4: Obtain the school-level average for persistence and enrollment
schoolData <- plotdf %>% group_by(groupVar, last_hs_name) %>%
  summarize(persistCount = sum(enrl_grad_persist_any, na.rm=TRUE), 
            totalCount = n()) %>% 
  ungroup %>% group_by(last_hs_name) %>%
  mutate(total = sum(persistCount)) %>% 
  mutate(persistRate = persistCount / totalCount)

# Combine for chart
chartData <- bind_rows(agencyData, schoolData)
# // Step 5: Recode variables for plotting 
chartData$last_hs_name <- gsub(" High School", "", chartData$last_hs_name)

# // STep 6: Filter rows out with missing values or small cell sizes
chartData <- na.omit(chartData)
chartData <- filter(chartData, totalCount > 20)

# // Step 7: Calculate rank for plot order
chartData <- chartData %>% group_by(groupVar) %>% 
  mutate(order = min_rank(-persistRate))
chartData %<>% arrange(last_hs_name)

# Make ranks the same for 2 and 4 year colleges
chartData$order[chartData$groupVar == "2-year College"] <-
  chartData$order[chartData$groupVar == "4-year College"] 
# Conver to a factor and order for ggplot purposes
chartData$groupVar <- factor(chartData$groupVar)
chartData$groupVar <- relevel(chartData$groupVar, ref = "4-year College")


## ----E1plot--------------------------------------------------------------
# // Step 8: Plot
ggplot(chartData, aes(x = reorder(last_hs_name, -order), 
                                      group = groupVar, 
                      y = persistRate, fill = groupVar, 
                      color = I("black"))) + 
  geom_bar(stat = 'identity', position = 'dodge') +
  geom_text(aes(label = round(persistRate * 100, 0)), 
            position = position_dodge(0.9), vjust = -0.4) +
  scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.2), 
                     name = "% Of Seamless Enrollers", 
                     expand = c(0,0), label = percent) +
  theme_classic() + 
  guides(fill = guide_legend("", keywidth = 3, nrow = 2)) + 
  theme(axis.text.x = element_text(angle = 30, vjust = 0.5, color = "black"), 
        legend.position = c(0.1, 0.925), axis.ticks.x = element_blank(),
        legend.key = element_rect(color = "black")) +
  scale_fill_brewer(type = "div", palette = 2) + 
  labs(x = "", 
       title = "College Persistence by High School, at Any College", 
       subtitle = "Seamless Enrollers by Type of College", 
       caption = paste0(
         "Sample: 2007-2008 through 2008-2009 Agency high school graduates.\n",
                 "Postsecondary enrollment outcomes from NSC matched records. \n", 
                  "All other data from agency administrative records"))


## ----E2filterAndSort-----------------------------------------------------
# // Step 1: Keep students in high school graduation cohorts you can observe 
# enrolling in college the fall after graduation

plotdf <- cgdata %>% filter(chrt_grad >= chrt_grad_begin & 
                              chrt_grad <= chrt_grad_end) %>% 
  select(sid, chrt_grad, enrl_1oct_grad_yr1_2yr, enrl_1oct_grad_yr1_4yr,
         enrl_1oct_grad_yr1_any, enrl_1oct_grad_yr2_2yr, enrl_1oct_grad_yr2_4yr,
         enrl_1oct_grad_yr2_any, enrl_grad_persist_any, 
         enrl_grad_persist_2yr, enrl_grad_persist_4yr, last_hs_name) 


## ----E2recodeAndReshape--------------------------------------------------
# Clean up missing data for binary recoding
plotdf$enrl_grad_persist_4yr <- zeroNA(plotdf$enrl_grad_persist_4yr)
plotdf$enrl_grad_persist_2yr <- zeroNA(plotdf$enrl_grad_persist_2yr)
plotdf$enrl_1oct_grad_yr1_2yr <- zeroNA(plotdf$enrl_1oct_grad_yr1_2yr)
plotdf$enrl_1oct_grad_yr1_4yr <- zeroNA(plotdf$enrl_1oct_grad_yr1_4yr)

# // Step 2: Create binary outcomes for enrollers who switch from 4-yr to 2-yr, 
# or vice versa and recode variables
plotdf$persist_pattern <- "Not persisting"
plotdf$persist_pattern[plotdf$enrl_grad_persist_4yr == 1 &
                         !is.na(plotdf$chrt_grad)] <- "Persisted at 4-Year College"
plotdf$persist_pattern[plotdf$enrl_grad_persist_2yr ==1 &
                         !is.na(plotdf$chrt_grad)] <- "Persisted at 2-Year College"
plotdf$persist_pattern[plotdf$enrl_1oct_grad_yr1_4yr == 1 & 
                        plotdf$enrl_1oct_grad_yr2_2yr == 1 & 
                         !is.na(plotdf$chrt_grad)] <- "Switched to 2-Year College"
plotdf$persist_pattern[plotdf$enrl_1oct_grad_yr1_2yr == 1 & 
                        plotdf$enrl_1oct_grad_yr2_4yr == 1 & 
                         !is.na(plotdf$chrt_grad)] <- "Switched to 4-Year College"

plotdf$groupVar <- NA
plotdf$groupVar[plotdf$enrl_1oct_grad_yr1_2yr == 1] <- "2-year College"
plotdf$groupVar[plotdf$enrl_1oct_grad_yr1_4yr == 1] <- "4-year College"
# Drop NA
plotdf %<>% filter(!is.na(groupVar))
# // Step 3: Obtain agency and school level average for persistence outcomes
chartData <- plotdf %>% 
  group_by(last_hs_name, groupVar, persist_pattern) %>% 
  summarize(tally = n()) %>% # counts the occurrence persist_pattern
  ungroup %>% 
  group_by(last_hs_name, groupVar) %>% # regroup by grouping variable and school
  mutate(denominator = sum(tally)) %>% # sum all levels of persist_pattern
  mutate(persistRate = tally / denominator) %>% # calculate rate
  filter(persist_pattern != "Not persisting") %>%
  mutate(rankRate = sum(persistRate))

agencyData <- plotdf %>%
  group_by(groupVar, persist_pattern) %>% 
  summarize(tally = n(), 
            last_hs_name = "Agency AVERAGE") %>% 
  ungroup %>% 
  group_by(last_hs_name, groupVar) %>% 
  mutate(denominator = sum(tally)) %>% 
  mutate(persistRate = tally / denominator) %>% 
  filter(persist_pattern != "Not persisting") %>%
  mutate(rankRate = sum(persistRate))

chartData <- bind_rows(chartData, agencyData)

# // Step 4: Recode variable names, sort data frame, and code labels for plot
chartData$last_hs_name <- gsub(" High School", "", chartData$last_hs_name)
chartData$last_hs_name <- gsub(" ", "\n", chartData$last_hs_name)
# chartData %<>% filter(persist_pattern != "Not persisting")
chartData %<>% arrange(persist_pattern)
chartData <- as.data.frame(chartData)
chartData$persist_pattern <- factor(as.character(chartData$persist_pattern), 
                                    ordered = TRUE, 
                                    levels = c("Switched to 4-Year College", 
                                               "Switched to 2-Year College", 
                                               "Persisted at 2-Year College", 
                                               "Persisted at 4-Year College"))

## ----E2plot--------------------------------------------------------------
# // Step 5: Prepare plot for 2-year colleges
p1 <- ggplot(chartData[chartData$groupVar == "2-year College",], 
       aes(x = reorder(last_hs_name, rankRate), 
           y = persistRate, group = persist_pattern, 
           fill = persist_pattern)) + 
  scale_y_continuous(limits = c(0, 1), expand = c(0, 0), 
                     label = percent, breaks = seq(0, 1, 0.2)) + 
  geom_bar(stat = 'identity', position = 'stack', 
           color = I("black")) + 
  geom_text(aes(label = round(persistRate * 100, 0)), 
            position = position_stack(vjust = 0.5)) +
  geom_text(aes(label = round(rankRate * 100, 0), y = rankRate), vjust = -0.7) +
  guides(fill = guide_legend("", keywidth = 2, nrow = 2)) +
  scale_fill_brewer(type = "qual", palette = 1) +
  labs(x = "", y = "Percent of Seamless Enrollers") + 
  theme_classic() + theme(axis.text.x = element_text(angle = 30, vjust = 0.2), 
                          axis.ticks.x = element_blank(), 
                          legend.position = c(0.3, 0.875), 
                          plot.caption = element_text(hjust = 0, size = 7)) + 
  labs(subtitle = "Seamless Enrollers at 2-year Colleges", 
       caption = paste0(
          "Sample: 2007-2008 through 2008-2009 Agency high school graduates.\n", 
              "Postsecondary enrollment outcomes from NSC matched records. \n", 
              "All other data from agency administrative records"))

# // Step 6: Prepare plot for 4-year colleges by replacing data in plot 
# above with 4 year data
p2 <- p1 %+% chartData[chartData$groupVar == "4-year College",] + 
  labs(subtitle = "Seamless Enrollers at 4-year Colleges")

# // Step 7: Print out plots with labels
grid.arrange(grobs= list(p2, p1), nrow=1, 
             top = "College Persistence by High School")


## ----E3filterAndSort-----------------------------------------------------
# // Step 1: Keep students in high school graduation cohorts you can observe 
# enrolling in college the fall after graduation

plotdf <- cgdata %>% filter(chrt_grad >= chrt_grad_begin & 
                              chrt_grad <= chrt_grad_end) %>% 
  select(sid, chrt_grad, enrl_1oct_grad_yr1_2yr, enrl_1oct_grad_yr1_4yr,
         enrl_1oct_grad_yr1_any, enrl_1oct_grad_yr2_2yr, enrl_1oct_grad_yr2_4yr,
         enrl_1oct_grad_yr2_any, enrl_grad_persist_any, 
         enrl_grad_persist_2yr, enrl_grad_persist_4yr, 
         first_college_name_any, first_college_name_2yr, first_college_name_4yr) 

# // Step 2: Indicate the number of institutions you would like listed

num_inst <- 5


## ----E3reshapeAndCalculate-----------------------------------------------
# // Step 3: Calculate the number and % of students enrolled in each college 
# the fall after graduation, and the number and % of students persisting, by 
# college type

chart4year <- bind_rows(
  plotdf %>% group_by(first_college_name_4yr) %>% 
  summarize(enrolled = sum(enrl_1oct_grad_yr1_4yr, na.rm=TRUE), 
            persisted = sum(enrl_grad_persist_4yr, na.rm=TRUE)) %>% 
  ungroup %>% 
  mutate(total_enrolled = sum(enrolled)) %>% 
  mutate(perEnroll = round(100 * enrolled/total_enrolled, 1), 
         perPersist = round(100 * persisted/enrolled, 1)),
  plotdf %>% 
  summarize(enrolled = sum(enrl_1oct_grad_yr1_4yr, na.rm=TRUE), 
            persisted = sum(enrl_grad_persist_4yr, na.rm=TRUE), 
            first_college_name_4yr = "All 4-Year Colleges") %>% 
  ungroup %>% 
  mutate(total_enrolled = sum(enrolled)) %>% 
  mutate(perEnroll = round(100 * enrolled/total_enrolled, 1), 
         perPersist = round(100 * persisted/enrolled, 1))
)


chart2year <- bind_rows(plotdf %>% group_by(first_college_name_2yr) %>% 
  summarize(enrolled = sum(enrl_1oct_grad_yr1_2yr, na.rm=TRUE), 
            persisted = sum(enrl_grad_persist_2yr, na.rm=TRUE)) %>% 
  ungroup %>% 
  mutate(total_enrolled = sum(enrolled)) %>% 
  mutate(perEnroll = round(100 * enrolled/total_enrolled, 1), 
         perPersist = round(100 * persisted/enrolled, 1)),
  plotdf %>% 
  summarize(enrolled = sum(enrl_1oct_grad_yr1_2yr, na.rm=TRUE), 
            persisted = sum(enrl_grad_persist_2yr, na.rm=TRUE), 
            first_college_name_2yr = "All 2-Year Colleges") %>% 
  ungroup %>% 
  mutate(total_enrolled = sum(enrolled)) %>% 
  mutate(perEnroll = round(100 * enrolled/total_enrolled, 1), 
         perPersist = round(100 * persisted/enrolled, 1))
)
  

## ----E3createTables, results='markup'------------------------------------
# // Step 4: Create tables
chart4year %>% arrange(-enrolled) %>% 
  select(first_college_name_4yr, enrolled, perEnroll, persisted, perPersist) %>%
  head(num_inst) %>%
    kable(., col.names = c("Name", "Number Enrolled", 
                         "% Enrolled", "Number Persisted", 
                         "% Persisted"))

chart2year %>% arrange(-enrolled) %>% 
  select(first_college_name_2yr, enrolled, perEnroll, persisted, perPersist) %>%
  head(num_inst) %>%
  kable(., col.names = c("Name", "Number Enrolled", 
                         "% Enrolled", "Number Persisted", 
                         "% Persisted"))


