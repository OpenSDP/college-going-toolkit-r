/****************************************************************************
* File name: Task_2.do
* Author(s): 
* Date: 
* Description: This program generates a clean Student_School_Year file unique
* by sid + school_year by:
* 1. Creating one consistent grade level for each student within the same year.
* 2. Creating one consistent FRPL value for each student within the same year.
* 3. Creating one consistent IEP value for each student within the same year.
* 4. Creating one consistent ELL value for each student within the same year.
* 5. Creating one consistent gifted eligible value for each student within the same year.
*
* Inputs: /raw/Student_Classifications_Raw.dta
*
* Outputs: /clean/Student_School_Year.dta
*
***************************************************************************/

clear
set more off
capture log close

cd "C:\Desktop\sdp_toolkit\"

global raw ".\raw"
global clean ".\clean"
global programs ".\programs"

log using "${programs}\task2.txt", text replace

/*** Step 0: Load the Student_Classifications_Raw data file ***/
	use "${raw}\Student_Classifications_Raw.dta", clear
	
	
/*** Step 1: Create one consistent grade level for each student within the same year. ***/

// 1. Keep the highest grade_level when a student has multiple grade levels within the same year. 

	// Check if there are any instances of multiple grade levels per sid per school_year

	
	// Keep the highest value per school year

	
	// drop temporary variables


	
/*** Step 2: Create one consistent FRPL value for each student within the same year. ***/

// 1. Recode raw frpl variable with string type to numeric type
	

	// Drop the old string variable and rename the numeric variable as frpl

	
// 2. Ensure that frpl is consistent by sid and school_year. In cases where multiple values exist, report the highest value.
	
	// Check if there are any cases where different values of frpl status are reported in a year

	
	// Report the highest value of frpl by year for each student, selecting free over reduced over not participating.

	
	// Label the values so they are easy to understand
	
	
	// Drop the temporary values we created
	

	
/*** Step 3: Create one consistent IEP value for each student within the same year. ***/
	
// Report the highest value of iep by year for each student, selecting has iep over not iep.
	

/*** Step 4: Create one consistent ELL value for each student within the same year. ***/

// Report the highest value of ell by year for each student, selecting is ell over not ell.
	

/*** Step 5: Create one consistent gifted value for each student within the same year. ***/

// Report the highest value of gifted by year for each student, selecting is enrolled in gifted program over not enrolled.


/**** Step 6: Drop any unneeded variables, drop duplicates, and save the file ****/

// 1. Drop duplicate observations 
	duplicates drop

// 2. Make sure your file is now unique by student and school year
	isid sid school_year

// 3. Save the current file as Student_School_Year.dta which you will need for Task 3.
	save "${clean}\Student_School_Year.dta", replace
	
capture log close
