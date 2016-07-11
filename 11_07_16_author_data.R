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
names.data[,2] <- gsub(',',' & ',names.data[,2])
names.data[,2] <- gsub(' in',' & ',names.data[,2])