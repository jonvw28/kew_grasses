################################################################################
#                                                                              #
# Function that takes as input a csv file of a list of species including their #
# year of publication and an optional csv of the locations of these species.   #
# The script will ouput a series of csv files of numbers of new species        #
# published in each time window as defined by the inputs below as well as      #
# cumulative numbers of species discovered.                                    #
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
# dir.path - location of csv input files
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
# levels - Names of each level of regional data
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
species_data <- function(dir.path, spec.file.name, loc.file.name = NULL, id.ind, 
                         yr.ind, tax.stat=FALSE, stat.ind=NULL, stat.mk=NULL, 
                         hyb.stat=FALSE, hyb.ind=NULL, hyb.mk=NULL, 
                         rnk.stat=FALSE, rnk.ind=NULL, rnk.mk=NULL,
                         filt.ind=NULL, filt.mk=NULL, loc.ind=NULL, levels=NULL,
                         st.yr, en.yr, int.yr,out.dir,dir.name, id.str){
	#
	# Check for directory and create if needed
	#
	tmp.dir <- paste(out.dir,"/",id.str,"/",dir.name,"/",sep = "")
	if(dir.exists(tmp.dir)==FALSE){
		dir.create(tmp.dir,recursive = T)
}
	rm(out.dir,dir.name)
	#
	#
	# Install any dependancies and load functions
	#
	source("./kew_grasses/Support/packages.R")
	source("./kew_grasses/Support/functions.R")
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
	# Append location data with species status, hybrid status, rank and year of
	# publication
	#
	data.index <- c(yr.ind)
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
	#
	# Deal with filters if appropriate
	#
	filter.table <- c(tax.stat,hyb.stat,rnk.stat)
	if(tax.stat){
		spec.data <- spec.data[which(spec.data[,stat.ind] %in% stat.mk),]
		if(!is.null(levels)){
		        loc.data <- loc.data[which(loc.data[,tmp.l+2] %in% stat.mk),]        
		}
		
	}
	if(hyb.stat){
		for(p in 1:length(hyb.ind)){
		        if(!is.null(levels)){
		                tmp <- which(loc.data[,tmp.l+1+filter.table[1]+p] == hyb.mk[p])
		                # get error if filter has nothing to remove
		                if(length(tmp)>0){
		                        loc.data <- loc.data[-tmp,]
		                }
		                rm(tmp)
		        }
			tmp2 <- which(spec.data[,hyb.ind[p]] == hyb.mk[p])
			if(length(tmp2)>0){
			        spec.data <- spec.data[-tmp2,]
			}
			rm(tmp2)
		}
		rm(p)
	}
	if(rnk.stat){
	        if(!is.null(levels)){
	                tmp.ind <- 2+filter.table[1]+length(hyb.ind)*filter.table[2]+tmp.l
	                loc.data <- loc.data[which(loc.data[,tmp.ind] %in% rnk.mk),]
	                rm(tmp.ind)        
	        }
		spec.data <- spec.data[which(spec.data[,rnk.ind] %in% rnk.mk),]
	}
	#
	# Pick out only relevant data
	#
	spec.data <- spec.data[,c(id.ind[1],yr.ind)]
	if(!is.null(levels)){
	        loc.data <- loc.data[,1:(tmp.l+1)]	        
	}
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
	tmp <- which(spec.data[,2] < yrs[1])
	spec.sum[1,3] <- length(tmp)
	rm(tmp)
	#
	# Check uniqueness
	#
	spec.data <- spec.data[!duplicated(spec.data[,1]),]
	#
	# Deal with aggregate species data
	#
	for (q in 1:length(yrs)){
		tmp <- which(
			spec.data[,2] >= yrs[q] & spec.data[,2] < yrs[q]+int.yr)
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
		  file=paste(tmp.dir,id.str,"_","species_overall_summary",".csv",
				sep =""),
		  row.names = FALSE)
	rm(spec.sum,spec.data)
	#
	# Deal with location data
	#
	if(!is.null(levels)){
        	loc.sum <- c()
        	loc.code <-c()
        	for (j in 1:(ncol(loc.data)-2)){
        		loc.sum[[j]] <- as.data.frame(matrix(data=0,nrow=length(yrs),
        						     ncol=2*length(unique(
        							     loc.data[,j+1]))+3))
        		loc.code[[j]] <- unique(loc.data[,j+1])
        		loc.sum[[j]][,1] <- yrs
        		names(loc.sum[[j]]) <- c("Start_Year",loc.code[[j]],"Non_endogenous",
        					 paste(loc.code[[j]],"cumulative",
        					       sep = "_"),"Non_endogenous_cumulative")
        	}
        	rm(j)
        	#
        	# Collect data
        	#
        	for(k in 1:(ncol(loc.data)-2)){
        		#
        		# slimline data to non-redundant data at relevent detail level
        		tmp.data <- unique(loc.data[,c(1,k+1,ncol(loc.data))])
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
        	rm(k,int.yr,yrs,loc.data,loc.code)
        	#
        	# Save Output
        	#
        	for (s in 1:length(loc.sum)){
        		#
        		# Set up output directory
        		#
        		lvl.dir <- paste(tmp.dir,levels[s],"/",sep = "")
        		if(dir.exists(lvl.dir)==FALSE){
        			dir.create(lvl.dir,recursive = T)
        		}
        		#
        		write.csv(loc.sum[[s]],
        			  file=paste(lvl.dir,id.str,"_species_summary_",levels[s],
        				     ".csv",sep =""),
        			  row.names = FALSE)
        		rm(lvl.dir)
        	}
        	rm(s,loc.sum,tmp.dir,id.str,levels)
	}
}