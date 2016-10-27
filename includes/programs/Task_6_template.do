/****************************************************************************
* File name: Task_6.do
* Author(s): 
* Date: 
* Description: This program generates a clean Student_Class_Enrollment file
* through two parts: 
* Part  I: Cleaning the Class file
* Part II: Cleaning the Student_Class_Enrollment file
*
* Inputs: /raw/Class_Raw.dta
		  /raw/Student_Class_Enrollment.dta
*
* Outputs: /clean/Student_Class_Enrollment_Merged.dta
*
***************************************************************************/

clear
set more off
capture log close

cd "C:\Desktop\sdp_toolkit\"
 
global raw ".\raw"
global clean ".\clean"
global programs ".\programs"

log using "${programs}\task6.txt", text replace

/*** Part I: Clean the Class file ***/
{
/*** Step 0: Load the Class_Raw data file. ***/
	use "${raw}\Class_Raw.dta", clear

/*** Step 1: Review the data and drop incomplete observations. ***/

// 1. Identify the critical variables that identify a class.
	
// 2. Drop the observations where any of the critical variables are missing
	

/*** Step 2: Flag core math and English courses. ***/

// Note that agencies may have varying consistency in course names and use different criteria to identify a core course vs an elective.
// In some cases, other criteria may have to be applied to identify core courses (e.g. the department the course is listed in, or length of the course.)
// We provide a simplified version of the cleaning process for the class file: work within your agency to determine the best criteria.

// 1. Tabulate course names
	

// 2. Flag math courses based on the tabulation results

	// Generate a flag variable
	

	// Use the regexm function to identify course names that contain common word stems, but slightly different spellings, e.g. Algebra I and Algebra-I
	
								
	// Use the inlist funtion to identify other course names 
						
	
	// Check the results of flagging your variables
	
	
	// Once each math course has been flagged, mark the non-math courses.
	
	
// 3. Repeat this process for flagging ELA courses 

	// Generate a flag variable
	

	// Use the regexm function to identify course names that contain common word stems, but slightly different spellings
	
														
	// Check the results of flagging your variables
	
	
	// Once each ELA course has been flagged, mark the non-ELA courses.
	

/**** Step 3: Drop any unneeded variables, drop duplicates, and save the temporary file ****/
		
// 1. Drop the course_code_desc, as it is no longer needed. 
	

// 2. Verify that the data is unique by cid, and also unique by school year, school code, section code and course code.
	
// 3. Save the data in a temporary file
	

/*** Part II: Clean the Student_Class_Enrollment file. ***/
{
/*** Step 0: Load the Student_Class_Enrollment data file. ***/
	use "${raw}\Student_Class_Enrollment.dta", clear
	
/*** Step 1: Merge on the temporary Class file you saved earlier to the Student_Class_Enrollment file ***/
	

	// Keep only observations that merged from both files

/*** Step 2: Evaluate course marks. ***/

	
	// Some letter marks (NGPA and P) indicate that they do not count toward GPA, so you may leave the numeric mark as missing.
	
/*** Step 3: Evaluate course completion. ***/

	// Drop observations that have no record of course completion
	
/*** Step 4: Evaluate course enrollment. ***/
// Fix cases where a student has multiple observations for the same course with the same year and marking period (i.e. with overlapping enrollment dates)

// 1. Remove enrollment and withdrawal dates that are not in the current school year
	
// 2. Identify the variables that identify a course
	
// 3. Populate all enrollments with the earliest enrollment date
	
	
// 4. Populate all enrollments with the latest withdrawal date
	
		
/**** Step 5: Drop any unneeded variables, drop duplicates, and save the file ****/

// 1. Drop duplicate values
	
// 2. Verify that the file is unique by sid and cid
	
// 3. Order the variables
	
// 4. Sort the data

// 5. Save the current file as Student_Class_Enrollment_Merged.dta.
	save "${clean}\Student_Class_Enrollment_Merged.dta" , replace 
}

capture log close
