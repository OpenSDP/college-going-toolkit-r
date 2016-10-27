/****************************************************************************
* File name: Task_3.do
* Author(s): 
* Date:
* Description: This program assigns students to a ninth grade cohort
* based on the school year the student first appears in ninth grade by:
* 1. Flagging the first school year a student enrolls in grades 9, 10, 11, or 12.
* 2. Identifying the school year in which the student was first observed in 9th grade.
* 3. Imputing the year when transfer students would have been in grade 9.
* 4. Adjusting the assignment of first_9th_school_year_observed for students who appear in a lower grade later.
*
* Inputs: /raw/Student_School_Year.dta
*
* Outputs: /clean/Student_School_Year_Ninth.dta
*
***************************************************************************/

clear
set more off
capture log close

cd "C:\Desktop\sdp_toolkit\"

global raw ".\raw"
global clean ".\clean"
global programs ".\programs"


log using "${programs}\task3.txt", text replace

/*** Step 0: Load the Student_School_Year data file ***/
	use "${clean}\Student_School_Year.dta", clear

/*** Step 1: Flag the first school year a student enrolls in grades 9, 10, 11, or 12. ***/

	// Create four binary indicators to flag the first school year a student enrolls in grades 9, 10, 11, or 12.
	foreach grade in 9 10 11 12 

	// Check how many students are identified as enrolled in grades 9, 10, 11, or 12
	foreach grade in 9 10 11 12 

	
/*** Step 2: Identify the school year in which the student was first observed in 9th grade. ***/

	// Create a variable that lists the first school year a student is observed as enrolled in grade 9. 
	

	// Check the distribution of first_9th_school_year_observed across years
	
	
/*** Step 3: Impute the school year in which transfer students would have been in grade 9. ***/

	// Impute first_9th_school_year_observed as school_year - 1, school_year - 2, or school_year - 3  
	// for students first observed in 10th, 11th or 12th grade as transfer-ins
	

	
	// Review the distribution of first_9th_school_year_observed for students who transferred in grades 10-12
	
	
/*** Step 4: Adjust the imputation of first_9th_school_year_observed for students who appear in a lower grade in a later school year. ***/

// 1. Flag students who are observed to be in a lower grade in a subsequent school year.
	

// 2. Flag the first school year in which students appear in high school grades
	

// 3. Create temporary variables imputing the appropriate first school year of ninth grade
	
// 4. Replace the first_9th_school_year_observed with the correctly imputed values
	

/*** Step 5: Keep only variables relevant to future analyses, and save the file.  ***/	

	// Keep relevant variables
	keep sid school_year grade_level frpl iep ell gifted total_days_enrolled days_absent days_suspended_out_of_school first_9th_school_year_observed

	// Save the current file as Student_School_Year_Ninth.dta.
	save "${clean}\Student_School_Year_Ninth.dta", replace

capture log close
