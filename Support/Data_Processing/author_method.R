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
# This script looks as the user set methods in RunMe.R and sets appropriate 
# parameters for author data scripts
#
if(!(taxonomist.method %in% c("all","filtered - not status","filtered - status", 
			   "all basionyms",
			   "basionyms filtered - not status", 
			   "basionyms filtered - status")
	)
){
	#
	# Not a valid choice
	#
	stop("Invalid species data handling method entered")
}
#
if(taxonomist.method == "all"){
#
# Method simply takes all names so no need to filter
#
	spe.tax.stat <- FALSE
	spe.hyb.stat <- FALSE
	spe.rank.stat <- FALSE
#
# As all names are included, we are interested in the year of publication of
# each combination so no correction for basionyms
#
	basio.year <- FALSE
	basio.filt <- FALSE
}
#
if(taxonomist.method == "filtered - not status"){
#
# Method only filters on rank and hybrid status
#
	spe.tax.stat <- FALSE
	spe.hyb.stat <- TRUE
	spe.rank.stat <- TRUE
#
# As all names are included, we are interested in the year of publication of
# each combination so no correction for basionyms
#
	basio.year <- FALSE
	basio.filt <- FALSE
}
#
if(taxonomist.method == "filtered - status"){
#
# Method applies all filters 
#
	spe.tax.stat <- TRUE
	spe.hyb.stat <- TRUE
	spe.rank.stat <- TRUE
#
# As all names are included, we are interested in the year of publication of
# each combination so no correction for basionyms
#
	basio.year <- FALSE
	basio.filt <- FALSE
}
#
if(taxonomist.method == "all basionyms"){
#
# Method applies no filters 
#
	spe.tax.stat <- FALSE
	spe.hyb.stat <- FALSE
	spe.rank.stat <- FALSE
#
# As all basionyms are included, we are interested in the year of publication of
# each combination so no correction for basionyms
#
	basio.year <- FALSE
	basio.filt <- TRUE
}
#
if(taxonomist.method == "basionyms filtered - not status"){
#
# Method applies all filters but status
#
	spe.tax.stat <- FALSE
	spe.hyb.stat <- TRUE
	spe.rank.stat <- TRUE
#
# As all basionyms are included, we are interested in the year of publication of
# each combination so no correction for basionyms
#
	basio.year <- FALSE
	basio.filt <- TRUE
}
#
if(taxonomist.method == "basionyms filtered - not status"){
#
# Method applies all filters
#
	spe.tax.stat <- TRUE
	spe.hyb.stat <- TRUE
	spe.rank.stat <- TRUE
#
# As all basionyms are included, we are interested in the year of publication of
# each combination so no correction for basionyms
#
	basio.year <- FALSE
	basio.filt <- TRUE
}