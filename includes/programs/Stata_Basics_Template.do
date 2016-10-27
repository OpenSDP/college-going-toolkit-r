/****************************************************************************
* File name: Stata_Basics_Template.do
* Author(s): Strategic Data Project
* Date: 7/27/2012
* Description: Goes over some basic Stata commands.
*
* Inputs: /raw/Student_Demographics_Raw.dta
*
***************************************************************************/

clear
set more off
capture log close

cd ""

global raw ".\raw\"
global clean ".\clean\"
global programs ".\programs\"

/* this is a multi-
                  line
                     comment */
// this is a single line comment

/****************************************************************************
Keyboard Shortcuts:
	ctrl + L --> select line
	ctrl + D --> run selected
	ctrl + C --> copy
	ctrl + V --> paste
	ctrl + S --> save
****************************************************************************/

// 1. Load the Student_Demographics_Raw data file.


// 2. Describe the variables in the dataset. Try adding the option fullnames.


// 3. Summarize the data. What percent of students have a high school diploma?  To really answer, this question you may have to sort first.


// 4. Tabulate twoway first_9th_school_year_reported and hs_diploma for unique students.


// 5. Report duplicates for sid and school_year.


// 6. Tag duplicates for sid and school_year.


// 7. Browse these duplicates.


// 8. Browse observations for the student with sid of 7.


