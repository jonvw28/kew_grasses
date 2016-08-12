# Issue with geographic data thus far



# This script can be used to replicate the analysis undertaken in the summer
# project "Where are the missing grasses?" based at RBG Kew in summer 2016.
#
# For a full explanation of the script and the methods it employs, as well as
# how to use it yourself please see the readme in this repository.
#
#
################################################################################
#
# SET DIRECTORY where you have downloaded repository (ie before /kew_grasses)
#
setwd("~/Kew Summer")
#
############################ SET INPUT VALUES HERE #############################
#
######################## Select models to apply ################################
#
# By default, the regression search model will be applied to the global data as 
# as well as to each level in region data. Cross validation and the Joppa method 
# will only be applied if the appropriate variables below are set to true.
#
#
# Cross Validation on glabal level
global.CV <- FALSE
#
# Cross Validation on regional data
region.CV <- FALSE
#
# Joppa on glabal level
global.joppa <- FALSE
#
# Joppa on regional data
region.joppa <- FALSE
#
#
####################### RAW DATA LOCATION - WCSP download ######################
#
# Directory path - location of csv input files
dir.path <- "./Data/07_05/"
# Species File name - name of csv file with species information 
# (without .csv at end)
spec.file.name <- "public_checklist_flat_plant_dl_20160705_poaceae"
# Location File name - name of csv file with location information 
# (without .csv at end)
loc.file.name <- "Poaceae_distribution"
#
###################### Filtering to subset data ################################
#
# Column where filter is to be applied for species and location data set 
# respectively - eg family
subset.col <- 3
#
# Each subset to be selected - will apply method to each subset
subset.mk <- c("Poaceae")
#
########################## INDICES IN DATA FILES ###############################
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
############################# DATA FILTERING ###################################
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
####################### MODEL PARAMETERS #######################################
#
# Start year
st.yr <- 1766
# End year
en.yr <- 2015
# Window Interval - how many years you want aggregation to occur over
int.yr <- 5
#
###################### St SEARCH PARAMETERS ####################################
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
###################### Gradient Descent Parameters #############################
#
# Scaling to apply to taxonomist numbers and species numbers respectively
# (years are dealt with automatically) - This is to help gradient descent
# efficiency
scale <- c(100,1000)
#
# Range to test for a and b starting point in each gradient 
# descent - note these are not transformed by the scalings (ie these values will
#  be used as they currently are directly with the tranformed data, however a 
# and b as output are for the none scaled data) 
rng.a <- c(-0.1,0.1)
rng.b <- c(-0.1,0.1)
#
# No of initial values of a and b to try
ab.guesses <- c(100,100)
#
# Max repetitions of grad descent to get a,b for each St value
max.grad <- 500
#
# Step size for each gradient descent step
alpha <- 0.01
#
# Minimum step size - program quits if a step smaller than this is required
min.alp <- 2e-14
#
# Ratio for gradient/parameter value where gradient descent should be 
# terminated - ie once this ratio is reached, gradient descent ends
grd.rat <- 1e-4
#
######################### OUTPUT SAVE LOCATIONS ################################
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
# to go
reg.dir <- "regression_search"
#
# Name of sub-directory within the output directory for regression model 
# cross-validation results to go
regcv.dir <- "regression_search_cross_validation"
#
# Name of sub-directory within the output directory for log difference gradient 
# descent model results to go
log.dir <- "grad_descent_search_log_residuals"
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
# Loop over each subset
#
for(s in 1:length(subset.mk)){
        #
        # Identifier string
        id.str <- paste(subset.mk[s],"_",st.yr,"_",int.yr,"_year",sep = "")
        #
        tmp.dir <- paste(out.dir,"/",id.str,"/",sep="")
        tmp.spec <- paste(spec.file.name,"_",subset.mk[s],sep="")
        tmp.loc <- paste(loc.file.name,"_",subset.mk[s],sep="")
        #
        csv_filter(dir.path, paste(spec.file.name,".csv",sep=""), subset.col, 
                   subset.mk[s], tmp.dir, paste(tmp.spec,".csv",sep=""))
        
        #
        #
        # HERE BE ISSUE ~~~~~~~~~~~~~~ Don't currently have a location filter possible
        # Could simply rely on filtering based on plant id
        #
        #
        write.csv(read.csv(paste(dir.path,loc.file.name,".csv",sep=""),
                           stringsAsFactors = FALSE),
                  file=paste(tmp.dir,tmp.loc,".csv",sep =""),
                  row.names = FALSE)
        
        
        #
        # Complete the aggregated species data processing
        #
        cat("Processing Aggregate Species Data...\n")
        source("./kew_grasses/data_processing/species_data.R")
        species_data(tmp.dir, tmp.spec, tmp.loc, id.ind, yr.ind, tax.stat,
                     stat.ind, stat.mk, hyb.stat, hyb.ind, hyb.mk, rnk.stat, rnk.ind,
                     rnk.mk, filt.ind, filt.mk, loc.ind, levels, st.yr, en.yr, int.yr, 
                     out.dir, spec.dir, id.str)
        cat("Complete!\n\n")
        #
        # Complete the aggregated taxonomist data processing
        #
        cat("Processing Aggregate Taxonomists Data...\n")
        source("./kew_grasses/data_processing/author_data.R")
        author_data(tmp.dir, tmp.spec, tmp.loc, id.ind, yr.ind,auth.ind, 
                    tax.stat, stat.ind, stat.mk, hyb.stat, hyb.ind, hyb.mk, rnk.stat,
                    rnk.ind, rnk.mk, filt.ind, filt.mk, loc.ind, levels, st.yr, en.yr, 
                    int.yr, out.dir, tax.dir, id.str)
        cat("Complete!\n\n")
        #
        # locations of the aggregate output
        #
        agg.loc <- paste(out.dir,"/",id.str,"/",sep="")
        agg.spec <- paste(spec.dir,"/",id.str,"_species_overall_summary",sep = "")
        agg.tax <- paste(tax.dir,"/",id.str,"_tax_overall_summary",sep = "")
        #
        # Load in global data
        #
        spec.data <- read.csv(paste(agg.loc,agg.spec,".csv",sep=""),
                              stringsAsFactors = FALSE)
        tax.data <- read.csv(paste(agg.loc,agg.tax,".csv",sep=""),
                                          stringsAsFactors = FALSE)
        #
        # Run complete normal regression search method for global data
        #
        cat("Computing Regression Search Model...\n")
        source("./kew_grasses/model/regression_search.R")
        regression_search(spec.data, tax.data, en.yr, mult, guess.n, ratio, stretch, 
                          max.it, out.dir, id.str, mod.dir=reg.dir)
        cat("Complete!\n\n")
        #
        # Run complete normal regression search method cross validation for global data
        # if selected
        #
        if(global.CV){
                cat("Computing Regression Search Model cross validation...\n")
                source("./kew_grasses/model/regression_search_cross_validation.R")
                regression_search_cross_validation(spec.data, tax.data, en.yr, mult, guess.n, 
                                                   ratio, stretch, max.it, out.dir, id.str, 
                                                   mod.dir=regcv.dir)
                cat("Complete!\n\n")
        }
        #
        # Run Joppa inspired difference in logs via (a,b) gradient descent combined with
        # St search if selected
        #
        if(global.joppa){
                cat("Computing Log Difference Gradient Descent Search Model...\n")
                source("./kew_grasses/model/grad_descent_search_log_residuals.R")
                grad_descent_search_log_residuals(spec.data, tax.data, en.yr, mult, guess.n,
                                                  ratio, stretch, max.it, scale, rng.a, rng.b,
                                                  ab.guesses, max.grad, alpha, min.alp, 
                                                  grad.rat, out.dir,id.str, mod.dir=log.dir)
                cat("Complete!\n\n")  
        }
        rm(spec.data,tax.data)
        #
        # Deal with regional levels
        #
        #
        # Set up collection for predictions and later adjustments
        #
        predictions <- list()
        if(region.CV){
                source("./kew_grasses/model/regression_search_cross_validation.R")
        }
        if(region.joppa){
                source("./kew_grasses/model/grad_descent_search_log_residuals.R")
        }
        for(i in 1:length(levels)){
                spec.data <- read.csv(paste(agg.loc,spec.dir,"/",levels[i],"/",
                                            id.str,"_species_summary_",levels[i],".csv",sep=""),
                                      stringsAsFactors = FALSE)
                tax.data <- read.csv(paste(agg.loc,tax.dir,"/",levels[i],"/",
                                            id.str,"_",levels[i],"_tax_summary.csv",sep=""),
                                      stringsAsFactors = FALSE)
                names(tax.data) <- paste(names(tax.data),"_t",sep="")
                n.region <- (ncol(spec.data)-1)/2
                predictions[[i]] <- matrix(0, ncol = 5, nrow = n.region)
                predictions[[i]] <- as.data.frame(predictions[[i]])       
                names(predictions[[i]]) <- c("region","current_level","raw_prediction",
                                        "adjusted_prediction","percentage_observed")
                #
                for(j in 1:n.region){
                        predictions[[i]][j,2] <- (spec.data[nrow(spec.data),n.region+j+1]
                                             + spec.data[nrow(spec.data),j+1])
                        tmp.reg <- colnames(spec.data)[j+1]
                        predictions[[i]][j,1] <- tmp.reg
                        if(spec.data[nrow(spec.data),n.region+j+1] < 50){
                                next()
                        }
        
                        cat("Fitting models for",levels[i],tmp.reg,"\n")
                        capture.output(regression_search(spec.data[,c(1,j+1,j+n.region+1)], 
                                          tax.data[,c(1,j+1)], en.yr, mult, guess.n, 
                                          ratio, stretch, 
                                          max.it, out.dir, id.str, 
                                          mod.dir=paste(reg.dir,"/",levels[i],"/",
                                                        tmp.reg,sep="")
                                          ),
                                       file='NUL'
                        )
                        if(region.CV){
                                capture.output(regression_search_cross_validation(spec.data[,c(1,j+1,j+n.region+1)], 
                                                                   tax.data[,c(1,j+1)],
                                                                   en.yr, mult, guess.n, 
                                                                   ratio, stretch, max.it,
                                                                   out.dir, id.str, 
                                                                   mod.dir=paste(reg.dir,"/",levels[i],"/",
                                                                                 tmp.reg,sep="")
                                                                   ),
                                               file='NUL'
                                )
                        }
                        if(region.joppa){
                                capture.output(grad_descent_search_log_residuals(spec.data[,c(1,j+1,j+n.region+2)], 
                                                                  tax.data[,c(1,j+1)], en.yr, mult,
                                                                  guess.n, ratio, stretch, max.it, 
                                                                  scale, rng.a, rng.b, ab.guesses, 
                                                                  max.grad, alpha, min.alp, 
                                                                  grad.rat, out.dir,id.str, 
                                                                  mod.dir=paste(reg.dir,"/",levels[i],"/",
                                                                                tmp.reg,sep="")
                                                                  ),
                                               file = 'NUL'
                                )
                        }
                        tmp.dat <- read.csv(paste(agg.loc,reg.dir,"/",levels[i],"/",tmp.reg,"/",
                                                  id.str,"_regression_search_model_summary.csv",sep=""),
                                            stringsAsFactors = FALSE)
                        predictions[[i]][j,3] <- tmp.dat[1,3]
                        rm(tmp.reg,tmp.dat)
                        cat("Complete!\n\n")
                }
                rm(spec.data,tax.data,n.region)
        }
        #
        # Pick out global predicted total
        #
        tmp.file <- read.csv(paste(agg.loc,reg.dir,"/",id.str,
                                   "_regression_search_model_summary.csv",sep=""),
                             stringsAsFactors = FALSE)
        pred.glob <- tmp.file[1,3]
        rm(tmp.file)
        #
        # impute predictions where total is too small
        #       Here any missing values are assumed to take on the ratio of
        #       prediction/current as given by the aggregated data for regions 
        #       with a prediction
        #
        # Rescale eventual predictions in current ratio so that global total is equal
        # to the predicted global trend
        #
        for(k in 1:length(levels)){
                issues <- which(predictions[[k]][,3]==0)
                pred.rat <- sum(predictions[[k]][,3])/sum(predictions[[k]][-issues,2])
                predictions[[k]][issues,3] <- predictions[[k]][issues,2]*pred.rat
                rm(pred.rat)
                adj.rat <- pred.glob/sum(predictions[[k]][,3])
                predictions[[k]][,4] <- predictions[[k]][,3]*adj.rat
                predictions[[k]][,5] <- predictions[[k]][,2]/predictions[[k]][,4]*100
                rm(adj.rat)
                write.csv(predictions[[k]],
                          file=paste(agg.loc,id.str,"_regional_predictions_",levels[k],
                                     "_model_summary.csv",sep=""),
                          row.names = FALSE)
        }
        rm(tmp.dir,tmp.spec,tmp.loc)
}
#
# Clear the workspace
#
rm(list = ls())