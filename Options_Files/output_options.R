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
# This file contains the set-up for the output file directory structure.
# The default is set up for a relatively sensible system where there is a folder
# for the species aggregate data, a folder for the taxonomist aggregate data and
# folders for each model that is fitted. Geographic models are then nested 
# within these folders.
#
#
# Name of sub-directory within the output directory for processed aggregate 
# species data to go
spec.dir <- "species_data"
#
# Name of sub-directory within the output directory for processed aggregate 
# taxonomist data to go
tax.dir <- "taxon_data"
#
# Name of sub-directory within the output directory for regression search 
# results to go
reg.dir <- "regression_search"
#
# Name of sub-directory within the output directory for regression search
# cross-validation results to go
regcv.dir <- "regression_search_cross_validation"
#
# Name of sub-directory within the output directory for gradient descent 
# search results to go
grad.dir <- "grad_descent_search"