# This file will implement the model described in this repository whilst using 
# as many default settings as possible. Should the user wish to change settings 
# then they can dig into the settings_files directory where various scripts and
# explanaitions of their variables are held.
#
# Jonathan Williams, 2016                                                      
# jonvw28@gmail.com    
#
################################################################################
#
# First set the location of the working directory to the directory within which
# the repository has been downloaded
#
setwd("~/Kew Summer")
#
# Now set the directory within this where the .csv files are held
#
dir.path <- "./Data/07_05/"
#
#
# Set the names of the species data file (and optional distribution data file)
# NOTE: these are without the '.csv' at the end
# NOTE: If you are not using a WCSP download then you will need to go to the
# indices settings file and manually set the relevant indices for your dataset.
#
spec.file.name <- "public_checklist_flat_plant_dl_20160705_poaceae"
loc.file.name <- "Poaceae_distribution"
#
#
# Set the name of the repository within the working directory where you would 
# like the output to go. if you would like to alter the structure of the output
# you will need to go into the output options file
#
output.location <- "./Output"
#
# Set a unique and memorable identfier to be used in all of the output file 
# names
identifier <- "grass"
#
#
# Set the start and end years
#
start.year <- 1766
end.year <- 2015
#
#
# Set the window size (in years)
#
interval <- 5
#
#
# If you would like to use rolling windows set the below to TRUE and then set 
# the number of years you want the offset to be:
#
rolling.windows <- FALSE
offset <- 3
#
#
# Decide on the method you would like to use for counting the numbers of 
# species for each window. Select from "all", "filtered - not status",
# "filtered - status", "filtered - status - basionym dated",  "all basionyms",
# "basionyms filtered - not status", "basionyms filtered - status"
#
species.method <- "all basionyms"
#
#
# Decide on the method you would like to use for counting the numbers of 
# taxonomists for each window. Select from "all", "filtered - not status",
# "filtered - status", "all basionyms", "basionyms filtered - not status", 
# "basionyms filtered - status"
#
taxonomist.method <- "all"
#
#
# If you would like to use the subsetting method, where the model is fitted to 
# a list of subsets of the data then set the below to TRUE. You will also need 
# to set the column where the subsetting varibale is, and set the different 
# subsetting factors in a vector.
#
subsetting <- FALSE
subset.column <- 5
subsets <- c("Poa","Agrostis")
#
#
# If you would like to apply the gradient descent search method and/or the
# regression search cross-validation to be used on the complete data then set 
# the below to TRUE
#
gradient.descent <- FALSE
cross.validation <- FALSE
#
#
# Set the below to TRUE if you want to use a geographic model - to customise
# this from the default will require the user to go to the geographic data file.
# You can also set the option of gradient descent search and cross-validation 
# for each region.
#
geo.model <- FALSE
geo.gradient.descent <- FALSE
geo.cross.validation <- FALSE
#
# 
################################################################################
#                                                                              #
#                       DO NOT EDIT CODE BELOW THIS LINE                       #            
#                                                                              #
################################################################################
#
# Call script that selects the appropriate inputs and applies correct models
#
source("./kew_grasses/Support/handler.R")
#
rm(list = ls())