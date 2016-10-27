/****************************************************************************
* File name: Task_1.do
* Author(s): Strategic Data Project
* Date: 7/25/2012
* Description: This program generates a clean Student_Attributes file unique
* by sid by:
* 1. Creating one consistent value for gender for each student across years.
* 2. Creating one consistent value for race_ethnicity for each student across years.
* 3. Creating consistent values for high school diploma variables.
*
* Inputs: /raw/Student_Demographics_Raw.dta
*
* Outputs: /clean/Student_Attributes.dta
*
***************************************************************************/

clear
set more off
capture log close

cd "C:\Desktop\sdp_toolkit\"

global raw ".\raw"
global clean ".\clean"
global programs ".\programs"

log using "${programs}\task1.txt", text replace

/*** Step 0: Load the Student_Demographics_Raw data file ***/
	use "${raw}\Student_Demographics_Raw.dta", clear

// Drop the first_9th_school_year_reported variable. You will create a first_9th_grade_observed variable in Task 3 that also imputes the first 9th grade for transfer-ins.
	drop first_9th_school_year_reported
	
/*** Step 1: Create one consistent value for gender for each student across years. ***/

// 1. Create a variable that shows how many unique values male assumes for each student. Name this variable nvals_male. Tabulate the variable and browse the relevant data.

	
// 2. Identify the modal gender. If multiple modes exist for a student, report the most recent gender recorded.
	
	// Define the modal gender. For students who have a mode, replace male with the modal value (male_mode will be missing if there is no single mode).

	
	// If multiple modes exist for a student, report the most recent gender recorded

	
	// Drop temporary variables
	drop nvals_male male_mode temp_male_last male_last
	
/*** Step 2: Create one consistent value for race_ethnicity for each student across years. ***/

// 1. Recode the raw race_ethnicity variable as a numeric variable and label it.  Replace the string race_ethnicity variable with the numeric one.
	generate race_num=.
	replace race_num = 1 if race_ethnicity=="B"
	replace race_num = 2 if race_ethnicity =="A"
	replace race_num = 3 if race_ethnicity =="H"
	replace race_num = 4 if race_ethnicity =="NA"
	replace race_num = 5 if race_ethnicity =="W"
	replace race_num = 6 if race_ethnicity =="M/O"
	
	order race_num, after(race_ethnicity)

	label define race 1 "Black" 2 "Asian" 3 "Hispanic" 4 "Native American" 5 "White" 6 "Multiple/Other"
	label val race_num race

	tab race_ethnicity, mi
	tab race_num, mi
	drop race_ethnicity
	rename race_num race_ethnicity

// 2. Create a variable that shows how many unique values race_ethnicity assumes for each student. Name this variable nvals_race. Tabulate the variable.
	bys sid: egen nvals_race = nvals(race_ethnicity)
	tab nvals_race

// 3. Create a variable that shows how many unique values race_ethnicity assumes for each student and school_year. Name this variable nvals_race_yr. Tabulate the variable and browse the relevant data.
	bys sid school_year: egen nvals_race_yr = nvals(race_ethnicity)
	tab nvals_race_yr
	br if nvals_race_yr > 1

// 4. If more than one race is reported in the same school_year, report students as multiracial, unless one of their reported race_ethnicity values is Hispanic.  Report the student as Hispanic in that case.
	gen temp_ishispanic = .
	replace temp_ishispanic = 1 if race_ethnicity == 3 & nvals_race_yr > 1
	bys sid school_year: egen ishispanic = max(temp_ishispanic)

	replace race_ethnicity = 3 if nvals_race_yr > 1 & ishispanic == 1
	replace race_ethnicity = 6 if nvals_race_yr > 1 & ishispanic != 1
		
	// Drop the temporary variables we created	
	drop temp_ishispanic ishispanic
	
	// Drop the duplicates resulting from fixing students with different race_ethnicity in a school_year
	duplicates drop if nvals_race_yr > 1

	
// 5. Report the modal race. If multiple modes exist for a student, report the most recent race recorded.
	
	// Identify the modal race. For students who have a mode, replace race with the modal value (race_mode will be missing if there is no single mode).
	bys sid: egen race_mode = mode(race_ethnicity)	
	replace race_ethnicity = race_mode if !mi(race_mode)		
	
	// If multiple modes exist for a student, report the most recent race recorded
	gsort sid -school_year
	bys sid: gen temp_race_last = race_ethnicity if _n==1
	bys sid: egen race_last = max(temp_race_last)
	replace race_ethnicity = race_last if mi(race_mode)
	
	// Drop temporary variables
	drop nvals_race* race_mode temp_race_last race_last
	
	// Examine the distribution of race_ethnicity in your agency.
	tab race_ethnicity, mi
	
/*** Step 3: Create consistent values for high school diploma variables. ***/

// 1. Recode the hs_diploma_type variable as a numeric variable and label it.  Replace the string hs_diploma_type variable with the numeric one. Use lower numbers for more competitive diploma types.
	generate dipl_num =.
	replace dipl_num = 1 if hs_diploma_type=="College Prep Diploma"
	replace dipl_num = 2 if hs_diploma_type=="Standard Diploma"
	replace dipl_num = 3 if hs_diploma_type=="Alternative Diploma"
		
	order dipl_num, after(hs_diploma_type)

	label define dipl 1 "College Prep Diploma" 2 "Standard Diploma" 3 "Alternative Diploma" 4 "Unknown"
	label val dipl_num dipl
	
	drop hs_diploma_type
	rename dipl_num hs_diploma_type

// 2. Identify the first diploma date reported

	
// 3. Identify the diploma type associated with the first diploma date	


// 4. Create a variable that shows the number of unique diploma types recorded for the first diploma date.


// 5. Identify the modal diploma type. If multiple modes exist for a student, report the diploma type in the earliest school year for the first diploma date.


// 6. If multiple diploma types were recorded for the same school year and first diploma date, report the most competitive diploma type.

	
// 7. If there are any missing diploma types, mark these as an unknown diploma type.
	replace hs_diploma_type = 4 if mi(hs_diploma_type) & !mi(hs_diploma_date)

// 8. Finally, replace hs_diploma_date with the first hs_diploma_date

	
// 9. Make sure that diploma is set to 1 if there is a diploma date reported


/**** Step 4: Drop any unneeded variables, drop duplicates, and save the file ****/

// 1. Drop school_year as you no longer need it.  Also drop birth_date since it is not used in later analyses.

	drop school_year birth_date temp_earliest_dipl_date-most_compet 
	
// 2. Drop duplicate values
	duplicates drop
	
// 3. Make sure that the file is unique by sid
	isid sid

// 4. Save the current file as Student_Attributes.dta
	save "${clean}\Student_Attributes.dta", replace

capture log close
