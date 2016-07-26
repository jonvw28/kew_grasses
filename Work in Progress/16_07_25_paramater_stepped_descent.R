################################################################################           
#                                                                              #
#                                                                              #
# This script is an altered implementation of the work of Joppa et al 2010 in  #
# their Brazil paper.It takes as inout two files, one giving aggregated        #
# as well as cumulative species for set time windows, the other giving number  #
# of active taxonomists. These can be easily created using the scripts in this #
# repository.                                                                  #
#                                                                              #
# This script will then attempt to produce an estimate for total species yet   #
# to be found using the model as proposed by Joppa. However, the algorithm to  #
# do so varies from theirs. Here the least squares regression is used to       #
# evaluate each estimate, as opposed to first log-transforming the data.       #
#                                                                              #
# The algorithm works by guessing a selection of of equally spaced values for  #
# total species, where the number of guesses is set below. It then uses linear #
# regression with appropraite weights to find the values for a and b in the    #
# model of taxonomic efficiency that Joppa proposes. The initial guesses from  #
# the range of the current number of species up to a multiple of this given    #
# as a parameter below. From these guesses, the top scoring are selected, the  #
# proportion relative to the guesses being set below, and a new range of       #
# guesses are picked by stretching the range of of this selection by a scaling #
# factor set below. These new guesses are then used to repeat the procedure    #
# until either the range of guesses converges to be accurate to the nearest    #
# integer, or the maximum number of iterations as set below is reached. Should #
# the stretching cause the bottom value to drop below the current number of    #
# species, then the range will be truncated to be no lower than the current    #
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
# SET DIRECTORY where you have downloaded repository (ie before /kew_grasses)
#
setwd("~/Kew Summer")
#
############################ SET INPUT VALUES HERE #############################
#
# Directory path - location of csv input file
dir.path <- "./Output/grass_1753_5y_acc/"
#
# Species File name - name of csv file with species information 
#(without .csv at end)
spec.file.name <- "grass_1753_5y_acc_spec_summary"
#
# Location File name - name of csv file with location information 
#(without .csv at end)
tax.file.name <- "grass_1753_5y_acc_tax_summary"
#
# End year - input year at which data ends so as to enable trimming if need be
en.yr <- 2015
#
# Directory where the output directory should go - will be created within
# a directory created by the id string below
out.dir <- "./Output/"
#
# Identifier string - include info for the file names and graph labels that 
# describe the set of data used
id.str <- "grass_1753_5y_acc_test"
#
########################### Algorithm Parameters ###############################
#
# Initial Parameter guess
init.g <- c(3e-5,3e-5,22559.35)
#
# Scaling to apply to taxonomist numbers and species numbers respectively
# (years are dealt with automatically)
scale <- c(100,1000)
#
# Step size for each step of gradient descent
alpha <- 1
#
# Max iteratations
max.it <- 200000
#
# set maximum amount St can move by per iteration
max.gap <- 100
#
################################################################################
#                                                                              #
#                       DO NOT EDIT CODE BELOW THIS LINE                       #            
#                                                                              #
################################################################################
#
# Check for directory and create if needed
#
tmp.dir <- paste(out.dir,id.str,"/","least_squares_regression","/",sep = "")
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
# Tidy data and remove any partial end year - note years in data are start years
#
yr.int <- data[2,1] - data[1,1]
if((en.yr-data[1,1]+1) %% yr.int != 0){
        data <- data[1:(nrow(data)-1),]
}
rm(en.yr)
#
# Scale data so as to make convergence of gradient descent better
#
scale <- c(scale,yr.int,data[1,1])
names(scale) <- c("taxon","species","year_gap","start_year")
data[,4] <- data[,4]/scale[1]
data[,2:3] <- data[,2:3]/scale[2]
data[,1] <- (data[,1]-data[1,1])/(yr.int*(nrow(data)-1))
init.g[3] <- init.g[3]/scale[2]
max.gap <- max.gap/scale[2]
rm(yr.int)
#
#
################################################################################
#
# Apply Gradient Descent
#
start <- data[nrow(data),2] + data[nrow(data),3]
cur.par <- init.g
rm(init.g)
flag <- 0
tweaks <- list()
j <- 1
#
while (flag < max.it){
        for(i in 1:length(cur.par)){
                grad <- conv.grad(data,cur.par[1],cur.par[2],cur.par[3])
                nxt.par <- cur.par
                nxt.par[i] <- nxt.par[i] - grad[i]*alpha
                new.cost <- conv.cost(data,nxt.par[1],nxt.par[2],nxt.par[3])
                cur.cost <- conv.cost(data,cur.par[1],cur.par[2],cur.par[3])
                tmp.a <- alpha
                while(new.cost > 1.1*cur.cost){
                        tmp.a <- tmp.a/2
                        nxt.par <- cur.par
                        nxt.par[i] <- nxt.par[i] - grad[i]*tmp.a
                        new.cost <- conv.cost(data,nxt.par[1],nxt.par[2],nxt.par[3])
                }
                cur.par <- nxt.par
                rm(nxt.par)
        }
        if (flag %% 1000 == 0){
                print(cur.par)
                print(grad)
                print(flag/1000 + 1)
        }
        flag <- flag + 1
        #
}