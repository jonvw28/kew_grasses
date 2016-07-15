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
# Plant ID column - indices of the columns where plant IDs are held for the
# species and location data respectively
id.ind <- c(1,2)
#
# Year column - index of the column where the year of publication is stored in 
# the species data
yr.ind <- 15
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
# Output file name for window species totals (again without .csv)
out.name1 <- "5_year_species_summary_grass"
#
# Output file name for window species totals per location (again without .csv)
out.name2 <- "5_year_loc_species_summary_grass"
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
rm(dir.path,loc.file.name,spec.file.name)
#
# Tidy up publication date data into numeric format, removing brackets
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
# Filter out any messy location data
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
# Append location data with species status, hybrid status and year of
# publication
#
loc.data <- table.merge(loc.data,spec.data,id = c(id.ind[1],1),
                        data.index = c(yr.ind,stat.ind,hyb.id),
                        split = tmp.l)
# Remove the NAs
#
spec.data <- spec.data[which(is.na(spec.data[,yr.ind])==FALSE),]
loc.data <- loc.data[which(is.na(loc.data[,tmp.l+1])==FALSE),]
#
# Remove Hybrids
#
for(i in 1:length(hyb.id)){
        tmp <- which(spec.data[,hyb.id[i]] == hyb.mk[i])
        tmp2 <- which(loc.data[,tmp.l+2+i] == hyb.mk[i])
        spec.data <- spec.data[-tmp,]
        loc.data <- loc.data[-tmp2,]
        rm(tmp,tmp2)
}
rm(i)
#
# Filter for only accepted species
#
Acc.sp <- spec.data[which(spec.data[,stat.ind]==acc.string),]
Acc.loc <- loc.data[which(loc.data[,tmp.l+2]==acc.string),]
rm(loc.data,spec.data,acc.string)
#
# Pick out only relevant data
#
Acc.sp <- Acc.sp[,c(id.ind[1],yr.ind)]
Acc.loc <- Acc.loc[,1:(tmp.l+1)]
rm(yr.ind,stat.ind,hyb.mk,hyb.id,tmp.l)
#
# Summarise totals in each window plus cumulative total
#
yrs<-seq(st.yr,en.yr,int.yr)
rm(st.yr,en.yr)
#
# Set up data collection
#
spec.sum<-matrix(data=0,ncol=3,nrow=length(yrs))
colnames(spec.sum)<-c("Start_Year","New_species","Cumulative_species")
spec.sum[,1]<-yrs
loc.sum <- c()
for (j in 1:(ncol(Acc.loc)-2)){
        loc.sum[[j]] <- as.data.frame(matrix(data=0,nrow=length(yrs),
                                             ncol=2*length(unique(
                                                     Acc.loc[,j+1]))+1))
        loc.sum[[j]][,1] <- yrs
        names(loc.sum[[j]])[1] <- "Start_Year"
}
#
#
#
for (q in 1:length(yrs)){
        # overall species data
        tmp <- which(
                Acc.sp[,2] >= yrs[q] & Acc.sp[,2] < yrs[q]+int.yr)
        spec.sum[q,2] <- length(tmp)
        spec.sum[q,3] <- sum(spec.sum[,2])
        rm(tmp)
}
rm(q)
#
# Output the species tallies summary
#
write.csv(spec.sum,
          file=paste("./output/",out.name1,".csv",sep =""),
          row.names = FALSE)
rm(spec.sum,Acc.sp,out.name1,tmp.data)
#
##############################################################################
#
# LOCATION DATA










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