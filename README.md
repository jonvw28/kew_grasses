# Where are the Missing Grasses?

### *Jonathan Williams*
### *2016*

## Introduction

This repository contains the code used for the project "Where are the Missing Grasses?". This was a summer project based at the [Royal Botanic Garden Kew][1]. The aim of the project was to build on existing work such as Joppa et al 2010<sup>1</sup> and 2011<sup>3,4</sup> and Pimm et al. 2010<sup>2</sup> and to extend it to look at the problem of where we expect the gaps in our knowledge of plant species to be. Here the rate of discovery of new species is assumed to be proportional to both the number of remaining species to be discovered and the taxonomic effort at the time. In this particular project the goal was to apply this model to the grasses family (Poaceae) and to use this to try to determine where we expect the grasses currently unknown to science to be.

Within this repository there is also a script to facilitate the comparison of taxonomic effort to global scientific effort. This can be found in the [subdirectory here][link7]. This enables the user to analyse the issue of whether taxonomy is a science keeping up with other disciplines.

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

Before counting the numbers of species published in each time window the data is first filtered. To do this the user can select one of 7 methods. The default is to accept all names. Full details of the different methods that can be set are laid out [here][link2]

The data is then summarised into time windows as set by the user. Where the year of publication for a name is missing, it is excluded.

### Taxonomists

The number of taxonomists active in each time window is calculated by taking the primary authors on names published in each window. The names which are used to calculate this are filtered by using the methods as outlined [here][link2].

For each plant name, the primary authors are given as a string. In order to count the number of authors this string is split into the individual author names. The splits occur on the string `"&"` and optionally on the strings `","`, `"in"` and `"ex"`. The full details of this splitting can be seen [here][link3]. The number of authors is then counted in a method similar to that used by Joppa et al 2011<sup>4</sup>. 

## Model Fitting

The method for fitting the model can be selected to be one of two methods inspired by the work of Joppa et al 2010<sup>1</sup> and Pimm et al 2010<sup>2</sup> (or both). Both methods fit the model parameters by minimising the sum of squared residuals. In the default method employed in the analysis of this project, here referred to as 'Regression Search', these residuals are simply the difference in each window between the estimate of new species that the model gives and the actual number of new species published. This is a measure not used by Joppa et al in any of their published work. The other method, here referred to as 'Gradient Descent Search', instead first log-transforms the model estimate and actual number of species and then calculates the difference in these log values and uses this as the residual for each data point.

As a general outline, each method tries guesses of the total number of species, and then finds the values of a and b which best fit the model for these guesses. An iterative process is then applied where the best fitting values for total species are used to decide a new round of guesses. This repeats until the convergence of the method upon a final value of S<sub>T</sub>.

Details of the fitting methods can be found in the detailed section [here][link4]

### Cross Validation

In order to test the reliability of the results from the methods above a cross-validation regime was also implemented. This works by applying a jack-knife approach and fitting the model whilst leaving out one time window at a time. The complete set of S<sub>T</sub> predictions can then be compared to the prediction made by the model on the complete data. Owing to how exhaustive this is, the method has only been implemented for the primary regression search method. However a very similar implementation could relatively easily be applied to the gradient descent search method.

### Family Filtering

It is also possible to subset the dataset before applying the model to select certain families of interest. This script will then apply the above pipelines to each family in turn. This is designed for applying the model to specific sub-groups of interest and can be set in the global options below.

## Geographical Methods

To address the question of where the gaps in our knowledge lie, the above methods were extended to predict the total number of species which exist in each geographic region of interest. This is supported at any [Taxonomic Database Working Group (TDWG)][3] level.

The output will be a summary of the number of species predicted in each region as well as a comparison with the current number of species descibed in each region. For full details of how the method works see [here][link5]

## Utilising the Scripts

In order to run this repository, the user must first download a copy to their local machine.

The script will require the input of a .csv file of a download of WCSP data and a posisble extra .csv file of the distribution data from the WCSP. These files should be located in a directory at the same level as the downloaded repository. That is to say you should have a structure of this form `./location/kew_grasses` with your data in a directory of the form `./location/data` or similar.

To run the pipeline, a user should then open the script `RunMe.R`. First the user must set the working directory to the location where the download was made. To use the above example, this will be `"./location"` and set the variables as per the table below. The script can then be run and will output the results of the run to the output folder as set in `RunMe.R` If the user wishes to see more about this structure they can do so [here][link6].

Furthermore, any other alterations to the methods can be set per the instructions in the below:

* [Indices in Data][link1]
* [Data Processing Methods][link2]
* [Name Processing][link3]
* [Model Fitting][link4]
* [Geographic Models][link5]
* [Output Structure][link6]

