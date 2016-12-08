
# Task Template


**Purpose:** 


**Required Analysis File Variables:**


**Analysis-Specific Sample Restrictions:** 


**Ask Yourself** 


**Analytic Technique:** 


We can also use the `dplyr` `rename` function:

```{r}

mtcars %<>% dplyr::rename(engsize = disp)

```


```{r}
library(dplyr)
library(haven)
tmpfileName <- "raw/Student_Demographics_Raw.dta"

# This assumes analysis is a raw subfolder from where the file is read, 
# in this case inside the zipfile

con <- unz(description = "data/raw.zip", filename = tmpfileName, 
           open = "rb")

# The zipfile is located in the subdirectory data, called raw.zip

stuatt <- read_stata(con) # read data in the data subdirectory
close(con) # close the connection to the zip file, keeps data in memory


# Read in Stata
library(haven) # required for .dta files

# To read data from a zip file we create a connection to the path of the 
# zip file
tmpfileName <- "raw/Student_Classifications_Raw.dta"
con <- unz(description = "data/raw.zip", filename = tmpfileName, 
           open = "rb")
stuclass <- read_stata(con) # read data in the data subdirectory
glimpse(stuclass)

library(haven) # required for .dta f;iles

# To read data from a zip file we create a connection to the path of the 
# zip file
tmpfileName <- "raw/Student_School_Enrollment_Raw.dta"
con <- unz(description = "data/raw.zip", filename = tmpfileName, 
           open = "rb")
stuenr <- read_stata(con) # read data in the data subdirectory
glimpse(stuenr)

########
# Merge stuatt and stuclass


out <- full_join(stuatt, stuclass, by = c("sid", "school_year"))
out <- full_join(stuenr, out, by = c("sid", "school_year"))

save(out, file="data/CGToolkit_Student_Demog_Sch_Enr.rda")
write_dta(out, path="data/CGToolkit_Student_Demog_Sch_Enr.dta")


```
