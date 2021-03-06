################################################################################           
#                                                                              #
#                                                                              #
# This function is an altered implementation of the sister function	       #
# regression_search. Here the script runs the same algorithm as its sister,    #
# but uses it to run a jack-knife cross-validation. Here the algorithm is      #
# applied repeatedly to the data with one year left out and the results are    #
# compiled and output as a .csv file. The parameters function in the same way  #
# as laid out in the sister script                                             #
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
# eg "regression_search/cross_validation"
#
#
#
regression_search_cross_validation <- function(spec.data, tax.data, en.yr, mult,
                                               guess.n, ratio, stretch, max.it, 
                                               out.dir, id.str, mod.dir){
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
	source("./kew_grasses/Support/packages.R")
	source("./kew_grasses/Support/functions.R")
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
	# Set up results variable to store results of each round of jack-knife
	#
	cv.results <- matrix(NA,nrow = nrow(data),ncol = 10+nrow(data))
	cv.results <- as.data.frame(cv.results)
	names(cv.results) <- c("year_out","a","b","St","cost_fn","iterations_taken",
				"guesses_per_it","ratio_kept","expansion_per_it",
				"initial_multiple",as.character(data[,1]))
	#
	# Apply Jack-knifing
	#
	for(j in 1:nrow(data)){
		tmp.data <- data[-j,]
		#
		########################## Optimization Algorithm ######################
		#
		# employ method in Joppa Brazil paper - without using log transform
		#
		# Calculate the current level of total species
		#
		start <- data[nrow(tmp.data),2] + data[nrow(tmp.data),3]
		#
		# Pick initial guesses as starting with the above and ending with the
		# multiple of this as given in the parameters, using equally spaced
		# guesses as set
		#
		guesses <- seq(start+1,mult*start,length.out = guess.n)
		#
		# Set flag as counter for number of iterations
		# Set mark as a score for how big the range of candidate values for St 
		# is. Once this is below 0.5 we know we have convergence to the
		# precision of 1 integer.
		#
		flag <- 0
		mark <- 2
		#
		# Iteration over each set of guesses starts here and ends when maximum 
		# iterations are reached, or convergence as defined above is reached
		#
		while (mark > 0.5 && flag < max.it){
			#
			# Create placeholder for error score of each guess for St
			#
			results <- numeric(length(guesses))
			#
			# Find best choice of a, b for each guess of St using linear
			# regression
			#
			for(i in 1:length(guesses)){
				#
				# Weights are needed to ensure the residuals being 
				# considered for optimisation in calculating a, b are
				# the same as those used in calculating the global best 
				# fit for a, b & St
				#
				# This means that we can ensure the a, b choice for each
				# St minimises our overall error score for given St
				#
				weight <- (tmp.data[,4]*(guesses[i]-tmp.data[,3]))
				test <- lm(tmp.data[,2]/weight ~ tmp.data[,1],
							weights = weight^2)
				#
				# Produce error score for each St guess
				#
				results[i] <- conv.cost(tmp.data,test$coefficients[1],
							test$coefficients[2],
							guesses[i])
				rm(weight,test)
			}
			rm(i)
			#
			# Order the scores for each round of guesses and select only the
			# top proportion, as set by the ratio parameter
			#
			picks <- guesses[order(results)[1:(ratio*length(guesses))]]
			#
			# Calculate the range of these selected values and extend it by
			# the stretch factor set in the parameters
			#
			rng <- range(picks)
			extra <- (rng[2]-rng[1])*(stretch-1)/2
			rng[1] <- rng[1] - extra
			rng[2] <- rng[2] + extra
			#
			# Ensure the range never drops below the current total number of
			# species
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
		# Calculate a and b for the best choice of St output and store these
		#
		weight <- (tmp.data[,4]*(picks[1]-tmp.data[,3]))
		test <- lm(tmp.data[,2]/weight ~ tmp.data[,1],weights = weight^2)
		cv.results[j,2:4]<-c(test$coefficients[1],test$coefficients[2],picks[1])
		cv.results[j,1] <- data[j,1]
		rm(test,weight,picks)
		cv.results[j,5] <- conv.cost(tmp.data,cv.results[j,2],cv.results[j,3],
						cv.results[j,4])
		cv.results[j,6] <- flag
		cv.results[j,7] <- guess.n
		cv.results[j,8] <- ratio
		cv.results[j,9] <- stretch
		cv.results[j,10] <- mult
		if(mark > 0.5){
			cat("Algorithm failed to converge to a value of total species",
			" accurate to the nearest integer after",max.it,"iterations,",
			" when excluding start year ",data[j,1],
			" Try using more iterations or reducing the ratio of values",
			" passed on after each round")
		}
		rm(mark,flag,start)
		tmp <- (cv.results[j,4]-tmp.data[,3])
		pred <- (cv.results[j,2]+cv.results[j,3]*tmp.data[,1])*tmp.data[,4]*tmp
		if(j>1){
			for(k in 1:(j-1)){
				cv.results[j,k+10] <- pred[k]
			}
			rm(k)
		}
		if(j < nrow(data)){
			for(l in j:nrow(tmp.data)){
				cv.results[j,l+11] <- pred[l]
			}
			rm(l)
		}

		rm(tmp,tmp.data,pred)
		cat("Jack-Knife ",j," complete!\n")
	}
	write.csv(cv.results,file=paste(tmp.dir,id.str,"_regression_search_cv.csv",
					sep=""),
			  row.names = FALSE)
	rm(mult,stretch,max.it,ratio,guess.n,j)
	rm(data,tmp.dir,id.str,cv.results)
}