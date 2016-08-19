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
# Install any dependancies and load basic functions
#
source("./kew_grasses/Support/packages.R")
source("./kew_grasses/Support/functions.R")
#
# Load in all files giving setting for the models
#
source("./kew_grasses/Options_Files/indices.R")
source("./kew_grasses/Options_Files/output_options.R")
source("./kew_grasses/Options_Files/search_parameters.R")
source("./kew_grasses/Options_Files/name_formatting.R")
#
# Call geographical setting is requested, else set levels to NULL to signal
# not to apply geographic model
#
if(geo.model){
	source("./kew_grasses/Options_Files/geographical_model.R")
} else{
	levels <- NULL
	loc.ind <- NULL
	filt.ind <- NULL
	filt.mk <- NULL
	n.spec <- NULL
}
#
# Load gradient descent parameters if appropriate
#
if(gradient.descent || geo.gradient.descent){
	source("./kew_grasses/Options_Files/gradient_descent.R")
}
#
# Call scripts which set parameters to ensure the correct method is applied.
#
source("./kew_grasses/Support/Data_Processing/species_method.R")
source("./kew_grasses/Support/Data_Processing/taxon_method.R")
#
# Call corect script to run analysis
#
if(subsetting){
	source("./kew_grasses/support/complete_pipeline_filter.R")
}else{
# No filtering
	source("./kew_grasses/support/complete_pipeline_whole_dataset.R")
}