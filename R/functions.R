# Packages
library(tidyverse)


# R Function for Task 1
statamode <- function(x) {
  z <- table(as.vector(x))
  m<-names(z)[z == max(z)]
  if(length(m)==1){
    return(m)
  }
  return(".")
}

# distinct values function
nvals <- function(x){
  length(unique(x))
}

# Cluster standard errors
get_CL_vcov <- function(model, cluster){
  # cluster is an actual vector of clusters from data passed to model
  # from: http://rforpublichealth.blogspot.com/2014/10/easy-clustered-standard-errors-in-r.html
  require(sandwich, quietly = TRUE)
  require(lmtest, quietly = TRUE)
  
  # NA
  cluster <- as.character(cluster)
  
  #calculate degree of freedom adjustment
  M <- length(unique(cluster))
  N <- length(cluster)
  K <- model$rank
  dfc <- (M/(M-1))*((N-1)/(N-K))
  
  #calculate the uj's
  uj  <- apply(estfun(model), 2, function(x) tapply(x, cluster, sum))
  
  #use sandwich to get the var-covar matrix
  vcovCL <- dfc*sandwich(model, meat=crossprod(uj)/N)
  return(vcovCL)
}



# Assign one value
# Task 1

# nvals<-function(df,id,year,var){
#   require(plyr)
#   mdf<-eval(parse(text=paste('ddply(',df,',.(',id,'),summarize,var_temp=statamode(',var,'),
#              nvals=length(unique(',var,')),most_recent_year=max(',year,'),
#              most_recent_var=tail(',var,',1))',sep="")))
#   return(mdf)
# }

# 
# 
# task1<-function(df,id,year,var){
#   require(plyr)
#   mdf<-eval(parse(text=paste('ddply(',df,',.(',id,'),summarize,var_temp=statamode(',var,'),
#              nvals=length(unique(',var,')),most_recent_year=max(',year,'),
#              most_recent_var=tail(',var,',1))',sep="")))
#   mdf$var2[mdf$var_temp!="."]<-mdf$var_temp[mdf$var_temp!="."]
#   mdf$var2[mdf$var_temp=="."]<-as.character(mdf$most_recent_var[mdf$var_temp=="."])
#   ndf<-eval(parse(text=paste('merge(',df,',mdf)',sep="")))
#   return(ndf)
# }
# 
# dedupe<-function(x){
#   x$d<-FALSE
#   z<-duplicated(x,fromLast=FALSE)
#   y<-duplicated(x,fromLast=TRUE)
#   x$d[z==TRUE | y==TRUE]<-TRUE
#   return(x$d)
# }


