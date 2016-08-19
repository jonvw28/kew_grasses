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
# This file contains the set-up for the St search parameters within the search
# section of the algorithm.
#
#
# multiple of current total species to start at as maxmimum guess for St
#
mult <- 3
#
#
# Guesses per round for St values
#
guess.n <- 500
#
#
# Ratio of top scoring guesses to keep from all guesses per round
#
ratio <- 0.2
#
#
# stretch - Range Stretch to apply at each end (ie 1.25 would mean extend the
# range in each iteration by 25%)
#
stretch <- 1.5
#
#
# Max iteratations of guessing St
#
max.it <- 20