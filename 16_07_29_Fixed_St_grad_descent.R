################################################################################
#
# SET DIRECTORY where you have downloaded repository (ie before /kew_grasses)
#
setwd("~/Kew Summer")
#
############################ SET INPUT VALUES HERE #############################
#
# Directory path - location of csv input file
dir.path <- "./Output/grass_1755_5y/"
#
# Species File name - name of csv file with species information 
#(without .csv at end)
spec.file.name <- "grass_1755_5y_spec_summary"
#
# Location File name - name of csv file with location information 
#(without .csv at end)
tax.file.name <- "grass_1755_5y_tax_summary"
#
# End year - input year at which data ends so as to enable trimming if need be
en.yr <- 2015
#
########################### Algorithm Parameters ###############################
#
# Scaling to apply to taxonomist numbers and species numbers respectively
# (years are dealt with automatically) - This is to help gradient descent
#nefficiency
scale <- c(100,1000)
#
########## Iteration of St Search parameters
#
# multiple of current level to start at as maxmimum guess
mult <- 3
#
# Guesses per round for St values
guess.n <- 100
#
# Ratio of top scoring guesses to keep from all guesses per round
ratio <- 0.2
#
# Range Stretch to apply at each end (ie 1.25 would mean extend the
# range in each iteration by 25%)
stretch <- 1.5
#
# Max iteratations of guessing St
max.it <- 20
#
#
######### Gradient Descent Paramters
#
# Range to test for a starting point in each gradient descent
rng.a <- c(-0.1,0.1)
#
# Range to test for b starting point in each gradient descent
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
# Calculate initial guesses for a and b for each gradient descent
#
a.guess <- seq(rng.a[1],rng.a[2],length = ab.guesses[1])
b.guess <- seq(rng.b[1],rng.b[2],length = ab.guesses[2])
rm(rng.a,rng.b)
#
# Calculate the current level of total species
#
start <- data[nrow(data),2] + data[nrow(data),3]
#
# Pick initial guesses as starting with the above and ending with the multiple
# of this as given in the parameters, using equally spaced guesses as set
#
guesses <- seq(start+0.001,mult*start,length.out = guess.n)


### Loop for each round of guesses

results <- matrix(0,length(guesses),ncol = 5)

for(i in 1:length(guesses)){
        #
        # Create cached variable for faster computation
        #
        grad.cache <- matrix(0,nrow(data),2)
        grad.cache[,1] <- (guesses[i]-data[,3])*data[,4]
        grad.cache[,2] <- grad.cache[,1]*data[,1]
        #
        # Calculate best place to start a and b
        #
        init.score <- matrix(0,nrow = ab.guesses[1],ncol=ab.guesses[2])
        for(a in 1:length(a.guess)){
                for(b in 1:length(b.guess)){
                        init.score[a,b] <- conv.cost(data,a.guess[a],b.guess[b],
                                                     guesses[i],T,grad.cache[,1])
                        
                }
        }
        rm(a,b)
        #
        # Pick best fitting a and b as initial guesses
        #
        st.ind <- which(init.score[,]==min(init.score[,]),arr.ind = T)
        rm(init.score)
        #
        # Apply gradient descent with fixed St - ie for a,b
        #
        cur.par <- c(a.guess[st.ind[1,1]],b.guess[st.ind[1,2]],guesses[i])
        rm(st.ind)
        grad <- conv.grad(data,cur.par[1],cur.par[2],cur.par[3],T,grad.cache)
        #
        flag <- 0
        while (flag < max.grad){
                alp.flag <-0
                nxt.par <- cur.par
                nxt.par[1] <- cur.par[1] - grad[1]*alpha
                nxt.par[2] <- cur.par[2] - grad[2]*alpha
                nxt.grad <- conv.grad(data,nxt.par[1],nxt.par[2],nxt.par[3],
                                      T,grad.cache)
                tmp.a <- alpha
                while(nxt.grad[1]*grad[1] < 0 || nxt.grad[2]*grad[2] < 0){
                        tmp.a = tmp.a/2
                        if(tmp.a < min.alp){
                                alp.flag <- 2
                                break
                        }
                        tmp.grad <- nxt.grad
                        tmp.par <- cur.par
                        tmp.par[1] <- cur.par[1] - grad[1]*tmp.a
                        tmp.par[2] <- cur.par[2] - grad[2]*tmp.a
                        nxt.grad <- conv.grad(data,tmp.par[1],tmp.par[2],
                                              tmp.par[3],T,grad.cache)
                        alp.flag <- 1
                }
                if(alp.flag == 2){
                        print("Algorithm terminated on run",i,"where St was",
                              guesses[i],
                              "as alpha was smaller than minimum step size")
                        break
                }
                if(alp.flag == 1){
                        tmp.a = 2*tmp.a
                        nxt.par <- cur.par
                        nxt.par[1] <- cur.par[1] - grad[1]*tmp.a
                        nxt.par[2] <- cur.par[2] - grad[2]*tmp.a
                        nxt.grad <- tmp.grad
                        rm(tmp.par,tmp.grad)
                }
                grad <- nxt.grad
                cur.par <- nxt.par
                rm(nxt.par,nxt.grad,tmp.a)
                test <- abs(grad/cur.par[1:2])
                if(test[1]< grd.rat && test[2] < grd.rat){

                        break
                }
                rm(test)
                flag <- flag + 1
                if(flag == max.grad){
                        cat("Algorithm failed to fully converge for a,b for St = ",
                            guesses[i]," try using a greater number of maximum steps for gradient descent, or allowing larger ratio to define convergence\n")
                }
        }
        rm(alp.flag,grad)
        results[i,1] <- conv.cost(data,cur.par[1],cur.par[2],guesses[i],T,
                                  grad.cache[,1])
        results[i,2:4] <- cur.par
        results[1,5] <- flag
        rm(cur.par)
        cat("run",i,"complete\n")
        rm(grad.cache)
}
rm(i)






rm(a.guess,b.guess,ab.guesses,min.alp,grd.rat,alpha,max.grad,mult,stretch,guess.n,ratio,max.it,scale,start,data)
