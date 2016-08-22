# Where are the Missing Grasses?

### *Jonathan Williams*
### *2016*

## Introduction

This repository contains the code used for the project "Where are the Missing Grasses?". This was a summer project based at the [Royal Botanic Garden Kew][1]. The aim of the project was to build on existing work such as Joppa et al 2010<sup>1</sup> and 2011<sup>3,4</sup> and Pimm et al. 2010<sup>2</sup> and to extend it to look at the problem of where we expect the gaps in our knowledge of plant species to be. Here the rate of discovery of new species is assumed to be proportional to both the number of remaining species to be discovered and the taxonomic effort at the time. In this particular project the goal was to apply this model to the grasses family (Poaceae) and to use this to try to determine where we expect the grasses currently unknown to science to be.

## Model

The base of the model is that as has been introduced and used by Joppa et al 2010<sup>1</sup>. Here the discovery of species is considered in aggregated time windows. This is to help deal with issues such as the publication of monographs which give rise to a large variation in year on year species publication. The base model uses a time window of five years when summarising the data, with 10 years being tried as a measure of validation for the model.

Within each window, the model calculates the total number of species left to be discovered for that window by subtracting the cumulative number of species published prior to that window from the theoretical total number of species to be discovered, so for window i the total number of species left to be described is given by:

![alt text][img1]

As per the original model, the taxonomic effort is then modelled as the product of the number of active taxonomists in the window and the taxonomic efficiency in that window. As per the work of Joppa et al<sup>1</sup>, this is modelled with as a linear function of the start year of the window. Thus for window i, the taxonomic effort is given by:

![alt text][img2]

The model then states that the estimate for the number of new species published in a given window i is given by:

![alt text][img3]

Thus the model is parameterised by the the coefficients of the efficiency term, and the theoretical total number of species:

![alt text][img4]

## Data

### Species Discovery

The raw data for the project were taken from a [World Checklist of Selected Plant Families (WCSP)][2]<sup>5</sup> download that was made on 5th July 2016 for the Poaceae family. From this, two unaltered comma-seperated value files were extracted, one giving the species data, and the other containing the distribution information. This is the format in which the default method will require the data to be for column references to be correct. Should the user wish to alter these column references then they should look [here][link1]















Before counting the numbers of species published in each time window the data was first filtered so as to only select those currently accepted species. To do this the WCSP species data was filtered to select only entries with accepted taxonomic status, and only entries with a listed rank of species were included (removing sub-species). Finally any hybrids at the genus and/or species level were removed to leave only natural accepted species.

The above data set was then summarised, collecting the number of species first published in each time window. Where a species didn't have a year of publication it was excluded. The cumulative number of species up to each time window were also calculated.

### Taxonomists

The number of taxonomists was calculated by taking WCSP data set and collecting the entries for each time window. In this instance the filtering of the species as per above was not used as it was deemed appropriate to keep all of the data: this representing the effort in grass taxonomy at the time. This includes authors whose work is later moved into synonomy or who were working on various sub-species and hybrids. It is however possible to set the script to apply such filters should the user desire.

For the collected data for each time winow, the primary authors are then collected. To these strings the names are split based upon commas, '&' and the specific taxonomic symbols 'in' and 'ex'. By default the string of names is split wherever a comma is found. Also the default is for the authors after the string 'in' to be included as these represent authors on the paper that published the species description, and hence were active at the time of publication (the authors before the 'in' are always included as these are the authors of the description). For the string 'ex' the authors to the right are always included (as these are the authors of the descriptions), but by default the names to the left are excluded as these represent the taxonomist to whom the name is attributed, but this can be historic and so does not necessarily represent taxonomic effort at the time. The user is able to alter these settings.

## Model Fitting

The method for fitting the model can be selected to be one of two methods inspired by the work of Joppa et al 2010<sup>1</sup> and Pimm et al 2010<sup>2</sup> (or both). Both methods fit the model parameters by minimising the sum of squared residuals. In the default method employed in the analysis of this project, here referred to as 'Regression Search', these residuals are simply the difference in each window between the estimate of new species that the model gives and the actual number of new species published. This is a measure not used by Joppa et al in any of their published work. The other method, here referred to as 'Gradient Descent Search', instead first log-transforms the model estimate and actual number of species and then calculates the difference in these log values and uses this as the residual for each data point.

As a general outline, each method tries guesses of the total number of species, and then finds the values of a and b which best fit the model for these guesses. An iterative process is then applied where the best fitting values for total species are used to decide a new round of guesses. This repeats until the convergence of the method upon a final value of S<sub>T</sub>.

Details of the fitting methods can be found in the detailed section [here][link4]


### Cross Validation

