cd "C:\Users\kawakito\Dropbox\Private\products\sdp_toolkit\SILA\"
set more off

log using "${programs}/connect_ontrack.txt", replace text

global create_sample			"1"  // Restricts sample to students with linear enrollment and observed in fall of 9th grade
global ontrack_variables		"1"  // Calculates cumulative credits earned and creates on-track indicators
global gpa_test_variables		"1"  // Creates GPA variables, brings in SAT scores, identifies highly qualified students

if $create_sample == 1 {

/***************************************************************
1.1.	Keep the students who have all records to be in the sample
****************************************************************/

// Load the Student School Year file and merge with Student School Enrollment, to determine if the student ever transferred out of the district.

		
	
	/*
	 Create a new withdrawal-code-based binary variable that identifies transfer-out codes. 
	 This variable will be 1 for all withdrawal codes related with transfer-out, 
	 not just last withdrawal code observed for the student. It will be used for restricting the on-track sample.
	*/
	
	// Create an indicator for students ever observed with a transfer out code.
		
		
	// Omit students who ever transfer out of the district since we can't 
	// determine their total credit accumulation in any year in which they left the district 


// Load the Student Class Enrollment file, and merge with the college going analysis file.


	
	// we can only assess if a student is on track if we have course information for them. Keep only records that appear in both files.


// Merge with the Student School year file


	
// Keep only students who were in the district in first semester of 9th grade, to ensure that we have complete record for them
	

		
// Restrict to cohorts that have had time to graduate. We assume here that you have complete records until the school year before the current year. 

		
// Identify students who don't enroll subsequently from one year to the next and omit those from our sample




/***************************************************
1.2.	Resolve inconsistencies with credit variables
****************************************************/
	
	// No missing credits_possible/earned. In our data, there are a handful have 2 or 3 credits_possible. This may be due to block scheduling

	
	
	
	/* Some students with credits_possible == 0 have received credits_earned > 0
	   Typically a course has 0 credits possible if it does not count towards GPA. In most cases students receive a "P" for these courses.
	   However, in some cases a student has a normal final grade mark, for these courses. We will change the credits possible to credits earned for these.
	*/
	
	



		// we had to exclude "NGPA" specifically, because it contains the letter "A"

// Review final grade marks and credits earned
	
	
	
	// Make sure that final grade marks of F and non credit-carrying letter grades (in our case, NGPA) have 0 credits earned


	// For the most part, students with credits_earned == 0 receive an "F" letter grade.
	// However, some receive passing grades and should receive credits_earned.

	
	// Assign these students non-zero credits earned = credits_possible.


	
	// If credits_possible in that observation is also zero, then replace with mode of course.
	// Calculate modal credits_earned for each course (cid is unique by  school_year school_code section_code course_code)
	bys cid: egen credits_earned_mode = mode(credits_earned)
	replace credits_earned = credits_earned_mode if credits_earned == 0 & credits_earned_mode!=. & regexm(final_grade_mark, "A|B|C|D|E") & final_grade_mark != "NGPA"

	// Finally, if still 0 for credits_earned and credits_attempted, leave as is. 
	// Look at the tabulation and make sure that there are not many cases like this; Otherwise, work with your agency to determine possible causes.
	


	
// Resolve instances in which credits_earned > credits_possible



	// Set credits_possible to credits_earned if credits_possible is zero and credits_earned is non-zero 


	
	// Now set remaining credits_earned AND credits_possible to equal the mode credits earned computed above
	

	
	// Review remaining mismatched credits_possible and credits_earned. These all have missing modes. Drop them.


	
	// Look at the results by credit and final grade mark.


	

/*********************************************
1.3.	Create variable indicating years in HS
**********************************************/

	// Preserve data, then keep only one observation per student/school_year, create years in data counter, merge back onto main file
	
	
	compress
	save "${analysis}\Student_OnTrack_Sample.dta", replace
}

//2.1 Calculate credits earned in each of a student's first four school years in high school. 

	// Calculate total credits earned 
		


	// Calculate total credits earned in math and ela. Replace with 0 if student didn't earn credit.
		


//2.2 Generate on track indicators
		
	/*  In our sample district, 23 credits are needed to graduate from high school with regular diploma,
		including 4 credits in ELA, 3 in Math.
		
		In addition, promotion to next grade guidelines are as follows:
		
		Promotion from grade to grade should be based on credits earned:
			• Promotion to 10th grade – 5 credits
			• Promotion to 11th grade – 11 credits
			• Promotion to 12th grade - 17 credits

		Using this information, define on-track indicators by year enrolled in HS, of graduating within
		4 years of initial high school enrollment.
		
		DEFINITION:	- on track by end of 9th:	5  total credits, 1 math, 1 English
					- on track by end of 10th:	10 total credits, 1 math, 2 English
					- on track by end of 11th:	15 total credits, 2 math, 3 English
					- on track by end of 12th:	20 total credits, 3 math, 4 English
	*/
	
	
	
	// Label on-track variables created above
	

	// Keep only relevant variables, and make sure you only have one observation per student/yr observed in high school

	
//2.3 Generate outcome indicators at the end of each year in high school
	
	
	
//2.3a Define status in first 3 years of HS
	
			
	// Replace status_after_yr vars to enrolled_on-track for those students who graduated in less than 4 years.
	

//2.3b Define status after 4th year - using diploma information.
	
	
// Label the variables
	
	
// keep time-invariant variables


//3.1 Process final grades and credits

	// ensure final_grade_mark and final_grade_mark_num comport
	
	
	// For "P" and "NGPA" set credits_possible and numeric grade mark to 0 to exclude from GPA calculation
	
	
	// Calculate GPA points by multiplying the numeric final grade marks by credits possible. 
	// This allows you to weight higher credit courses.
	
	

	// Ensure that credits attempted field is populated for everyone with GPA points
	
	
	// Determine gpa points and credits by year
	
	
	// Reduce to student/yr file
	

	// Add gpa points & credits across years until given year to obtain cumulative GPAs by year
	

	// Identify final cumulative GPA in high school
	

	// Reshape data to have one record per student, and variables for each high school year.
	

	// Merge on track variables
	

//3.2 Add SAT and ACT Scores

	// Add SAT scores
	
	
	// Add ACT scores 
	

// Create a uniform SAT/ACT test score for students with either score populated
// We will use Math and ELA portion of SAT (Excluding Writing)

	//  Convert ACT scores to SAT scores for all students according to ACT-SAT Concordance tables
	
	
// Generate SAT concordance
	
	// SAT_ACT_concordance equal to SAT total_score if student has SAT score and does not have ACT score
	
	// SAT_ACT_concordance equal to mean of SAT and ACT score if student has taken both exams
	
	
	// SAT_ACT_concordance = concordance score calculated above if a student has only ACT score
	
//3.3 Identify highly qualified students (eligible to attend flagship university)
	
	// Use the SPI definition of highly qualified.
	
	
	
	// Keep only cohorts who have had a chance to graduate
	//keep if inlist(chrt_ninth, 2005, 2006)
	
	// Keep relevant variables
	
	

// Merge on-track variables with the analysis file used for all other analyses



capture log close
