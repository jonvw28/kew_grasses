################################################################################
#                                                                              #
# Script that takes as input a csv file of a list of species including their   #
# year of publication and a column of thie primary authors. This will return   #
# a csv file of aggregated numbers of active taxonimists for time windows      #
# defined by the inputs below as well as a breakdown of these taxonimists for  #
# each window, showing how many species they were authors on, broken down by   #
# the number of authors on each of these papers                                #
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
# SET INPUT VALUES HERE
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
# Year column - index of the column where the year of publication is stored
yr.ind <- 15
#
# Taxonomic status column - index of the column containing taxonomic status
stat.ind <- 17
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
# Output file name for window species totals (again without .csv)
out.name1 <- "5_year_species_summary_grass"
#
# SET DIRECTORY where you have downloaded repository
#
setwd("~/Kew Summer")
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
loc.data <- read.csv(paste(dir.path,loc.file.name,".csv",sep=""),
                      stringsAsFactors = FALSE)
rm(dir.path,spec.file.name,loc.file.name)
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
#############################
################################################################################
################################################################################
#
# PICK UP HERE
#
################################################################################
##
#
#
#
#
data <- data[which(is.na(data[,yr.ind])==FALSE),]
spec.data <- data[,c(1,yr.ind,stat.ind)]
rm(data,yr.ind,stat.ind)
#
################################################################################
#
# Append location data with species status and year of publication
#
tmp.id <- c(which.index(loc.data,"plant_name_id"),
            which.index(grass.data,"plant_name_id"))
tmp.dat <- which.index(grass.data,c("first_published","taxon_status_id",
                                    "genus_hybrid_marker","species_hybrid_marker"))
#
loc.data <- table.merge(loc.data,grass.data,id=tmp.id,data.index=tmp.dat,
                        split = ncol(loc.data))
#
rm(tmp.id,tmp.dat)
#
# Select only accepted species
#
Accep.loc <- dplyr::filter(loc.data,taxon_status_id == "A")
#
# remove hybrids
#
Accep.loc <- dplyr::filter(Accep.loc, genus_hybrid_marker != "x") %>%
        dplyr::filter(species_hybrid_marker != "x")
#
#
################################################################################
#
# Now pick out continent TDGW level 1 info for discoveries
#
loc.trend <- dplyr::group_by(loc.data,plant_name_id,continent_code_l1) %>%
        dplyr::summarise(continent = unique(continent))
temp <- numeric(length = nrow(loc.trend))
#
# Add year of publication
#
loc.trend <- cbind(loc.trend,temp)
rm(temp)
names(loc.trend)[4] <- "first_published"
indices <- match(loc.trend[,1],grass.data[,1])
loc.trend[,4] <- grass.data[indices,15]
rm(indices)
#
# Filter missing values
#
loc.trend <- loc.trend[which(is.na(loc.trend[,4])==FALSE),]
#
################################################################################
#
# Cumulative curves for each continent per TDWG level 1
#
nyears <- 2015 -1753 +1

cum.spec.reg <- matrix(nrow = nyears,
                        ncol = length(unique(loc.trend[,2]))+1)
reg.label <- character(length(unique(loc.trend[,2])))
cum.spec.reg[,ncol(cum.spec.reg)] <- 1753:(1753+nyears-1)
#
# Calculate cumulative species discovered for each region
#
for (reg in unique(loc.trend[,2])){
        tmp.data <- dplyr::filter(loc.trend,continent_code_l1 == reg)
        reg.label[reg] <- unique(tmp.data[,3])
        
        for(j in 1:nyears){
                cum.spec.reg[j,reg] <- sum(tmp.data[,4] <= j+1752)
        }
        
        rm(tmp.data)
}
cum.spec.reg <- as.data.frame(cum.spec.reg)
names(cum.spec.reg)[ncol(cum.spec.reg)] <- "year"
names(cum.spec.reg)[1:(ncol(cum.spec.reg)-1)] <- reg.label
rm(j,reg,nyears)
#
# Plot
#
melt.trend <- reshape::melt(cum.spec.reg, id = "year")
#
g <- ggplot2::ggplot(data = melt.trend,
                     aes(x = year, y = value, colour = variable))
g <- g + geom_line()
g

rm(g,reg.label,melt.trend)
#
#
################################################################################
#
# Isolate endogenous species
#
end.test <- dplyr::group_by(loc.trend,plant_name_id) %>%
        dplyr::summarise(count = n())

end.spec <- dplyr::filter(end.test,count == 1)[,1]
nonend.spec <- dplyr::filter(end.test, count >1)[,1]
rm(end.test)

tmp <- character(nrow(loc.trend))
loc.trend <- cbind(loc.trend,tmp,stringsAsFactors=F)
names(loc.trend)[ncol(loc.trend)] <- "endogeny_status"
rm(tmp)
#
# Add endgoeny tag to existing trend data
#
end.ind <- which(is.na(match(loc.trend[,1],as.data.frame(end.spec)[,1])) == F)
nonend.ind <- which(is.na(match(loc.trend[,1],
                                as.data.frame(nonend.spec)[,1])) == F)
rm(end.spec,nonend.spec)
#
loc.trend[end.ind,ncol(loc.trend)] <- "E"
loc.trend[nonend.ind,ncol(loc.trend)] <- "NE"
loc.trend[,5] <- as.factor(loc.trend[,5])
rm(end.ind,nonend.ind)
#
#
# Endogenous info first
#
end.data <- dplyr::filter(loc.trend, endogeny_status == "E")
#
# Cumulative curves for each continent per TDWG level 1
#
nyears <- 2015 -1753 +1

cum.spec.reg <- matrix(nrow = nyears,
                       ncol = length(unique(loc.trend[,2]))+2)
reg.label <- character(length(unique(loc.trend[,2])))
cum.spec.reg[,ncol(cum.spec.reg)] <- 1753:(1753+nyears-1)
#
# Calculate cumulative species discovered for each region
#
for (reg in unique(loc.trend[,2])){
        tmp.data <- dplyr::filter(end.data,continent_code_l1 == reg)
        reg.label[reg] <- unique(tmp.data[,3])
        
        for(j in 1:nyears){
                cum.spec.reg[j,reg] <- sum(tmp.data[,4] <= j+1752)
        }
        
        rm(tmp.data)
}
rm(end.data)
#
# Add non-endogenous species
#
nonend.data <- dplyr::filter(loc.trend, endogeny_status == "NE")
for(j in 1:nyears){
        cum.spec.reg[j,ncol(cum.spec.reg)-1] <- sum(nonend.data[,4] <= j+1752)
}
rm(nonend.data)
#
#
#
cum.spec.reg <- as.data.frame(cum.spec.reg)
names(cum.spec.reg)[ncol(cum.spec.reg)] <- "year"
names(cum.spec.reg)[ncol(cum.spec.reg)-1] <- "Non-Endogenous"
names(cum.spec.reg)[1:(ncol(cum.spec.reg)-2)] <- reg.label
rm(j,reg,nyears)
#
# Plot
#
melt.trend <- reshape::melt(cum.spec.reg, id = "year")
#
g <- ggplot2::ggplot(data = melt.trend,
                     aes(x = year, y = value, colour = variable))
g <- g + geom_line()
g

rm(g,reg.label,melt.trend)
#
#