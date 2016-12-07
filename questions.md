Questions for David and Ashley

%/ ------------

Data Linking - Connect questions

- Do you want to include the table and figures from "Data and Structure" and 
"Step Components" at the top of the document? Can I screenshot these out of the 
PDF and insert them as image files in the R version? To do this I'll need 
finalized versions...


- The Infrastructure section at the front will need to be updated with additional text
and updated web addresses, etc.

- On p.14 the Stata code reads:

```
// restrict to only high school
keep if grade_level >= 9 & grade_level!=.
```

However, in the data file there are students who have a grade level > 12. 29 
student-observations have a grade-level of 13 and 5 have a grade-level of 17. 
If this is run in Stata, it will cause calculations to be wrong if those students 
are not excluded.

- on P.22 there is a list of variables to keep in the data file. It is included 
in a nice rendered table. Should I include an image version of this table or 
recreate it in R?

- on p. 36 the transfer codes do not line up with the values in the data file. The 
code suggests there should be "Left District" and a "Transfer Out of District", 
but only the latter is actually observed in the data

- I think we might want to provide a check here to show how many students are 
dropped from the sample. I am not sure if I have it correct either as I think 
too many students are labeled as a transfer out above (which then causes problems 
below)

- on p. 38-39 the credit numbers I am getting do not square with the toolkit. 
The toolkit finds that there are 287,426 possible credits earned. After doing 
the filtering for students found in grade 9 and and dropping cases not found 
in the school year enrollment file, my dataset is much smaller. I cannot seem 
to reconcile this... can you take a look? `Student_Class_Enrollment_Merged.dta`

  - I think this is a problem related to selecting only students who appear in grade level 9
  - I am just finding way fewer 9th graders using the filters that appear on p. 37
  - Note that this is not an issue with the work done in the previous task, I am 
  reading in the "Clean" files fresh from those provided by SDP with the toolkit, so 
  the issue is either with the data file itself or with the code here (though it is 
  a straightforward subset so I'm wondering about the data file)
  
- Later on loading the `OnTrack` analysis file, there are way more observations 
and the grade level distribution looks way different


- I think p.44 also needs a check to see how many students should be labeled as 
`ontrack_endyr` at this point in the file. Coming from different contexts, analysts 
may have very different expectations about how many students meet this

%/ ------------



In SDP R Glossary

- Is the glossary too long? 
- Is it too short?
- Is any content missing?

In Toolkit Data Building Tasks:

- Should the decision rules glossary be included in the R version, or will 
this be broken out separately and consulted separately? It seems odd that it 
is placed at the front of the data building tasks (glossary implies if anything 
end or a separate document to me), but we can do what you think is best.

- There are lots of nice figures depicting the transformations (e.g. p.5). Do you 
have these as standalone image files in an organized way? If so, I could include 
them fairly easily in the text. If not, I could snapshot them out of the PDF 
and include them, but this would be more labor intensive.

- In the TOC for the version I sent you the step names appear but the way they 
are written in the original text they clearly were not designed for a TOC (they 
have those funny variable_names_that_go_on_and_on). Should we modify the step 
language to be more TOC friendly, or shorten the TOC text for each step to just 
"Step 1", "Step 2" ... etc. ?

- p. 36, the rendered table for sid 1:
Check on p. 35-36 of the guide, incosistency on whether observed_9 indicator 
is unique by student, or by student-grade. I've coded it unique by student 
because above it uses a tab of this variable (grouped by student) to see how many 
9th graders are in the data. 

Is this correct?

- p. 37 Why is sid 2 assigned a temp2_first9year of 2003 and a temp3_first9year 
of 2003. It should be 2005

Another thing to check is after this step (but before step 4)

```
# This student is in the wrong order...
stusy %>% select(sid, school_year, grade_level, 
                first_9th_schyear_obs, observed_9) %>% 
 filter(sid == 3)
 
```

- On p.44 this Stata code gives:

```
sort sid school_code enrollment_date

count if sid==sid[_n-1] & school_code==school_code[_n-1] & enrollment_date <= withdrawal_date[_n-1] & withdrawal_
date[_n-1]!=.

710
```

- The R equivalent: 

```
stuenr %<>% group_by(sid, school_code) %>% 
  arrange(sid, school_code, enrollment_date) %>%
  mutate(lag_withdrawal_date = lag(withdrawal_date)) %>% ungroup %>% 
  group_by(sid, school_code, school_year) %>% 
    mutate(min_enroll_date = min(enrollment_date))

 table(stuenr$enrollment_date <= stuenr$lag_withdrawal_date & 
         !is.na(stuenr$lag_withdrawal_date))
```

Gives 682.

I suspect that Stata may be having a problem with places where students have only 
1 enrollment date, but I am not sure...

- On p.46 the student with `sid` 16 is shown as having two entries (2008 and 2007), 
but each date has an identical withdrawal date

- In R, this student should have two spearate withdrawal dates (at the end of each 
school year): (2007-05-22 and 2008-05-28)

```
stuenr %>% filter(sid == 16) %>% 
  select(sid, school_year, school_code, enrollment_date, 
         enrollment_code_desc, withdrawal_date,
         withdrawal_code_desc)
```

- On p. 59 this block of text is incorrect:

> The input file, Student_Class_Enrollment_Raw, follows the structure of Student_Class_Enrollment in Identify so it is unique by sid, cid, and class_enrollment_
date. The aim of this task then is to take things one step further by consolidating any overlapping enrollment spells for the same student and cid.

The data file is actually just called Student_Class_Enrollment.dta in the zip 
file provided by the Toolkit.

- On p.60 it goes from Step 0: to Step 2:
- I propose: Step 1. Identify the critical variables that identify a class.

- Consider adding a link on p.67 to the "NSC Missing Manual" by Sue Dynarski. It 
is helpful for analysts who are really going to dig into this data. http://capseecenter.org/the-missing-manual-using-national-student-clearinghouse-data-to-track-postsecondary-outcomes/


- On p. 69 it goes from Step 0 to 5 subtasks then jumps to Step 2 on p. 71
- Proposal Step 1: Rename variables and format them for analysis