In order to test the reliability of the results from the methods above a cross-validation regime was also implemented. This works by applying a jack-knife approach and fitting the model whilst leaving out one time window at a time. The complete set of S<sub>T</sub> predictions can then be compared to the prediction made by the model on the complete data. Owing to how exhaustive this is, the method has only been implemented for the primary regression search method. However a very similar implementation could relatively easily be applied to the gradient descent search method.

### Geographical Methods

To address the question of where the gaps in our knowledge lie, the above methods were extended to predict the total number of species which exist in each geographic region of interest. This is supported at any [Taxonomic Database Working Group (TDWG)][3] level.

In this method the total number of species globally is first calculated using the regression search method. Following this, the species data is mapped to the distribution data at the desired TDWG level. The distribution data is then filtered to remove any location where there is doubt or only artifically introduced presence of the species. Each species is then classified as endogenous or not at this level. Here endogeny refers to any species that is only present in one region at the given TDWG level.

For each region, the regression search model is then used to predict the total number of endogenous species in that region (regions with fewer than a user-defined cumulative endogenous species to date are excluded as the model is unrelaible with too little data, the example being 50). The same model is then applied to the non-endogenous species.

The predictions for the regions and non-endogenous species are then collated. For regions where the model couldn't be applied, the prediction for total number of species is calculated by finding the ratio of aggregate predictions to aggregate current species recorded for the regions that succeeded and non-endogenous species. This is then used to multiply the current recorded species in these as-yet-unscored regions to get a predicted total of species.

The total number of predicted species across all regions and non-endogenous species is then computed and compared to the earlier global prediction. At this point all of the regional predictions as well as non-endogenous species are scaled by a constant ratio such that the total of the regional analysis is equal to the global total. The final results are then reported, as well as the percentage of the predicted total of species in each region that have so far been recorded. 

### Family Filtering

This repository contains two main scripts for this analysis. The main script is desgined to be used for a WCSP download where the analysis is to be applied to all species included in the data, this is designed to calculate global gaps in knowledge across all included plant data. There is an altered script that allows additional filtering of the raw download, for example, to select on certain families of interest. This script will then apply the above pipelines to each family in turn. This is designed for applying the model to specific sub-groups of interest.

## Utilising the Scripts

In order to run this repository, the user must first download a copy to their local machine.

There are two scripts in this repository which can be used to re-create the analysis described above. Both scripts will require the input of a .csv file of a download of WCSP data and a posisble extra .csv file of the distribution data from the WCSP. These files should be located a directory at the same level as the downloaded repository. That is to say you should have a structure of this form `./location/kew_grasses` with your data in a directory of the form `./location/data` or similar.

The user should then decide whether they desire a geographic breakdown, and whether they want the analysis to be on the entire dataset or if they would like it subsetted in some way. The table below shows which script to use in which case, and which csv files will be needed.

| Model Desired 		| Script 				| Required .csv 		|
|:-----------------------------:|:-------------------------------------:|:-----------------------------:|
| Global only - Entire Dataset	| `complete_pipeline_whole_dataset.r`	| Species Data only		|
| Global only - Subsets		| `complete_pipeline_filter.r`		| Species Data only		|
| Geographic - Entire Dataset 	| `complete_pipeline_whole_dataset.r`	| Species Data and Distribution	|
| Geographic - Subsets		| `complete_pipeline_filter.r`		| Species Data and Distribution	|

With knowledge of the required script and the input files in place the user should then load the script they need and edit any of the input variables as explained in the table below. Any non-essential input variables can be left as they are, but are left for the user to alter should they wish to do so.

Both scripts will create a sub-directory within the output directory for their analysis. This sub-directory will then have further sub-directories created within it. One of these will be filled with aggregated species discovery data, broken down by each time window and with an additional file for each geographic level of interest showing this breakdown by region.

Next of these will be a subdirectory created and populated with aggreagted taxonomist data. Here there will be a summary file, with a breakdown by time window. There is also a detailed breakdown file showing the names of all authors in each time window, and how many papers they authored, broken down by number of co-authors. This analysis is then repeated at each geogrpahic level where appropriate. Here there is a summary file with sregional summary data broken down by time window. There is then an additional file for each region with the full author breakdown as per the overall data analysis.

For each model that is fitted, there is also a sub-directory created. Within each of these there is a model summary file showing the key model parameters. There is then a full model file showing the estimates for each time window. There are also three plots ocmpleted. One shows the squared residuals score for the best fitting model for the initial guesses of S<sub>T</sub>. Another shows the trends in number of taxonomists and new species discovered over time, with the model fit overlaid. The final plot shows the number of species per taxonomist with the fitted model theoretical species per taxonomist overlaid. Within this directory, if appropriate, there are then subdirectories containing the same information for the models fitted for different regions.

