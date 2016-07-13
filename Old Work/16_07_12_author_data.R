setwd("~/Kew Summer")
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
source("./kew_grasses/16_07_12_functions.R")
#
# Import data
#
grass.data <- read.csv("./Data/07_05/public_checklist_flat_plant_dl_20160705_poaceae.csv",
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
# Removes the NAs
#
grass.data <- grass.data[which(is.na(grass.data[,15])==FALSE),]

names.data <- grass.data[,c(1,15,11,12)]
rm(grass.data)
#
# Deal with one exception where ex. is not followed by a space
#
tmp <- grep('ex\\..',names.data[,3])
names.data[tmp,3] <- gsub('ex\\.','ex. ',names.data[tmp,3])
rm(tmp)
#
# Re format to have breaks between authors given by &
#
names.data <- name.formatter(names.data, col.ind = c(3,4), T,T,T,T,F)
#
# Deal with the missing author names
#
miss.ind <- which(summary(strsplit(names.data[,3],'&'))[,1] == 0)
names.data <- names.data[-miss.ind,]
rm(miss.ind)
#
# Apply Method from Joppa et al, 2011 to count authors
#
names.data <- taxonomic.splitting.function(names.data,3)
#
# Keep format as numeric for id and year
#
names.data[,1] <- as.numeric(names.data[,1])
names.data[,2] <- as.numeric(names.data[,2])
#
# Get table of taxonomist data
#
taxon.data <- taxonimist.summary(names.data,2,1753,2015,5)
