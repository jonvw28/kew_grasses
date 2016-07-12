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
                        mu.len[i] <- length(spl.list[[m.spl[i]]])
                }
                rm(i)
        }
        # reformat the list to pull out strings of interest
        out <- unlist(spl.list)
        # Deal with any multi split cases
        if(length(mu.spl) > 0){
                for (i in 1:length(m.spl)){
                        out <- out[-((2*m.spl[i]+1):(2*m.spl[i]+m.len[i]-2))]
                }
                rm(i,m.len,m.spl)
        }
        # Take only the first half of each remaining string
        out <- out[c(TRUE,FALSE)]
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
        for(i in length(col.indices)){
                # Replace commas with &
                if(comma){
                        df[,col.ind[i]] <- gsub(',',' & ',df[col.ind[i]])
                }
                # Remove in from names and include the authors
                if(in.tag == TRUE && in.inc == TRUE){
                        df[,col.ind[i]] <- gsub(' in ',' & ',df[col.ind[i]])
                }
                # Remove in from names and exclude following authors
                if(in.tag == TRUE && in.inc == FALSE){
                        tmp <- grep(' in ',df[,col.ind[i]])
                        df[tmp,col.ind[i]] <- str.trunc(strsplit(df[tmp,col.ind[i]],
                                                                 ' in '))
                        rm(tmp)
                }
                # Remove ex from names and include the authors
                if(ex.tag == TRUE && ex.inc == TRUE){
                        df[,col.ind[i]] <- gsub(' ex\\. ',' & ',df[,col.ind[i]])
                        df[,col.ind[i]] <- gsub(' ex ',' & ',df[,col.ind[i]])
                }
                # Remove ex from names and exlude following authors
                if(ex.tag == TRUE && ex.inc == FALSE){
                        tmp1 <- grep(' ex ',df[col.ind[i]])
                        tmp2 <- grep(' ex\\. ',df[col.ind[i]])
                        tmp <- c (tmp1,tmp2)
                        rm(tmp1,tmp2)
                        df[tmp,col.ind[i]] <- str.trunc(strsplit(df[tmp,col.ind[i]],
                                                                 ' ex'))
                }
        }
}