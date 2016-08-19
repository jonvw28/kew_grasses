################################################################################
#                                                                              #
# Functions created as past of the summer project "where are the missing       #
# grasses?" undertaken during July-September 2016 at the Royal Botanic Gardens #
# Kew                                                                          #
#                                                                              #
#                                                                              #
# Jonathan Williams, 2016                                                      #
# jonvw28@gmail.com                                                            #
#                                                                              #
################################################################################


table.merge <- function(df1,df2,id=c(1,1),data.index=1,split=1){
        #
        # Function that merges selected data fields between two data frames
        #
        # df1 is the data frame to which the fields are to be added, coming
        # from df2. The argument id gives the numeric columns of the merging
        # id for df1 and df2 respectively. These must be the same, and should
        # be non-redundant in df2 (or else only the first occurance will be
        # used). data.index gives the indices of columns in df2 to be merged
        # to df1. split then gives the column number after which these extra
        # columns should be added, where they will be added in the order given
        # by data.index
        #
        if(!require("dplyr")){
                install.packages("dplyr")
        }
        library(dplyr)
        #
        if (length(id) != 2 || class(id) != "numeric"){
                stop("id must give numeric indices of the columns of the id
                     variables being used as basis of merge")
        }
        #
        if (length(split) != 1){
                stop("split must be a singular integer")
        }
        #
        if (class(data.index) != "numeric"){
                stop("data.index must give numeric indices of the columns of the
                     variables being merged")
        }
        #
        tmp.ind <- match(df1[,id[1]],df2[,id[2]])
        #
        if(sum(is.na(tmp.ind)) != 0){
                warning("Some merge IDs in df1 do not have a correpsonding
                        ID in df2. NAs introduced as result")
        }
        #
        temp <- ncol(df1)
        #
        for (i in 1:length(data.index)){
                tmp.vec <- vector(mode = class(df2[,data.index[i]]),
                                  length = nrow(df1))
                df1 <- cbind(df1,tmp.vec)
                rm(tmp.vec)
                names(df1)[ncol(df1)] <- names(df2)[data.index[i]]
                df1[,ncol(df1)] <- df2[tmp.ind,data.index[i]]
        }
        #
        df1 <- df1 %>%
                dplyr::select(c(1:split,
                                (temp + 1):(temp + length(data.index)),
                                (split + 1):temp))
        df1
}


which.index <- function(df,namesvec){
        #
        # Function which takes a dataframe and a character vector of names and 
        # returns a vector of the indices of these names
        #
        if(class(namesvec) != "character"){
                stop("namesvec muct be a character vector")
        }
        #
        index <- vector("numeric",length = length(namesvec))
        for(i in 1:length(namesvec)){
                index[i] <- which(names(df)==as.character(namesvec[i]))
        }
        index
}

str.trunc <- function(spl.list){
        #
        # Function that takes as its argument a list object created via a call
        # to the base function strsplit. This function will return the portion
        # of each string before the first split as a character vector
        #
        if(class(spl.list) != "list"){
                stop("input must be a list prepared with strsplit")
        }
        # First deal with cases where there was more than one split
        m.spl <- which(as.numeric(summary(spl.list)[,1]) > 2)
        # find number of parts for each split string
        if(length(m.spl) > 0){
                m.len <- c()
                for (i in 1:length(m.spl)){
                        m.len[i] <- length(spl.list[[m.spl[i]]])
                }
                rm(i)
        }
        # reformat the list to pull out strings of interest
        out <- unlist(spl.list)
        # Deal with any multi split cases
        if(length(m.spl) > 0){
                for (i in 1:length(m.spl)){
                        out <- out[-((2*m.spl[i]+1):(2*m.spl[i]+m.len[i]-2))]
                }
                rm(i,m.len,m.spl)
        }
        # Take only the first half of each remaining string
        out <- out[c(TRUE,FALSE)]
        out
}

str.trunc_r <- function(spl.list){
        #
        # Function that takes as its argument a list object created via a call
        # to the base function strsplit. This function will return the portion
        # of each string after the last split as a character vector
        #
        if(class(spl.list) != "list"){
                stop("input must be a list prepared with strsplit")
        }
        # First deal with cases where there was more than one split
        m.spl <- which(as.numeric(summary(spl.list)[,1]) > 2)
        # find number of parts for each split string
        if(length(m.spl) > 0){
                m.len <- c()
                for (i in 1:length(m.spl)){
                        m.len[i] <- length(spl.list[[m.spl[i]]])
                }
                rm(i)
        }
        # reformat the list to pull out strings of interest
        out <- unlist(spl.list)
        # Deal with any multi split cases to cut to only two strings
        if(length(m.spl) > 0){
                for (i in 1:length(m.spl)){
                        out <- out[-((2*m.spl[i]-1):(2*m.spl[i]+m.len[i]-4))]
                }
                rm(i,m.len,m.spl)
        }
        # Take only the second half of each remaining string
        out <- out[c(FALSE,TRUE)]
        out
}

name.formatter <- function(df,col.ind,comma = TRUE,in.tag=TRUE,in.inc=TRUE,
                           ex.tag = TRUE, ex.inc = FALSE){
        #
        # Function that takes a data frame and reformats the strings in columns
        # as given by the argument col.ind. In all cases the function will 
        # replace the specified patterns with the string ' & '. By setting the
        # arguments comma, in.tag and ex.tag to TRUE, & will replace commas, the 
        # string ' in ' and the strings ' ex ' and ' ex. ' respectively.
        #
        # If in.inc and ex.inc are set to TRUE then the section of the string
        # after each occurance fo the break is included in the ouptut. If these
        # are set to false, then everything after the first case of ' in ' and
	# before the first instances of ' ex '/' ex. ' respectively is removed.
        #
        if (class(col.ind) != "numeric"){
                stop("col.ind must give numeric indices of the columns 
                     containing the names to be formatted and merged")
        }
        #
        if(class(comma) != "logical"){
                stop("comma must be of class logical")
        }
        #
        if(class(in.tag) != "logical"){
                stop("in.tag must be of class logical")
        }
        #
        if(class(in.inc) != "logical"){
                stop("in.inc must be of class logical")
        }
        #
        if(class(ex.tag) != "logical"){
                stop("ex.tag must be of class logical")
        }
        #
        if(class(ex.inc) != "logical"){
                stop("ex.inc must be of class logical")
        }
        #
        for(i in 1:length(col.ind)){
                # Replace commas with &
                if(comma){
                        df[,col.ind[i]] <- gsub(',',' & ',df[,col.ind[i]])
                }
                # Remove in from names and include the authors
                if(in.tag){
                        if(in.inc){
                                df[,col.ind[i]] <- gsub(' in ',
                                                        ' & ',df[,col.ind[i]])
                        } 
                }
                # Remove in from names and exclude following authors
                if(in.tag){
                        if(in.inc == FALSE){
                                tmp <- grep(' in ',df[,col.ind[i]])
                                if(length(tmp) > 0){
                                        df[tmp,col.ind[i]] <- str.trunc(
                                                strsplit(df[tmp,col.ind[i]],
                                                         ' in '))
                                }
                                rm(tmp)
                        }
                }
                # Remove ex from names and include the authors
                if(ex.tag){
                        if(ex.inc){
                        df[,col.ind[i]] <- gsub(' ex\\. ',' & ',df[,col.ind[i]])
                        df[,col.ind[i]] <- gsub(' ex ',' & ',df[,col.ind[i]])
                        }
                }
                # Remove ex from names and exlude following authors
                if(ex.tag){
                        if(ex.inc == FALSE){
                                tmp1 <- grep(' ex ',df[,col.ind[i]])
                                tmp2 <- grep(' ex\\. ',df[,col.ind[i]])
                                tmp <- c (tmp1,tmp2)
                                rm(tmp1,tmp2)
                                if(length(tmp) > 0){
                                        df[tmp,col.ind[i]] <- str.trunc_r(
                                                strsplit(df[tmp,col.ind[i]],
                                                         ' ex'))
                                }
                                
                        } 
                }
        }
        df
}
#
#
csv_filter <- function(dir.path, file.name, filter.col, filter.mk,
                       out.dir, out.file.name){
        #
        # Function that reads a .csv file at the directory dir.path and filters
        # the data to only include the data which matches the selections given
        # by filter.mk in the column filter.col. This then outputs a .csv file
        # in the directory given by out.dir and with the name out.file.name
        #
        # Create output directory if needed
        if(dir.exists(out.dir)==FALSE){
                dir.create(out.dir,recursive = T)
        }
        #
        data <- read.csv(paste(dir.path,file.name,sep=""),
                         stringsAsFactors = FALSE) 
        ind <- NULL
        for(i in 1:length(filter.mk)){
                ind <- c(ind,which(data[,filter.col]==filter.mk[i]))
        }
        data <- data[ind,]
        write.csv(data,file=paste(out.dir,out.file.name,sep =""),
                  row.names = FALSE)
}
#
#
################################################################################
#                                                                              #
# Functions based on work of Joppa et al 2011                                  #
#                                                                              #
################################################################################
#
taxonomic.splitting.function<-function(dataset,taxonomist.column){
        #
        # Function taken from Joppa et al 2011, but modified for our
        # purposes
        #
        start.data<-as.matrix(dataset)
        # additional line - to minimise issue of any whitespace
        start.data[,taxonomist.column] <- gsub(' ','',
                                               start.data[,taxonomist.column])
        #
        #Line edited to reflect lack of whitespace
        split.in<-strsplit(start.data[,taxonomist.column],split=c("&"))
        mx.tx<-max(unlist(lapply(split.in,function(x){x<-length(x)}))) 
        # (Joppa) the maximum number of authors describing a single species#
        
        
        #(Joppa) THIS SPLITS THE AUTHORS INTO INDIVIDUAL COLUMNS
        na.matrix<-matrix(data="NA",ncol=mx.tx,nrow=nrow(start.data))
        start.data1<-cbind(start.data,na.matrix) 
        #(Joppa) there are never more than mx.tx authors per species...
        colnames(start.data1)<-c(colnames(start.data),
                                 paste("Taxonomist_",seq(1,mx.tx,1),sep=""))
        
        for(j in 1:mx.tx){
                start.data1[,(j+ncol(start.data))]<-unlist(
                        lapply(split.in,function(x){x<-noquote(x[j])}))
        }
        # Edited to avoid factoring
        start.data1<-as.data.frame(start.data1,stringsAsFactors = FALSE)
        return(start.data1)
}
#
taxonimist.summary<-function(data,yr.col,start.year,end.year,year.interval,
                             rolling.years,offset){
        #
        # Heavily modified form of the Joppa et al (2011) function 
        # yearly.summary.function
        #
        # Note: the data argument must be the output of the related
        # taxonomic.splitting.function
        #
        # Output is now a list with the aggregated data for totals as the first 
        # element, and the second element being a data frame showing all 
        # taxonomists for each time window and a break down of their publication
        # record in that window broken down by number of authors for their 
        # publications.
        #
        #
        # Set up output
        if(rolling.years){
                yrs <- seq(start.year,end.year,offset)
        } else {
                yrs<-seq(start.year,end.year,year.interval)
        }	
        mat<-matrix(data=0,ncol=2,nrow=length(yrs))
        colnames(mat)<-c("Start_Year","Taxonomists")
        mat[,1]<-yrs
        y.d <- year.interval
        #
        # Deal with case of no data
        #
        if(nrow(data) == 0){
                tax.tbl <- matrix(data=0 ,nrow =1, ncol =3)
                tax.tbl <- as.data.frame(tax.tbl)
                tax.tbl[1,1] <- "No_Author"
                tax.tbl[1,2] <- start.year
                colnames(tax.tbl) <- c("Start_Year","author",
                                       paste("Pubs_w_1_authors",sep=""))
                return(list(mat,tax.tbl))
        }
        #
        # Pull out maximum number of taxonimists per species
        tx.pos<-grep("Taxonomist_",colnames(data))
        n.tx<-length(tx.pos)
        # prepare to collect a table of taxonomists and their publication 
        # breakdown
        tax.tbl <- c()
        # Deal with each time window
        for (q in 1:length(mat[,1])){
                # subset data
                tmp <- which(
                        data[,yr.col] >= yrs[q] & data[,yr.col] < yrs[q]+y.d)
                sam<-data[tmp,]
                rm(tmp)
                if(nrow(sam) == 0){
                        next()
                }
                # Collect a list of all authors
                for (j in 1:n.tx){
                        assign(paste("sam.tax",j,sep=""),
                               as.matrix(sam[,tx.pos[j]]))
                        
                }
                tax.dat<-ls()[grep("sam.tax",ls())]
                out.list<-c()
                for(k in 1:length(tax.dat)){
                        out.list<-c(out.list,get(tax.dat[k]))
                }
                # Filter the list of authors to be only unique names
                sam.all.tax<-unique(out.list)
                sam.un.tax<-sam.all.tax[!is.na(sam.all.tax)]
                mat[q,2]<-length(sam.un.tax)
                #
                # Create a table of tallies for number of publications and 
                # number of co-authors for each author in the window
                #
                tmp.mat <- matrix(data = 0, nrow = length(sam.un.tax),
                                  ncol = n.tx + 2)
                tmp.mat[,1] <- rep(yrs[q],times = length(sam.un.tax))
                # table of no of authors for each species
                tot.tx <- sam[,tx.pos]
                tot.tx <- cbind(tot.tx,num_auth = n.tx - apply(
                                                as.matrix(is.na(tot.tx)),1,sum))
                #deal with each author
                for(i in 1:length(sam.un.tax)){
                        tmp.mat[i,2] <- sam.un.tax[i]
                        tmp.ind <- c()
                        #pick publications for that author in this window
                        for (j in 1:n.tx){
                                tmp.ind <- c(tmp.ind,
                                             grep(sam.un.tax[i],tot.tx[,j]))
                        }
                        rm(j)
                        tmp.dat <- tot.tx[tmp.ind,ncol(tot.tx)]
                        rm(tmp.ind)
                        #tally for pubs with each no of authors
                        for(k in 1:n.tx){
                                tmp.mat[i,k+2] <- sum(tmp.dat == k)
                        }
                        rm(k,tmp.dat)
                }
                tax.tbl <- rbind(tax.tbl,tmp.mat)
                rm(tmp.mat)
                rm(sam,tax.dat,out.list,sam.all.tax,sam.un.tax)
        }
        colnames(tax.tbl) <- c("Start_Year","author",
                               paste("Pubs_w_",seq(1,n.tx,1),"_authors",sep=""))
        # housekeeping for data formats
        mat <- as.data.frame(mat,stringsAsFactors = FALSE)
        mat[,1] <- as.numeric(mat[,1])
        mat[,2] <- as.numeric(mat[,2])
        tax.tbl <- as.data.frame(tax.tbl,stringsAsFactors = FALSE)
        tax.tbl[,1] <- as.numeric(tax.tbl[,1])
        for(l in 1:n.tx){
                tax.tbl[,l+2] <- as.numeric(tax.tbl[,l+2])
        }
        return(list(mat,tax.tbl))
}
#
#
joppa.grad <- function(df,a,b,St,St.fixed = FALSE,cache = NULL){
        #
        # Function that calculates the gradient of the cost function for the 
        # model of species discovery rates proposed by Joppa et al in
        # How many species of flowering plants are there 2010
        #
        # St.fixed is used to indicate the gradient is desired for St fixed.
        # In this case, only the partial derivatives wrt a and b are calculated.
        # Additionally, in such a case the speed of programs is vastly increased
        # by using precalculated variables. Here there need to be extra 
        # variables given to the input cache where repeated computation can be
        # avoided. This needs to be in the form of a dataframe or matrix with a
        # row for each row in df and the columns containing in order: 
        #
        # (St - cumulative species) multiplied by number of taxnomonists
        # natural log of actual number of new species
        #
        #
        if(St.fixed){
                grad <- numeric(length = 2)
                tmp <- (a + b*df[,1])*cache[,1]
                diff <- log(tmp) - cache[,2]
                out <- diff*cache[,1]/tmp
                grad[1] = sum(out)
                grad[2] = sum(out*df[,1])
                
        } else {
                grad <- numeric(length = 3)
                tmp1 <- a + b*df[,1]
                tmp2 <- (St - df[,3])
                tmp3 <- tmp1*tmp2*df[,4] 
                tmp4 <- ((log(tmp3)-log(df[,2]))*df[,4])/tmp3
                g.1 <- tmp4*tmp2
                grad[1] <- sum(g.1)
                grad[2] <- sum(g.1*df[,1])
                grad[3] <- sum(tmp4*tmp1)
        }
        grad
}
#
joppa.cost <- function(df,a,b,St,St.fixed = FALSE,cache = NULL){
        #
        # Function that calculates the cost function for the 
        # model of species discovery rates proposed by Joppa et al in
        # How many species of flowering plants are there 2010.
        #
        # St.fixed is used to indicate the cost is desired for St fixed.
        # In such a case the speed of programs is vastly increased
        # by using precalculated variables. Here there needs to be an extra 
        # variable given to the input cache where repeated computation can be
        # avoided. This needs to be in the form of a vector with a
        # as many elements as there are rows in df and containing: 
        #
        # (St - cumulative species) multiplied by number of taxnomonists
        #
        #
        if(St.fixed){
                cost <- sum((log((a+b*df[,1])*cache)-log(df[,2]))^2)
        }else{
                cost <- sum((log((a+b*df[,1])*df[,4]*(St-df[,3]))-log(df[,2]))^2)
        }
        cost
}

conv.cost <- function(df,a,b,St,St.fixed = FALSE,cache = NULL){
        #
        # Function that calculates the cost function for the 
        # model of species discovery rates proposed by Joppa et al in
        # How many species of flowering plants are there 2010, but using
        # normal least squares (ie not log transformed)
        #
        # St.fixed is used to indicate the cost is desired for St fixed.
        # In such a case the speed of programs is vastly increased
        # by using precalculated variables. Here there needs to be an extra 
        # variable given to the input cache where repeated computation can be
        # avoided. This needs to be in the form of a vector with a
        # as many elements as there are rows in df and containing: 
        #
        # (St - cumulative species) multiplied by number of taxnomonists
        #
        #
        if(St.fixed){
                cost <- sum(((a+b*df[,1])*cache-df[,2])^2)
        }else{
                cost <- sum(((a+b*df[,1])*df[,4]*(St-df[,3])-df[,2])^2)
        }
        cost
}
#
#
conv.grad <- function(df,a,b,St,St.fixed = FALSE,cache = NULL){
        #
        # Function that calculates the gradient of the cost function for the 
        # model of species discovery rates proposed by Joppa et al in
        # How many species of flowering plants are there 2010, but using
        # normal least squares (ie not log transformed)
        #
        # St.fixed is used to indicate the gradient is desired for St fixed.
        # In this case, only the partial derivatives wrt a and b are calculated.
        # Additionally, in such a case the speed of programs is vastly increased
        # by using precalculated variables. Here there need to be extra 
        # variables given to the input cache where repeated computation can be
        # avoided. This needs to be in the form of a dataframe or matrix with a
        # row for each row in df and the columns containing in order: 
        #
        # (St - cumulative species) multiplied by number of taxnomonists
        # the above multipled additionally by year
        #
        #
        if(St.fixed){
                grad <- numeric(length = 2)
                diff <- (a + b*df[,1])*cache[,1] - df[,2]
                grad[1] = sum(diff*cache[,1])
                grad[2] = sum(diff*cache[,2])
                
        } else {
                grad <- numeric(length = 3)
                tmp1 <- a + b*df[,1]
                tmp2 <- (St - df[,3])*df[,4]
                diff <- tmp1*tmp2 - df[,2]
                tmp3 <- diff*tmp2
                grad[1] <- sum(tmp3)
                grad[2] <- sum(tmp3*df[,1])
                grad[3] <- sum(diff*tmp1*df[,4])
        }
        grad
}