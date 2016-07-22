################################################################################
#                                                                              #
# Script that takes as input a csv file of a list of species including their   #
# year of publication and a csv of the locations of thsese species. The script #
# will ouput a series of csv files of numbers of new species published in each #
# time window as defined by the inputs below as well as cumulative numbers of  #
# species discovered.                                                          #
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
# Rank Column - column showing taxonomic rank
rnk.id <- 23
#
# Rank String - string identifying species is above column
rnk.str <- "Species"
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
                        data.index = c(yr.ind,stat.ind,rnk.id,hyb.id),
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
        tmp2 <- which(loc.data[,tmp.l+3+i] == hyb.mk[i])
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
# Filter for only species rank
#
Acc.sp <- Acc.sp[which(Acc.sp[,rnk.id]==rnk.str),]
Acc.loc <- Acc.loc[which(Acc.loc[,tmp.l+3]==rnk.str),]
#
# Pick out only relevant data
#
Acc.sp <- Acc.sp[,c(id.ind[1],yr.ind)]
Acc.loc <- Acc.loc[,1:(tmp.l+1)]
rm(yr.ind,stat.ind,hyb.mk,hyb.id,tmp.l,id.ind,rnk.id,rnk.str)
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
tmp <- which(Acc.sp[,2] < yrs[1])
spec.sum[1,3] <- length(tmp)
rm(tmp)
#
# Check uniqueness
#
Acc.sp <- Acc.sp[!duplicated(Acc.sp[,1]),]
#
# Deal with aggregate species data
#
for (q in 1:length(yrs)){
        tmp <- which(
                Acc.sp[,2] >= yrs[q] & Acc.sp[,2] < yrs[q]+int.yr)
        spec.sum[q,2] <- length(tmp)
        if(q >1){
                spec.sum[q,3] <- spec.sum[q-1,3] + spec.sum[q-1,2]
        }
        rm(tmp)
}
rm(q)

#
# Output the tallies
#
write.csv(spec.sum,
          file=paste(tmp.dir,id.str,"_","spec_summary",".csv",sep =""),
          row.names = FALSE)
rm(spec.sum,Acc.sp)
#
# Deal with location data
#
loc.sum <- c()
loc.code <-c()
for (j in 1:(ncol(Acc.loc)-2)){
        loc.sum[[j]] <- as.data.frame(matrix(data=0,nrow=length(yrs),
                                             ncol=2*length(unique(
                                                     Acc.loc[,j+1]))+3))
        loc.code[[j]] <- unique(Acc.loc[,j+1])
        loc.sum[[j]][,1] <- yrs
        names(loc.sum[[j]]) <- c("Start_Year",loc.code[[j]],"Non_endogenous",
                                 paste(loc.code[[j]],"cumulative",
                                       sep = "_"),"Non_endogenous_cumulative")
}
rm(j)
#
# Collect data
#
for(k in 1:(ncol(Acc.loc)-2)){
        # slimline data to non-redundant data at relevent detail level
        tmp.data <- unique(Acc.loc[,c(1,k+1,ncol(Acc.loc))])
        leng <- length(loc.code[[k]])
        #
        # Deal with endogeny
        #
        end.test <- as.data.frame(table(tmp.data[,1]),stringsAsFactors = F)
        end.test[,1] <- as.numeric(end.test[,1])
        end.id <- end.test[which(end.test[,2] == 1),1] %>%
                match(tmp.data[,1],.) %>%
                is.na() == F
        end.ind <- which(end.id)
        non.id <- end.test[which(end.test[,2] > 1),1] %>%
                match(tmp.data[,1],.) %>%
                is.na() == F
        non.ind <- which(non.id)
        rm(end.id,non.id,end.test)
        #
        tmp <- character(nrow(tmp.data))
        tmp.data <- cbind(tmp.data,tmp,stringsAsFactors=F)
        names(tmp.data)[ncol(tmp.data)] <- "endogeny_status"
        rm(tmp)
        tmp.data[end.ind,ncol(tmp.data)] <- "E"
        tmp.data[non.ind,ncol(tmp.data)] <- "NE"
        rm(end.ind,non.ind)
        #
        # Deal with already existing species
        #
        tmp <- tmp.data[which(tmp.data[,3] < yrs[1]),]
        non.end <- tmp[which(tmp[,4]=="NE"),]
        loc.sum[[k]][1,2*leng+3] <- length(unique(non.end[,1]))
        end <- tmp[which(tmp[,4]=="E"),]
        for(s in 1:leng){
                tmp.inf <- end[which(end[,2] == loc.code[[k]][s]),]
                loc.sum[[k]][1,leng+2+s] <- nrow(tmp.inf)
                rm(tmp.inf)
        }
        rm(tmp,non.end,end)
        #
        # Year window summaries
        #
        for (p in 1:length(yrs)){
                tmp <- tmp.data[which(
                        tmp.data[,3] >= yrs[p] & tmp.data[,3] < yrs[p]+int.yr),]
                non.end <- tmp[which(tmp[,4]=="NE"),]
                loc.sum[[k]][p,leng+2] <- length(unique(non.end[,1]))
                if (p > 1){
                        loc.sum[[k]][p,2*leng+3] <- (loc.sum[[k]][p-1,2*leng+3] 
                                             + loc.sum[[k]][p-1,leng+2])
                }
                rm(non.end)
                end <- tmp[which(tmp[,4]=="E"),]
                for(r in 1:leng){
                        tmp.inf <- end[which(end[,2] == loc.code[[k]][r]),]
                        loc.sum[[k]][p,r+1] <- nrow(tmp.inf)
                        if (p > 1){ 
                                loc.sum[[k]][p,leng+2+r] <- (loc.sum[[k]][p-1,
                                                                          leng+r+2] 
                                                        + loc.sum[[k]][[p-1,r+1]])
                        }
                        rm(tmp.inf)
                }
                rm(tmp,end,r)
        }
        rm(p,leng,tmp.data)
}
rm(k,int.yr,yrs,Acc.loc,loc.code)
#
# Save Output
#
for (s in 1:length(loc.sum)){
        write.csv(loc.sum[[s]],
                  file=paste(tmp.dir,id.str,"_","loc_summary","_level_",s,
                             ".csv",sep =""),
                  row.names = FALSE)
}
rm(s,loc.sum,tmp.dir,id.str)