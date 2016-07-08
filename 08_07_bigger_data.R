setwd("~/Kew Summer/Data/07_05")
#
# Install any dependancies
#
if(!require("dplyr")){
        install.packages("dplyr")
}
library(dplyr)
#
if(!require("stringr")){
        install.packages("stringr")
}
library(stringr)
#
if(!require("reshape")){
        install.packages("reshape")
}
library(reshape)
#
if(!require("ggplot2")){
        install.packages("ggplot2")
}
library(ggplot2)
#
# Import data
#
grass.data <- read.csv("public_checklist_flat_plant_dl_20160705_poaceae.csv",
                       stringsAsFactors = FALSE)
loc.data <- read.csv("Poaceae_distribution.csv",stringsAsFactors = FALSE)
#
# Tidy up publication date data into numeric format
#
template <- "]"
index <- grep(template,grass.data[,15])
tmp <- strsplit(grass.data[index,15],template)
grass.data[index,15] <- paste(tmp[[1]][1],tmp[[1]][2],sep = "")
rm(tmp,template,index)
#
grass.data[,15] <- as.numeric(stringr::str_sub(grass.data[,15],-5,-2))
#
# 267 NAs from missing data
# 2 NAs from (
# 1 NA from (v)
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