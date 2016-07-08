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
        # Function which takes a dataframe and a character vector of names and returns
        # a vector of the indices of these names
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
