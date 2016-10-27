/****************************************************************************
* File name: Task_5.do
* Author(s): 
* Date: 
* Description: This program generates clean files from Student_Test_Scores 
* including Prior_Achievement_Clean, SAT_Clean, and ACT_Clean:
* Part   I: Obtain clean prior achievement (8th grade) test scores.
* Part  II: Obtain clean SAT test scores. 
* Part III: Obtain clean ACT test scores. 
*
* Inputs: /raw/Student_Test_Scores.dta
*
* Outputs: /clean/Prior_Achievement.dta
*          /clean/SAT.dta
*          /clean/ACT.dta
*
***************************************************************************/

clear
set more off
capture log close

cd "C:\Desktop\sdp_toolkit\"
 
global raw ".\raw"
global clean ".\clean"
global programs ".\programs"

log using "${programs}\task5.txt", text replace

/*** Part I: Clean Prior Achievement Scores ***/
{
// 0. Load the Student_Test_Scores data file.
	use "${raw}/Student_Test_Scores.dta", clear

// 1. Keep only the variables you need and limit the sample to state test scores in 8th grade.
	

// 2. Clean up raw and scaled scores.

	// Change raw and scaled scores to missing if zero.  
	

	//Drop observations missing both a raw and scaled test score.
	

// 3. Identify same-year repeat test takers and take the highest test score.
	
		
	// Verify that each student has only one state test in a subject in a school year.
	

// 4. Reshape the data so math and ELA tests appear on the same row.
	// Generate the stub names for math and ELA
	
// 5. Compute standardized test scores with mean 0 and standard deviation 1.
	

// 6. Identify different-year repeat test takers and take the earliest test score.
	// First process ELA scores
	preserve 

		
		// Keep only the earliest instance in which the student took the test 
	
		
		// Save the ela_scores as a tempfile to be merged on
		
	
	restore
	
	// Next process math scores
		
		
		// Keep only the earliest instance in which the student took the test
		

	// Merge the ela_scores tempfile onto the math scores
	
	
// 7. Verify that each student has only one state test, and drop unneeded variables.
	

// 8. Generate composite scaled and standardized scores that average ELA and math scores.
	
// 9. Save the current file as Prior_Achievement.dta.
	order sid school_year grade_level ///
		raw_score_math raw_score_ela scaled_score_math scaled_score_ela scaled_score_composite ///
		scaled_math_std scaled_ela_std scaled_score_composite_std
		
	save "${clean}\Prior_Achievement", replace		
}	

/*** Part II: Clean SAT Scores ***/
{
// 0. Load the Student_Test_Scores data file.
	use "${raw}/Student_Test_Scores.dta", clear
	
// 1. Keep only the variables and limit the sample to SAT.
	

// 2. Drop duplicate observations and any observations missing test scores.
	

// 3. Reshape the data so that math, ELA, and writing scores appear on one row by student and test date.
	

// 4. Identify repeat test takers and take the earliest test score.
	

	// Verify that the file is now unique by student.
	

// 5. Verify that test scores from the component subjects are not missing and generate total scores.
	

// 6. Save the current file as SAT.dta.
	save "${clean}\SAT", replace	
}

/*** Part III: Clean ACT Scores ***/
{
// 0. Load the Student_Test_Scores data file.
	use "${raw}/Student_Test_Scores.dta", clear

// 1. Keep only the variables you need and limit the sample to ACT.
	

// 2. Identify repeat test takers and take the earliest test score.
	
// 3. Keep and rename the relevant variables.
	
	// Verify that the file is now unique by student.
	

// 4. Save the current file as ACT.dta.
	save "${clean}\ACT", replace

}

capture log close
