/****************************************************************************
* File name: Analyze_Template.do
* Author(s): Strategic Data Project
* Date: 
* Description: This program uses the CG_Analysis file connect to produce
*              analyses and graphs:
*              1. It defines the sample restrictions.
*              2. It then includes all the analyses along the education pipeline
*                 in Analyze: College-Going Success Analysis Guide.  Each analysis
*                 is marked by a letter A-E (for the five steps along the pipeline)
*                 and a number indicating the sequence of analyses in that step.
*
* Inputs: /analysis/CG_Analysis.dta
*
* Outputs: various graphs as emfs and gph files in /analysis/graphs/
*
***************************************************************************/

clear
set more off
capture log close

cd ""

global analysis ".\analysis\"
global graphs   ".\analysis\graphs"


/*** Define sample restrictions ***/

// Agency name
global agency_name "Agency"

// Ninth grade cohorts you can observe persisting to the second year of college
global chrt_ninth_begin_persist_yr2 = 2005
global chrt_ninth_end_persist_yr2 = 2005

// Ninth grade cohorts you can observe graduating high school on time
global chrt_ninth_begin_grad = 2005
global chrt_ninth_end_grad = 2006

// Ninth grade cohorts you can observe graduating high school one year late
global chrt_ninth_begin_grad_late = 2005
global chrt_ninth_end_grad_late = 2005

// High school graduation cohorts you can observe enrolling in college the fall after graduation
global chrt_grad_begin = 2008
global chrt_grad_end = 2009

// High school graduation cohorts you can observe enrolling in college two years after hs graduation
/*global chrt_grad_begin_delayed = 2008
global chrt_grad_end_delayed = 2008*/


/**** A. Attainment along the Education Pipeline ****/
/**** 1. Overall Progression ****/
{
// Step 1: Load the college-going analysis file into Stata
use "${analysis}/CG_Analysis", clear
 
// Step 2: Keep students in ninth grade cohorts you can observe persisting to the second year of college
local chrt_ninth_begin = 
local chrt_ninth_end = 
keep if (chrt_ninth >= `chrt_ninth_begin' & chrt_ninth <= `chrt_ninth_end')
 
// Step 3: Create variables for the outcomes "regular diploma recipients", "seamless transitioners" and "second year persisters" 


// Step 4: Create agency-level average outcomes
// 1. Preserve the data (to work with the data in its existing structure later on)

// 2. Calculate the mean of each outcome variable by agency

// 3. Create a string variable called school_name equal to "${agency_name} Average"

// 4. Save this data as a temporary file

// 5. Restore the data to the original form

 
// Step 5: Create school-level maximum and minimum outcomes
// 1. Create a variable school_name that takes on the value of students’ first high school attended
gen school_name = first_hs_name
// 2. Calculate the mean of each outcome variable by first high school attended
collapse (mean) grad seamless_transitioners second_year_persisters (count) N = sid , by(school_name)
 
// 3. Identify the agency maximum values for each of the three outcome variables
preserve

restore
 
// 4. Identify the agency minimum values for each of the three outcome variables
preserve

restore
 
// 5. Append the three tempfiles to the school-level file loaded into Stata


 
// Step 6: Format the outcome variables so they read as percentages in the graph
foreach var of varlist grad seamless_transitioners_any second_year_persisters {

}
 
// Step 7: Reformat the data file so that one variable contains all the outcomes of interest
// 1. Create 4 observations for each school: ninth grade, hs graduation, seamless college transition and second-year persistence
foreach i of numlist 1/4 {

}
// 2. Reshape the data file from wide to long

// 3. Create a single variable that takes on all the outcomes of interest

 
// Step 8: Prepare to graph the results
// 1. Label the outcome

// 2. Generate a cohort label to be used in the footnote for the graph
local temp_begin = `chrt_ninth_begin'-1
local temp_end = `chrt_ninth_end'-1
if `chrt_ninth_begin'==`chrt_ninth_end' {
    local chrt_label "`temp_begin'-`chrt_ninth_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_ninth_begin' through `temp_end'-`chrt_ninth_end'"
}
 
// Step 9: Graph the results
#delimit ;
twoway (connected outcome time if school_name == "${agency_name} AVERAGE",
    sort lcolor(dkorange) mlabel(outcome) mlabc(black) mlabs(vsmall) mlabp(12)
    mcolor(dknavy) msymbol(circle) msize(small))
    (connected outcome time if school_name == "${agency_name} MAX HS", sort lcolor(black)
    lpattern(dash) mlabel(outcome) mlabs(vsmall) mlabp(12) mlabc(black)
    mcolor(black) msize(small))
    (connected outcome time if school_name == "${agency_name} MIN HS", sort lcolor(blue)
    lpattern(dash) mlabel(outcome) mlabs(vsmall) mlabp(12) mlabc(black)
    mcolor(black) msize(small)),
title("Student Progression from 9th Grade Through College")
    subtitle("${agency_name} Average", size(medsmall))
    xscale(range(.8(.2)4.2))
    xtitle("") xlabel(1 2 3 4 , valuelabels labsize(vsmall))
    ytitle("Percent of Ninth Graders")
    yscale(range(0(20)100))
    ylabel(0(20)100, nogrid)
legend(col(1) position(2) size(vsmall)
    label(1 "${agency_name} Average")
    label(2 "${agency_name} Max HS")
    label(3 "${agency_name} Min HS")
    ring(0) region(lpattern(none) lcolor(none) fcolor(none)))
graphregion(color(white) fcolor(white) lcolor(white))
plotregion(color(white) fcolor(white) lcolor(white))
note(" " "Sample: `chrt_label' ${agency_name} first-time ninth graders. Postsecondary enrollment outcomes from NSC matched records." "All other data from ${agency_name} administrative records.", size(vsmall));
#delimit cr
graph export "${graphs}/A1_Overall_Progression.emf", replace
graph save "${graphs}/A1_Overall_Progression.gph", replace
}

/**** A. Attainment along the Education Pipeline ****/
/**** 2. Progression by Student Race/Ethnicity ****/
{
// Step 1: Load the college-going analysis file into Stata
use "${analysis}/CG_Analysis", clear
 
// Step 2: Keep students in ninth grade cohorts you can observe persisting to the second year of college
local chrt_ninth_begin = 
local chrt_ninth_end = 
keep if (chrt_ninth >= `chrt_ninth_begin' & chrt_ninth <= `chrt_ninth_end')
 
// Step 3: Create variables for the outcomes "regular diploma recipients", "seamless transitioners" and "second year persisters"

 
// Step 4: Create average outcomes by race/ethnicity

 
// Step 5: Format the outcome variables so they read as percentages in the graph
foreach var of varlist grad seamless_transitioners_any second_year_persisters {

}
 
// Step 6: Reformat the data file so that one variable contains all the outcomes of interest
// 1. Create 4 observations for each school: ninth grade, hs graduation, seamless college transition and second-year persistence
foreach i of numlist 1/4 {

}
// 2. Keep only African-American, Asian-American, Hispanic, and White students

// 3. Reshape the data file from wide to long

// 4. Create a single variable that takes on all the outcomes of interest

 
// Step 7: Prepare to graph the results
// 1. Label the outcome

// 2. Generate a cohort label to be used in the footnote for the graph
local temp_begin = `chrt_ninth_begin'-1
local temp_end = `chrt_ninth_end'-1
if `chrt_ninth_begin'==`chrt_ninth_end' {
    local chrt_label "`temp_begin'-`chrt_ninth_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_ninth_begin' through `temp_end'-`chrt_ninth_end'"
}
 
// Step 8: Graph the results
#delimit;
twoway (connected outcome time if race_ethnicity==1,
    sort lcolor(dknavy) mlabel(outcome) mlabc(black)mlabs(vsmall) mlabp(12)
    mcolor(dknavy) msymbol(circle) msize(small))
    (connected outcome time if race_ethnicity==2 , sort lcolor(lavender) lpattern(dash)
    mlabel(outcome) mlabs(vsmall) mlabp(12) mlabc(black) mcolor(lavender) msize(small))
    (connected outcome time if race_ethnicity==3 , sort lcolor(dkgreen) lpattern(dash)
    mlabel(outcome) mlabs(vsmall) mlabp(12) mlabc(black) mcolor(dkgreen) msize(small))
    (connected outcome time if race_ethnicity==5 , sort lcolor(orange) mlabel(outcome) mlabc(black)
    mlabs(vsmall) mlabp(12) mcolor(orange) msymbol(circle) msize(small)),
title("Student Progression from Ninth Grade through College", size(medium))
    subtitle("By Student Race/Ethnicity", size(medsmall))
    xscale(range(.8(.2)4.2))
    xlabel(1 2 3 4 , valuelabels labsize(vsmall))
    ytitle("Percent of Ninth Graders")
    yscale(range(0(20)100))
    ylabel(0(20)100, nogrid)
    xtitle("", color(white))
legend(order(2 4 1 3) col(1) position(2) size(vsmall)
    label(1 "African American Students")
    label(2 "Asian American Students")
    label(3 "Hispanic Students")
    label(4 "White Students")
    ring(0) region(lpattern(none) lcolor(none) fcolor(none)))
graphregion(color(white) fcolor(white) lcolor(white))
plotregion(color(white) fcolor(white) lcolor(white))
note(" " "Sample: `chrt_label' ${agency_name} first-time ninth graders." "Postsecondary enrollment outcomes from NSC matched records. All other data from ${agency_name} administrative records." , size(vsmall));
#delimit cr
graph export "${graphs}/A2_Progression_by_RaceEthnicity.emf", replace
graph save "${graphs}/A2_Progression_by_RaceEthnicity.gph", replace
}

