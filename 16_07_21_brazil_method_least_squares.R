################################################################################           
#                                                                              #
#                                                                              #
# To use simply edit the variables below and run the whole script              #
#                                                                              #
#                                                                              #
# Jonathan Williams, 2016                                                      #
# jonvw28@gmail.com                                                            #
#                                                                              #
################################################################################
#
# SET DIRECTORY where you have downloaded repository (ie before /kew_grasses)
#
setwd("~/Kew Summer")
#
############################ SET INPUT VALUES HERE #############################
#
# Directory path - location of csv input file
dir.path <- "./Output/Start_1753_5yr_only_acc/"
#
# Species File name - name of csv file with species information 
#(without .csv at end)
spec.file.name <- "5_year_species_summary_grass"
#
# Location File name - name of csv file with location information 
#(without .csv at end)
tax.file.name <- "5_year_taxon_summary_grass"
#
# End year - input year at which data ends so as to enable trimming if need be
en.yr <- 2015
#
########################### Algorithm Parameters ###############################
#
# multiple of current level to start at
mult <- 3
#
# Guesses per round
guess.n <- 500
#
# Ratio to be kept
ratio <- 0.2
#
# Range Stretch to apply at each end (ie 1.25 would mean extend the
# range in each iteration by 25%)
stretch <- 1.5
#
# Max iteratations
max.it <- 20
#
################################################################################
#                                                                              #
#                       DO NOT EDIT CODE BELOW THIS LINE                       #            
#                                                                              #
################################################################################
#
# Install any dependancies and load functions
#
source("./kew_grasses/packages.R")
source("./kew_grasses/functions.R")
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
# Tidy data and remove any partial end year
#
yr.int <- data[2,1] - data[1,1]
if((en.yr-data[1,1]) %% yr.int != 0){
        data <- data[1:(nrow(data)-1),]
}
rm(en.yr,yr.int)
#
#
################################################################################
#
# employ method in Joppa Brazil paper
#
start <- data[nrow(data),2] + data[nrow(data),3]
guesses <- seq(start+1,mult*start,length.out = guess.n)
flag <- 0
mark <- 2
#
while (mark > 0.5 && flag < max.it){
        results <- numeric(length(guesses))
        #
        for(i in 1:length(guesses)){
                weight <- (data[,4]*(rep(guesses[i],nrow(data))-data[,3]))
                test <- lm(data[,2]/weight ~ data[,1],weights = weight^2)
                results[i] <- conv.cost(data,test$coefficients[1],
                                        test$coefficients[2],
                                       guesses[i])
                rm(weight,test)
        }
        rm(i)
        picks <- guesses[order(results)[1:(ratio*length(guesses))]]
        rng <- range(picks)
        extra <- (rng[2]-rng[1])*(stretch-1)/2
        rng[1] <- rng[1] - extra
        rng[2] <- rng[2] + extra
        if(rng[1] <= start){
                rng[1] <- start + 1
        }
        guesses <- seq(rng[1],rng[2],length.out = guess.n)
        mark <- rng[2]-rng[1]
        rm(rng,extra)
        flag <- flag + 1
        #
        #
}
rm(results,guesses)
#
weight <- (data[,4]*(rep(picks[1],nrow(data))-data[,3]))
test <- lm(data[,2]/weight ~ data[,1],weights = weight^2)
params <- c(test$coefficients[1],test$coefficients[2],picks[1])
names(params) <- c("a","b","St")
rm(test,weight,picks)
#
if(mark > 1){
        cat("Algorithm failed to converge to a value of total species accurate to the nearest integer after",
            max.it,
            "iterations. Try using more iterations or reducing the ratio of values passed on after each round")
} else {
        cat("Algorithm reported the best-fitting number of species to be",
            params[3],"after completing",flag,"iterations, each comprising",
            guess.n,"guesses derived by taking the range of the top",
            100*ratio,"% best-fitting guesses in the previous iteration and expanding it about its mid-point to",
            100*stretch,
            "% of its size and spacing guesses equally amongst this")
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
        # plot of optimisation lanscape
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
        png("./output/error_plot_1753_5yr_acc.png",width = 960, 
            height = 960)
        plot(guesses,results,xlab = "Total Species",
             ylab = "Least Squares Score",
             main = "Least Squares Error vs Total Species - 1753, 5yr, accepted",
             col = "blue",
             type = 'l')
        dev.off()
        #
        # Predicted fit
        #
        tmp <- (rep(params[3],nrow(data))-data[,3])
        pred <- (params[1] + params[2]*data[,1])*data[,4]*tmp
        rm(tmp)
        #
        # Plot species and taxons per year
        #
        png("./output/species_rate_1753_5yr_acc.png",width = 960, 
            height = 960)
        plot(data[,1],data[,2],pch = 21,col='red',ylim = c(0,700),
             xlab = "year", ylab = "Number")
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
        png("./output/species_per_tax_1753_5yr_acc.png",width = 960, 
            height = 960)
        plot(data[,1],data[,2]/data[,4],pch = 21,col='red', ylim = c(0,20),
             xlab = "year", ylab = "Number")
        lines(data[,1],data[,2]/data[,4],pch = 21,col='red')
        lines(data[,1],pred/data[,4],col = 'green')
        dev.off()
}
rm(mult,stretch,max.it,ratio,mark,flag,guess.n,start)


rm(params,out.dat,data)