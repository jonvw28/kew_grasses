################################################################################
#                                                                              #
# Script that takes as input a csv file of a list of species including their   #
# year of publication and a column of their primary authors as well as a csv   #
# containing the geographic locations of species. This will return a csv file  #
# of aggregated numbers of active taxonimists for time windows defined by the  #
# inputs below as well as a breakdown of these taxonimists for each window,    #
# showing how many species they were authors on, broken down by the number of  #
# authors on each of these papers                                	       #
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
# Taxonomic status filtering - if set to true then there will be filtering to 
# only allow authors of species of the status specified in the column given
tax.stat <- TRUE
stat.ind <- 17
stat.mk <- c("A")
#
# Hybrid filtering - if set to true then there will be filtering to 
# remove authors of species which are hybrids
hyb.stat <- TRUE
hyb.ind <- c(4,6)
hyb.mk <- c("×","×")
#
# Taxonomic rank filtering - if set to true then there will be filtering to 
# only allow authors of species of the status specified in the column given
rnk.stat <- TRUE
rnk.ind <- 23
rnk.mk <- c("Species")
#
# Location Filter IDs - any columns in location data that are to be filtered in
# creating a valid dataset
filt.ind <- c(11,12,13,14)
#
# Location Filter marks - marker in each such columns used to show data to be
# filtered
filt.mk <- c(1,1,1,1)
#
# Location IDs - indices of columns in location data where loactions are stored
loc.ind <- c(4,6)
#
# Names of each level of regions
levels <- c("TDWG1","TDWG2")
#
# Start year
st.yr <- 1755
#
# End year
en.yr <- 2015
#
# Window Interval - how many years you want aggregation to occur over
int.yr <- 5
#
# Output directory
out.dir <- "./Output"
#
# Identifier string - include info for the file names and as subdirectory
id.str <- "grass_1755_5y"
#
# Name of sub-directory within the above for this to go
dir.name <- "taxon_data"
#
#
################################################################################
#                                                                              #
#                       DO NOT EDIT CODE BELOW THIS LINE                       #            
#                                                                              #
################################################################################
#
# Check for directory and create if needed
#
tmp.dir <- paste(out.dir,"/",id.str,"/",dir.name,"/",sep = "")
if(dir.exists(tmp.dir)==FALSE){
        dir.create(tmp.dir,recursive = T)
}
rm(out.dir,dir.name)
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
tmp <- grep('ex\\..',spec.data[,auth.ind])
spec.data[tmp,auth.ind] <- gsub('ex\\.','ex ',spec.data[tmp,auth.ind])
rm(tmp)
#
# Re format to have breaks between authors given by &
#
spec.data <- name.formatter(spec.data, col.ind = auth.ind, T,T,T,T,F)
#
#
######################## Merge names to location data ##########################
#
#
# Filter out any location data which is irrelevant - eg introduced species
#
for(i in 1:length(filt.ind)){
        tmp <- which(loc.data[,filt.ind[i]] == filt.mk[i])
        loc.data <- loc.data[-tmp,]
        rm(tmp)
}
rm(i,filt.ind,filt.mk)
#
# Select relevant location data
#
loc.data <- loc.data[,c(id.ind[2],loc.ind)]
tmp.l <- ncol(loc.data)
rm(loc.ind)
#
# Append location data with species author and year of
# publication - as well as markers if appropriate
#
data.index <- c(yr.ind,auth.ind)
if(tax.stat){
	data.index <- c(data.index,stat.ind)
}
if(hyb.stat){
	data.index <- c(data.index,hyb.ind)
}
if(rnk.stat){
	data.index <- c(data.index,rnk.ind)
}
#
# Make the merge
#
loc.data <- table.merge(loc.data,spec.data,id = c(id.ind[1],1),
                        data.index = data.index,
                        split = tmp.l)
#
# Remove the NAs
#
spec.data <- spec.data[which(is.na(spec.data[,yr.ind])==FALSE),]
loc.data <- loc.data[which(is.na(loc.data[,tmp.l+1])==FALSE),]
#
# Take only necessary data for overall names
#
names.data <- spec.data[,c(id.ind[1],data.index)]
rm(spec.data,yr.ind,auth.ind,id.ind,data.index)
#
#
##################### Author information with no location ######################
#
# Deal with filters if appropriate
#
filter.table <- c(tax.stat,hyb.stat,rnk.stat)
if(tax.stat){
	names.data <- names.data[which(names.data[,4] %in% stat.mk),]
}
if(hyb.stat){
        for(p in 1:length(hyb.ind)){
                tmp <- which(names.data[,3+filter.table[1]+p] != hyb.mk[p])
                names.data <- names.data[tmp,]
                rm(tmp)
        }
        rm(p)
}
if(rnk.stat){
        tmp.ind <- 4+filter.table[1]+length(hyb.ind)*filter.table[2]
	names.data <- names.data[which(names.data[,tmp.ind] %in% rnk.mk),]
        rm(tmp.ind)
}
names.data <- names.data[,1:3]
#
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
overall.tax <- taxonimist.summary(names.data,2,st.yr,en.yr,int.yr)
rm(names.data)
#
# Output aggregated data
#
write.csv(overall.tax[[1]],
          file=paste(tmp.dir,id.str,"_","tax_overall_summary",".csv",sep =""),
          row.names = FALSE)
