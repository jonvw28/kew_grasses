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
# This file contains the set-up for the manner in which author names are
# processed
#
#
# logical expression respectively decide whether to split 
# name strings based on the string ',' (splits if true)
#
comma <- TRUE
#
#
# logical expressions respectively decide whether to split name strings based on
# the string 'in' (if in.tag = TRUE) and then whether to include the names to 
# the right of the split (if in.inc = TRUE)
#
in.tag <- TRUE
in.inc <- TRUE
#
#
# logical expressions respectively decide whether to split name strings based on
# the string 'ex' (if ex.tag = TRUE) and then whether to include the names to 
# the left of the split (if ex.inc = TRUE)
#
ex.tag <- TRUE
ex.inc <- TRUE