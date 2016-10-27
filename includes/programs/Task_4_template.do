/****************************************************************************
* File name: Task_4.do
* Author(s): 
* Date: 
* Description: This program generates a clean Student_School_Enrollment file unique
* by sid + school_year + school_code + enrollment_date by:
* 1. Creating a school_start and school_end variable 
* 2. Removing abnormal enrollment observations
* 3. Consolidating overlapping enrollments by student by school.
* 4. Updating days_enrolled based on the consolidated enrollments using enrollment and withdrawal dates.
* 5. Determining the last withdrawal code for each student.
*
* Inputs: /raw/Student_School_Enrollment_Raw.dta
*
* Outputs: /clean/Student_School_Enrollment_Clean.dta
*
***************************************************************************/

clear
set more off
capture log close

cd "C:\Desktop\sdp_toolkit\"

global raw ".\raw"
global clean ".\clean"
global programs ".\programs"

log using "${programs}\task4.txt", text replace

/*** Step 0: Load the Student_School_Enrollment_Raw data file ***/
	use "${raw}\Student_School_Enrollment_Raw.dta", clear

/*** Step 1: Create a school_start and school_end variable  ***/
// In this example, school start is August 1, and school end is July 31 of each school year. This may be different in your agency.

	

/*** Step 2: Remove abnormal enrollment observations.  ***/

// 1. Drop observations missing both enrollment and withdrawal dates.
	
// 2. Drop observations with enrollment and withdrawal dates on same day.
	
		
// 3. Drop observations with withdrawal date earlier than enrollment date.
	

// 4. Drop observations with enrollment date after the end of the current school year.
	

// 5. Drop observations with enrollment date before the beginning of the current school year.
	
// 6. Drop observations with withdrawal date more than one month after the end of the school year.
	
// 7. Check to make sure enrollment dates are in the correct school year.
	
/*** Step 3: Consolidate overlapping enrollments by student by school.  ***/
		
// 1. Sort enrollment spells in ascending order and then check how many overlapping enrollment spells exist for a student at the same school.	
	

// 2. For overlapping observations, replace the enrollment date and enrollment code description of all but the first enrollment spell with the earliest enrollment date
	
	// Replace enrollment_date
	
		
	// Replace enrollment_code_description		
	
	

// 3. Replace the withdrawal date and withdrawal code description of the earliest enrollment spell with the latest withdrawal date. 

	// Sort the data first so that latest withdrawal information appears as the first record.
	
	// Replace withdrawal_date
	
		
	// Replace withdrawal_code_description	
	
				
/*** Step 4: Update days_enrolled based on the consolidated enrollments using the new enrollment and withdrawal dates.  ***/
		
	
		
/*** Step 5: Determine the last withdrawal code for each student. You will use this data in later analyses to determine a student's end of high school outcomes.  ***/
	
	
/**** Step 6: Drop any unneeded variables, drop duplicates, and save the file ****/

// 1. Drop duplicate records
	

// 2. Confirm that file is unique by student/school_year/school_code/enrollment_date		
	

// 3. Save the current file as Student_School_Enrollment_Clean
	save "${clean}\Student_School_Enrollment_Clean.dta", replace

capture log close