/**** A. Attainment along the Education Pipeline ****/
/**** 3. Progression by Student Race/Ethnicity, Among Frpl-Eligible Kids ****/
{
// Step 1: Load the college-going analysis file into Stata
use "${analysis}/CG_Analysis", clear
 
// Step 2: Keep students in ninth grade cohorts you can observe persisting to the second year of college AND are ever FRPL-eligible
local chrt_ninth_begin = 
local chrt_ninth_end = 
keep if (chrt_ninth >= `chrt_ninth_begin' & chrt_ninth <= `chrt_ninth_end')
keep if frpl_ever == 1
 
// Next, repeat steps 3-9 from the previous analysis
// Step 3: Create variables for the outcomes "regular diploma recipients", "seamless transitioners" and "second year persisters" .

 
// Step 4: Create average outcomes by race/ethnicity and drop any race/ethnic groups with fewer than 20 students


// Step 5: Format the outcome variables so they read as percentages in the graph
foreach var of varlist grad seamless_transitioners_any second_year_persisters {

}
 
// Step 6: Reformat the data file so that one variable contains all the outcomes of interest
// 1. Create 4 observations for each school: ninth grade, hs graduation, seamless college transition and second-year persistence
foreach i of numlist 1/4 {

}
// 2. Keep only African American, Asian American, Hispanic, and White students
keep if race_ethnicity == 1 | race_ethnicity == 2 | race_ethnicity == 3 | race_ethnicity == 5

// 3. Reshape the data file from wide to long

// 4. Create a single variable that takes on all the outcomes of interest

 
// Step 7: Prepare to graph the results
// 1. Label the outcome

// 2. Generate a cohort label to be used in the footnote for the graph
local temp_begin = `chrt_ninth_begin'-1
local temp_end = `chrt_ninth_end'-1
if `chrt_ninth_begin'==`chrt_ninth_end' {
    local chrt_label "`temp_begin'-`chrt_ninth_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_ninth_begin' through `temp_end'-`chrt_ninth_end'"
}
 
// Step 8: Graph the results
#delimit ;
twoway (connected outcome time if race_ethnicity==1 , sort lcolor(dknavy) mlabel(outcome)
    mlabc(black) mlabs(vsmall) mlabp(12) mcolor(dknavy) msymbol(circle) msize(small))
    (connected outcome time if race_ethnicity==3 , sort lcolor(forest_green) lpattern(dash)
    mlabel(outcome) mlabs(vsmall) mlabp(12) mlabc(black) mcolor(forest_green) msize(small))
    (connected outcome time if race_ethnicity==5 , sort lcolor(orange) mlabel(outcome) mlabc(black)
    mlabs(vsmall) mlabp(12) mcolor(orange) msymbol(circle) msize(small)),
title("Student Progression from Ninth Grade through College", size(medium))
    subtitle("Among Students Qualifying for Free or Reduced Price Lunch" "By Student Race/Ethnicity", size(medsmall))
    xscale(range(.8(.2)4.2))
    xlabel(1 2 3 4, valuelabels labsize(vsmall))
    ytitle("Percent of Ninth Graders")
    yscale(range(0(20)100))
    ylabel(0(20)100, nogrid)
    xtitle("", color(white))
legend(order(3 1 2) col(1) position(2) size(vsmall)
    label(1 "African American Students")
    label(2 "Hispanic Students")
    label(3 "White Students")
    ring(0) region(lpattern(none) lcolor(none) fcolor(none)))
graphregion(color(white) fcolor(white) lcolor(white))
plotregion(color(white) fcolor(white) lcolor(white))
note(" " "Sample: `chrt_label' ${agency_name} first-time ninth graders." "Postsecondary enrollment outcomes from NSC matched records. All other data from ${agency_name} administrative records." , size(vsmall));
#delimit cr
graph export "${graphs}/A3_Progression_by_RaceEthnicity_Frpl.emf", replace
graph save "${graphs}/A3_Progression_by_RaceEthnicity_Frpl.gph", replace
}

