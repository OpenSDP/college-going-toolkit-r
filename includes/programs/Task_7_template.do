/****************************************************************************
* File name: Task_7.do
* Author(s): 
* Date: 
* Description: This program generates a clean Student_NSC_Enrollment file by: 
* 1. Standardizing the NSC variables.
* 2. Identifying first college attended (any, 4-year, and 2-year) that didn't result in a withdrawal.
*
* Inputs: /raw/Student_NSC_Enrollment.dta
*
* Outputs: /clean/Student_NSC_Enrollment_Indicators.dta
*
***************************************************************************/

clear
set more off
capture log close

cd "C:\Desktop\sdp_toolkit\"
 
global raw ".\raw"
global clean ".\clean"
global programs ".\programs"

log using "${programs}\task7.txt", text replace

/*** Step 0: Load the Class data file. ***/
	use "${raw}\Student_NSC_Enrollment.dta", clear

/*** Step 1: Standardize the NSC variables. ***/

// 1. Rename variables to indicate that they are NSC variables.
	
	
// 2. Format the date values as dates.


// 3. Standardize types of college by:

	// 2-year and 4-year college
	
	
	// Public and private college
	
	
	// In-state and out-of-state college
	
	
// 4. Create a college graduation indicator.
	

// 5. Interpret enrollment status.
	
	

		
/*** Step 2: Identify first college attended by type (any, 4-year and 2-year) that didn't result in a withdrawal. ***/
	
// 1. Specify these types of college (any, 4-year, 2-year) in globals.
	
// 2. Calculate the days enrolled.
	
	
// 3. Identify the first college a student enrolled in by type (any, 2-year, and 4-year).

	foreach type in any 2yr 4yr { 
		// Identify the first enrollment date a student is enrolled full time, half time or less than half time (based on n_enrl_status)
		
		
		// Identify the name and ID of the first college of each type
		
		
			// Get the  college name and id for the first enrollment date
			
				
			// Count how many first college names and ids you got for each student
			
				
			// If a student started at multiple colleges of the same type on the same date, indicate this by replacing
			// these values with a dummy value (">1") for processing.
			
			
			// For students who end up with multiple colleges, apply the following selection order:
			// (1) take the one with the highest enrollment status (full-time, half-time, less than half time in order of importance) then (2) longest days enrolled.
			
					
			// Remove the remaining ">1" values.
			
			// Assign the first college
				
	
	
/**** Step 3: Drop any unneeded variables, and save the file ****/

// 1. Drop the unneeded variables
	

// 2. Save the current file as Student_NSC_Enrollment_Indicators
	save "${clean}\Student_NSC_Enrollment_Indicators.dta", replace

capture log close
