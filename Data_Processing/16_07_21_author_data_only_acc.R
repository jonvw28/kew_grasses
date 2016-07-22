################################################################################
#                                                                              #
# Script that takes as input a csv file of a list of species including their   #
# year of publication and a column of thie primary authors. This will return   #
# a csv file of aggregated numbers of active taxonimists for time windows      #
# defined by the inputs below as well as a breakdown of these taxonimists for  #
# each window, showing how many species they were authors on, broken down by   #
# the number of authors on each of these papers                                #
#                                                                              #
# This script will only consider authors for species currently listed as       #
# accepted - excluding subspecies and hybrids.                                 #
#                                                                              #
# Excluding brackets, the year of publication will need to be in a 4 digit     #
# format and be at the end of the entry in the year column for each row.       #
#                                                                              #
# For example: "[Feb 2008]"  and "(1975)" fould be fine but "2008, Feb" and    #
# "1975  " would result in NAs and hence their rows will be removed            #
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
dir.path <- "./Data/07_05/"
#
# File name - name of csv file (without .csv at end)
file.name <- "public_checklist_flat_plant_dl_20160705_poaceae"
#
# Year column - index of the column where the year of publication is stored
yr.ind <- 15
#
# Primary Authors column - index of the column containing the primary authors
auth.ind <- 11
#
# Taxonomic status column - index of the column containing taxonomic status in
# the species data
stat.ind <- 17
#
# Accepted Species string - string that represents accepted species in the 
# taxonomic status column
acc.string <- "A"
#
# Hybrid column(s) - indices of columns containing markes for hybrid species or
# genera
hyb.id <- c(4,6)
#
# Hybrid markers - markers for hybrids for each column as given above
hyb.mk <- c("×","×")
#
# Rank Column - column showing taxonomic rank
rnk.id <- 23
#
# Rank String - string identifying species is above column
rnk.str <- "Species"
#
# Start year
st.yr <- 1753
#
# End year
en.yr <- 2015
#
# Window Interval - how many years you want aggregation to occur over
int.yr <- 5
#
# Output directory
out.dir <- "./Output/"
#
# Identifier string - include info for the file names and as subdirectory
id.str <- "grass_1753_5y_acc"
#
################################################################################
#                                                                              #
#                       DO NOT EDIT CODE BELOW THIS LINE                       #            
#                                                                              #
################################################################################
#
# Check for directory and create if needed
#
tmp.dir <- paste(out.dir,id.str,"/",sep = "")
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
data <- read.csv(paste(dir.path,file.name,".csv",sep=""),
                 stringsAsFactors = FALSE)
rm(dir.path,file.name)
#
# Tidy up publication date data into numeric format, removing brackets
#
template <- c("\\[","\\]","\\(","\\)")
for (i in 1:length(template)){
       data[,yr.ind] <- gsub(template[i],"",data[,yr.ind])
}
rm(i,template)
#
data[,yr.ind] <- as.numeric(stringr::str_sub(data[,yr.ind],-4,-1))
#
# EXPLANATION OF NAs IN THE CASE OF THE EXAMPLE DATA
#
# 267 NAs from missing data
# 2 NAs from (
# 1 NA from (v)
#
# Remove the NAs
#
data <- data[which(is.na(data[,yr.ind])==FALSE),]
#
# Remove Hybrids
#
for(i in 1:length(hyb.id)){
        tmp <- which(data[,hyb.id[i]] == hyb.mk[i])
        data <- data[-tmp,]
        rm(tmp)
}
rm(i)
#
# Only consider accepted species
#
data <- data[which(data[,stat.ind]==acc.string),]
#
# Filter for only species rank
#
data <- data[which(data[,rnk.id]==rnk.str),]
#
# Pick only necessary data
#
names.data <- data[,c(1,yr.ind,auth.ind)]
rm(data,yr.ind,auth.ind,acc.string,stat.ind,rnk.str,rnk.id,hyb.mk,hyb.id)
#
# Deal with exceptions where ex. is not followed by a space
#
tmp <- grep('ex\\..',names.data[,3])
names.data[tmp,3] <- gsub('ex\\.','ex ',names.data[tmp,3])
rm(tmp)
#
# Re format to have breaks between authors given by &
#
names.data <- name.formatter(names.data, col.ind = 3, T,T,T,T,F)
#
# Deal with the missing author names
#
miss.ind <- which(summary(strsplit(names.data[,3],'&'))[,1] == 0)
names.data <- names.data[-miss.ind,]
rm(miss.ind)
#
# Apply Method from Joppa et al, 2011 to count authors
#
names.data <- taxonomic.splitting.function(names.data,3)
#
# Keep format as numeric for id and year
#
names.data[,1] <- as.numeric(names.data[,1])
names.data[,2] <- as.numeric(names.data[,2])
#
# Get table of taxonomist data
#
taxon.data <- taxonimist.summary(names.data,2,st.yr,en.yr,int.yr)
rm(st.yr,en.yr,int.yr,names.data)
#
# Output aggregated data
#
write.csv(taxon.data[[1]],
          file=paste(tmp.dir,id.str,"_","tax_summary",".csv",sep =""),
          row.names = FALSE)
#
write.csv(taxon.data[[2]],
          file=paste(tmp.dir,id.str,"_","tax_breakdown",".csv",sep =""),
          row.names = FALSE)
rm(tmp.dir,id.str,taxon.data)