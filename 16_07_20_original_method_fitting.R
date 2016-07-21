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
# SET INPUT VALUES HERE
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
# SET DIRECTORY where you have downloaded repository
#
setwd("~/Kew Summer")
#
#
#### Algorithm
#
# multiple of current level to start at
mult <- 3
#
# Guesses per round
guess.n <- 500
#
# Ratio to be kept
ratio <- 0.1
#
# Range Stretch to apply at each end (ie 1.25 would mean extend the
# range in each iteration by 25%)
stretch <- 1.5
#
# Max iteratations
max.it <- 20
#
# DO NOT EDIT CODE BELOW THIS LINE
#
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
data[,1] <- data[,1] - data[1,1]
data <- data[1:52,]
rm(spec.data,tax.data)
#
#
################################################################################
#
# employ method in Joppa Brazil paper
#
start <- data[nrow(data),2] + data[nrow(data),3]
guesses <- seq(start+1,mult*start,length.out = guess.n)
rm(start)
flag <- 0
mark <- 2
#
while (mark > 1 && flag < max.it){
        results <- numeric(length(guesses))
        #
        for(i in 1:length(guesses)){
                tmp.var <- data[,2]/(data[,4]*(rep(guesses[i],
                                                   nrow(data))-data[,3]))
                test <- lm(tmp.var ~ data[,1])
                results[i] <- joppa.cost(data,test$coefficients[1],
                                         test$coefficients[2],
                                         guesses[i])
                rm(tmp.var,test)
        }
        rm(i)
        picks <- guesses[order(results)[1:(ratio*length(guesses))]]
        rng <- range(picks)
        extra <- (rng[2]-rng[1])*(stretch-1)/2
        guesses <- seq(rng[1]-extra,rng[2]+extra,length.out = guess.n)
        mark <- rng[2]-rng[1]
        rm(rng,extra)
        flag <- flag + 1
        #
        #
}
#
rm(mult,guess.n,ratio,stretch,max.it)


tmp.var <- data[,2]/(data[,4]*(rep(picks[1],
                                   nrow(data))-data[,3]))
test <- lm(tmp.var ~ data[,1])
