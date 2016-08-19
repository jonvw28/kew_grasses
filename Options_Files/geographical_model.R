# This script can be used to replicate the analysis undertaken in the summer
# project "Where are the missing grasses?" based at RBG Kew in summer 2016.
#
# For a full explanation of the script and the methods it employs, as well as
# how to use it yourself please see the readme in this repository.
#                                                                              
# Jonathan Williams, 2016                                                      
# jonvw28@gmail.com    
#
################################################################################
#
# This file contains the set-up for geographical models, if selected. As default
# the set up will work for a WCSP downloaded distribution dataset. However, this
# can be readily editted to work for your dataset of choice.
#
#
# Location IDs - indices of columns in location data where locations are stored
#
loc.ind <- c(4,6)
#
#
# Names of each level of regions - will be used for output names
#
levels <- c("TDWG1","TDWG2")
#
#
# Minimum number of species in each region for model to be fitted to that region
#
n.spec <- 50
#
#
# Location Filter IDs - any columns in location data that are to be filtered in
# creating a valid dataset and the marks in these columns for removal 
# eg remove locations where a species has been introduced
#
# To remove multiple marks in the same column, enter both marks and repeat the
# index in the corresponding positions in filt.ind
#
filt.ind <- c(11,12,13,14,15)
filt.mk <- c(1,1,1,1,1)