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
# This file contains the set-up for the gradient descent method, if selected.
#
#
# Scaling to apply to taxonomist numbers and species numbers respectively
# (years are dealt with automatically) - This is to help gradient descent
# efficiency
#
scale <- c(100,1000)
#
#
# Range to test for a and b starting point in each gradient 
# descent - note these are not transformed by the scalings (ie these values will
# be used as they currently are directly with the scaled data, however a 
# and b as output are for the raw data) 
#
rng.a <- c(-0.1,0.1)
rng.b <- c(-0.1,0.1)
#
#
# No of initial values of a and b respectively to try
#
ab.guesses <- c(100,100)
#
#
# Max repetitions of grad descent to get a,b for each St value
#
max.grad <- 500
#
#
# Step size for each gradient descent step
#
alpha <- 0.01
#
#
# Minimum step size - program quits if a step smaller than this is required
#
min.alp <- 2e-14
#
#
# Ratio for gradient/parameter value where gradient descent should be 
# terminated - ie once this ratio is reached, gradient descent ends
#
grd.rat <- 1e-4