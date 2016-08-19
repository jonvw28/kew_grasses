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
# Complete the aggregated species data processing
#
cat("Processing Aggregate Species Data...\n")
source("./kew_grasses/Support/data_processing/species_data.R")
species_data(dir.path, spec.file.name, loc.file.name, id.ind, yr.ind, 
             basio.filt, basio.year, basio.ind, miss.bas, spe.tax.stat,
             stat.ind, stat.mk, spe.hyb.stat, hyb.ind, hyb.mk, spe.rnk.stat, 
             rnk.ind, rnk.mk, filt.ind, filt.mk, loc.ind, levels, st.yr, en.yr, 
             int.yr, rolling.windows, offset, output.location, spec.dir, id.str)
cat("Complete!\n\n")
#
# Complete the aggregated taxonomist data processing
#
cat("Processing Aggregate Taxonomists Data...\n")
source("./kew_grasses/Support/data_processing/author_data.R")
author_data(dir.path, spec.file.name, loc.file.name, id.ind, yr.ind,auth.ind,
	    comma, in.tag, in.inc, ex.tag, ex.inc, basio.filt, basio.ind, 
            miss.bas, tx.tax.stat, stat.ind, stat.mk, tx.hyb.stat, hyb.ind, 
            hyb.mk, tx.rnk.stat, rnk.ind, rnk.mk, filt.ind, filt.mk, loc.ind,
            levels, st.yr, en.yr, int.yr, rolling.windows, offset,
            output.location, tax.dir, id.str)
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
source("./kew_grasses/Support/model/regression_search.R")
regression_search(spec.data, tax.data, en.yr, mult, guess.n, ratio, stretch, 
                  max.it, out.dir, id.str, mod.dir=reg.dir)
cat("Complete!\n\n")
#
# Run complete normal regression search method cross validation for global data
# if selected
#
if(cross.validation){
        cat("Computing Regression Search Model cross validation...\n")
        source("./kew_grasses/Support/model/regression_search_cross_validation.R")
        regression_search_cross_validation(spec.data, tax.data, en.yr, mult, guess.n, 
                                           ratio, stretch, max.it, out.dir, id.str, 
                                           mod.dir=regcv.dir)
        cat("Complete!\n\n")
}
#
# Run Joppa inspired difference in logs via (a,b) gradient descent combined with
# St search if selected
#
if(gradient.descent){
        cat("Computing Log Difference Gradient Descent Search Model...\n")
        source("./kew_grasses/Support/model/grad_descent_search_log_residuals.R")
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
if(!is.null(levels)){
        #
        # Set up collection for predictions and later adjustments
        #
        predictions <- list()
        if(geo.cross.validation){
                source("./kew_grasses/Support/model/regression_search_cross_validation.R")
        }
        if(geo.gradient.descent){
                source("./kew_grasses/Support/model/grad_descent_search_log_residuals.R")
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
                        if(spec.data[nrow(spec.data),n.region+j+1] < n.spec){
                                next()
                        }
        
                        cat("Fitting models for",levels[i],tmp.reg,"\n")
                        capture.output(regression_search(spec.data[,c(1,j+1,j+n.region+1)], 
                                          tax.data[,c(1,grep(names(spec.data)[j+1],names(tax.data)))], 
                                          en.yr, mult, guess.n, ratio, stretch, 
                                          max.it, out.dir, id.str, 
                                          mod.dir=paste(reg.dir,"/",levels[i],"/",
                                                        tmp.reg,sep="")
                                          ),
                                       file='NUL'
                        )
                        if(geo.cross.validation){
                                capture.output(regression_search_cross_validation(spec.data[,c(1,j+1,j+n.region+1)], 
                                                                   tax.data[,c(1,grep(names(spec.data)[j+1],names(tax.data)))],
                                                                   en.yr, mult, guess.n, 
                                                                   ratio, stretch, max.it,
                                                                   out.dir, id.str, 
                                                                   mod.dir=paste(reg.dir,"/",levels[i],"/",
                                                                                 tmp.reg,sep="")
                                                                   ),
                                               file='NUL'
                                )
                        }
                        if(geo.gradient.descent){
                                capture.output(grad_descent_search_log_residuals(spec.data[,c(1,j+1,j+n.region+2)], 
                                                                  tax.data[,c(1,grep(names(spec.data)[j+1],names(tax.data)))], 
                                                                  en.yr, mult,
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
}