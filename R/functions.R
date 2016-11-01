# Packages
library(ggplot2)
library(xtable)
library(plyr)

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


# Assign one value
# Task 1

nvals<-function(df,id,year,var){
  require(plyr)
  mdf<-eval(parse(text=paste('ddply(',df,',.(',id,'),summarize,var_temp=statamode(',var,'),
             nvals=length(unique(',var,')),most_recent_year=max(',year,'),
             most_recent_var=tail(',var,',1))',sep="")))
  return(mdf)
}



task1<-function(df,id,year,var){
  require(plyr)
  mdf<-eval(parse(text=paste('ddply(',df,',.(',id,'),summarize,var_temp=statamode(',var,'),
             nvals=length(unique(',var,')),most_recent_year=max(',year,'),
             most_recent_var=tail(',var,',1))',sep="")))
  mdf$var2[mdf$var_temp!="."]<-mdf$var_temp[mdf$var_temp!="."]
  mdf$var2[mdf$var_temp=="."]<-as.character(mdf$most_recent_var[mdf$var_temp=="."])
  ndf<-eval(parse(text=paste('merge(',df,',mdf)',sep="")))
  return(ndf)
}

dedupe<-function(x){
  x$d<-FALSE
  z<-duplicated(x,fromLast=FALSE)
  y<-duplicated(x,fromLast=TRUE)
  x$d[z==TRUE | y==TRUE]<-TRUE
  return(x$d)
}


