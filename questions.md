Questions for David and Ashley

In Toolkit Data Building Tasks:

- Should the decision rules glossary be included in the R version, or will 
this be broken out separately and consulted separately? It seems odd that it 
is placed at the front of the data building tasks (glossary implies if anything 
end or a separate document to me), but we can do what you think is best.

- There are lots of nice figures depicting the transformations (e.g. p.5). Do you 
have these as standalone image files in an organized way? If so, I could include 
them fairly easily in the text. If not, I could snapshot them out of the PDF 
and include them, but this would be more labor intensive.

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