/**** A. Attainment along the Education Pipeline ****/
/**** 4. Progression by Students' On-Track Status After Ninth Grade ****/
{
// Step 1: Load the college-going analysis file into Stata
use "${analysis}/CG_Analysis", clear
 
// Step 2: Keep students in ninth grade cohorts you can observe persisting to the second year of college AND are included in the on-track analysis sample
local chrt_ninth_begin = 
local chrt_ninth_end = 
keep if (chrt_ninth >= `chrt_ninth_begin' & chrt_ninth <= `chrt_ninth_end')
keep if ontrack_sample == 1
 
// Step 3: Generate on-track indicators that take into account students’ GPAs upon completion of their first year in high school

 
// Step 4: Create variables for the outcomes "regular diploma recipients", "seamless transitioners" and "second year persisters"

 
// Step 5: Create average outcomes by on-track status at the end of ninth grade

 
// Step 6: Format the outcome variables so they read as percentages in the graph
foreach var of varlist grad seamless_transitioners_any second_year_persisters {

}
 
// Step 7: Reformat the data file so that one variable contains all the outcomes of interest
// 1. Create 4 observations for each school: ninth grade, hs graduation, seamless college transition and second-year persistence
foreach i of numlist 1/4 {

}
// 2. Reshape the data file from wide to long

// 3. Create a single variable that takes on all the outcomes of interest

 
// Step 8: Prepare to graph the results
// 1. Label the outcome

// 2. Generate a cohort label to be used in the footnote for the graph
local temp_begin = `chrt_ninth_begin'-1
local temp_end = `chrt_ninth_end'-1
if `chrt_ninth_begin'==`chrt_ninth_end' {
    local chrt_label "`temp_begin'-`chrt_ninth_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_ninth_begin' through `temp_end'-`chrt_ninth_end'"
}

// 3. Determine the location of the label for each on-track outcome

foreach obsnum of numlist 4(4)12 {

}
 
// Step 9: Graph the results
#delimit ;
twoway (connected outcome time if ontrack_endyr1_gpa == 1,
    sort lcolor(dkorange) mlabel(outcome) mlabc(black) mlabs(vsmall) mlabp(3)
    mcolor(dkorange) msymbol(circle) msize(small))
    (connected outcome time if ontrack_endyr1_gpa == 2, sort lcolor(navy*.6)
    mlabel(outcome) mlabs(vsmall) mlabp(3) mlabc(black) mcolor(navy*.6)
    msymbol(square) msize(small))
    (connected outcome time if ontrack_endyr1_gpa == 3, sort lcolor(navy*.9)
    mlabel(outcome) mlabs(vsmall) mlabp(3) mlabc(black) mcolor(navy*.9)
    msymbol(diamond) msize(small))
    (connected outcome time if ontrack_endyr1_gpa == 4, sort lcolor(navy*.3)
    mlabel(outcome) mlabs(vsmall) mlabp(3) mlabc(black) mcolor(navy*.3)
    msymbol(triangle) msize(small)),
title("Student Progression from 9th Grade through College", size(medium))
    ylabel(, nogrid)
    subtitle("by Course Credits and GPA after First High School Year", size(medsmall))
    xscale(range(.8(.2)4.2)) xlabel(1 2 3 4, valuelabels labsize(vsmall)) xtitle("")
    yscale(range(0(20)100)) ylabel(0(20)100, labsize(small) format(%9.0f))
    ytitle("Percent of Ninth Graders" " ")
text(`ontrack4_label' 4 "Off-Track to Graduate", color(dkorange) size(2))
text(`ontrack8_label' 4 "On-Track to Graduate," "GPA<3.0", color(navy*.8) size(2))
text(`ontrack12_label' 4 "On-Track to Graduate," "GPA>=3.0", color(navy*1.3) size(2))
legend(off)
graphregion(color(white) fcolor(white) lcolor(white))
plotregion(color(white) fcolor(white) lcolor(white))
note(" " "Sample: `chrt_label' ${agency_name} first-time ninth graders. Students who transferred into or out of ${agency_name} are excluded from the sample." "Postsecondary enrollment outcomes from NSC matched records. All other data are from ${agency_name} administrative records.", size(vsmall));
#delimit cr
graph export "${graphs}/A4_Progression_by_OnTrack_Ninth.emf", replace
graph save "${graphs}/A4_Progression_by_OnTrack_Ninth.gph", replace
}
 
/**** B. Ninth to Tenth Grade Transition by On-Track Status ****/
/**** 1. Proportion of Students On-Track at the End of Ninth Grade, By High School ****/
{
// Step 1: Load the college-going analysis file into Stata
use "${analysis}/CG_Analysis", clear
 
// Step 2: Keep students in ninth grade cohorts you can observe graduating high school on time AND are part of the on-track sample
local chrt_ninth_begin = 
local chrt_ninth_end = 
keep if (chrt_ninth >= `chrt_ninth_begin' & chrt_ninth <= `chrt_ninth_end')
keep if ontrack_sample == 1
 
// Step 3: Create on-track categories that account for students’ credits earned (already captured in the ontrack_endyr1 variable) and GPA after ninth grade

 
// Step 4: Obtain the agency average for the key variables
preserve

restore
 
// Step 5: Obtain mean rates for each school and append the agency average

 
// Step 6: Provide a hs name label for the appended agency average and shorten hs name

 
// Step 7: For students who are off-track upon completion of their first year of high school, convert the values to be negative for ease of visualization in the graph

 
// Step 8: Multiply the average of each outcome by 100 for graphical representation of the rates. Create a variable equal to the sum of the two on-track status variables for easier sorting
foreach var of varlist ontrack_endyr1_1 ontrack_endyr1_2 ontrack_endyr1_3  {

}
 
// Step 9: Prepare to graph the results
// Generate a cohort label to be used in the footnote for the graph
local temp_begin = `chrt_ninth_begin'-1
local temp_end = `chrt_ninth_end'-1
if `chrt_ninth_begin'==`chrt_ninth_end' {
    local chrt_label "`temp_begin'-`chrt_ninth_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_ninth_begin' through `temp_end'-`chrt_ninth_end'"
}
 
// Step 10: Graph the results
#delimit ;
graph bar ontrack_endyr1_3 ontrack_endyr1_2 ontrack_endyr1_1,
    over(first_hs_name, gap(20) sort(ontrack_endyr1_sum) label(angle(40)labsize(small)))
    blabel(bar, position(inside) size(2) format(%8.0f))
    bar(3, fcolor(maroon*.6) lcolor(maroon*.6))
    bar(1, fcolor(navy*.5) lcolor(navy*.5))
    bar(2, fcolor(navy*.8) lcolor(navy*.8)) stack
title("Proportion of Students On-Track to Graduate by School", size(medium))
    subtitle("End of Ninth Grade On-Track Status" "By High School")
legend(region(lcolor(white)) position(11) ring(0) order(2 1 3)
    label(3 "Off Track to Graduate")
    label(1 "On Track, GPA <3.0")
    label(2 "On Track, GPA>=3.0")
    symxsize(5) symysize(2) cols(1) size(vsmall))
yline(0, lcolor(black) lwidth(vvthin))
ytitle("Percent of Ninth Graders") yscale(range(-60(20)80)) ylabel(-60(20)80, nogrid)
graphregion(color(white) fcolor(white) lcolor(white))
plotregion(color(white) fcolor(white) lcolor(white))
note(" " "Sample: `chrt_label' ${agency_name} first-time ninth graders. Students who transferred into or out of ${agency_name} are excluded" "from the sample. All data from ${agency_name} administrative records.", size(vsmall));
#delimit cr
graph export "${graphs}/B1_OnTrack_Ninth_by_HS.emf", replace
graph save "${graphs}/B1_OnTrack_Ninth_by_HS.gph", replace
}
 
/**** B. Ninth to Tenth Grade Transition by On-Track Status ****/
/**** 2. Ninth Grade to Tenth Grade Transition, By On-Track Status ****/
{
// Step 1: Load the college-going analysis file into Stata
use "${analysis}/CG_Analysis", clear
 
// Step 2: Keep students in ninth grade cohorts you can observe graduating high school on time AND are part of the on-track sample
local chrt_ninth_begin = 
local chrt_ninth_end = 
keep if (chrt_ninth >= `chrt_ninth_begin' & chrt_ninth <= `chrt_ninth_end')
keep if ontrack_sample == 1
 
// Step 3: Create on-track categories that account for students’ credits earned (already captured in the ontrack_endyr1 variable) and GPA after ninth grade

 
// Step 4: Create indicators for students upon completion of their second year of high school

 
// Step 5: Determine the agency average for each of the indicators created in step 4.

foreach var of varlist ontrack_endyr2_1 ontrack_endyr2_2 ontrack_endyr2_3 ontrack_endyr2_4 {

}
 
// Step 6: For students who are off-track upon completion of their second year of high school, convert the values to be negative for ease of visualization in the graph.

 
// Step 7: Prepare to graph the results
// Generate a cohort label to be used in the footnote for the graph
local temp_begin = `chrt_ninth_begin'-1
local temp_end = `chrt_ninth_end'-1
if `chrt_ninth_begin'==`chrt_ninth_end' {
    local chrt_label "`temp_begin'-`chrt_ninth_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_ninth_begin' through `temp_end'-`chrt_ninth_end'"
}
 
// Step 8: Graph the results
#delimit ;
graph bar ontrack_endyr2_1 ontrack_endyr2_4 ontrack_endyr2_2 ontrack_endyr2_3 ,
    over(ontrack_endyr1_gpa, label(labsize(vsmall)) gap(50)) outergap(50)
    bar(1, fcolor(maroon*.4) lcolor(maroon*.4))
    bar(2, fcolor(maroon*.8) lcolor(maroon*.8))
    bar(3, fcolor(navy*.5) lcolor(navy*.5))
    bar(4, fcolor(navy*.8) lcolor(navy*.8)) stack
    blabel(bar, size(2) format(%8.0f) position(inside))
legend(symxsize(2) symysize(2) rows(4) size(2)
    region(lcolor(white)) position(2) order(4 3 1 2)
    label(1 "Off-Track to Graduate")
    label(2 "Dropout/Disappear")
    label(3 "On-Track to" "Graduate, GPA<3.0")
    label(4 "On-Track to" "Graduate, GPA>=3.0")
    title("End of Tenth Grade" "On-Track Status", size(small)))
title("End of Tenth Grade On-Track Status", size(medium))
    subtitle("by End of Ninth Grade Status", size(small))
    ytitle("Percent of Tenth Grade Students" "by Ninth Grade Status" " " " ", size(small))
    yscale(range(-100(20)100))
    ylabel(-100(20)100, nogrid labsize(small))
    ylabel(-100 "100" -80 "80" -60 "60" -40 "40" -20 "20" 0 "0" 20 "20" 40 "40" 60 "60"
    80 "80" 100 "100")
    yline(0, lcolor(black) lwidth(vvthin))
text(-130 60 "Ninth Grade On-Track Status", size(small))
graphregion(color(white) fcolor(white) lcolor(white))
plotregion(color(white) fcolor(white) lcolor(white))
note(" " " " "Sample: `chrt_label' ${agency_name} first-time ninth graders. Students who transferred into or out of ${agency_name} are excluded" "from the sample. All data from ${agency_name} administrative records.", size(vsmall));
#delimit cr
graph export "${graphs}/B2_OnTrack_Tenth_by_OnTrack_Ninth.emf", replace
graph save "${graphs}/B2_OnTrack_Tenth_by_OnTrack_Ninth.gph", replace
}

/**** C. High School Graduation ****/
/**** 1. High School Graduation Rates by School ****/
{
// Step 1: Load the college-going analysis file into Stata
use "${analysis}/CG_Analysis", clear
 
// Step 2: Keep students in ninth grade cohorts you can observe graduating high school one year late
local chrt_ninth_begin = 
local chrt_ninth_end = 
keep if (chrt_ninth >= `chrt_ninth_begin' & chrt_ninth <= `chrt_ninth_end')
 
// Step 3: Obtain the agency-level high school graduation rates.
preserve

restore
 
// Step 4: Obtain the school-level high school graduation rates and append the agency average
'
 
// Step 5: Provide a hs name label for the appended agency average and shorten hs name

 
// Step 6: Multiply the average of each outcome by 100 for graphical representation of the rates
foreach var of varlist ontime_grad late_grad {

}
 
// Step 7: Prepare to graph the results
// Generate a cohort label to be used in the footnote for the graph
local temp_begin = `chrt_ninth_begin'-1
local temp_end = `chrt_ninth_end'-1
if `chrt_ninth_begin'==`chrt_ninth_end' {
    local chrt_label "`temp_begin'-`chrt_ninth_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_ninth_begin' through `temp_end'-`chrt_ninth_end'"
}
 
// Step 8: Graph the results
#delimit ;
graph bar (sum) ontime_grad late_grad, stack over(first_hs_name, label(angle(40)
    labsize(small)) gap(20) sort(ontime_grad))
    blabel(bar, position(inside) color(black) size(small) format(%8.0f))
    bar(1, fcolor(dkorange) fintensity(70) lcolor(black))
    bar(2, fcolor(navy) fintensity(70) lcolor(black))
legend(region(lcolor(white)) symxsize(3) symysize(2) rows(2) order(2 1) size(vsmall)
    position(11) label(1 "On-Time High School Graduate") label(2 "Graduate in 4+ Yrs."))
title("High School Graduation Rates by High School")
    ytitle("Percent of Ninth Graders") yscale(range(0(20)100)) ylabel(0(20)100, nogrid)
graphregion(color(white) fcolor(white) lcolor(white))
plotregion(color(white) fcolor(white) lcolor(white))
note(" " "Sample: `chrt_label' ${agency_name} first-time ninth graders. Data from ${agency_name} administrative records." , size(vsmall));
#delimit cr
graph export "${graphs}/C1_HS_Grad_by_HS.emf", replace
graph save "${graphs}/C1_HS_Grad_by_HS.gph", replace
}

/**** C. High School Graduation ****/
/**** 2. High School Completion Rates by Average 8th Grade Achievement ****/
{
// Step 1: Load the college-going analysis file into Stata.
use "${analysis}/CG_Analysis", clear
 
// Step 2: Keep students in ninth grade cohorts you can observe graduating high school AND have non-missing eighth grade math scores.
local chrt_ninth_begin = 
local chrt_ninth_end = 
keep if (chrt_ninth >= `chrt_ninth_begin' & chrt_ninth <= `chrt_ninth_end') & !mi(test_math_8_std)
 
// Step 3: Obtain agency-level high school completion rate and prior achievement score along with the position of their labels.

 
// Step 4: Obtain school-level high school completion and prior achievement rates

 
// Step 5: Multiply the high school completion rate by 100 for graphical representation of the rates,

 
// Step 6: Shorten high school names and create a legend label for the graph
sort first_hs_name
replace first_hs_name = subinstr(first_hs_name, " High School", "", .)
gen hs_code_label = _n
 
levelsof first_hs_name, local(hs_names)
local count = 1
local legend_labels ""
foreach hs of local hs_names {
    local legend_labels `"`legend_labels' `count' = `hs'"' `" "'
    local ++count
}
 
// Step 7: Prepare to graph the results
// Generate a cohort label to be used in the footnote for the graph
local temp_begin = `chrt_ninth_begin'-1
local temp_end = `chrt_ninth_end'-1
if `chrt_ninth_begin'==`chrt_ninth_end' {
    local chrt_label "`temp_begin'-`chrt_ninth_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_ninth_begin' through `temp_end'-`chrt_ninth_end'"
}
 
// Step 8: Graph the results
#delimit ;
twoway (scatter ontime_grad test_math_8_std, mlabel(hs_code_label) mlabsize(vsmall)
    mlabposition(12) mlabcolor(dknavy) mstyle(x) msize(small) mcolor(dknavy)),
title("On-Time High School Graduation")
    subtitle("By Student Achievement Profile Upon High School Entry")
    xtitle("Average 8th Grade Math Standardized Score", linegap(0.3))
    ytitle("Percent of Ninth Graders")
    xscale(range(-0.8(0.2)1)) xlabel(-0.8(0.2)1)
    yscale(range(0(20)100)) ylabel(0(20)100, nogrid)
    legend(on order(3) col(1) label(3 `"`legend_labels'"')
    region(color(none)) size(vsmall) position(2) ring(1) linegap(.75))
yline(`agency_mean_grad', lpattern(dash) lcolor(dknavy) lwidth(vvthin))
xline(`agency_mean_test', lpattern(dash) lcolor(dkorange) lwidth(vvthin))
text(`agency_mean_grad_label' .8 "${agency_name} Average Graduation Rate", size(2.0) color(dknavy))
text(2 `agency_mean_test_label' "${agency_name} Average" "Test Score", size(2.0) color(dkorange))
text(99 -.5 "Below average math scores &" "above average graduation rates",
    size(vsmall) justification(left))
text(99 0.8 "Above average math scores &" "above average graduation rates",
    size(vsmall) justification(right))
text(2 -0.5 "Below average math scores &" "below average graduation rates",
    size(vsmall) justification(left))
text(2 0.8 "Above average math scores &" "below average graduation rates",
    size(vsmall) justification(right))
graphregion(color(white) fcolor(white) lcolor(white))
plotregion(color(white) fcolor(white) lcolor(white))
note("Sample: `chrt_label' ${agency_name} first-time ninth graders with eighth grade math test scores." "All data from ${agency_name} administrative records.", size(vsmall));
#delimit cr
graph export "${graphs}/C2_HS_Grad_by_Avg_Eighth.emf", replace
graph save "${graphs}/C2_HS_Grad_by_Avg_Eighth.gph", replace
}
 
**** C. High School Graduation ****/
/**** 3. High School Completion Rates by 8th Grade Achievement Quartiles ****/
{
// Step 1: Load the college-going analysis file into Stata.
use "${analysis}/CG_Analysis", clear
 
// Step 2: Keep students in ninth grade cohorts you can observe graduating high school AND have non-missing eighth grade math scores.
local chrt_ninth_begin = 
local chrt_ninth_end = 
keep if (chrt_ninth >= `chrt_ninth_begin' & chrt_ninth <= `chrt_ninth_end') & !mi(test_math_8)
 
// Step 3: Obtain the overall agency-level high school graduation rate along with the position of its label.

 
// Step 4: Obtain the agency-level high school graduation rates by test score quartile.
preserve

restore
 
// Step 5: Obtain school-level high school graduation rates by test score quartile and append the agency-level graduation rates by quartile

 
// Step 6: Shorten high school names and drop any high schools with fewer than 20 students

 
// Step 7: Multiply the high school completion rate by 100 for graphical representation of the rates

 
// Step 8: Create a variable to sort schools within each test score quartile in ascending order

 
// Step 9: Prepare to graph the results
// Generate a cohort label to be used in the footnote for the graph
local temp_begin = `chrt_ninth_begin'-1
local temp_end = `chrt_ninth_end'-1
if `chrt_ninth_begin'==`chrt_ninth_end' {
    local chrt_label "`temp_begin'-`chrt_ninth_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_ninth_begin' through `temp_end'-`chrt_ninth_end'"
}
 
// Step 10: Graph the results
#delimit ;
graph bar ontime_grad, over(first_hs_name, sort(rank) gap(0) label(angle(70) labsize(vsmall))) 
    over(qrt_8_math, relabel(1 "Bottom Quartile" 2 "2nd Quartile" 3 "3rd Quartile" 4 "Top Quartile") gap(400))
    bar(1, fcolor(dknavy) finten(70) lcolor(dknavy) lwidth(thin))
    blabel(bar, format(%8.0f) size(1.5))
    yscale(range(0(20)100)) ylabel(0(20)100, nogrid) legend(off)
title("On-Time High School Graduation Rates")
    subtitle("By Prior Student Achievement", size(msmall))
    ytitle("Percent of Ninth Graders")
    yline(`agency_mean', lpattern(dash) lwidth(vvthin) lcolor(dknavy))
text(`agency_mean_label' 5 "${agency_name} Average", size(vsmall))
graphregion(color(white) fcolor(white) lcolor(white))
plotregion(color(white) fcolor(white) lcolor(white))
note(" " "Sample: `chrt_label' ${agency_name} first-time ninth graders with eighth grade math test scores." "All data from ${agency_name} administrative records.", size(vsmall));
#delimit cr
graph export "${graphs}/C3_HS_Grad_by_Eighth_Qrt.emf", replace
graph save "${graphs}/C3_HS_Grad_by_Eighth_Qrt.gph", replace
}
 
/**** C. High School Graduation ****/
/**** 4. Graduation Rates by Race Overall and By 8th Grade Achievement Quartiles ****/
{
// Step 1: Load the college-going analysis file into Stata
use "${analysis}/CG_Analysis", clear
 
// Step 2: Keep students in ninth grade cohorts you can observe graduating high school AND have non-missing eighth grade math scores
local chrt_ninth_begin = 
local chrt_ninth_end = 
keep if (chrt_ninth >= `chrt_ninth_begin' & chrt_ninth <= `chrt_ninth_end') & !mi(test_math_8)
 
// Step 3: Obtain the average on-time high school completion rate by race/ethnicity; you will restore in step 8
preserve

 
// Step 4: Multiply the high school completion rate by 100 for graphical representation of the rates

 
// Step 5: Reshape the data wide so that each race is associated with the outcome variable

 
// Step 6: Prepare to graph the results
// Generate a cohort label to be used in the footnote for the graph
local temp_begin = `chrt_ninth_begin'-1
local temp_end = `chrt_ninth_end'-1
if `chrt_ninth_begin'==`chrt_ninth_end' {
    local chrt_label "`temp_begin'-`chrt_ninth_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_ninth_begin' through `temp_end'-`chrt_ninth_end'"
}
 
// Step 7: Graph the results (1/2)
#delimit ;
graph bar ontime_grad3 ontime_grad1 ontime_grad5 ontime_grad2,
    bargap(25) outergap(100)
    bar(1, fcolor(forest_green*.7) lcolor(forest_green*.7))
    bar(2, fcolor(dknavy*.7) lcolor(dknavy*.7))
    bar(3, fcolor(orange*.7) lcolor(orange*.7))
    bar(4, fcolor(lavender*.85) lcolor(lavender*.85))
    blabel(bar, size(small) format(%8.0f))
text(-4 22 "Hispanic", size(small))
text(-4 40 "African American", size(small))
text(-4 59 "White", size(small))
text(-4 77 "Asian American", size(small))
title("On-Time High School Graduation Rates")
    subtitle("by Race")
    ytitle("Percent of Ninth Graders")
    yscale(range(0(20)100))
    ylabel(0(20)100, nogrid)
legend(off)
graphregion(color(white) fcolor(white) lcolor(white))
plotregion(color(white) fcolor(white) lcolor(white))
note(" " " " "Sample: `chrt_label' ${agency_name} first-time ninth graders." "All data from ${agency_name} administrative records.", size(vsmall));
#delimit cr
graph export "${graphs}/C4a_HS_Grad_by_Race.emf", replace
graph save "${graphs}/C4a_HS_Grad_by_Race.gph", replace
 
// Step 8: Restore the data and repeat steps 3-6 to obtain completion rates by race/ethnicity and eighth grade test score quartiles
restore

 
// Step 9: Graph the results (2/2)
#delimit ;
graph bar ontime_grad3 ontime_grad1 ontime_grad5 ontime_grad2, over(qrt_8_math,
    relabel(1 "Bottom Quartile" 2 "2nd Quartile" 3 "3rd Quartile" 4 "Top Quartile") label(labsize(small)))
    bar(1, fcolor(forest_green*.7) lcolor(forest_green*.7)) bar(2, fcolor(dknavy*.7) lcolor(dknavy*.7))
    bar(3, fcolor(orange*.7) lcolor(orange*.7)) bar(4, fcolor(lavender*.85) lcolor(lavender*.85)) 
    blabel(bar, format(%8.0f))
title("On-Time High School Graduation Rates")
    subtitle("By Race and Prior Achievement")
    b1title("8th Grade Math Score Test Quartile")
    ytitle("Percent of Ninth Graders") yscale(range(0(20)100)) ylabel(0(20)100, nogrid)
legend(order(1 2 3 4) row(1) label(1 "Hispanic")
    label(2 "African American") label(3 "White") label(4 "Asian American") size(vsmall)
    symxsize(7) position(inside) ring(1) region(lstyle(none)
    lcolor(none) color(none)))
graphregion(color(white) fcolor(white) lcolor(white))
plotregion(color(white) fcolor(white) lcolor(white))
note("Sample: `chrt_label' ${agency_name} first-time ninth graders." "All data from ${agency_name} administrative records.", size(vsmall));
#delimit cr
graph export "${graphs}/C4b_HS_Grad_by_Race_by_Eighth_Qrt.emf", replace
graph save "${graphs}/C4b_HS_Grad_by_Race_by_Eighth_Qrt.gph", replace
}

/**** C. High School Graduation ****/
/**** 5. Enrollment Outcome in Year 4 By On-Track Status at the End of Ninth Grade ****/
{
// Step 1: Load the college-going analysis file into Stata
use "${analysis}/CG_Analysis", clear
 
// Step 2: Keep students in ninth grade cohorts you can observe graduating high school AND are part of the on-track sample (attended the first semester of ninth grade and never transferred into or out of the system)
local chrt_ninth_begin = 
local chrt_ninth_end = 
keep if (chrt_ninth >= `chrt_ninth_begin' & chrt_ninth <= `chrt_ninth_end') & !mi(cum_gpa_yr1)
keep if ontrack_sample==1
 
// Step 3: Assert that the on-track status after year 4 is not missing

 
// Step 4: Keep only the variables of interest and generate graduation outcomes after year 4. Assign students as still enrolled if they have a graduation cohort but are not observed to be on-time graduates

 
// Step 5: Ensure that the graduation outcome variables after year 4 are now mutually exclusive for each student

 
// Step 6: Generate on-track indicators that take into account students' GPA upon completion of their first year in high school.

 
// Step 7: Create average outcomes by on-track status at the end of ninth grade.

 
// Step 8: Format the outcome variables so they read as percentages in the graph
foreach var of varlist hs_grad still_enrl dropout disappear {

}
 
// Step 9: For students who dropout or disappear, convert their values to be negative for ease of visualization in the graph
foreach var in dropout disappear { 

}
 
// Step 10: Prepare to graph the results
// Generate a cohort label to be used in the footnote for the graph
local temp_end = `chrt_ninth_end'-1
if `chrt_ninth_begin'==`chrt_ninth_end' {
    local chrt_label "`temp_begin'-`chrt_ninth_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_ninth_begin' through `temp_end'-`chrt_ninth_end'"
}

// Step 11: Graph the results
#delimit ;
graph bar dropout disappear still_enrl hs_grad, over(ontrack_endyr1, gap(100) label(labsize(2.5)))  
    stack blabel(bar, position(inside) color(black) format(%9.0f) size(2.1)) 
    bar(1, fcolor(maroon*.8) lcolor(maroon*.85))    
    bar(2, fcolor(dkorange*.5) lcolor(dkorange*.65) lwidth(vvthin)) 
    bar(3, fcolor(navy*.5) lcolor(navy*.65) lwidth(vvthin)) 
    bar(4, fcolor(navy*.8) lcolor(navy*.95) lwidth(vvthin)) 
legend(col(1) order(4 3 1 2) 
    lab(1 "Drop Out") 
    lab(2 "Disappear" ) 
    lab(3 "Still Enrolled") 
    lab(4 "Graduated") 
    size(2.3) symxsize(2) symysize(2) position(2) region(color(none)) title("Status After Year Four", size(2.5))) 
title("Enrollment Status After Four Years in High School", size(large)) 
    subtitle("By Course Credits and GPA after First Year of High School", size(medium)) 
    ytitle("Percent of Students", size(small) margin(2 2 0 0)) 
    yscale(range(-60(20)100)) 
    ylabel(-60(20)100, nogrid labsize(small)) 
    ylabel(-60 "60" -40 "40" -20 "20" 0 "0" 20 "20" 40 "40" 60 "60" 80 "80" 100 "100") 
    yline(0, lcolor(black) lwidth(vvthin)) 
text(-87 50 "Ninth Grade On-Track Status", size(small))  
graphregion(color(white) fcolor(white) lcolor(white)) 
plotregion(color(white) fcolor(white) lcolor(white)) 
note(" " " " " " "Sample: `chrt_label' ${agency_name} first-time ninth graders. Students who transferred into or out of the agency" 
"are excluded from the sample. All data from ${agency_name} administrative records." , size(vsmall));
#delimit cr
graph export "${graphs}/C5_Yr4_Status_by_OnTrack_Ninth.emf", replace
graph save "${graphs}/C5_Yr4_Status_by_OnTrack_Ninth.gph", replace
}
 
/**** C. High School Graduation - remove ****/
/**** 6. Recovery Rates from Off-Track to High School Completion ****/
 
/**** D. College Enrollment ****/
/**** 1. Seamless College Enrollment Rates by High School ****/
{
// Step 1:  Load the college-going analysis file into Stata
use "${analysis}/CG_Analysis", clear 
 
// Step 2: Keep students in high school graduation cohorts you can observe enrolling in college the fall after graduation
local chrt_grad_begin = 
local chrt_grad_end = 
keep if (chrt_grad >= `chrt_grad_begin' & chrt_grad <= `chrt_grad_end')
 
// Step 3: Obtain the agency-level average for seamless enrollment  
preserve

restore
 
// Step 4: Obtain the school-level averages for seamless enrollment and append on the agency average.                   

 
// Step 5: Provide a hs name label for the appended agency average and shorten hs name

 
// Step 6: Generate percentages of high school grads attending college. Multiply outcomes of interest by 100 for graphical representations of the rates
foreach var of varlist enrl_1oct_grad_yr1_* {

}           
 
// Step 7: Create a total seamless college enrollment rates by summing up the other variables                       

 
// Step 8: Prepare to graph the results
// 1. Generate a cohort label to be used in the footnote for the graph
local temp_begin = `chrt_grad_begin'-1
local temp_end = `chrt_grad_end'-1
if `chrt_grad_begin'==`chrt_grad_end' {
    local chrt_label "`temp_begin'-`chrt_grad_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_grad_begin' through `temp_end'-`chrt_grad_end'"
}

// 2. Generate graphing code to place value labels for the total enrollment rates; change xpos (the position of the first leftmost label) and xposwidth (the horizontal width of the labels) to finetune.
sort total_seamless
local total_seamless ""
local num_obs = _N
foreach n of numlist 1/`num_obs' {
    local temp_total_seamless = total_seamless in `n'
    local total_seamless "`total_seamless' `temp_total_seamless'"
}
local total_seamless_label ""
local xpos = 4.8
local xposwidth = 98.7
foreach val of local total_seamless {
    local val_pos = `val' + 3
    local total_seamless_label `"`total_seamless_label' text(`val_pos' `xpos' "`val'", size(2.5) color(gs7))"'
    local xpos = `xpos' + `xposwidth'/_N
}
disp `"`total_seamless_label'"'
 
// Step 9: Graph the results
#delimit ;
graph bar pct_enrl_1oct_grad_yr1_4yr  pct_enrl_1oct_grad_yr1_2yr 
    if hs_diploma >= 20, stack over(last_hs_name, label(angle(40) labsize(small)) gap(20) sort(total_seamless)) 
    bar(1, fcolor(dkorange) fi(inten80) lcolor(dkorange) lwidth(vvvthin)) 
    bar(2, fcolor(navy*.8) fi(inten80) lcolor(dknavy*.8) lwidth(vvvthin))
    blabel(bar, position(inside) color(black) size(small))
legend(label(1 "4-yr Seamless Enrollers") 
    label(2 "2-yr Seamless Enrollers") 
    position(11) ring(0) symxsize(2) symysize(2) rows(2) size(small) region(lstyle(none) lcolor(none) color(none))) 
title("College Enrollment by High School", size(medium)) 
    ytitle("Percent of High School Graduates") 
    subtitle("Seamless Enrollers") 
    `total_seamless_label'
    yscale(range(0(20)100)) 
    ylabel(0(20)100, nogrid)
graphregion(color(white) fcolor(white) lcolor(white)) 
plotregion(color(white) fcolor(white) lcolor(white)) 
note("Sample: `chrt_label' ${agency_name} graduates. Postsecondary enrollment outcomes from NSC matched records." "All other data from administrative records.", size(vsmall));
#delimit cr
graph export "${graphs}/D1_Col_Enrl_Seamless_by_HS.emf", replace
graph save "${graphs}/D1_Col_Enrl_Seamless_by_HS.gph", replace
}
/**** D. College Enrollment ****/
/**** 2. Seamless and Delayed College Enrollment Rates by High School ****/
{
// Step 1: Load the college-going analysis file into Stata
use "${analysis}/CG_Analysis", clear 
 
// Step 2: Keep students in high school graduation cohorts you can observe enrolling in college the fall after graduation
local chrt_grad_begin = 
local chrt_grad_end = 
keep if (chrt_grad >= `chrt_grad_begin' & chrt_grad <= `chrt_grad_end')
 
// Step 3: Create binary outcomes for late enrollers

 
// Step 4: Obtain the agency average for seamless and delayed enrollment        
preserve

restore
 
// Step 4: Obtain the school-level averages for seamless and delayed enrollment and append on the agency average                

 
// Step 5: Provide a hs name label for the appended agency average and shorten hs name

 
// Step 6: Generate percentages of high school grads attending college. Multiply outcomes of interest by 100 for graphical representations of the rates
foreach var of varlist enrl_1oct_grad_yr1_* late_* {

}   
 
// Step 7: Create total college enrollment rates by summing up the other variables; you can add additional labels as you see fit                                                

 
// Step 8: Prepare to graph the results
// Generate a cohort label to be used in the footnote for the graph
local temp_begin = `chrt_grad_begin'-1
local temp_end = `chrt_grad_end'-1
if `chrt_grad_begin'==`chrt_grad_end' {
    local chrt_label "`temp_begin'-`chrt_grad_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_grad_begin' through `temp_end'-`chrt_grad_end'"
}
 
// Step 9: Graph the results
#delimit ;
graph bar pct_enrl_1oct_grad_yr1_4yr pct_late_4yr pct_enrl_1oct_grad_yr1_2yr pct_late_2yr 
    if hs_diploma >= 20, over(last_hs_name, label(angle(40)labsize(small)) gap(20) sort(total)) 
    bar(1, fcolor(dkorange) fi(inten80) lcolor(dkorange) lwidth(vvvthin)) 
    bar(2, fcolor(dkorange*.4) fi(inten80) lcolor(dkorange*.4) lwidth(vvvthin)) 
    bar(3, fcolor(navy*.8) fi(inten80) lcolor(navy*.8) lwidth(vvvthin)) 
    bar(4, fcolor(navy*.4) fi(inten30) lcolor(navy*.4) lwidth(vvvthin)) stack 
    blabel(bar, position(inside) color(black) size(small)) 
legend(label(1 "4-yr Seamless") 
    label(2 "4-yr Delayed") 
    label(3 "2-yr Seamless") 
    label(4 "2-yr Delayed") 
    position(11) order(4 3 2 1) ring(0) symxsize(2) symysize(2) rows(4) size(small) region(lstyle(none) lcolor(none) color(none))) 
title("College Enrollment by High School", size(medium)) 
    ytitle("Percent of High School Graduates") 
    subtitle("Seamless and Delayed Enrollers") 
    yscale(range(0(20)100)) 
    ylabel(0(20)100, nogrid) 
graphregion(color(white) fcolor(white) lcolor(white)) 
plotregion(color(white) fcolor(white) lcolor(white)) 
note("Sample: `chrt_label' ${agency_name} graduates."  
"Postsecondary enrollment outcomes from NSC matched records. All other data from administrative records.", size(vsmall));
#delimit cr
graph export "${graphs}/D2_Col_Enrl_Seamless_Delayed_by_HS.emf", replace
graph save "${graphs}/D2_Col_Enrl_Seamless_Delayed_by_HS.gph", replace
}

// Step 1: Load the college-going analysis file into Stata
use "${analysis}/CG_Analysis", clear
// Step 2: Restrict the sample to include only students from the three most recent graduation cohorts who seamlessly enrolled in four-year institutions after completing high school
local chrt_grad_begin = 
local chrt_grad_end = 
keep if (chrt_grad >= `chrt_grad_begin' & chrt_grad <= `chrt_grad_end') & ///
enrl_1oct_grad_yr1_4yr == 1
// Step 3: Obtain the agency average of the outcomes of interest
preserve

restore
// Step 4: Obtain the school-level averages of the outcomes of interest

// Step 5: Create variables that aggregate the selectivity rankings into the three categories desired (i.e. very competitive to most competitive, competitive, and least competitive or unranked)
foreach v in _mc _hc _vc _c _lc _nr {

}
gen pct_4yr_total = round((enrl_1oct_grad_yr1_4yr * 100), .1)
egen mc_to_vc = rowtotal(pct_4yr_mc pct_4yr_hc pct_4yr_vc)
egen lc_or_nr = rowtotal(pct_4yr_lc pct_4yr_nr)
// Step 6: Create a bar graph of the results
#delimit ;
local temp_begin = `chrt_grad_begin'-1;
local temp_end = `chrt_grad_end'-1;
graph bar mc_to_vc pct_4yr_c lc_or_nr if N >= 20,
over(first_hs_name, label(angle(40)labsize(tiny)) gap(20) sort(pct_4yr_total))
bar(1, fcolor(navy) lcolor(black))
bar(2, fcolor(navy) fi(inten60) lcolor(black))
bar(3, fcolor(gs14) lcolor(black))
stack blabel(bar, position(inside) color(black) size(tiny) format(%9.1f))
legend(label(1 "Very Competitive to Most Competitive" "(e.g. College A / B / C)")
label(2 "Competitive" "(e.g. College A / B / C)")
label(3 "Least Competitive / Unranked" "(e.g. College A / B / C)")
position(10) ring(0) symxsize(2) symysize(2) symplacement(north)
rows(1) region(lstyle(none) lcolor(none) color(none)) size(tiny)
stack justification(center))
title("Four-Year College Enrollment by Barron’s Selectivity Ranking", size(medlarge))
subtitle("among Graduates Enrolled The Fall Following Graduation")
yscale(range(0(20)100)) ylabel(0(20)100, labsize(small))
ytitle("Percent of Graduates", margin(0 3 0 0) size(small))
graphregion(color(white) fcolor(white) lcolor(white))
plotregion(color(white) fcolor(white) lcolor(white))
note("Sample: `temp_begin'-`chrt_grad_begin' through `temp_end'-`chrt_grad_end' ${agency_name} regular diploma recipients. Postsecondary outcomes are from NSC matched records. All other data are from ${agency_name} administrative records.", size(vsmall));
#delimit cr
}

/**** D. College Enrollment ****/ 
/**** 3. College Enrollment Rates by Average 8th Grade Achievement ****/
{
// Step 1: Load the college-going analysis file into Stata
use "${analysis}/CG_Analysis", clear
 
// Step 2: Keep students in high school graduation cohorts you can observe enrolling in college the fall after graduation AND have non-missing eighth grade math scores
local chrt_grad_begin = 
local chrt_grad_end = 
keep if (chrt_grad >= `chrt_grad_begin' & chrt_grad <= `chrt_grad_end') & !mi(test_math_8_std)
 
// Step 3: Obtain agency-level college enrollment rate and prior achievement score along with the position of their labels.

 
// Step 4: Obtain school-level college enrollment rates and prior achievement scores

 
// Step 5: Multiply the college enrollment rate by 100 for graphical representation of the rates

 
// Step 6: Shorten high school names and create a legend label for the graph

 
// Step 7: Prepare to graph the results
// Generate a cohort label to be used in the footnote for the graph
local temp_begin = `chrt_grad_begin'-1
local temp_end = `chrt_grad_end'-1
if `chrt_grad_begin'==`chrt_grad_end' {
    local chrt_label "`temp_begin'-`chrt_grad_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_grad_begin' through `temp_end'-`chrt_grad_end'"
}
 
// Step 8: Graph the results
#delimit ;
twoway (scatter enrl_1oct_grad_yr1_any test_math_8_std, mlabel(hs_code_label) mlabsize(vsmall)
    mlabposition(12) mlabcolor(dknavy) mstyle(x) msize(small) mcolor(dknavy)),
title("College Enrollment Rates by Prior Student Achievement")
    subtitle("Seamless Enrollers")
    xtitle("Average 8th Grade Math Standardized Score", linegap(0.3))
    ytitle("Percent of High School Graduates" " ")
xscale(range(-0.8(0.2)1)) xlabel(-0.8(0.2)1)
yscale(range(0(20)100)) ylabel(0(20)100, nogrid)
legend(on order(3) col(1) label(3 `"`legend_labels'"')
    region(color(none)) size(vsmall) position(2) ring(1) linegap(.75))
    yline(`agency_mean_enroll', lpattern(dash) lcolor(dknavy) lwidth(vvthin))
    xline(`agency_mean_test', lpattern(dash) lcolor(dkorange) lwidth(vvthin))
text(`agency_mean_enroll_label' -0.45 "${agency_name} Average College Enrollment Rate", size(2.0) color(dknavy))
text(20 `agency_mean_test_label' "${agency_name} Average" "Test Score", size(2.0) color(dkorange))
text(99 -0.5 "Below average math scores &" "above average college enrollment",
    size(vsmall) justification(left))
text(99 0.8 "Above average math scores &" "above average college enrollment",
    size(vsmall) justification(right))
text(2 -0.5 "Below average math scores &" "below average college enrollment",
    size(vsmall) justification(left))
text(2 0.8 "Above average math scores &" "below average college enrollment",
    size(vsmall) justification(right))
graphregion(color(white) fcolor(white) lcolor(white))
plotregion(color(white) fcolor(white) lcolor(white))
note("Sample: `chrt_label' ${agency_name} graduates with eighth grade math scores. Postsecondary enrollment" 
"outcomes from NSC matched records. All other data from ${agency_name} administrative records.", size(vsmall));
#delimit cr
graph export "${graphs}/D3_Col_Enrl_by_Avg_Eighth.emf", replace
graph save "${graphs}/D3_Col_Enrl_by_Avg_Eighth.gph", replace
}

/**** D. College Enrollment ****/
/**** 4. College Enrollment Rates by 8th Grade Achievement Quartiles ****/
{
// Step 1: Load the college-going analysis file into Stata
use "${analysis}/CG_Analysis", clear
 
// Step 2: Keep students in high school graduation cohorts you can observe enrolling in college the fall after graduation AND have non-missing eighth grade math scores
local chrt_grad_begin = 
local chrt_grad_end = 
keep if (chrt_grad >= `chrt_grad_begin' & chrt_grad <= `chrt_grad_end') & !mi(qrt_8_math)
 
// Step 3: Obtain the overall agency-level high school graduation rate along with the position of its label.

 
// Step 4: Obtain the agency-level college enrollment rate by test score quartile
preserve

restore
 
// Step 5: Obtain school-level college enrollment rates by test score quartile and append the agency-level enrollment rates by quartile 

 
// Step 6: Shorten high school names and drop any high schools with fewer than 20 students

 
// Step 7: Multiply the college enrollment rate by 100 for graphical representation of the rates

 
// Step 8: Create a variable to sort schools within each test score quartile in ascending order

 
// Step 9: Prepare to graph the results
// Generate a cohort label to be used in the footnote for the graph
local temp_begin = `chrt_grad_begin'-1
local temp_end = `chrt_grad_end'-1
if `chrt_grad_begin'==`chrt_grad_end' {
    local chrt_label "`temp_begin'-`chrt_grad_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_grad_begin' through `temp_end'-`chrt_grad_end'"
}
 
// Step 10: Graph the results
#delimit ;
graph bar enrl_1oct_grad_yr1_any, over(last_hs_name, sort(rank) gap(0) label(angle(70) labsize(vsmall)))
    over(qrt_8_math, relabel(1 "Bottom Quartile" 2 "2nd Quartile" 3 "3rd Quartile" 4 "Top Quartile") gap(400))
    bar(1, fcolor(dknavy) finten(70) lcolor(dknavy) lwidth(thin))
    blabel(bar, position(outside) format(%8.0f) size(tiny))
    yscale(range(0(20)100))
    ylabel(0(20)100, nogrid)
legend(off)
title("College Enrollment Rates")
    subtitle("By Prior Student Achievement, Seamless Enrollers Only", size(msmall))
    ytitle("Percent of High School Graduates")
    yline(`agency_mean', lpattern(dash) lwidth(vvthin) lcolor(dknavy))
text(`agency_mean_label' 5 "${agency_name} Average", size(vsmall))
graphregion(color(white) fcolor(white) lcolor(white))
plotregion(color(white) fcolor(white) lcolor(white))
note("Sample: `chrt_label' ${agency_name} graduates with eighth grade math scores. Postsecondary enrollment" "outcomes from NSC matched records. All other data from ${agency_name} administrative records.", size(vsmall));
#delimit cr
graph export "${graphs}/D4_Col_Enrl_by_Eighth_Qrt.emf", replace
graph save "${graphs}/D4_Col_Enrl_by_Eighth_Qrt.gph", replace
}

/**** D. College Enrollment ****/
/**** 5. Rates of College Enrollment Among Graduates Highly Qualified to Attend Four-Year Colleges By College Type****/
{
// Step 1: Load the college-going analysis file into Stata
use "${analysis}/CG_Analysis", clear
 
// Step 2: Keep students in high school graduation cohorts you can observe enrolling in college the fall after graduation 
local chrt_grad_begin = 
local chrt_grad_end = 
keep if (chrt_grad >= `chrt_grad_begin' & chrt_grad <= `chrt_grad_end') 
 
// Step 3: Get total number of students in sample

 
// Step 4: Further restrict sample to include only highly qualified students

 
// Step 5: Create "undermatch" outcomes

 
// Step 6: Create agency-level outcomes for total undermatching rates
preserve

restore
 
// Step 7: Create race/ethnicity-level outcomes for undermatching rates by race/ethnicity

 
// Step 8: Multiply the college enrollment rate by 100 for graphical representation of the rates
foreach v of varlist no_college enrl_2yr enrl_4yr {

}
 
// Step 9: Multiply the outcome variables corresponding to undermatching by "-1" to visually display these rates as negative values
foreach var of varlist no_college enrl_2yr {

}
 
// Step 10: Prepare to graph the results
// 1. Create labels for numbers in graph
gen pct_total = N/total_count
sort group
local numobs = _N
foreach v of numlist 1/`numobs' {

}
// 2. Generate a cohort label to be used in the footnote for the graph
local temp_begin = `chrt_grad_begin'-1
local temp_end = `chrt_grad_end'-1
if `chrt_grad_begin'==`chrt_grad_end' {
    local chrt_label "`temp_begin'-`chrt_grad_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_grad_begin' through `temp_end'-`chrt_grad_end'"
}
 
// Step 11: Graph the results
#delimit ;
graph bar enrl_4yr enrl_2yr no_college, stack over(group, 
    relabel(1 `""African American" "`pct_1'% of Graduates""' 2 `""Asian American" "`pct_2'% of Graduates""' 3 `""Hispanic American" "`pct_3'% of Graduates""' 4 `""White" "`pct_4'% of Graduates""' 5 `""Total" "`pct_5'% of Graduates""') 
    label(labsize(2.5)) gap(80)) blabel(bar, format(%9.0f) size(small) position(inside) color(black)) 
    bar(1, fcolor(dknavy*.7) lcolor(dknavy*.7) lwidth(vvthin)) 
    bar(2, fcolor(dknavy*.2) lcolor(dknavy*.2) lwidth(vvthin)) 
    bar(3, fcolor(dkorange) lcolor(dkorange) lwidth(vvthin))    
    yscale(range(-20(20)100)) 
    ylabel(-20(20)100, nogrid labsize(small)) 
    ylabel(-20 "20" 0 "0" 20 "20" 40 "40" 60 "60" 80 "80" 100 "100") 
    yline(0, lcolor(black) lwidth(vvthin)) 
title("Rates of Highly Qualified Students Attending College, by Race", size(medlarge) span) 
    subtitle("Among Graduates Eligible to Attend Four-Year Universities", size(*.8) span) 
    ytitle("Percent of Highly-Qualified Graduates" " ", size(small)) 
legend(region(lcolor(white)) position(12) row(1) label(1 "Enrolled at 4-Yr College") 
    label(2 "Enrolled at 2-Yr College") label(3 "Not Enrolled in College") symxsize(2) symysize(2) size(*.7)) 
    graphregion(color(white) fcolor(white) lcolor(white)) 
    plotregion(color(white) fcolor(white) lcolor(white)) 
note(" " "Sample: `chrt_label' ${agency_name} first-time ninth graders. Students who transferred into or out of ${agency_name} are excluded" 
"from the sample. Eligibility to attend a public four-year university is based on students' cumulative GPA and ACT/SAT scores." 
"Sample includes `count_1' African American, `count_2' Asian American students, `count_3' Hispanic, and `count_4' White students." 
"Post-secondary enrollment data are from NSC matched records. $admin_nsc_note", size(2));
#delimit cr
graph export "${graphs}/D5_Col_Enrl_HiQualified_by_Type.emf", replace
graph save "${graphs}/D5_Col_Enrl_HiQualified_by_Type.gph", replace
}
 
/**** D. College Enrollment ****/
/**** 6. Gaps in Rates of College Enrollment Between Race/Ethnic Groups ****/
{
// Step 1: Load the college-going analysis file into Stata
use "${analysis}/CG_Analysis", clear
 
// Step 2: Keep students in high school graduation cohorts you can observe enrolling in college the fall after graduation AND have non-missing eighth grade test scores AND non-missing FRPL status
local chrt_grad_begin = 
local chrt_grad_end = 
keep if (chrt_grad >= `chrt_grad_begin' & chrt_grad <= `chrt_grad_end')
keep if frpl_ever != . | test_math_8 != .
 
// Step 3: Include only black, Latino, and white students
keep if race_ethnicity==1 | race_ethnicity == 3 | race_ethnicity == 5


// Step 4: Estimate the unadjusted and adjusted differences in college enrollment between Latino and white students and between black and white students.
 
// 1. Create a unique codeentifier for each cohort at each high school, so that we can cluster the standard errors at the cohort/high school level 

 
// 2. Fit 4 separate regression models with and without control variables, and save the coefficients associated with each race.
// 2A. Estimate unadjusted enrollment gap

 
// 2B. Estimate enrollment gap adjusting for prior achievement

 

 
// 2D. Estimate enrollment gap adjusting for prior achievement and FRPL status

 
//3. Transform the regression coefficients estimated in Step 4.2 to be displayed in positive % terms
foreach race in afam hisp {

}
 
// Step 5: Retain a data file containing only the regression coefficients

 
// Step 6: Prepare to graph the results
// Generate a cohort label to be used in the footnote for the graph
local temp_begin = `chrt_grad_begin'-1
local temp_end = `chrt_grad_end'-1
if `chrt_grad_begin'==`chrt_grad_end' {
    local chrt_label "`temp_begin'-`chrt_grad_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_grad_begin' through `temp_end'-`chrt_grad_end'"
}

// Step 7: Graph the results
// 1. Graph results for black and white students
#delimit ;
graph bar afam_unadj afam_adj_prior_ach afam_adj_frpl afam_adj_prior_frpl,
    legend(row(2) size(vsmall) region(lcolor(white)) 
    label(1 "Unadjusted enrollment gap") 
    label(2 "Gap adjusted for prior achievement") 
    label(3 "Gap adjusted for FRPL status") 
    label(4 "Gap adjusted for prior achievement & FRPL status")) 
outergap(300)   
blabel(bar, format(%9.0f) size(vsmall))
    bar(1, fcolor(dknavy) lcolor(dknavy) fi(inten100)) 
    bar(2, fcolor(dknavy) lcolor(dknavy) fi(inten70))
    bar(3, fcolor(dknavy) lcolor(dknavy) fi(inten50)) 
    bar(4, fcolor(dknavy) lcolor(dknavy) fi(inten20))
    title("Differences In Rates Of College Enrollment" 
    "Between Black High School Graduates And White High" 
    "School Graduates", size(med))
    ytitle("Percentage Points", margin(2 2 0 0) size(small))
    yscale(range(-20(10)50)) ylabel(-20(10)50, labsize(small)) 
    graphregion(color(white) fcolor(white) lcolor(white)) 
    plotregion(color(white) fcolor(white) lcolor(white)) 
note("Sample: `chrt_label' high school graduates. Postsecondary enrollment outcomes from NSC matched records. All other data from ${agency_name} administrative records.", size(vsmall));
#delimit cr
 
// 2. Graph results for Latino and white students
#delimit ;
graph bar hisp_unadj hisp_adj_prior_ach hisp_adj_frpl hisp_adj_prior_frpl,
    legend(row(2) size(vsmall) region(lcolor(white)) 
    label(1 "Unadjusted enrollment gap") 
    label(2 "Gap adjusted for prior achievement") 
    label(3 "Gap adjusted for FRPL status") 
    label(4 "Gap adjusted for prior achievement & FRPL status")) 
    outergap(300)
blabel(bar, format(%9.0f) size(vsmall))
    bar(1, fcolor(dknavy) lcolor(dknavy) fi(inten100)) 
    bar(2, fcolor(dknavy) lcolor(dknavy) fi(inten70))
    bar(3, fcolor(dknavy) lcolor(dknavy) fi(inten50)) 
    bar(4, fcolor(dknavy) lcolor(dknavy) fi(inten20))
    title("Differences In Rates Of College Enrollment" 
    "Between Latino High School Graduates And White High" 
    "School Graduates", size(med))
    ytitle("Percentage Points", margin(2 2 0 0) size(small))
    yscale(range(-20(10)50)) ylabel(-20(10)50, labsize(small)) 
    graphregion(color(white) fcolor(white) lcolor(white)) 
    plotregion(color(white) fcolor(white) lcolor(white)) 
note("Sample: `chrt_label' high school graduates. Postsecondary enrollment outcomes from NSC matched records." "All other data from ${agency_name} administrative records.", size(vsmall));
#delimit cr
graph export "${graphs}/D6_Col_Enrl_Gap_Latino_Black.emf", replace
graph save "${graphs}/D6_Col_Enrl_Gap_Latino_Black.gph", replace
} 
 
/**** D. College Enrollment ****/
/**** 7. College Enrollment Rates by 8th Grade Achievement Quartiles - Bubbles ****/
{
// Step 1: Load the college-going analysis file into Stata
use "${analysis}/CG_Analysis", clear
 
// Step 2: Keep students in high school graduation cohorts you can observe enrolling in college the fall after graduation AND have non-missing eighth grade test scores
local chrt_grad_begin = 
local chrt_grad_end = 
keep if (chrt_grad >= `chrt_grad_begin' & chrt_grad <= `chrt_grad_end') 
keep if qrt_8_math != .
 
// Step 4: Create agency- and school-level average outcomes for each quartile
// 1. Calculate the mean of each outcome variable by high school

// 2. Calculate the mean of each outcome variable for the agency as a whole

 
// Step 5: Prepare to graph the results
// Generate a cohort label to be used in the footnote for the graph
local temp_begin = `chrt_grad_begin'-1
local temp_end = `chrt_grad_end'-1
if `chrt_grad_begin'==`chrt_grad_end' {
    local chrt_label "`temp_begin'-`chrt_grad_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_grad_begin' through `temp_end'-`chrt_grad_end'"
}
 
// Step 6: Graph the results
gen agency_quartile_code = .
forvalues qrt = 1(1)4 {

}   
 
#delimit ;
graph twoway scatter pct_enrl agency_quartile_code [aweight = hs_diploma], 
    msymbol(Oh) msize(vsmall) mcolor(dknavy) || 
scatter agency_avg agency_quartile_code, 
    mcolor(cranberry) msymbol(D) msize(small) 
title("College Enrollment Rates Among High School" 
"Graduates Within Quartile Of Prior Achievement," 
"By High School", size(med)) 
    xscale(range(1 6)) yscale(range(0 105)) ylabel(0 20 40 60 80 100) 
    xlabel(1.2 "Q1" 1.4 "Q2" 1.6 "Q3" 1.8 "Q4", labsize(small)) 
    xtitle(" " "Quartile of Prior Achievement") ytitle("Percent" " ") 
    ylabel(,nogrid) legend(off) 
graphregion(color(white) fcolor(white) lcolor(white)) 
plotregion(color(white) fcolor(white) lcolor(white))
xline(2)  
note("Sample: `chrt_label' high school graduates. Postsecondary enrollment outcomes from NSC matched records." 
"All other data from ${agency_name} administrative records.", size(vsmall));
#delimit cr
graph export "${graphs}/D7_Col_Enrl_by_Eighth_Qrt_Bubbles.emf", replace
graph save "${graphs}/D7_Col_Enrl_by_Eighth_Qrt_Bubbles.gph", replace
}
 
/**** D. College Enrollment ****/
/**** 8. Undermatch Rates Among Highly Qualified High School Graduates  ****/
{
// Step 1: Load the post-sec analysis file into Stata
use "${analysis}/CG_Analysis", clear
 
// Step 2: Keep students in high school graduation cohorts you can observe enrolling in college the fall after graduation AND are highly qualified
local chrt_grad_begin = 
local chrt_grad_end = 
keep if (chrt_grad >= `chrt_grad_begin' & chrt_grad <= `chrt_grad_end')
keep if highly_qualified == 1
 
// Step 3: Link the analysis file with the college selectivity table to obtain the selectivity level for each college. Use this selectivity information to create college enrollment indicator variables for each college selectivity level. This script assumes that there are 5 levels of selectivity, as in Barron’s College Rankings—Most Competitive (1), Highly Competitive (2), Very Competitive (3), Competitive (4), Least Competitive (5)—as well as a category for colleges without assigned selectivity (assumed to be not competitive).
//1. Link analysis file with college selectivity data 

//2. Create college enrollment dummy variables for each of the five selectivity levels
forvalues i = 1/5 {

}
 
//3. Create a college enrollment dummy variable for colleges that are not ranked 

 
//4. Rename and label the college enrollment variables with clear labels

 
//5. Check to make sure that each student who appears enrolled in college as of the first fall after high school graduation is associated with one and only one college selectivity level

 
// Step 4: Create undermatch outcomes
//1. Not enrolled in college
 
//2. Enrolled in a 2-year college

//3. Enrolled in a least competitive 4-year college or a 4-year college without an assigned selectivity

//4. Enrolled in a 4-year college with a selectivity rating of Competitive, Very Competitive, Most Competitive, or Highly Competitive

//5. Check to make sure that each student is associated one and only one undermatch outcome
// assert no_college + enrl_2yr + enrl_4yr_under + enrl_4yr_match == 1
 
// Step 5: Create agency-average undermatch outcomes and transform them into % terms

foreach v of varlist no_college enrl_2yr enrl_4yr_under enrl_4yr_match {

}
 
// Step 6: Prepare to graph the results
// Generate a cohort label to be used in the footnote for the graph
local temp_begin = `chrt_grad_begin'-1
local temp_end = `chrt_grad_end'-1
if `chrt_grad_begin'==`chrt_grad_end' {
    local chrt_label "`temp_begin'-`chrt_grad_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_grad_begin' through `temp_end'-`chrt_grad_end'"
}

// Step 7: Graph the results
#delimit ;
graph bar no_college enrl_2yr enrl_4yr_under, stack
    blabel(bar, format(%9.1f) size(2.05) position(inside) color(white)) 
    bar(1, fcolor(dknavy) lcolor(dknavy) finten(200) lwidth(thin)) 
    bar(2, fcolor(dknavy) lcolor(dknavy) finten(90) lwidth(thin)) 
    bar(3, fcolor(dknavy) lcolor(dknavy) finten(40) lwidth(thin))
    yscale(range(0(5)35)) outergap(400)
    ylabel(0(5)35, labsize(small)) 
title("Undermatch Rates by Agency" 
    "Among Highly Qualified High School Graduates", size(med)) 
    ytitle("Percent of High School Graduates" " ", size(small)) 
legend(region(lcolor(white)) 
    label(1 "Not Enrolled in College") 
    label(2 "Enrolled at 2-Year College") 
    label(3 "Enrolled at Unranked or Less Competitive 4-Year College") 
    symxsize(*.7) symysize(*.7) size(*.7)) 
graphregion(color(white) fcolor(white) lcolor(white)) 
plotregion(color(white) fcolor(white) lcolor(white))
note("Sample: `chrt_label' high school graduates. Postsecondary enrollment outcomes from NSC matched records." 
"All other data from ${agency_name} administrative records.", size(vsmall)) ;
#delimit cr
graph export "${graphs}/D8_Undermatching_HiQualified.emf", replace
graph save "${graphs}/D8_Undermatching_HiQualified.gph", replace
}
 
/**** E. College Persistence ****/
/**** 1. Persistence Rates to the Second Year of College by High School ****/
{
// Step 1: Load the college-going analysis file into Stata
use "${analysis}/CG_Analysis", clear
 
// Step 2: Keep students in high school graduation cohorts you can observe enrolling in college the fall after graduation
local chrt_grad_begin =
local chrt_grad_end = 
keep if (chrt_grad >= `chrt_grad_begin' & chrt_grad <= `chrt_grad_end')
 
// Step 3: Rename outcome variable names for simplicity

 
// Step 4: Obtain the agency-level average for persistence and enrollment
preserve

restore
 
preserve

restore
 
// Step 5: Obtain the school-level average for persistence and enrollment
preserve

restore 
 

 
// Step 6: Append on the previous agency-level and school-level files

 
// Step 7: Provide a hs name label for the agency average and shorten hs name

 
// Step 8: Calculate percent persistence at 4-year and 2-year colleges and multiply outcomes of interest by 100 for graphical representation of the rates

 
foreach type in 2yr 4yr {

}
 
// Step 9: Drop any high schools with fewer than 20 students
 
 
// Step 10: Consolidate persistence data into single column and then reshape the data

 
// Step 11: Prepare to graph the results
// Generate a cohort label to be used in the footnote for the graph
local temp_begin = `chrt_grad_begin'-1
local temp_end = `chrt_grad_end'-1
if `chrt_grad_begin'==`chrt_grad_end' {
    local chrt_label "`temp_begin'-`chrt_grad_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_grad_begin' through `temp_end'-`chrt_grad_end'"
}
 
// Step 12: Graph the results
#delimit ;
graph bar pct_persist4 pct_persist2, 
    over(last_hs_name, label(angle(45)labsize(small)) sort(pct_persist4)) bargap(0) outergap(100) 
    bar(1, fcolor(dkorange) fi(inten70) lcolor(dkorange) lwidth(vvvthin)) 
    bar(2, fcolor(navy) fi(inten60) lcolor(navy) lwidth(vvvthin)) 
    blabel(total, position(outside) color(black) size(vsmall) format(%8.0f)) 
legend(label(1 "4-year College") label(2 "2-year College") 
    position(11) ring(1) symxsize(2) symysize(2) rows(2) size(small) region(lstyle(none) lcolor(none) color(none)))  
title("College Persistence by High School, at Any College") 
    subtitle("Seamless Enrollers by Type of College") 
    ytitle("% of Seamless Enrollers") 
    yscale(range(0(20)100)) 
    ylabel(0(20)100, nogrid) 
graphregion(color(white) fcolor(white) lcolor(white)) 
plotregion(color(white) fcolor(white) lcolor(white)) 
note(" " "Sample: `chrt_label' ${agency_name} high school graduates. Postsecondary enrollment outcomes from NSC matched records." 
"All other data from agency administrative records.", size(vsmall));            
#delimit cr     
graph export "${graphs}/E1_Persistence_by_HS.emf", replace
graph save "${graphs}/E1_Persistence_by_HS.gph", replace              
}
 
/**** E. College Persistence ****/
/**** 2. Persistence Across Two-Year and Four-Year Colleges ****/
{
// Step 1:Load the college-going analysis file into Stata
use "${analysis}/CG_Analysis", clear 
 
// Step 2: Keep students in high school graduation cohorts you can observe enrolling in college the fall after graduation
local chrt_grad_begin = 
local chrt_grad_end = 
keep if (chrt_grad >= `chrt_grad_begin' & chrt_grad <= `chrt_grad_end')
 
// Step 3: Rename outcome variable names for simplicity

 
// Step 4: Create binary outcomes for enrollers who switch from 4-yr to 2-yr, or vice versa

 
// Step 5: Obtain the agency-level average for the different persistence outcomes
preserve

restore
 
// Step 6: Obtain the school-level average for the different persistence outcomes

 
// Step 7: Provide a hs name label for the agency average and shorten hs name

 
// Step 8: Generate percentages for different persistence outcomes.  Multiply outcomes of interest by 100 for graphical representations of the rates

 
foreach var in pct_persist_2yr pct_persist_2to4yr pct_persist_4yr pct_persist_4to2yr {

}
 
// Step 9: Create total persistence rates by summing up the other variables

 
//Step 10: Prepare to graph the results
// 1. Generate a cohort label to be used in the footnote for the graph
local temp_begin = `chrt_grad_begin'-1
local temp_end = `chrt_grad_end'-1
if `chrt_grad_begin'==`chrt_grad_end' {
    local chrt_label "`temp_begin'-`chrt_grad_begin'"
} 
else {
    local chrt_label "`temp_begin'-`chrt_grad_begin' through `temp_end'-`chrt_grad_end'"
}
// 2. Generate graphing code to place value labels for the total persistence rates; change xpos (the position of the first leftmost label) and xposwidth (the horizontal width of the labels) to finetune.
foreach yr in 4 2 {
    sort total_persist_`yr'yr
    local total_persist_`yr'yr ""
    local num_obs = _N
    foreach n of numlist 1/`num_obs' {
    local temp_total_persist_`yr'yr = total_persist_`yr'yr in `n'
    local total_persist_`yr'yr `"`total_persist_`yr'yr' `temp_total_persist_`yr'yr'"'
    }
    local total_persist_`yr'yr_label ""
    local xpos = 7
    local xposwidth = 93.5
    foreach val of local total_persist_`yr'yr {
    local val_pos = `val' + 6
    local total_persist_`yr'yr_label `"`total_persist_`yr'yr_label' text(`val_pos' `xpos' "`val'", size(2.1) color(gs7))"'
    local xpos = `xpos' + `xposwidth'/_N
    }
    disp `"`total_persist_`yr'yr_label'"'
}

// Step 11: Graph the results (1/2) for seamless enrollers at 4-year colleges
#delimit ;
graph bar pct_persist_4yr pct_persist_4to2yr if enrl_4yr >= 20, 
    over(last_hs_name, label(angle(45)labsize(small)) sort(total_persist_4yr)) bargap(0) outergap(100) 
    bar(1, fcolor(dkorange) fi(inten70) lcolor(dkorange) lwidth(vvvthin)) 
    bar(2, fcolor(navy) fi(inten60) lcolor(navy) lwidth(vvvthin)) stack 
    blabel(bar, position(inside) color(black) size(vsmall) format(%8.0f)) 
legend(label(1 "Persisted at 4-year College") label(2 "Switched to 2-year College") 
    position(11) order(2 1) ring(1) symxsize(2) symysize(2) rows(2) size(small) region(lstyle(none) lcolor(none) color(none)))  
title("College Persistence by High School") 
    subtitle("Seamless Enrollers at 4-year Colleges") 
    `total_persist_4yr_label'
    ytitle("Percent of Seamless Enrollers") 
    yscale(range(0(20)100)) 
    ylabel(0(20)100, nogrid) 
graphregion(color(white) fcolor(white) lcolor(white)) 
plotregion(color(white) fcolor(white) lcolor(white)) 
note(" " "Sample: `chrt_label' ${agency_name} high school graduates. Postsecondary enrollment outcomes from NSC matched records." 
"All other data from agency administrative records.", size(vsmall));
#delimit cr
graph export "${graphs}/E2a_Persistence_4yr_Seamless_Enrlers.emf", replace
graph save "${graphs}/E2a_Persistence_4yr_Seamless_Enrlers.gph", replace  
 
// Step 12: Graph the results (1/2) for seamless enrollers at 2-year colleges
#delimit ;
graph bar pct_persist_2yr pct_persist_2to4yr if enrl_4yr >= 20, 
    over(last_hs_name, label(angle(45)labsize(small)) sort(total_persist_2yr)) bargap(0) outergap(100) 
    bar(1, fcolor(navy) fi(inten60) lcolor(navy) lwidth(vvvthin)) 
    bar(2, fcolor(dkorange) fi(inten70) lcolor(dkorange) lwidth(vvvthin)) stack 
    blabel(bar, position(inside) color(black) size(vsmall) format(%8.0f)) 
legend(label(2 "Switched to 4-year College") label(1 "Persisted at 2-year College") 
    position(11) order(2 1) ring(1) symxsize(2) symysize(2) rows(2) size(small) region(lstyle(none) lcolor(none) color(none)))  
title("College Persistence by High School") 
    subtitle("Seamless Enrollers at 2-year Colleges") 
    `total_persist_2yr_label'
    ytitle("Percent of Seamless Enrollers") 
    yscale(range(0(20)100)) 
    ylabel(0(20)100, nogrid) 
graphregion(color(white) fcolor(white) lcolor(white)) 
plotregion(color(white) fcolor(white) lcolor(white)) 
note(" " "Sample: `chrt_label' ${agency_name} high school graduates. Postsecondary enrollment outcomes from NSC matched records." 
"All other data from agency administrative records.", size(vsmall));
#delimit cr
graph export "${graphs}/E2b_Persistence_2yr_Seamless_Enrlers.emf", replace
graph save "${graphs}/E2b_Persistence_2yr_Seamless_Enrlers.gph", replace  
}

/**** E. College Persistence ****/
/**** 3. Top-Enrolling Colleges/Universities of Agency Graduates ****/
{
// Step 1: Load the college-going analysis file into Stata
use "${analysis}/CG_Analysis", clear 
 
// Step 2: Keep students in high school graduation cohorts you can observe enrolling in college the fall after graduation
local chrt_grad_begin = ${chrt_grad_begin}
local chrt_grad_end = ${chrt_grad_end}
keep if (chrt_grad >= `chrt_grad_begin' & chrt_grad <= `chrt_grad_end')
 
// Step 3: Indicate the number of top-enrolling institutions you would like listed
local num_inst = 5

// Step 4: Calculate the number and % of students enrolled in each college the fall after graduation, 
// and the number and % of students persisting, by college type

// 1. Calculate for 4-year colleges
preserve


	
restore

// 2. Calculate for 2-year colleges, and append the information for 4-year colleges


// Step 5: Create Table 1 with all 2-year and 4-year colleges listed
preserve

    // 1. Create two observations, one for each college type
	local newrows = _N+2
	set obs `newrows'
	replace  type="2yr" if _n==_N-1
	replace  type="4yr" if _n==_N
	
	replace  first_college_name = "ALL 2-YEAR COLLEGES" if type=="2yr" & mi(first_college_name)
	replace  first_college_name = "ALL 4-YEAR COLLEGES" if type=="4yr" & mi(first_college_name)

	// 2. Populate the new observations 
	foreach type in 2 4 {
		summ total_enrolled if type == "`type'yr"
		replace enrl_1oct_grad_yr1 = r(mean) if first_college_name=="ALL `type'-YEAR COLLEGES"
		summ total_persisted if type == "`type'yr"
		replace enrl_grad_persist = r(mean) if first_college_name=="ALL `type'-YEAR COLLEGES"
	}
	replace pct_enrolled_college = 100 if mi(pct_enrolled_college)
	
	// 3. Retain, reorder, and rename necessary variables
	keep first_college_name enrl_1oct_grad_yr1 enrl_grad_persist pct_enrolled_college pct_persist_college type
	order first_college_name enrl_1oct_grad_yr1 pct_enrolled_college enrl_grad_persist pct_persist_college type
	
	gen rank = (regexm(first_college_name, "ALL"))
	gsort -type rank -enrl_1oct_grad_yr1
	drop rank type
	
	rename first_college_name College_Name
	rename enrl_1oct_grad_yr1 Number_Enrolled
	rename pct_enrolled_college Percent_Enrolled
	rename enrl_grad_persist Number_Persisted
	rename pct_persist_college Percent_Persisted

	// 4. Outsheet Table 1 into a csv file
	outsheet using "${graphs}/E3_Top_Enrl_Col_Institutions_Table_1.csv", comma replace

restore

// Step 6: Create Tables 2 and 3 with the number of institutions you wanted to list in Step 3 for 4-year (Table 2) and 2-year (Table 3) colleges, respectively
// 1. Identify the five top-enrolling 2- and 4-year institutions (5 based on the number you selected in step 3)
gsort type -pct_enrolled_college
gen rank_2yr = _n in 1/`num_inst' 

gsort -type -pct_enrolled_college
gen rank_4yr = _n in 1/`num_inst' 

// 2. Calculate the remaining proportion of students attending other 2- and 4-year colleges for purposes of populating the "Other" line (all other 2- and 4-year colleges beyond the number selected) in the table.
foreach type in 2yr 4yr {
	egen other_number_`type'_temp = sum(enrl_1oct_grad_yr1) if mi(rank_`type') & type=="`type'"
	egen other_number_`type' = max(other_number_`type'_temp) 
	egen other_pct_`type'_temp = sum(pct_enrolled_college) if mi(rank_`type') & type=="`type'"
	egen other_pct_`type' = max( other_pct_`type'_temp) 
	egen other_number_persist_`type'_temp = sum(enrl_grad_persist) if mi(rank_`type') & type=="`type'"
	egen other_number_persist_`type' = max(other_number_`type'_temp) 
	drop *_temp
}

keep if !mi(rank_2yr) | !mi(rank_4yr)

// 3. Create four new rows, one per college type for total counts and one per college type for colleges other than the top-enrolling ones
local newrows = _N+4
set obs `newrows'
replace  type="2yr" if _n==_N-2 | _n==_N-3
replace  type="4yr" if _n==_N | _n==_N-1

replace first_college_name = "OTHER 2-YEAR COLLEGES" if type=="2yr" & mi(first_college_name) & _n==_N-3
replace first_college_name = "ALL 2-YEAR COLLEGES" if type=="2yr" & mi(first_college_name) & _n==_N-2
replace first_college_name = "OTHER 4-YEAR COLLEGES" if type=="4yr" & mi(first_college_name) & _n==_N-1	
replace first_college_name = "ALL 4-YEAR COLLEGES" if type=="4yr" & mi(first_college_name) & _n==_N

// 4. Populate the new rows
foreach type in 2 4 {
	summ total_enrolled if type == "`type'yr"
	replace enrl_1oct_grad_yr1 = r(mean) if first_college_name=="ALL `type'-YEAR COLLEGES"
	summ total_persisted if type == "`type'yr"
	replace enrl_grad_persist = r(mean) if first_college_name=="ALL `type'-YEAR COLLEGES"
	summ other_number_`type'yr if type == "`type'yr"
	replace enrl_1oct_grad_yr1 = r(mean) if first_college_name=="OTHER `type'-YEAR COLLEGES"
	summ other_pct_`type'yr if type == "`type'yr"
	replace pct_enrolled_college = r(mean) if first_college_name=="OTHER `type'-YEAR COLLEGES"
	summ other_number_persist_`type'yr if type == "`type'yr"
	replace enrl_grad_persist = r(mean) if first_college_name=="OTHER `type'-YEAR COLLEGES"
}
replace pct_enrolled_college = 100 if mi(pct_enrolled_college)

// 5. Retain, reorder, and rename necessary variables
keep first_college_name enrl_1oct_grad_yr1 enrl_grad_persist pct_enrolled_college pct_persist_college type
order first_college_name enrl_1oct_grad_yr1 pct_enrolled_college enrl_grad_persist pct_persist_college type

gen rank = (regexm(first_college_name, "ALL"))
replace rank = 0.5 if regexm(first_college_name, "OTHER")
gsort -type rank -enrl_1oct_grad_yr1
drop rank

rename first_college_name College_Name
rename enrl_1oct_grad_yr1 Number_Enrolled
rename pct_enrolled_college Percent_Enrolled
rename enrl_grad_persist Number_Persisted
rename pct_persist_college Percent_Persisted

// 6. Outsheet Table 2 (4-year colleges) into a csv file
preserve
	keep if type=="4yr"
	drop type
	outsheet using "${graphs}/E3_Top_Enrl_Col_Institutions_Table_2.csv", comma replace
restore

// 7. Outsheet Table 3 (2-year colleges) into a csv file
preserve
	keep if type=="2yr"
	drop type
	outsheet using "${graphs}/E3_Top_Enrl_Col_Institutions_Table_3.csv", comma replace
restore

}
