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
        ## are set to dalse, then everything after the first case of ' in ' and
        # ' ex '/' ex. ' respectively is removed.
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
taxonimist.summary<-function(data,yr.col,start.year,end.year,year.interval){
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
        yrs<-seq(start.year,end.year,year.interval)	
        mat<-matrix(data=0,ncol=2,nrow=length(yrs))
        colnames(mat)<-c("Start_Year","Taxonomists")
        mat[,1]<-yrs
        y.d <- year.interval
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
                tot.tx <- cbind(tot.tx,num_auth = 6 - apply(is.na(tot.tx),1,sum))
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
#
joppa.grad <- function(df,a,b,St){
        #
        # Function that calculates the gradient of the cost function for the 
        # model of species discovery rates proposed by Joppa et al in
        # How many species of flowering plants are there 2010
        #
        grad <- numeric(length = 3)
        for (i in 1:nrow(df)){
                est.S <- (a + b*df[i,1])*df[i,4]*(St - df[i,3])
                diff <- log(est.S) - log(df[i,2])
                d <- numeric(length = 3)
                d[1] <- diff*df[i,4]*(St-df[i,3])/est.S
                d[2] <- d[1]*df[i,1]
                d[3] <- diff*df[i,4]*(a+b*df[i,1])/est.S
                grad <- grad + d
                rm(d)
        }
        grad
}
#
#
joppa.cost <- function(df,a,b,St){
        #
        # Function that calculates the cost function for the 
        # model of species discovery rates proposed by Joppa et al in
        # How many species of flowering plants are there 2010
        #
        cost <- 0
        for (i in 1:nrow(df)){
                est.S <- (a + b*df[i,1])*df[i,4]*(St - df[i,3])
                tmp <- log(est.S) - log(df[i,2])
                cost <- cost + tmp^2
        }
        cost
}

conv.cost <- function(df,a,b,St){
        #
        # Function that calculates the cost function for the 
        # model of species discovery rates by square residuals
        #
        cost <- 0
        for (i in 1:nrow(df)){
                est.S <- (a + b*df[i,1])*df[i,4]*(St - df[i,3])
                tmp <- est.S - df[i,2]
                cost <- cost + tmp^2
        }
        cost
}
#
#
conv.grad <- function(df,a,b,St){
        #
        # Function that calculates the gradient of the cost function for the 
        # model of species discovery rates proposed by Joppa et al in
        # How many species of flowering plants are there 2010, but using
        # normal least squares (ie not log transformed)
        #
        grad <- numeric(length = 3)
        for (i in 1:nrow(df)){
                est.S <- (a + b*df[i,1])*df[i,4]*(St - df[i,3])
                diff <- est.S - df[i,2]
                d <- numeric(length = 3)
                d[1] <- diff*df[i,4]*(St-df[i,3])
                d[2] <- d[1]*df[i,1]
                d[3] <- diff*df[i,4]*(a+b*df[i,1])
                grad <- grad + d
                rm(d)
        }
        grad
}