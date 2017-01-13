# Knit and purr

purl(input = "SDPdatabuildingtasks.Rmd", 
     output = "ToolkitSDP_Clean.R")

purl(input = "SDPdatalinkingtasks.Rmd", 
     output = "ToolkitSDP_Connect.R")

purl(input = "SDPanalyze.Rmd", 
     output = "ToolkitSDP_Analyze.R")

purl(input = "SDP_R_Glossary.Rmd", 
     output = "ToolkitSDP_R_Glossary.R")