Finally the scripts output a csv file showing the regional predictions and percentage of species seen at each geographic lebvel if appropriate, at the top level output directory.

### Essential inputs

| Input Variable 	| Default 						| Explanation |
|:---------------------:|:-----------------------------------------------------:| ----------- |		
| `setwd()`		| `"~/Kew Summer"`					| This is where the user can set the parent directory within which the "kew_grasses" directory (and .csv files (or their directory) are)|
| `dir.path`		| `"./Data/07_05/"`					| This is the location within the above directory where the .csv files are stored (can simply be "./")|
| `spec.file.name`	| `"public_checklist_flat_plant_dl_20160705_poaceae"`	| This is the name of the WCSP species data file (**NOTE**: without the .csv at the end)|
| `levels`		| `c("TDWG1",TDWG2")`					| These are the names for the geographic levels to be used in output filenames (can be any string the user desires). **For a global only model this will need to be set to `NULL`**
| `loc.file.name`	| `"Poaceae_distribution"`				| If a geographic breakdown model is desired then this needs to be the name of the WCSP distribution data file (**NOTE**: without .csv). If no geographic breakdown is desired then this can be ignored, but does not need to be altered as it will be ignored|
| `out.dir`		| `"./Output"`						| This is the location of the directory within the working directory where the output should go (in default this would mean `"~/Kew Summer/Output/"`)

#### Subsetting Essential Inputs

These are the variables that are only available in the script `complete_pipeline_whole_dataset.r` which must be set in order to allow subsetting.

| Input Variable 	| Default 						| Explanation |
|:---------------------:|:-----------------------------------------------------:| ----------- |		
| `subset.col`		| `3`							| Index of the cloumn which contains the varibale uon which the data is to be subsetted|
| `subset.mk`		| `c("Poaceae")`					|The values within `subset.col` which are ot be the basis of the subset. Requires a vector, where each element represents a distinct subset|
  
  
### Optional Inputs

These are the remaining input variables in both scripts which the user if free to alter to adapt the method to their needs.

#### Model Options and Output Locations

| Input Variable 	| Default 						| Explanation |
|:---------------------:|:-----------------------------------------------------:| ----------- |	
| `global.CV`		| `FALSE`						| When set to `TRUE` this will run the cross-validation regime on the complete data set (or on each subset in complete_pipeline_filter.r)	|
| `region.CV`		| `FALSE`						| When set to `TRUE` this will run the cross-validation regime on each valid region (within each subset in complete_pipeline_filter.r)	|
| `global.grad`		| `FALSE`						| When set to `TRUE` this will run the gradient descent search method on the complete data set (or on each subset in complete_pipeline_filter.r)	|
| `region.grad`		| `FALSE`						| When set to `TRUE` this will run the gradient descent search method on each valid region (within each subset in complete_pipeline_filter.r) **WARNING: This will be very slow**|
| `spec.dir`		| `"species_data"`					| Name for the sub-directory within the output directory in which the aggregated species data will go|
| `tax.dir`		| `"taxon_data"`						| Name for the sub-directory within the output directory in which the aggregated taxonomist data will go|
| `reg.dir`		| `"regression_search"`					| Name for the sub-directory within the output directory in which the regression search results will go|
| `regcv.dir`		| `"regression_search_cross_validation"`		| Name for the sub-directory within the output directory in which the regression search cross validation results will go (if selected)|
| `log.dir`		| `"grad_descent_search_log_residuals"`			| Name for the sub-directory within the output directory in which the gradient descent search results will go (if selected)|

#### Indices in the Data Files

| Input Variable 	| Default 	| Explanation				|
|:---------------------:|:-------------:| ------------------------------------- |
| `loc.ind`		| `c(4,6)`	| If a geographic model is being applied then this is where the indices of the columns for each geographic level need to be supplied. Each column should refer to each level set via `levels`, in the same order|
| `n.spec`		| `50`		| For geographic models this is the minimum number of total species recorded to date required in a given region in order for the model to be applied|

#### Author Name Processing

| Input Variable 	| Default 	| Explanation				|
|:---------------------:|:-------------:| ------------------------------------- |
| `comma`		| `TRUE`	| If set to `TRUE` then the string of author names will be split on the string `','`|
| `in.tag`		| `TRUE`	| If set to `TRUE` then the string of author names will be split on the string `'in'`|
| `in.inc`		| `TRUE`	| If set to `TRUE` then names to the right of the string `'in'` will be included|
| `ex.tag`		| `TRUE`	| If set to `TRUE` then the string of author names will be split on the stirng `'ex'`|
| `ex.inc`		| `FALSE`	| If set to `TRUE` then names to the left of the string `'ex'` will be included| 