The variables in the `RunMe.R` file are explained below:

###Locations

| Input Variable 	| Default 						| Explanation |
|:---------------------:|:-----------------------------------------------------:| ----------- |
| `dir.path`		| `"./Data/07_05/"`					| This is the location within the working directory where the .csv files are stored (can simply be "./")|
| `spec.file.name`	| `"public_checklist_flat_plant_dl_20160705_poaceae"`	| This is the name of the WCSP species data file (**NOTE**: without the .csv at the end)|
| `loc.file.name`	| `"Poaceae_distribution"`				| If a geographic breakdown model is desired then this needs to be the name of the WCSP distribution data file (**NOTE**: without .csv). If no geographic breakdown is desired then this can be ignored, but does not need to be altered as it will be ignored|
| `output.location`	| `"./Output"`						| This is the location of the directory within the working directory where the output should go (in default this would mean `"~/Kew Summer/Output/"`)
| `identifier`		| `"grass"`						| This is a string that the user sets to be used in all of the output file names to help identify each model run|

### Time Window Settings

| Input Variable 	| Default 	| Explanation				|
|:---------------------:|:-------------:| ------------------------------------- |
| `st.yr`		| `1766`	| This is the year from which the analysis should start|
| `en.yr`		| `2015`	| This is the year at which the analysis should end|
| `int.yr`		| `5`		| This is the number of year to be considered in each window|
| `rolling.windows`	| `FALSE`	| If set to `TRUE` then the model will use sliding windows with an offset as set below|
| `offset`		| `3`		| This is the number of years for each sliding window to be offset|

### Data Summarising Methods

| Input Variable 	| Default 	| Explanation				|
|:---------------------:|:-------------:| ------------------------------------- |
| `species.method`	| `all`		| This can be set to any of the methods laid out [here][link2] depending on the needs of the user|
| `taxonomist.method`	| `all`		| This can be set to any of the methods laid out [here][link2] depending on the needs of the user|

### Options for Subsetting

| Input Variable 	| Default 						| Explanation |
|:---------------------:|:-----------------------------------------------------:| ----------- |	
| `subsetting`		| `FALSE`						| If set to `TRUE` then the data subsetting will used, as described above|
| `subset.col`		| `3`							| Index of the column which contains the varibale upon which the data is to be subsetted|
| `subset.mk`		| `c("Poaceae")`					|The values within `subset.col` which are ot be the basis of the subset. Requires a vector, where each element represents a distinct subset|

### Model Options

| Input Variable 	| Default 						| Explanation |
|:---------------------:|:-----------------------------------------------------:| ----------- |
| `gradient.descent`	| `FALSE`						| When set to `TRUE` this will run the gradient descent search algorithm on the complete data set (or on each subset)	|
| `cross.validation`	| `FALSE`						| When set to `TRUE` this will run the cross-validation regime on the complete datset (or on each subset)	|

### Geographical Model

| Input Variable 	| Default 						| Explanation |
|:---------------------:|:-----------------------------------------------------:| ----------- |
| `geo.model`		| `FALSE`						| When set to `TRUE` this will fit geographical models with the settings as per [here][link5]	|
| `geo.gradient.descent`| `FALSE`						| When set to `TRUE` this will run the gradient descent search algorithm on each valid region (or on each region in each subset)	|
| `geo.cross.validation`| `FALSE`						| When set to `TRUE` this will run the cross-validation regime on each valid region (or on each region in each subset)	|



## Technical Information

The code presented here was prepared in R studio using R version `3.2.3` in a Windows architecture, with 64-bit operating system. The following packages and version were used:

* `dplyr 0.4.3` 
* `stringr 1.0.0`
* `reshape 0.8.5`
* `gplot2 2.0.0`

## Acknowledgements

I would like to thank Maria Vorontsova and Eimear Nic Lughadha for arranging the project and for offering continued support throught out. I'd also like to thank Antonio Remiro for his very helpful teamwork and for continuing the project as my time at kew came to an end.


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
[link3]: https://github.com/jonvw28/kew_grasses/tree/master/Documents/name_splitting.md
[link4]: https://github.com/jonvw28/kew_grasses/tree/master/Documents/model_fitting.md
[link5]: https://github.com/jonvw28/kew_grasses/tree/master/Documents/geographic_model.md
[link6]: https://github.com/jonvw28/kew_grasses/tree/master/Documents/outputs.md
[link7]:  https://github.com/jonvw28/kew_grasses/tree/master/Taxonomic_effort_comparison/ReadMe.md

[img1]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img1.jpg "Species Left to be Discovered"
[img2]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img2.jpg "Taxonomiic Effort"
[img3]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img3.jpg "Estimate of Species Described"
[img4]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img4.jpg "Model Parameters"