

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
######## St SEARCH PARAMETERS
#
# multiple of current total species to start at as maxmimum guess for St
mult <- 3
# Guesses per round for St values
guess.n <- 500
# Ratio of top scoring guesses to keep from all guesses per round
ratio <- 0.2
# stretch - Range Stretch to apply at each end (ie 1.25 would mean extend the
# range in each iteration by 25%)
stretch <- 1.5
# Max iteratations of guessing St
max.it <- 20
#

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
# Name of sub-directory within the output directory for processed aggregate 
# taxonomist data to go
tax.dir <- "taxon_data"
#
# Name of sub-directory within the output directory for regression model results 
#  to go
reg.dir <- "regression_search"
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
cat("Processing Aggregate Species Data\n")
source("./kew_grasses/data_processing/species_data.R")
species_data(dir.path, spec.file.name, loc.file.name, id.ind, yr.ind, tax.stat,
             stat.ind, stat.mk, hyb.stat, hyb.ind, hyb.mk, rnk.stat, rnk.ind,
             rnk.mk, filt.ind, filt.mk, loc.ind, levels, st.yr, en.yr, int.yr, #
             out.dir, spec.dir, id.str)
#
# Complete the aggregated taxonomist data processing
#
cat("Processing Aggregate Taxonomists Data\n")
source("./kew_grasses/data_processing/author_data.R")
author_data(dir.path, spec.file.name, loc.file.name, id.ind, yr.ind,auth.ind, 
            tax.stat, stat.ind, stat.mk, hyb.stat, hyb.ind, hyb.mk, rnk.stat,
            rnk.ind, rnk.mk, filt.ind, filt.mk, loc.ind, levels, st.yr, en.yr, 
            int.yr, out.dir, tax.dir, id.str)
#
# loactions of the aggregate output
#
agg.loc <- paste(out.dir,"/",id.str,"/",sep="")
agg.spec <- paste(spec.dir,"/",id.str,"_species_overall_summary",sep = "")
agg.tax <- paste(tax.dir,"/",id.str,"_tax_overall_summary",sep = "")
#
# Run complete normal regression search method
#
cat("Computing Regression Search Model\n")
source("./kew_grasses/model/regression_search.R")
regression_search(dir.path = agg.loc, spec.file.name = agg.spec, tax.file.name = agg.tax, 
                  en.yr, mult, guess.n, ratio, stretch, max.it, out.dir,
                              id.str, mod.dir=reg.dir)
#
# Clear the workspace
#
rm(list = ls())