#### Data Filtering

| Input Variable 	| Default 		| Explanation			|
|:---------------------:|:---------------------:| ----------------------------- |
| `filt.ind`		| `c(11,12,13,14,15)`	| When using a geogrpahic model this allows filtering of the distribution dataset to remove data for regions where the species is doubtful, or has been introduced. Here the user sets the indices of the columns where filtering is to be applied|
| `filt.mk`		| `c(1,1,1,1,1)`	| Set the content for each column in `filt.ind` which is to be removed. If more than one mark is to be filtered in a given column, then enter that index twice in `filt.ind` and enter the two marks in the corresponding locations in `filt.mk`|
| `spe.tax.stat`	| `TRUE`		| If set to `TRUE` then the species dataset is filtered based on taxonomic status for creating the aggregated species data|
| `tx.tax.stat`		| `FALSE`		| If set to `TRUE` then the species dataset is filtered based on taxonomic status for creating the aggregated taxonomist data|
| `spe.hyb.stat`	| `TRUE`		| If set to `TRUE` then the species dataset is filtered based on hybrid status for creating the aggregated species data|
| `tx.hyb.stat`		| `FALSE`		| If set to `TRUE` then the species dataset is filtered based on hybrid status for creating the aggregated taxonomist data|
| `spe.rnk.stat`	| `TRUE`		| If set to `TRUE` then the species dataset is filtered based on taxonomic rnak for creating the aggregated species data|
| `tx.rnk.stat`		| `FALSE`		| If set to `TRUE` then the species dataset is filtered based on taxonomic rank for creating the aggregated taxonomist data|

#### Model Parameters

| Input Variable 	| Default 	| Explanation				|
|:---------------------:|:-------------:| ------------------------------------- |
| `st.yr`		| `1766`	| This is the year from which the analysis should start|
| `en.yr`		| `2015`	| This is the year at which the analysis should end|
| `int.yr`		| `5`		| This is the number of year to be considered in each window|


## Technical Information

The code presented here was prepared in R studio using R version `3.2.3` in a Windows architecture, with 64-bit operating system. The following packages and version were used:

* `dplyr 0.4.3` 
* `stringr 1.0.0`
* `reshape 0.8.5`
* `gplot2 2.0.0`


## References
1. [**How many specues of flowering plants are there?**][4] Lucas N. Joppa, David L. Roberts, Stuart L. Pimm; Proc. R. Soc. B 2010 -; DOI: 10.1098/rspb.2010.1004. Published 7 July 2010 
2. [**How many endangered species remian to be discovered in Brazil?**][5] Pimm, SL; Jenkins, CN; Joppa, LN; Roberts, DL; Russell, GJ; Natureza a Conservacao 2010; DOI: 10.4322/natcon.00801011
3. [**Biodiversity hotspots house most undiscovered plant species**][6] Lucas N. Joppa, David L. Roberts, Norman Myers, and Stuart L. Pimm; PNAS 2011 108 (32) 13171-13176; published ahead of print July 5, 2011, doi:10.1073/pnas.1109389108
4. [**The population ecology and social behaviour of taxonomists**][7] Lucas N. Joppa, David L. Roberts and Stuart L. Pimm; Trends in Ecology & Evolution 26, 551–553; doi:10.1016/j.tree.2011.07.010
5. W.D. Clayton, R. Govaerts, K.T. Harman, H. Williamson & M. Vorontsova (2016). World Checklist of Poaceae. Facilitated by the Royal Botanic Gardens, Kew. Published on the Internet; http://apps.kew.org/wcsp/ Retrieved 2016-07-05

[1]: http://www.kew.org/
[2]: http://apps.kew.org/wcsp/
[3]: http://www.tdwg.org/
[4]: http://rspb.royalsocietypublishing.org/content/early/2010/07/07/rspb.2010.1004#fn-group-1
[5]: http://doi.editoracubo.com.br/10.4322/natcon.00801011
[6]: http://www.pnas.org/content/108/32/13171.full
[7]: http://www.sciencedirect.com/science/article/pii/S0169534711002084

[link1]: https://github.com/jonvw28/kew_grasses/tree/master/Documents/indices.md
[link2]: https://github.com/jonvw28/kew_grasses/tree/master/Documents/data_methods.md
[link4]: https://github.com/jonvw28/kew_grasses/tree/master/Documents/model_fitting.md

[img1]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img1.jpg "Species Left to be Discovered"
[img2]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img2.jpg "Taxonomiic Effort"
[img3]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img3.jpg "Estimate of Species Described"
[img4]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img4.jpg "Model Parameters"
