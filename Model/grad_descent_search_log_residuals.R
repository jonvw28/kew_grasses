################################################################################           
#                                                                              #
#                                                                              #
# This function is an altered implementation of the work of Joppa et al 2010   #
# in their How many flowering species paper. It takes as input two files, one  #
# giving aggregated as well as cumulative species for set time windows, the    #
# other giving number of active taxonomists. These can be easily created using #
# the scripts in this repository.                                              #
#                                                                              #
# This script will then attempt to produce an estimate for total species yet   #
# to be found using the model as proposed by Joppa. However, the algorithm to  #
# do so varies from theirs.                                                    #
#                                                                              #
# The algorithm works by guessing a selection of of equally spaced values for  #
# total species, where the number of guesses is set below. It then uses a grid #
# search to pick an inital guess for a and b which minimises the squared log   #
# residuals. It then applies steepest descent to this starting point until it  #
# converges to a minimum of the square residuals for the log-tranformed        #
# variables for the given value of St. This is either when the gradient is     #
# below a certain proportion of the parameter value, or when a maximum number  #
# of steps have been taken.                                                    #
#                                                                              #
# In the gradient descent, the variables are re-scaled as set by the user to   #
# facilitate more efficient convergence. This scaling is then un-done before   #
# giving results, including appropriate adjusting the model coefficients. In   #
# addition, during the gradient descent an adaptive step size is used:         #
#                                                                              #
#       Initially, if the step would move the parameters to a point where      #
#       negative predicted values occur (causing issues for log                #
#       transformation), then the effective gradient is halved in magnitude    #
#       until the step is within a range where computation of the new          #
#       gradient is possible. The step is then adjusted to attempt to move     #
#       closer to a minimum:                                                   #
#                                                                              #
#       If the signs of the gradient are the same for the current, and next    #
#       parameters then the step is taken. (This assumes the step does not     #
#       cross the minimum)                                                     #
#                                                                              #
#       If the signs differ for any of the paramters then an alternative step  #
#       size is considered which is half of the current step size. Here the    #
#       sign changing shows the step has crossed a stationary point of the     #
#       cost function.                                                         #
#                                                                              #
#       This process of halving the step size is repeatedly applied until a    #
#       step size is found where the sign does not change. At this point the   #
#       step is taken with a step size that is twice the step size that first  #
#       preserves the sign of the gradient.                                    #
#                                                                              #
#       This process ensures that the crossing of a stationary point is always #
#       in the second half of a step taken across such a point. The step also  #
#       intentially overshoots the stationary point. The purpose of this is to #
#       facilitate faster convergence on the fixed point, as to pick the       #
#       alternative, smaller step size will constrain the algorithm to only be #
#       able to approach a minimum from only one side.                         #
#                                                                              #
#       The only exception to the above is when a step size is suggested which #
#       is smaller than the minimum user-defined step size. In such a case the #
#       algorithm terminates, outputting a warning and the values for the      #
#       parameters are set as per the output from the last succesful iteration #
#       of gradient descent                                                    #
#                                                                              #
# The initial guesses for St come from the range of the current total number   #
# of species up to a multiple of this given as a parameter below. From these   #
# guesses, the top scoring are selected, the proportion of these relative to   #
# the total mumber of guesses being set below. A new range of guesses are      #
# picked by stretching the range of this selection by a scaling factor set     #
# below.                                                                       #
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
# dir.path- location of csv input files
# eg "./Output/grass_1755_5y/"
#
# spec.file.name - name of csv file with species information 
# (without .csv at end)
# eg "grass_1755_5y_spec_summary"
#
# tax.file.name - name of csv file with taxonomist information 
# (without .csv at end)
# eg "grass_1755_5y_tax_summary"
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
# scale - Scaling to apply to taxonomist numbers and species numbers respectively
# (years are dealt with automatically) - This is to help gradient descent
# efficiency
# eg c(100,1000)
#
# rng.a, rng.b - Range to test for a and b starting point in each gradient 
# descent - note these are not transformed by the scalings (ie these values will
#  be used as they currently are directly with the tranformed data, however a 
# and b as output are for the none scaled data) 
# eg
# rng.a <- c(-0.1,0.1)
# rng.b <- c(-0.1,0.1)
#
# ab.guesses - No of initial values of a and b to try respectively
# eg c(100,100)
#
# max.grad - Max repetitions of grad descent to get a,b for each St value
# eg 500
#
# alpha - Step size for each gradient descent step
# eg 0.01
#
# min.alp - Minimum step size - gradient descent stops if a step smaller than 
# this is required
# eg 2e-14
#
# grd.rat - Ratio for gradient/parameter value where gradient descent should be 
# terminated - ie once this ratio is reached, gradient descent ends
# eg 1e-4
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
#
#
grad_descent_search_log_residuals <- function(dir.path, spec.file.name, 
                                              tax.file.name, en.yr, mult, 
                                              guess.n, ratio, stretch, max.it,
                                              scale, rng.a, rng.b, ab.guesses,
					      max.grad, alpha, min.alp,
					      grad.rat, out.dir, id.str, 
					      mod.dir){



        # Check for directory and create if needed
        #
        tmp.dir <- paste(out.dir,id.str,"/grad_descent_search_log_residuals/",sep = "")
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
        # Import data
        #
        spec.data <- read.csv(paste(dir.path,spec.file.name,".csv",sep=""),
                              stringsAsFactors = FALSE)
        tax.data <- read.csv(paste(dir.path,tax.file.name,".csv",sep=""),
                             stringsAsFactors = FALSE)
        rm(dir.path,tax.file.name,spec.file.name)
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
        rm(en.yr)
        #
        # Scale data so as to make convergence of gradient descent better
        # Years are scaled so the first year is 0 and the final year is 1
        #
        scale <- c(scale,yr.int,data[1,1])
        names(scale) <- c("taxon","species","year_gap","start_year")
        data[,4] <- data[,4]/scale[1]
        data[,2:3] <- data[,2:3]/scale[2]
        data[,1] <- (data[,1]-data[1,1])/(yr.int*(nrow(data)-1))
        rm(yr.int)
        #
        #
        ########################## Optimization Algorithm ##############################
        #
        # Calculate initial guesses for a and b for each grid search - these remain the 
        # same across all guesses of St
        #
        a.guess <- seq(rng.a[1],rng.a[2],length = ab.guesses[1])
        b.guess <- seq(rng.b[1],rng.b[2],length = ab.guesses[2])
        #
        # Calculate the current level of total species
        #
        start <- data[nrow(data),2] + data[nrow(data),3]
        #
        # Pick initial guesses as starting with the above and ending with the multiple
        # of this as given in the parameters, using equally spaced guesses as set
        #
        guesses <- seq(start+0.001,mult*start,length.out = guess.n)
        
        ###########################################################################
        #
        # Set flag as counter for number of iterations
        # Set mark as a score for how big the range of candidate values for St is. 
        #       Once this is below 0.5 we know we have convergence to the precision
        #       of 1 integer.
        #
        flag <- 0
        mark <- 2/scale[2]
        #
        # Iteration over each set of guesses starts here and ends when maximum 
        # iterations are reached, or convergence as defined abpove is reached
        #
        while (mark > 0.5/scale[2] && flag < max.it){
                #
                # Counter for human convenience
                #
                cat("Iteration ",flag+1,"\n")
                #
                # Create placeholder for error score of each guess for St, along with
                # the best fitting values of a and b and the number of gradient descent
                # steps taken
                #
                results <- matrix(0,length(guesses),ncol = 5)
                #
                # Find best choice of a, b for each guess of St via grid search and
                # steepest descent
                #
                for(i in 1:length(guesses)){
                        #
                        # Create cached variable for faster computation
                        #
                        grad.cache <- matrix(0,nrow(data),2)
                        grad.cache[,1] <- (guesses[i]-data[,3])*data[,4]
                        grad.cache[,2] <- log(data[,2])
                        #
                        # Calculate best place to start gradient descent via grid 
                        # search
                        #
                        init.score <- matrix(0,nrow = ab.guesses[1],ncol=ab.guesses[2])
                        for(a in 1:length(a.guess)){
                                for(b in 1:length(b.guess)){
                                        init.score[a,b] <- joppa.cost(data,a.guess[a],
                                                                     b.guess[b],
                                                                     guesses[i],
                                                                     T,grad.cache[,1])
                                }
                        }
                        rm(a,b)
                        #
                        # Pick best fitting a and b as initial guesses for grad descent
                        #
                        st.ind <- which(init.score[,]==min(init.score[,],na.rm = T)
                                        ,arr.ind = T)
                        rm(init.score)
                        #
                        # Apply gradient descent with fixed St - ie for a,b
                        #
                        cur.par <- c(a.guess[st.ind[1,1]],b.guess[st.ind[1,2]],
                                     guesses[i])
                        rm(st.ind)
                        grad <- joppa.grad(data,cur.par[1],cur.par[2],cur.par[3],T,
                                          grad.cache)
                        #
                        # Create a flag to count iterations of gradient descent
                        #
                        grad.flag <- 0
                        while (grad.flag < max.grad){
                                #
                                # Create flag for whether adaptive step size has been 
                                # used
                                #
                                alp.flag <- 0
                                grd.sze.flag <- 0
                                nxt.par <- cur.par
                                #
                                # Calculate next paramter choice using gradient descent
                                # step and calculate gradient here
                                #
                                nxt.par[1] <- cur.par[1] - grad[1]*alpha
                                nxt.par[2] <- cur.par[2] - grad[2]*alpha
                                nxt.grad <- joppa.grad(data,nxt.par[1],nxt.par[2],nxt.par[3],
                                                      T,grad.cache)
                                #
                                # Now consider if adaptive step size is needed:
                                #
                                tmp.a <- alpha
                                small.grad <- grad
                                #
                                # First ensure step taken doesn't cause issue with 
                                # non-defined logs
                                # If the step will cause predictions of negative species
                                # discovery (causing issues for taking logs) then the 
                                # effective gradient will be halved until this issue is
                                # resolved
                                #
                                while(is.na(nxt.grad[1]) || is.na(nxt.grad[2])){
                                        if(min(abs(small.grad)) < min.alp) {
                                                grd.sze.flag <- 2
                                                break
                                        }
                                        small.grad = small.grad/2
                                        tmp.grad <- nxt.grad
                                        tmp.par <- cur.par
                                        tmp.par[1] <- cur.par[1] - small.grad[1]*tmp.a
                                        tmp.par[2] <- cur.par[2] - small.grad[2]*tmp.a
                                        nxt.grad <- joppa.grad(data,tmp.par[1],tmp.par[2],
                                                               tmp.par[3],T,grad.cache)
                                }
                                
                                
                                
                                
                                while(min(nxt.grad*grad) < 0 && grd.sze.flag != 2){
                                        if(tmp.a < min.alp){
                                                alp.flag <- 2
                                                break
                                        }
                                        #
                                        # Comes before halving as the eventual step size 
                                        # is double the one that ends this loop. Hence
                                        # can try a step smaller than minimum step size
                                        # as long as the resulting doubled step would
                                        # still be big enough
                                        #
                                        tmp.a = tmp.a/2
                                        tmp.grad <- nxt.grad
                                        tmp.par <- cur.par
                                        tmp.par[1] <- cur.par[1] - small.grad[1]*tmp.a
                                        tmp.par[2] <- cur.par[2] - small.grad[2]*tmp.a
                                        nxt.grad <- joppa.grad(data,tmp.par[1],tmp.par[2],
                                                              tmp.par[3],T,grad.cache)
                                        alp.flag <- 1
                                }
                                #
                                # In case that step size is too small, revert to most 
                                # recent accepted parameters and break the loop
                                #
                                if(alp.flag == 2){
                                        warning(paste("Gradient descent terminated in ",
                                                      "iteration ",flag + 1,
                                                      " during step ",
                                                      i," where St was ",guesses[i],
                                                      " as alpha to be used was smaller 
                                                      than the minimum step size\n",
                                                      sep = ""))
                                        break
                                }
                                if(grd.sze.flag == 2){
                                        warning(paste("Gradient descent terminated in ",
                                                      "iteration ",flag + 1,
                                                      " during step ",
                                                      i," where St was ",guesses[i],
                                                      " as gradient to be used was ",
                                                      "smaller than the minimum step ",
                                                      "size\n",sep = ""))
                                        break
                                }
                                #
                                # If alpha modified in a permissible way then take the
                                # related step
                                #
                                if(alp.flag == 1){
                                        tmp.a = 2*tmp.a
                                        nxt.par <- cur.par
                                        nxt.par[1] <- cur.par[1] - small.grad[1]*tmp.a
                                        nxt.par[2] <- cur.par[2] - small.grad[2]*tmp.a
                                        nxt.grad <- tmp.grad
                                        rm(tmp.par,tmp.grad)
                                }
                                #
                                # Pass on the parameters for the next iteration
                                #
                                grad <- nxt.grad
                                cur.par <- nxt.par
                                rm(nxt.par,nxt.grad,tmp.a,small.grad)
                                #
                                # Test if gradient is now sufficiently small relative to
                                # the parameters and if so end the gradient descent
                                #
                                test <- abs(grad/cur.par[1:2])
                                if(test[1]< grd.rat && test[2] < grd.rat){
                                        rm(test)
                                        break
                                }
                                rm(test)
                                grad.flag <- grad.flag + 1
                                #
                                # Output warning if the maximum number of gradient 
                                # descent steps are taken
                                #
                                if(grad.flag == max.grad){
                                        warning(paste("Gradient descent failed to ", 
                                                      " fully converge in ",max.grad,
                                                      " steps for a,b for St = ",
                                                      guesses[i],"during iteration ",
                                                      flag + 1,
                                                      ". Try using a greater ",
                                                      "number of maximum steps for ",
                                                      "gradient descent, or allowing ",
                                                      "larger ratio to define ",
                                                      "convergence\n"))
                                }
                        }
                        rm(alp.flag,grad,grad.sze.flag)
                        #
                        # Calculate cost function at the paramter values determined
                        #
                        results[i,1] <- joppa.cost(data,cur.par[1],cur.par[2],guesses[i],T,
                                                  grad.cache[,1])
                        results[i,2:4] <- cur.par
                        results[i,5] <- grad.flag
                        rm(cur.par,grad.flag)
                        #
                        # Counter for human to see progress
                        #
                        if((i*100/guess.n)%%10==0){
                                if(i/guess.n == 1){
                                        cat(i*100/guess.n,"% complete!\n")   
                                }else{
                                        cat(i*100/guess.n,"% complete...") 
                                }
                        }
                        rm(grad.cache)
                }
                rm(i)
                #
                # Order the scores for each round of guesses and select only the top
                # proportion, as set by the ratio parameter
                #
                picks <- guesses[order(results[,1])[1:(ratio*length(guesses))]]
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
                #
                # Cache initial guesses and their costs for later graphing
                #
                if(flag == 0){
                        res.cache <- results
                }
                #
                flag <- flag + 1
                cat("Current Spread of top values is",mark*1000,"\n")
                }
        #
        # Pull out best fitted parameters
        #
        best.id <- which.min(results[,1])
        params <- c(results[best.id,2],results[best.id,3],picks[1])
        names(params) <- c("a","b","St")
        rm(picks)
        #
        # Transform all of data back into more meaningful form
        #
        data[,4] <- data[,4]*scale[1]
        data[,2:3] <- data[,2:3]*scale[2]
        data[,1] <- data[,1]*scale[3]*(nrow(data)-1) + scale[4]
        #
        # Transform parameters back into corrected form
        #
        params[3] <- params[3]*scale[2]
        params[1] = (params[1]-params[2]*scale[4]/(scale[3]*(nrow(data)-1)))/scale[1]
        params[2] = params[2]/(scale[1]*scale[3]*(nrow(data)-1))
        #
        # Process results depending on whether convergence was reached
        #
        if(mark > 0.5){
                cat("Algorithm failed to converge to a value of total species accurate",
                    "to the nearest integer after",max.it,"iterations. Try using more",
                    "iterations or reducing the ratio of values passed on after each",
                    "round\n")
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
                             "cost_fn" = joppa.cost(data,params[1],params[2],params[3]),
                             "iterations_taken" = flag,
                             "guesses_per_it" = guess.n,
                             "ratio_kept" = ratio,
                             "expansion_per_it" = stretch,
                             "initial_multiple" = mult,
                             "grad_descent_steps_taken" = results[best.id,5],
                             "a_grid_guesses" = ab.guesses[1],
                             "min_a_grid" = rng.a[1],
                             "max_a_grid" = rng.a[2],
                             "b_grid_guesses" = ab.guesses[2],
                             "min_b_grid" = rng.b[1],
                             "max_b_grid" = rng.b[2],
                             "alpha" = alpha,
                             "minimum_step" = min.alp,
                             "gradient_cutoff_ratio" = grd.rat)
                #
                # plot of error score against St for the initial range of guesses
                #
                guesses <- seq(scale[2]*start+0.001,mult*scale[2]*start,
                               length.out = guess.n)
                #
                png(paste(tmp.dir,id.str,"_error_plot.png",sep=""),width = 960,
                    height = 960)
                plot(guesses,res.cache[,1],xlab = "Total Species",
                     ylab = "Representative Least Squares Score - Log Residuals",
                     main = paste("Least Squares Error vs Total Species ",
                                  id.str,sep=""),
                     col = "blue",
                     type = 'l')
                dev.off()
                rm(res.cache)
                #
                # Calculate predicted fit
                #
                tmp <- (rep(params[3],nrow(data))-data[,3])
                pred <- (params[1] + params[2]*data[,1])*data[,4]*tmp
                rm(tmp)
                #
                # Plot species and taxonomists per year
                #
                png(paste(tmp.dir,id.str,"_species_rat.png",sep=""),width = 960,
                    height = 960)
                plot(data[,1],data[,2],pch = 21,col='red',
                     ylim = c(0,1.25*max(data[,2])),
                     xlab = "year", ylab = "Number",
                     main = paste("Discovery rates and number of taxonomists",
                                  " - Log Residuals ",
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
                png(paste(tmp.dir,id.str,"_species_per_tax.png",sep=""),width = 960, 
                    height = 960)
                plot(data[,1],data[,2]/data[,4],pch = 21,col='red', ylim = c(0,20),
                     xlab = "year", ylab = "Number",
                     main = paste("Species per taxonomist - Log Residuals ",
                                  id.str,sep=""))
                lines(data[,1],data[,2]/data[,4],pch = 21,col='red')
                lines(data[,1],pred/data[,4],col = 'green')
                dev.off()
                #
                # Save output of model
                #
                tmp <- cbind(data,pred)
                
                write.csv(tmp,
                          file=paste(tmp.dir,id.str,"_model.csv",sep=""),
                          row.names = FALSE)
                write.csv(t(out.dat),
                          file=paste(tmp.dir,id.str,"_model_summary.csv",sep=""),
                          row.names = FALSE)
        }
        rm(mult,stretch,max.it,ratio,mark,flag,guess.n,start,guesses,results,params)
        rm(out.dat,data,pred,tmp,tmp.dir,id.str,best.id)
        rm(a.guess,b.guess,ab.guesses,min.alp,grd.rat,alpha,max.grad,rng.a,rng.b,scale)
}