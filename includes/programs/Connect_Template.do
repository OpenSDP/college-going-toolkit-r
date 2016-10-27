cd "C:\Desktop\sdp_toolkit\"

global raw ".\raw\"
global clean ".\clean"
global programs ".\programs"
global analysis ".\analysis"

log using "${programs}/connect.txt", replace text
set more off

/******************************************************
* STEP 1: Prior Achievement Part 1
******************************************************/

//1.1 Load Prior Achievement
	

//1.2 Rename variables to indicate that they are 8th grade scores
	

//1.3 Define Prior Achievement Quartiles in Each Subject


		// keep only observations if 8th grade score is not missing
				

		// create a local variable containing all values of  school year in the test score research file
		
		// create variables that captures the quartile of students' 8th grade tests within each school year
			
			
		// create a variable that compiles all year-specific quartile variables into a single variable across years
			
		// create and save a tempfile
			
//1.4 Merge the three subjects together into one test file
	
	
	// you will not need school year and grade level, so drop those variables

	
	// order the variables so they are easier to follow

	
/*******************************************************
* STEP 2: School Crosswalk
*******************************************************/

// load School
	
// keep only schools that contain high school grades
	
// keep only the school code and name
	
// check that the file is unique by school_code
	
// create first / last / longest hs id variables
	

// create and save a tempfile
	
/*******************************************************
* STEP 3: Student Attributes
*******************************************************/

// load the Student_Attributes output from Task 1
	

// check that the file is unique by sid 

	
	
/*******************************************************
* STEP 4: Student School Year
*******************************************************/

// merge Student School Year from Task 3 onto Student Attributes 
	

// check the number and percentage of students appearing in both files 
	 
	// (if sid!=sid[_n-1] counts unique students instead of observations; this should be familiar from the tasks)

// once you have checked the _merge, keep only students at the intersection of both files
	
	
// Generate program participation variables

	
	
		// detect if the student has ever been flagged with a value of 1 for frpl / iep / ell / gifted
		
		// detect for only high school grades
		
		// this populates the high school only variables across all observations within each student


		// drop the temporary variable
	
	
/*******************************************************
* STEP 5: Student School Enrollment
*******************************************************/

// merge on Student School Enrollment from Task 4 onto Student Attributes 
	
	
// check the number and percentage of students appearing in both files
	
	// (if sid!=sid[_n-1] counts unique students instead of observations; this should be familiar from the tasks)
	
// once you have checked the _merge, keep only students at the intersection of both files

	
	
/*******************************************************
* STEP 6: High School Indicators and Outcomes
*******************************************************/

//6.1 Define first, last and longest high school

	// restrict to only high school
		
	/*  There might be students who are assigned to high schools but whose attendance duration is 0. 
		Drop these school assignments to ensure that you assign students high schools they actually attended. */
	
	
	/*** FIRST HS ***/

	/* 	Determine the first HS student enrolled in.
		In cases of joint enrollment, use the school where the student attended longest.
		Where joint enrollment duration is the same, randomly assign. */
		
	
	/*** LAST HS ***/

	/* 	Determine the last HS student enrolled in.
		In cases of joint enrollment, use the school where the student attended longest.
		Where joint enrollment duration is the same, randomly assign. */

		
	/*** LONGEST HS ***/

	/* 	To determine the longest enrolling HS, we first have to add up all enrollments within a HS.
		Since in Clean we ensured that there are no overlapping enrollments within a school, we can add enrollments up.
		In cases where students enrolled in more than one school for the same amount of time, randomly assign. */
		
		
		
	// delete temporary variables created
		
		
	// Merge on `highschoolinfo' 
		
	// Keep only observations that merged (Drop all observations only from the school file, 
	// and drop all observations for which neither a first, last or longest HS can be defined


//6.2 Assign ninth grade and graduation cohorts

	// define ninth grade cohort
		

	// define graduation cohort
		

//6.3 Define high school outcomes

//6.3a First, group last withdrawal codes to help you determine high school outcomes later.

	// Note: the values for last_withdrawal_code are defined locally by your agency.
	
				// do this at the end; hs_diploma overrides other indicators of graduation.					

		/* For students you classified as still enrolled, look at their last school year. 
			//gsort sid -school_year
			//bys sid: gen temp_last_schy = school_year if _n==1
			//egen last_schy = max(temp_last_schy), by(sid)
		
			
		// If the student did not show up in the data in the school year before the current year, reclassify them as "Disappeared"
			replace last_wd_group = 5 if (last_wd_group == 2 & last_schy < $current_schyr -1)
			drop temp_last_schy last_schy */

//6.3b Define high school outcomes

	// define on-time graduates
		

	// define late graduates
		
	// still enrolled
		
	// transfer out
		

	// drop out
		

	// disappear
	

// keep time-invariant variables
// the "*" symbol is a wildcard to indicate multiple variable names

// drop any duplicates

	
// make sure the file is unique by sid
		
	
/*******************************************************
* STEP 7: Prior Achievement Part 2
*******************************************************/

// merge `tests' onto the current file
	
	

// drop students who do not appear in the analysis file but have 8th grade test scores


/*******************************************************
* 8: Examining the Analysis File Part 1
*******************************************************/

// order the variables in a sensical way

/*******************************************************
* STEP 9: National Student Clearinghouse Data
*******************************************************/

use "${clean}\Student_NSC_Enrollment_Clean.dta", clear

// merge on variables needed from Student_College_Going
	
// only keep students who appear in both datasets
	

//9.1 Create a variable to indicate if the student enrolled in college within two years of graduating from high school.	
	
	// Graduation cohort
	
		// create and indicator to show if the student enrolled within two years of HS graduation
			
						
	// Ninth grade cohort

		// identify the date that would represent ontime high school graduation for students
			
		
		// create and indicator to show if the student enrolled within two years of expected HS graduation
			 
		
//9.2 Create variables to indicate if the student was enrolled in college by Oct 1 the 1st, 2nd, 3rd and 4th year after high school graduation.

	// Create the 4 enrollment outcomes of interest by October 1st
		
	// loop through the graduation years (actual and expected) that exist in your data. 
	
		// actual
		

			// assign the outcome of interest to assume a value of 1 when students enroll on or before October 1st
			
		// expected
		

			// assign the outcome of interest to assume a value of 1 when students enroll on or before October 1st
			
		
//9.3 Collapse and reshape the data to make it unique by student id
	
	// first, indicate which type of college the student enrolled. Make this the highest level of enrollment.
		

	// collapse by the invariants and type, to get one record by student by type. 
	// when you collapse, only the enrl_* and by() variables are retained


	// now, reshape, to get one record by student
		
		
	// at this point, we don't need the variables that refer to no college, so drop those
		

//9.4 Ensure mutual exclusivity of 2-year and 4-year college enrollment; 
// if have a student enrolled in both 2-year and 4-year college, report the 4-year.
	
	
	// set missing values to 0
		foreach chrt in grad ninth {
			foreach var of varlist enrl_ever_w2* enrl* {
				replace `var' = 0 if `var'==.
			}
		}

//9.5 Create "any college" version of the variables

	// create an any college version of the year-by-year college enrollment outcome
	
	// create an any college version of the within 2 years enrollment outcome
		

//9.6 Create persistence outcomes for graduates and ninth graders
	
	
		// create persistence outcomes to the second year of college	
		
			// create persistence outcomes that denote continuous enrollment over four consecutive years in college
			
	
/*******************************************************
* STEP 10: Merge the Collegegoing and NSC file
*******************************************************/
	
log close
