# Packages
library(tidyverse)


# R Function for Task 1
# Derive the mode in a stata friendly fashion
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