setwd("~/Kew Summer/Data/07_05")
#
# Install any dependancies
#
if(!require("dplyr")){
        install.packages("dplyr")
}
library(dplyr)
#
if(!require("stringr")){
        install.packages("stringr")
}
library(stringr)
#
if(!require("reshape")){
        install.packages("reshape")
}
library(reshape)
#
if(!require("ggplot2")){
        install.packages("ggplot2")
}
library(ggplot2)
#
# Import data
#
grass.data <- read.csv("public_checklist_flat_plant_dl_20160705_poaceae.csv",
                       stringsAsFactors = FALSE)
#
# Tidy up publication date data into numeric format
#
template <- "]"
index <- grep(template,grass.data[,15])
tmp <- strsplit(grass.data[index,15],template)
grass.data[index,15] <- paste(tmp[[1]][1],tmp[[1]][2],sep = "")
rm(tmp,template,index)
#
grass.data[,15] <- as.numeric(stringr::str_sub(grass.data[,15],-5,-2))
#
# 267 NAs from missing data
# 2 NAs from (
# 1 NA from (v)
#
names.data <- grass.data[,c(1,11,12)]
rm(grass.data)
#
# Splitting will be on & so replace ','
#
names.data[,2] <- gsub(',',' & ',names.data[,2])
#
# in is relevant for publication and hence for activity level so replace this 
# also with &
#
names.data[,2] <- gsub(' in',' & ',names.data[,2])
#
# ex is not linked to current period and hence will need to be removed
#
ex.ind <- grep('ex ',names.data[,2])
ex.ind2 <- grep('ex\\..',names.data[,2]) # allow cases of ex.
ex.ind <- c(ex.ind,ex.ind2)
rm(ex.ind2)
ex.split <- strsplit(names.data[ex.ind,2],' ex')
#
# Deal with issue of multiple occurances of ex
#
multi.split <- which(as.numeric(summary(ex.split)[,1]) > 2)
multi.len <- c()
for (i in 1:length(multi.split)){
        multi.len[i] <- length(ex.split[[multi.split[i]]])
}
rm(i)
ex.split <- unlist(ex.split)
for (i in 1:length(multi.split)){
        ex.split <- ex.split[-((2*multi.split[i]+1):(2*multi.split[i]+multi.len[i]-2))]
}
rm(i)
rm(multi.len,multi.split)
#
# take only first half of the strings
#
ex.split <- ex.split[c(TRUE,FALSE)]
names.data[ex.ind,2] <- ex.split

