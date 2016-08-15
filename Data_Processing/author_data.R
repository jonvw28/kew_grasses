################################################################################
#                                                                              #
# Function that takes as input a csv file of a list of species including their #
# year of publication and a column of their primary authors as well as a csv   #
# containing the geographic locations of species. This will return a csv file  #
# of aggregated numbers of active taxonimists for time windows defined by the  #
# inputs below as well as a breakdown of these taxonimists for each window,    #
# showing how many species they were authors on, broken down by the number of  #
# authors on each of these papers                                	       #
#                                                                              #
# The csv files outputted include aggregated worldwide data, if the optional   #
# location csv has been included, in such a case the levels argument will need #
# to be specified or else the location breakdown will not take place there     #
# will also be a breakdown at the specified geographic levels of levels of     #
# endogenous species. Here endogenous is taken to mean only naturally present  #
# in one region at the given level of geographic zoning                        #
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
########################## EXPLANATION OF ARGUMENTS ############################
#
# dir.path - location of csv input file
# eg "./Data/07_05/"
#
# spec.file.name - name of csv file with species information 
# (without .csv at end)
# eg "public_checklist_flat_plant_dl_20160705_poaceae"
#
# loc.file.name - name of csv file with location information 
# (without .csv at end)
# eg "Poaceae_distribution"
#
# id.ind - indices of the columns where plant IDs are held for the
# species and location datasets respectively
# eg c(1,2)
#
# yr.ind - index of the column where the year of publication is stored in
# the species dataset
# eg 15
#
# auth.ind - index of the column containing the primary authors in the species
# dataset
# eg 11
#
# tax.stat - if set to true then there will be filtering to only allow authors
# of species of the taxonomic status(es) specified by argument stat.mk in the
# column given by the index stat.ind
# eg
# tax.stat <- TRUE
# stat.ind <- 17
# stat.mk <- c("A")
#
# hyb.stat - if set to true then there will be filtering to remove authors of 
# species which are hybrids as given by the marks hyb.mk for the columns given
# by hyb.ind respectively
# eg
# hyb.stat <- TRUE
# hyb.ind <- c(4,6)
# hyb.mk <- c("×","×")
#
# rnk.stat - if set to true then there will be filtering to only allow authors
# of species of the taxonomic rank(s) specified by argument rnk.mk in the
# column given by the index rnk.ind
# eg
# rnk.stat <- TRUE
# rnk.ind <- 23
# rnk.mk <- c("Species")
#
# filt.id - any columns in location data that are to be filtered in
# creating a valid dataset filtering out on the value given by filt.mk for
# each index
# eg
# filt.ind <- c(11,12,13,14)
# filt.mk <- c(1,1,1,1)
#
# loc.ind - indices of columns in location data where location information is
# stored for the levels of interest
# eg c(4,6)
#
# levels - Names of each level of regional data - if NULL then the location 
# breakdown will not take place
# eg c("TDWG1","TDWG2")
#
# st.yr - Start year
# eg 1755
#
# en.yr - End year
# eg 2015
#
# int.yr - Window Interval - how many years you want aggregation to occur over
# eg 5
#
# out.dir - Output directory where csv(s) will be saved
# eg "./Output"
#
# dir.name - Name of sub-directory within the above for this to go
# eg "taxon_data"
#
# id.str - Identifier string - included in the file names and as subdirectory
# eg "grass_1755_5y"
#
#
#
author_data <- function(dir.path, spec.file.name, loc.file.name=NULL, id.ind,
                        yr.ind, auth.ind, tax.stat=FALSE, stat.ind=NULL, 
                        stat.mk=NULL, hyb.stat=FALSE, hyb.ind=NULL, 
                        hyb.mk=NULL, rnk.stat=FALSE, rnk.ind=NULL, rnk.mk=NULL,
                        filt.ind=NULL, filt.mk=NULL, loc.ind=NULL, levels=NULL,
                        st.yr, en.yr, int.yr, out.dir, dir.name, id.str){
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
	if(nrow(spec.data)==0){
	        stop("Species dataset contains no data")
	}
	spec.data[is.na(spec.data)] <- ""
	#
	# Import location data if appropriate
	#
	if(!is.null(levels)){
        	loc.data <- read.csv(paste(dir.path,loc.file.name,".csv",sep=""),
        			     stringsAsFactors = FALSE)
        	if(nrow(loc.data)==0){
        	        stop("Location dataset contains no data")
        	}
	        loc.data[is.na(loc.data)] <- ""
	        rm(loc.file.name)
	}
	rm(dir.path,spec.file.name)
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
	if(!is.null(levels)){
	        if(length(filt.ind) > 0){
	                for(i in 1:length(filt.ind)){
	                        tmp <- which(loc.data[,filt.ind[i]] == filt.mk[i])
	                        loc.data <- loc.data[-tmp,]
	                        rm(tmp)
	                }
	                rm(i,filt.ind,filt.mk)   
	        }
	}

	#
	# Select relevant location data
	#
	if(!is.null(levels)){
	        loc.data <- loc.data[,c(id.ind[2],loc.ind)]
	        tmp.l <- ncol(loc.data)
	        rm(loc.ind) 
	}
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
	if(!is.null(levels)){
	        loc.data <- table.merge(loc.data,spec.data,id = c(id.ind[1],1),
	                                data.index = data.index,
	                                split = tmp.l)   
	}
	#
	# Remove the NAs
	#
	spec.data <- spec.data[which(is.na(spec.data[,yr.ind])==FALSE),]
	if(!is.null(levels)){
	        loc.data <- loc.data[which(is.na(loc.data[,tmp.l+1])==FALSE),]        
	}
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
		        tmp <- which(names.data[,3+filter.table[1]+p] == hyb.mk[p])
		        # get error if filter has nothing to remove
		        if(length(tmp)>0){
        		        names.data <- names.data[-tmp,]
        		}
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
	# get error if filter has nothing to remove
	if(length(miss.ind)>0){
	        names.data <- names.data[-miss.ind,]
	}
	rm(miss.ind)
	#
	if(nrow(names.data)==0){
	        stop("After Filtering there is no data left")
	}
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
	if(!is.null(levels)){
        	if(tax.stat){
        		loc.data <- loc.data[which(loc.data[,tmp.l+3] %in% stat.mk),]
        	}
        	if(hyb.stat){
        		for(p in 1:length(hyb.ind)){
        			tmp <- which(loc.data[,tmp.l+2+filter.table[1]+p] == hyb.mk[p])
        			# get error if filter has nothing to remove
        			if(length(tmp)>0){
        			        loc.data <- loc.data[-tmp,]
        			}
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
        	#
        	# Deal with the missing author names
        	#
        	miss.ind <- which(summary(strsplit(loc.data[,tmp.l+2],'&'))[,1] == 0)
        	# get error if filter has nothing to remove
        	if(length(miss.ind)>0){
        	        loc.data <- loc.data[-miss.ind,]
        	}
        	rm(miss.ind)
        	#
        	if(nrow(loc.data)==0){
        	        stop("after filtering there is no location data")
        	}
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
        }
}