#
write.csv(overall.tax[[2]],
          file=paste(tmp.dir,id.str,"_","tax_overall_breakdown",".csv",sep =""),
          row.names = FALSE)
rm(overall.tax)
#
#
#################### Location breakdown of taxonomist data #####################
#
#
# Deal with filters if appropriate
#
if(tax.stat){
        loc.data <- loc.data[which(loc.data[,tmp.l+3] %in% stat.mk),]
}
if(hyb.stat){
        for(p in 1:length(hyb.ind)){
                tmp <- which(loc.data[,tmp.l+2+filter.table[1]+p] != hyb.mk[p])
                loc.data <- loc.data[tmp,]
                rm(tmp)
        }
        rm(p)
}
if(rnk.stat){
        tmp.ind <- tmp.l+3+filter.table[1]+length(hyb.ind)*filter.table[2]
        loc.data <- loc.data[which(loc.data[,tmp.ind] %in% rnk.mk),]
        rm(tmp.ind)
}
loc.data <- loc.data[,1:(tmp.l+2)]
rm(tax.stat,stat.ind,stat.mk,hyb.stat,hyb.ind,hyb.mk,rnk.stat,rnk.ind,rnk.mk,
	filter.table)
#
# Deal with the missing author names
#
miss.ind <- which(summary(strsplit(loc.data[,tmp.l+2],'&'))[,1] == 0)
loc.data <- loc.data[-miss.ind,]
rm(miss.ind)
#
# split the names in the location merge
#
loc.data <- taxonomic.splitting.function(loc.data,ncol(loc.data))
#
# Keep format as numeric for id and year
#
loc.data[,1] <- as.numeric(loc.data[,1])
loc.data[,tmp.l+1] <- as.numeric(loc.data[,tmp.l + 1])
#
# Set up data collection for location data - here have list where first index
# gives TDWG level, then second index includes first the overall summary, then
# full breakdown for each author
#
loc.sum <- c()
loc.code <-c()
yrs<-seq(st.yr,en.yr,int.yr)
for (j in 1:(tmp.l-1)){
	#
	# Set up summary table for each level
	#
        loc.sum[[j]] <- as.data.frame(matrix(data=0,nrow=length(yrs),
						ncol=length(unique(
							loc.data[,j+1]))+2))
	loc.sum[[j]][,1] <- yrs 
	#
	# List all regions at each level
	#
	loc.code[[j]] <- unique(loc.data[,j+1])
        names(loc.sum[[j]]) <- c("Start_Year",loc.code[[j]],
					"Non_endogenous")
}
rm(j,yrs)
#
# Loop over all levels of geographic detail
#
for(k in 1:(tmp.l-1)){
	#
        # Set up output directory
        #
        lvl.dir <- paste(tmp.dir,levels[k],"/",sep = "")
        if(dir.exists(lvl.dir)==FALSE){
                dir.create(lvl.dir,recursive = T)
        }
        #
        # slimline data to non-redundant data at relevent detail level
	# ie species id, region at relevant level, year and authors column
        #
	tmp.data <- unique(loc.data[,c(1,k+1,(tmp.l+1):ncol(loc.data))])
	#
	# Number of regions
	#
        leng <- length(loc.code[[k]])
        #
        # Classify each species as either endogenous or not at the given level
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
	# Apply method to endongenous data
	#
	end <- tmp.data[which(tmp.data[,ncol(tmp.data)]=="E"),]
	#
	# Loop over all regions at this level
	#
	for(l in 1:leng){
		#
		# Filter for each region
		#
		tmp.end <- end[which(end[,2] == loc.code[[k]][l]),]
		tmp.res <- taxonimist.summary(tmp.end,3,st.yr,en.yr,
						int.yr)
		#
		# Store aggreated data
		#
		loc.sum[[k]][,l+1] <- tmp.res[[1]][,2]
		#
		# Save breakdown
		#
		write.csv(tmp.res[[2]],
		          file=paste(lvl.dir,id.str,"_",levels[k],
		                     "_tax_breakdown_",loc.code[[k]][l],".csv",
		                     sep =""),
		          row.names = FALSE)
		rm(tmp.res,tmp.end)
	}
	rm(end,l)
	#
	# Deal with non-endogenous data
	#
	nend <- tmp.data[which(tmp.data[,ncol(tmp.data)]=="NE"),]
	tmp.res <- taxonimist.summary(nend,3,st.yr,en.yr,int.yr)
	loc.sum[[k]][,leng+2] <- tmp.res[[1]][,2]
	write.csv(tmp.res[[2]],
	          file=paste(lvl.dir,id.str,"_",levels[k],
	                     "_tax_breakdown_Non_Endogenous",".csv",
	                     sep =""),
	          row.names = FALSE)
	rm(nend,tmp.res,leng,tmp.data)
	#
	# Save summary data
	#
	write.csv(loc.sum[[k]],
	          file=paste(lvl.dir,id.str,"_",levels[k],
	                     "_tax_summary",".csv",
	                     sep =""),
	          row.names = FALSE)
}
rm(k,en.yr,st.yr,int.yr,loc.data,tmp.l,tmp.dir,id.str,levels,lvl.dir,loc.sum,
   loc.code)