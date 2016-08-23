# This script will combine data from a WCSP download and from a JSTOR download 
# of overall publication numbers. It compares the rates of publications between
# these two.
#
# Full details of how to use this script are included in the readme file in this
# sub directory
#
# Jonathan Williams, 2016                                                      
# jonvw28@gmail.com    
#
################################################################################
#
# First set the location of the working directory to the directory within which
# the repository has been downloaded
#
setwd("~/Kew Summer")
#
# Install any dependancies and load basic functions
#
source("./kew_grasses/Support/packages.R")
source("./kew_grasses/Support/functions.R")
#
# Set the year window of interest
#
start.year <- 1753
end.year <- 2014
#
# Set References for the dataset columns
#
tax.year.col <- 15
tax.id.col <- 1
sci.year.col <- 1
sci.pubs.col <- 2
#
# Now set the directory within this where the .csv files are held
#
dir.path <- "./Data/"
#
# Set the names of the taxonomy and global baseline data files
# NOTE: these are without the '.csv' at the end
# NOTE: If you are not using a WCSP download then you will need to go to the
# indices settings file and manually set the relevant indices for your dataset.
#
tax.file.name <- "08_12/public_checklist_flat_plant_dl_20160705"
baseline.file.name <- "08_23/JSTOR_All_authors"
#
# Set the locations for the outputs.
#
output.location <- "./Output/taxonomy_scientific_comparison"
id.str <- "taxonomic_names"

# 
################################################################################
#                                                                              #
#                       DO NOT EDIT CODE BELOW THIS LINE                       #            
#                                                                              #
################################################################################
#
# Process WCSP data
#
source("./kew_grasses/Support/data_processing/species_data.R")
species_data(dir.path, tax.file.name, loc.file.name = NULL, id.ind = tax.id.col, 
             yr.ind = 15, basio.filt = FALSE, basio.year = FALSE, 
             basio.ind = NULL, miss.bas = NULL, levels = NULL, st.yr=start.year, 
             en.yr = end.year, int.yr = 1, rolling.years = FALSE, 
             year.gap = NULL, out.dir = output.location, 
             dir.name = "", id.str = id.str)
#
tax.effort <- read.csv(paste(output.location,"/",id.str,"/",id.str,
                             "_species_overall_summary.csv",sep=""),
                       stringsAsFactors = FALSE)
sci.effort <- read.csv(paste(dir.path,baseline.file.name,".csv",sep=""),
                       stringsAsFactors = FALSE)
#
# Set up data collection
#
comp.table <- as.data.frame(matrix(nrow = end.year-start.year+1, ncol = 4))
names(comp.table) <- c("start_year","taxonomic_papers","JSTOR_papers","ratio")
#
# Add year and taxonomic info
#
comp.table[,1] <- start.year:end.year
comp.table[,2] <- tax.effort[,2]
#
# Bring in JSTOR info
#
for(i in start.year:end.year){
        ind <- which(sci.effort[,sci.year.col]==i)
        if(length(ind)==0){
                tmp <- 0
        } else{
                tmp <- sci.effort[ind,sci.pubs.col]
        }
        comp.table[i-start.year+1,3] <- tmp
        rm(tmp,ind,tmp.in)
}
#
# Compute ratio
#
comp.table[,4] <- comp.table[,2]/comp.table[,3]
#
# Save Output
#
write.csv(comp.table,paste(output.location,"/",
                           "comparison_table.csv",sep=""),
          row.names = FALSE)
#
rm(list = ls())