/****************************************************************************
* File name: Stata_Basics_Merging_Template.do
* Author(s): 
* Date: 
* Description: Goes over process of merging datasets in Stata.
*
* Inputs: /clean/Student_Attributes_Clean.dta
*         /clean/Prior_Achievement_Clean.dta
*
*
***************************************************************************/

clear
set more off
capture log close

cd "FILL ME IN!!!"

global raw ".\raw\"
global clean ".\clean"
global programs ".\programs"


// 1. Load the Student_Attributes_Clean data file
	use "${clean}\Student_Attributes.dta", clear
	
// 2. Make sure that the file is unique by sid


// 3. Merge on the Prior_Achievement data file


// 4. Examine your merge results.


// 5. What percent of students have an 8th grade test score?

