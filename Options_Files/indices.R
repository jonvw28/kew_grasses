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
# This file contains the set-up for the indices in the relevant data files.
# The default is set up for a download from the WCSP, and shouldn't need to be 
# changed unless a different data source is being used.
#
#
# Plant ID column - indices of the columns where plant IDs are held for the
# species and distribution data respectively - second index not required if 
# not using a geographic model
#
id.ind <- c(1,2)
#
#
# Year column - index of the column where the year of publication is stored in 
# the species data
#
yr.ind <- 15
#
#
# Primary Authors column - index of the column containing the primary authors in 
# the specis data
#
auth.ind <- 11
#
#
# Basionym ID column - index of column containing basionym id for each name.
# miss.bas gives the value that appears when there isn't a basionym id as the 
# name is a basionym.
#
basio.ind <- 20
miss.bas <- -9998
#
#
# Taxonomic status column - index of the column containing the taxonomic status
# of each name and the allowed statuses to be kept if status filtering is 
# applied
#
stat.ind <- 17
stat.mk <- c("A")
#
#
# Taxonomic rank column - index of the column containing the taxonomic rank
# of each name and the allowed ranks to be kept if rank filtering is 
# applied
#
rnk.ind <- 23
rnk.mk <- c("Species")
#
#
# hybrid status columns - indices of the columns containing the hybrid status
# of each name and the marks that signal those names to be removed if hybrid
# filtering is to be applied. If there is more than one mark per column, then 
# enter all marks and repeat the column number in hyb.ind as many times as 
# there are marks.
#
hyb.ind <- c(4,6)
hyb.mk <- c("×","×")
