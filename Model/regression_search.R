################################################################################           
#                                                                              #
#                                                                              #
# This function is an altered implementation of the work of Joppa et al 2010   #
# in their Brazil paper. It takes as input two dataframes, one giving          #
# aggregated as well as cumulative species for set time windows, the other     #
# giving number of active taxonomists. These can be easily created using the   #
# scripts in this repository.                                                  #                #
#                                                                              #
# This script will then attempt to produce an estimate for total species yet   #
# to be found using the model as proposed by Joppa. However, the algorithm to  #
# do so varies from theirs. Here the least squares residuals are used to       #
# evaluate each estimate, as opposed to first log-transforming the data.       #
#                                                                              #
# The algorithm works by guessing a selection of of equally spaced values for  #
# total species, where the number of guesses is set below. It then uses linear #
# regression with appropraite weights to find the values for a and b in the    #
# model of taxonomic efficiency that Joppa proposes. The initial guesses come  #
# from the range of the current total number of species up to a multiple of    #
# this given as a parameter below. From these guesses, the top scoring are     #
# selected, the proportion of these relative to the total mumber of guesses    #
# being set below. A new range of guesses are picked by stretching the range   #
# of this selection by a scaling factor set below.                             #
#                                                                              #
# These new guesses are then used to repeat the procedure until either the     #
# range of guesses converges to be accurate to the nearest integer,or the      #
# maximum number of iterations as set below is reached.                        #
#                                                                              #
# Should the stretching cause the bottom value to drop below the current total #
# number of species, then the range will be truncated to be no lower than this #
# number.                                                                      #
#                                                                              #
# To use simply edit the variables below. The output will be three graphs,     #
# a summary csv of the model parameters and scores and a csv of the raw data   #
# along with the predicted values                                              #
#                                                                              #
#                                                                              #
# Jonathan Williams, 2016                                                      #
# jonvw28@gmail.com                                                            #
#                                                                              #
################################################################################
#
########################## EXPLANATION OF ARGUMENTS ############################
#
# spec.data - data frame where column 1 is start year, column 2 is number of new
# species recorded in the time window, column 3 is the cumulative number of 
# species up to the given window.
#
# tax.data - data frame where column 1 is the start year and column 2 is the is 
# number of active taxonomists in the time window.
#
# en.yr - year at which data ends so as to enable trimming if need be
# eg 2015
#
# mult - multiple of current total species to start at as maxmimum guess for St
# eg 3
#
# guess.n - Guesses per round for St values
# eg 500
#
# ratio - Ratio of top scoring guesses to keep from all guesses per round
# eg 0.2
#
# stretch - Range Stretch to apply at each end (ie 1.25 would mean extend the
# range in each iteration by 25%)
# eg 1.5
#
# max.it - Max iteratations of guessing St
# eg 20
#
# out.dir - Directory where the output directory should go 
# eg "./Output"
#
# id.str - Identifier string - included in the file names and as subdirectory
# eg "grass_1755_5y"
#
# mod.dir - sub-directory where the model data should go
# eg "regression_search"
#
regression_search <- function(spec.data, tax.data, en.yr, mult, guess.n, ratio,
                              stretch, max.it, out.dir, id.str, mod.dir){
	#
	# Check for directory and create if needed
	#
	tmp.dir <- paste(out.dir,"/",id.str,"/",mod.dir,"/",sep = "")
	if(dir.exists(tmp.dir)==FALSE){
		dir.create(tmp.dir,recursive = T)
	}
	rm(out.dir)
	#
	# Install any dependancies and load functions
	#
	source("./kew_grasses/packages.R")
	source("./kew_grasses/functions.R")
	#
	#
	########################### DATA PROCESSING ####################################
	#
	# Merge data
	#
	data <- table.merge(spec.data,tax.data,data.index=2,split = 3)
	rm(spec.data,tax.data)
	#
	# Tidy data and remove any partial end year (ie if the final window is shorter 
	# than the other windows then it is excluded)
	# note: years in data are start years
	#
	yr.int <- data[2,1] - data[1,1]
	if((en.yr-data[1,1]+1) %% yr.int != 0){
		data <- data[1:(nrow(data)-1),]
	}
	rm(en.yr,yr.int)
	#
	#
	########################## Optimization Algorithm ##############################
	#
	# employ method in Joppa Brazil paper - without using log transform
	#
	# Calculate the current level of total species
	#
	start <- data[nrow(data),2] + data[nrow(data),3]
	#
	# Pick initial guesses as starting with the above and ending with the multiple
	# of this as given in the parameters, using equally spaced guesses as set
	#
	guesses <- seq(start+1,mult*start,length.out = guess.n)
	#
	# Set flag as counter for number of iterations
	# Set mark as a score for how big the range of candidate values for St is. 
	#       Once this is below 0.5 we know we have convergence to the precision
	#       of 1 integer.
	#
	flag <- 0
	mark <- 2
	#
	# Iteration over each set of guesses starts here and ends when maximum 
	# iterations are reached, or convergence as defined abpove is reached
	#
	while (mark > 0.5 && flag < max.it){
		#
		# Create placeholder for error score of each guess for St
		#
		results <- numeric(length(guesses))
		#
		# Find best choice of a, b for each guess of St using linear regression
		#
		for(i in 1:length(guesses)){
			#
			# Weights are needed to ensure the residuals being considered
			# for optimisation in calculating a, b are the same as those
			# used in calculating the global best fit for a, b & St
			#
			# This means that we can ensure the a, b choice for each St
			# minimises our overall error score for given St
			#
			weight <- (data[,4]*(rep(guesses[i],nrow(data))-data[,3]))
			test <- lm(data[,2]/weight ~ data[,1],weights = weight^2)
			#
			# Produce error score for each St guess
			#
			results[i] <- conv.cost(data,test$coefficients[1],
						test$coefficients[2],
					       guesses[i])
			rm(weight,test)
		}
		rm(i)
		#
		# Order the scores for each round of guesses and select only the top
		# proportion, as set by the ratio parameter
		#
		picks <- guesses[order(results)[1:(ratio*length(guesses))]]
		#
		# Calculate the range of these selected values and extend it by the
		# stretch factor set in the parameters
		#
		rng <- range(picks)
		extra <- (rng[2]-rng[1])*(stretch-1)/2
		rng[1] <- rng[1] - extra
		rng[2] <- rng[2] + extra
		#
		# Ensure the range never drops below the current total number of species
		#
		if(rng[1] <= start){
			rng[1] <- start + 1
		}
		#
		# Use this range to pick the new guesses for the next iteration
		#
		guesses <- seq(rng[1],rng[2],length.out = guess.n)
		#
		# Score current convergence
		#
		mark <- rng[2]-rng[1]
		rm(rng,extra)
		flag <- flag + 1
		#
		#
	}
	rm(results,guesses)
	#
	# Calculate a and b for the best choice of St output and store these in the
	# variable 'param'
	#
	weight <- (data[,4]*(rep(picks[1],nrow(data))-data[,3]))
	test <- lm(data[,2]/weight ~ data[,1],weights = weight^2)
	params <- c(test$coefficients[1],test$coefficients[2],picks[1])
	names(params) <- c("a","b","St")
	rm(test,weight,picks)
	#
	# Process results depending on whether convergence was reached
	#
	if(mark > 0.5){
		cat("Algorithm failed to converge to a value of total species accurate",
		    " to the nearest integer after",max.it,"iterations. Try using more",
		    " iterations or reducing the ratio of values passed on after each",
		    " round\n")
	} else {
		cat("Algorithm reported the best-fitting number of species to be",
		    params[3],"after completing",flag,"iterations, each comprising",
		    guess.n,"guesses derived by taking the range of the top",
		    100*ratio,"% best-fitting guesses in the previous iteration and",
		    " expanding it about its mid-point to",100*stretch,
		    "% of its size and spacing guesses equally amongst this\n")
		#
		# output data
		#
		out.dat <- c(params,
			     "cost_fn" = conv.cost(data,params[1],params[2],params[3]),
			     "iterations_taken" = flag,
			     "guesses_per_it" = guess.n,
			     "ratio_kept" = ratio,
			     "expansion_per_it" = stretch,
			     "initial_multiple" = mult)
		#
		# plot of error score against St for the initial range of guesses
		#
		guesses <- seq(start+1,mult*start,length.out = guess.n)
		results <- numeric(length(guesses))
		for(i in 1:length(guesses)){
			weight <- (data[,4]*(rep(guesses[i],nrow(data))-data[,3]))
			test <- lm(data[,2]/weight ~ data[,1],weights = weight^2)
			results[i] <- conv.cost(data,test$coefficients[1],
						test$coefficients[2],
						guesses[i])
			rm(weight,test)
		}
		rm(i)
		#
		png(paste(tmp.dir,id.str,"_regression_search_error_plot.png",sep=""),width = 960,
		    height = 960)
		plot(guesses,results,xlab = "Total Species",
		     ylab = "Least Squares Score",
		     main = paste("Least Squares Error vs Total Species - Regression Search ",
				  id.str,sep=""),
		     col = "blue",
		     type = 'l')
		dev.off()
		#
		# Calculate predicted fit
		#
		tmp <- (rep(params[3],nrow(data))-data[,3])
		pred <- (params[1] + params[2]*data[,1])*data[,4]*tmp
		rm(tmp)
		#
		# Plot species and taxonomists per year
		#
		png(paste(tmp.dir,id.str,"_regression_search_species_rat.png",sep=""),width = 960,
		    height = 960)
		plot(data[,1],data[,2],pch = 21,col='red',
		     ylim = c(0,1.25*max(data[,2])),
		     xlab = "year", ylab = "Number",
		     main = paste("Discovery rates and number of taxonomists - Regression Search ",
				  id.str,sep=""))
		lines(data[,1],data[,2],pch = 21,col='red')
		lines(data[,1],data[,4],col = 'blue')
		lines(data[,1],pred,col = 'green')
		legend("topleft", legend = c("New Species - Actual",
					     "New Species - Predicted",
					     "Active Taxnomists"),
		       col = c("red","green","blue"),lty = c(1,1,1))
		dev.off()
		#
		# Plot species per taxonomist
		#
		png(paste(tmp.dir,id.str,"_regression_search_species_per_tax.png",sep=""),width = 960, 
		    height = 960)
		plot(data[,1],data[,2]/data[,4],pch = 21,col='red', ylim = c(0,20),
		     xlab = "year", ylab = "Number",
		     main = paste("Species per taxonomist - Regression Search ",
				  id.str,sep=""))
		lines(data[,1],data[,2]/data[,4],pch = 21,col='red')
		lines(data[,1],pred/data[,4],col = 'green')
		dev.off()
		#
		# Save output of model
		#
		tmp <- cbind(data,pred)
		
		write.csv(tmp,
			  file=paste(tmp.dir,id.str,"_regression_search",
			             "_model.csv",sep=""),
			  row.names = FALSE)
		write.csv(t(out.dat),
			  file=paste(tmp.dir,id.str,"_regression_search",
			             "_model_summary.csv",sep=""),
			  row.names = FALSE)
	}
	rm(mult,stretch,max.it,ratio,mark,flag,guess.n,start,guesses,results,params)
	rm(out.dat,data,pred,tmp,tmp.dir,id.str)
}