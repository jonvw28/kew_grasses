setwd("~/Kew Summer/Data/07_04")
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
if(!require("RODBC")){
        install.packages("RODBC")
}
library(RODBC)
#
# Import data
#
grass.data <- read.csv("Basionyms_Poaceae.csv",stringsAsFactors = FALSE)
#
# deal with publication date issue
#
# One exception
#
template <- "]"
index <- grep(template,grass.data[,15])
tmp <- strsplit(grass.data[index,15],template)
grass.data[index,15] <- paste(tmp[[1]][1],tmp[[1]][2],sep = "")
rm(tmp,template,index)
#
grass.data[,15] <- as.numeric(stringr::str_sub(grass.data[,15],-5,-2))
#
# Here we get 235 NA because there are no years given in these cases, all dates
# are mapped to the date of publication
#
# Group by year for summaries of only accepted, and accepted and synonymous
# species
#
year_SA.data <- grass.data[!is.na(grass.data[,15]),] %>%
        dplyr::filter(taxon_status_id == "A" | taxon_status_id == "S") %>%
        dplyr::group_by(first_published) %>%
        dplyr::summarise(new_species = n())
#
year_A.data <- grass.data[!is.na(grass.data[,15]),] %>%
        dplyr::filter(taxon_status_id == "A") %>%
        dplyr::group_by(first_published) %>%
        dplyr::summarise(new_species = n())
#
# Group by decade and repeat
#
tmp <- 10*floor(grass.data[,15]/10)
#
group.data <- grass.data
group.data[,15] <- tmp
rm(tmp)
#
grp_year_SA.data <- group.data[!is.na(group.data[,15]),] %>%
        dplyr::filter(taxon_status_id == "A" | taxon_status_id == "S") %>%
        dplyr::group_by(first_published) %>%
        dplyr::summarise(new_species = n())
#
grp_year_A.data <- group.data[!is.na(group.data[,15]),] %>%
        dplyr::filter(taxon_status_id == "A") %>%
        dplyr::group_by(first_published) %>%
        dplyr::summarise(new_species = n())

#
# Percentage synonomy
#
grp_year_S_vs_A.data <- group.data[!is.na(group.data[,15]),] %>%
        dplyr::filter(taxon_status_id == "A" | taxon_status_id == "S") %>%
        dplyr::group_by(first_published,taxon_status_id) %>%
        dplyr::summarise(new_species = n()) %>%
        dplyr::ungroup() %>%
        reshape::melt(id = c('first_published','taxon_status_id')) %>%
        reshape::cast(...~taxon_status_id) %>%
        mutate(percent_syn = 100*S/(A+S))






#######

