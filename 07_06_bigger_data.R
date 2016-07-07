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
# Import data
#
grass.data <- read.csv("public_checklist_flat_plant_dl_20160705_poaceae.csv",stringsAsFactors = FALSE)
loc.data <- read.csv("Poaceae_distribution.csv",stringsAsFactors = FALSE)
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
#
#
# Append location data with species status and year of publication
#
temp.num <- numeric(length = nrow(loc.data))
temp.class <- character(length = nrow(loc.data))
loc.data <- cbind(loc.data,temp.num,temp.class)
rm(temp.num,temp.class)
names(loc.data)[ncol(loc.data)-1] <- names(grass.data)[15]
names(loc.data)[ncol(loc.data)] <- names(grass.data)[17]
#
indices <- match(loc.data[,2],grass.data[,1])
loc.data[,ncol(loc.data)-1] <- grass.data[indices,15]
loc.data[,ncol(loc.data)] <- grass.data[indices,17]
rm(indices)
#
# Select only accepted species
#
Accep.loc <- dplyr::filter(loc.data,taxon_status_id == "A")
#
# Now pick out continent TDGW level 1 info for discoveries
#
loc.trend <- dplyr::group_by(loc.data,plant_name_id,continent_code_l1) %>%
        dplyr::summarise(continent = unique(continent))
temp <- numeric(length = nrow(loc.trend))
#
# Add year of publication
#
loc.trend <- cbind(loc.trend,temp)
rm(temp)
names(loc.trend)[4] <- "first_published"
indices <- match(loc.trend[,1],grass.data[,1])
loc.trend[,4] <- grass.data[indices,15]
rm(indices)
#
# Filter missing values
#
loc.trend <- loc.trend[which(is.na(loc.trend[,4])==FALSE),]
#
# Cumulative curves for each continent per TDWG level 1
#
cum.spec.cont <- matrix(nrow = nrow(loc.trend),
                        ncol = length(unique(loc.trend[,2])))

