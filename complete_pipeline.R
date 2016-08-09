

#
# SET DIRECTORY where you have downloaded repository (ie before /kew_grasses)
#
setwd("~/Kew Summer")
#
############################ SET INPUT VALUES HERE #############################
#
################## RAW DATA LOCATION - WCSP download
#
# Directory path - location of csv input files
dir.path <- "./Data/07_05/"
# Species File name - name of csv file with species information 
#(without .csv at end)
spec.file.name <- "public_checklist_flat_plant_dl_20160705_poaceae"
# Location File name - name of csv file with location information 
#(without .csv at end)
loc.file.name <- "Poaceae_distribution"
#
######################## INDICES IN DATA FILES
#
# Plant ID column - indices of the columns where plant IDs are held for the
# species and location data respectively
id.ind <- c(1,2)
# Year column - index of the column where the year of publication is stored in 
# the species data
yr.ind <- 15
# Primary Authors column - index of the column containing the primary authors in 
# the specis data
auth.ind <- 11
# Location IDs - indices of columns in location data where loactions are stored
loc.ind <- c(4,6)
# Names of each level of regions
levels <- c("TDWG1","TDWG2")
#
#################### DATA FILTERING
#
# Taxonomic status filtering - if set to true then there will be filtering to 
# only allow authors of species of the status specified in the column given
tax.stat <- TRUE
stat.ind <- 17
stat.mk <- c("A")
# Hybrid filtering - if set to true then there will be filtering to 
# remove authors of species which are hybrids
hyb.stat <- TRUE
hyb.ind <- c(4,6)
hyb.mk <- c("×","×")
# Taxonomic rank filtering - if set to true then there will be filtering to 
# only allow authors of species of the status specified in the column given
rnk.stat <- TRUE
rnk.ind <- 23
rnk.mk <- c("Species")
# Location Filter IDs - any columns in location data that are to be filtered in
# creating a valid dataset and the marks in these columns for removal
filt.ind <- c(11,12,13,14)
filt.mk <- c(1,1,1,1)
#
#################### MODEL PARAMETERS
#
# Start year
st.yr <- 1753
# End year
en.yr <- 2015
# Window Interval - how many years you want aggregation to occur over
int.yr <- 5
#
################## OUTPUT SAVE LOCATIONS
#
# Output directory
out.dir <- "./Output"
#
# Identifier string - include info for the file names and will be used to create 
# sub-directory
id.str <- paste("grass_",st.yr,"_",int.yr,"_year",sep = "")
#
# Name of sub-directory within the above for processed aggregate species data to
# go
spec.dir <- "species_data"
#
# Name of sub-directory within the above for processed aggregate taxonomist data
# to go
tax.dir <- "taxon_data"
#
#
################################################################################
#                                                                              #
#                       DO NOT EDIT CODE BELOW THIS LINE                       #            
#                                                                              #
################################################################################
#
#
# Install any dependancies and load basic functions
#
source("./kew_grasses/packages.R")
source("./kew_grasses/functions.R")
#
# Complete the aggregated species data processing
#
source("./kew_grasses/data_processing/species_data.R")
species_data(dir.path, spec.file.name, loc.file.name, id.ind, yr.ind, tax.stat,
             stat.ind, stat.mk, hyb.stat, hyb.ind, hyb.mk, rnk.stat, rnk.ind,
             rnk.mk, filt.ind, filt.mk, loc.ind, levels, st.yr, en.yr, int.yr, #
             out.dir, spec.dir, id.str)
#
# Complete the aggregated taxonomist data processing
#
source("./kew_grasses/data_processing/author_data.R")
author_data(dir.path, spec.file.name, loc.file.name, id.ind, yr.ind,auth.ind, 
            tax.stat, stat.ind, stat.mk, hyb.stat, hyb.ind, hyb.mk, rnk.stat,
            rnk.ind, rnk.mk, filt.ind, filt.mk, loc.ind, levels, st.yr, en.yr, 
            int.yr, out.dir, tax.dir, id.str)
#
# Clear the workspace
#
rm(list = ls())