################################################################################           
#                                                                              #
#                                                                              #
# This script is an altered implementation of the work of Joppa et al 2010 in  #
# their how many species of flowering palnts paper.It takes as input two files #
# one giving aggregated as well as cumulative species for set time windows,    #
#the other giving number of active taxonomists. These can be easily created    #
# using the scripts in this repository.                                        #
#                                                                              #
# This script will then attempt to produce an estimate for total species yet   #
# to be found using the model as proposed by Joppa. However, the algorithm to  #
# do so varies from theirs. Here the least squares regression is used to       #
# evaluate each estimate, as opposed to first log-transforming the data.       #
#                                                                              #
# In addition, owing the high sensitivity of the gradient of the cost function #
# to the model of taxonomic efficiency a modified gradient descent algorithm   #
# is appplied. Here, the model parameters are optimised one by one by finding  #
# the minimum for each in turn, whilst holding the other two constant. This    #
# process is repeated until a fixed point is found. Here this is taken to mean #
# that within the minimum step size, the gradient changes sign as the          #
# parameters are simultaneously updated according to the relevant gradient     #
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
init.g <- c(3e-5,3e-5,16000)
#
# Scaling to apply to taxonomist numbers and species numbers respectively
# (years are dealt with automatically)
scale <- c(100,1000)
#
# Step size for each step of gradient descent
alpha <- 1
#
# Max iteratations of whole loop
max.it <- 300
#
# Max iterations in each loop
max.ea <- 300
#
# Maximum multiple which cost my increase by in a given change
mult <- 1.2
#
# test alpha
test.a <- 0.0001
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
rm(yr.int)
#
#
################################################################################
#
# Apply Gradient Descent
#
# Save current number of species
start <- data[nrow(data),2] + data[nrow(data),3]
cur.par <- init.g
rm(init.g)
flag <- 0
rep <- 0
end <- 0
#
while (flag < max.it){
        for(i in 1:length(cur.par)){
                rep <- 0
                grad <- conv.grad(data,cur.par[1],cur.par[2],cur.par[3])
                lst.grad <- grad
                while (grad[i]*lst.grad[i] > 0 && rep < max.ea){
                        nxt.par <- cur.par
                        nxt.par[i] <- nxt.par[i] - grad[i]*alpha
                        new.cost <- conv.cost(data,nxt.par[1],nxt.par[2],nxt.par[3])
                        cur.cost <- conv.cost(data,cur.par[1],cur.par[2],cur.par[3])
                        tmp.a <- alpha
                        while(new.cost > mult*cur.cost){
                                tmp.a <- tmp.a/2
                                nxt.par <- cur.par
                                nxt.par[i] <- nxt.par[i] - grad[i]*tmp.a
                                new.cost <- conv.cost(data,nxt.par[1],nxt.par[2],nxt.par[3])
                        }
                        cur.par <- nxt.par
                        rm(nxt.par,cur.cost,new.cost)
                        lst.grad <- grad
                        grad <- conv.grad(data,cur.par[1],cur.par[2],cur.par[3])
                        rep <- rep + 1
                }
                print(cur.par)
                print(grad)
                rm(rep)
                test <- cur.par - test.a*grad
                tst.grad <- conv.grad(data,test[1],test[2],test[3])
                if(tst.grad[1]*grad[1] <= 0 && tst.grad[2]*grad[2] <= 0 && tst.grad[3]*grad[3] <= 0){
                        end <- 1
                        break
                }
                rm(test,tst.grad,i)
        }
        if(end == 1){
                break
        }
        flag <- flag + 1
}

rm(flag,cur.par,grad,lst.grad,alpha,tmp.a,mult,rep,max.it,max.ea,scale,test,
   tst.grad,start,data,tmp.dir,id.str)