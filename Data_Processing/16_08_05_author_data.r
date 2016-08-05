################################################################################
#                                                                              #
# Script that takes as input a csv file of a list of species including their   #
# year of publication and a column of thie primary authors. This will return   #
# a csv file of aggregated numbers of active taxonimists for time windows      #
# defined by the inputs below as well as a breakdown of these taxonimists for  #
# each window, showing how many species they were authors on, broken down by   #
# the number of authors on each of these papers                                #
#                                                                              #
# The csv files outputted include aggregated worldwide data, as well as a      #
# breakdown at the specified geograhic levels of levels of endogenous species  #
# Here endogenous is taken to mean only naturally present in one region at     #
# the given level of geographic zoning                                         #
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
# Species File name - name of csv file with species information 
#(without .csv at end)
spec.file.name <- "public_checklist_flat_plant_dl_20160705_poaceae"
#
# Location File name - name of csv file with location information 
#(without .csv at end)
loc.file.name <- "Poaceae_distribution"
#
# Plant ID column - indices of the columns where plant IDs are held for the
# species and location data respectively
id.ind <- c(1,2)
#
# Year column - index of the column where the year of publication is stored
yr.ind <- 15
#
# Primary Authors column - index of the column containing the primary authors
auth.ind <- 11
#
# Location Filter IDs - any columns in location data that are to be filtered in
# creating a valid dataset
filt.id <- c(11,12,13,14)
#
# Location Filter marks - marker in each such columns used to show data to be
# filtered
filt.mk <- c(1,1,1,1)
#
# Location IDs - indices of columns in location data where loactions are stored
loc.id <- c(4,6,8)
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
id.str <- "grass_1753_5y"
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
spec.data <- read.csv(paste(dir.path,spec.file.name,".csv",sep=""),
                 stringsAsFactors = FALSE)
loc.data <- read.csv(paste(dir.path,loc.file.name,".csv",sep=""),
                     stringsAsFactors = FALSE)
rm(dir.path,loc.file.name,spec.file.name)
#
#
#### Tidy up publication date data into numeric format, removing brackets ######
#
#
template <- c("\\[","\\]","\\(","\\)")
for (i in 1:length(template)){
        spec.data[,yr.ind] <- gsub(template[i],"",spec.data[,yr.ind])
}
rm(i,template)
#
spec.data[,yr.ind] <- as.numeric(stringr::str_sub(spec.data[,yr.ind],-4,-1))
#
# EXPLANATION OF NAs IN THE CASE OF THE EXAMPLE DATA
#
# 267 NAs from missing data
# 2 NAs from (
# 1 NA from (v)
#
#
#################### TIDY NAMES into relevant format ###########################
#
#
# Deal with exceptions where ex. is not followed by a space
#
tmp <- grep('ex\\..',spec.data[,aut.id])
spec.data[tmp,auth.id] <- gsub('ex\\.','ex ',nspec.data[tmp,aut.id])
rm(tmp)
#
# Re format to have breaks between authors given by &
#
spec.data <- name.formatter(spec.data, col.ind = auth.id, T,T,T,T,F)
#
# Deal with the missing author names
#
miss.ind <- which(summary(strsplit(spec.data[,auth.id],'&'))[,1] == 0)
names.data <- names.data[-miss.ind,]
rm(miss.ind)
#
#
######################## Merge names to location data ##########################
#
#
# Filter out any location data which is irrelevant - eg introduced species
#
for(i in 1:length(filt.id)){
        tmp <- which(loc.data[,filt.id[i]] == filt.mk[i])
        loc.data <- loc.data[-tmp,]
        rm(tmp)
}
rm(i,filt.id,filt.mk)
#
# Select relevant location data
#
loc.data <- loc.data[c(id.ind[2],loc.id)]
tmp.l <- ncol(loc.data)
rm(loc.id)
#
# Append location data with species author and year of
# publication
#
loc.data <- table.merge(loc.data,spec.data,id = c(id.ind[1],1),
                        data.index = c(yr.ind,auth.id),
                        split = tmp.l)
#
# Remove the NAs
#
spec.data <- spec.data[which(is.na(spec.data[,yr.ind])==FALSE),]
loc.data <- loc.data[which(is.na(loc.data[,tmp.l+1])==FALSE),]
#
# Take only necessary data for overall names
#
names.data <- spec.data[,c(id.ind[1],yr.ind,auth.ind)]
rm(spec.data,yr.ind,auth.ind)



########################## HERE'S WHERE TO CARRY ON
# NEED TO ADD THE SAME AS BELOW BUT ALSO FOR EACH GEOGRAPHIC LEVEL



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