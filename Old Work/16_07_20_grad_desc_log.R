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
dir.path <- "./Output/Start_1755_5yr/"
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
# estimates to start from
int.param <- c(5e-3,5e-3,15)
#
# Step size
alp <- 0.01
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
data[,2:3] <- data[,2:3]/1000
data <- data[1:52,]
rm(spec.data,tax.data)
#
#
################################################################################
#
# employ method in Joppa flowering plants paper
#
param <- int.param
i <- 0
test <- 1
while(i < max.it){
        n.param <- param - alp*joppa.grad(data,param[1],param[2],param[3])
        test <- abs(n.param[3]-param[3])
        param <- n.param
        i <- i + 1
}