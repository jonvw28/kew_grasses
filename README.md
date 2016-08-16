# Where are the Missing Grasses?

### *Jonathan Williams*
### *2016*

## Introduction

This repository contains the code used for the project "Where are the Missing Grasses?". This was a summer project based at the [Royal Botanic Garden Kew][1]. The aim of the project was to build on existing work such as Joppa et al 2010<sup>1,2</sup> and 2011<sup>3,4</sup> and extend it to look at the problem of where we expect the gaps in our knowledge of plant species to be. Here the rate of discovery of new species is assumed to be proportional to both the number of remaining species to be discovered and the taxonomic effort at the time. In this particular project the goal was to apply this model to the grasses family (Poaceae) and to use this to try to determine where we expect the grasses currently unknown to science to be.

## Model

The base of the model is that as has been introduced and used by Joppa et al 2010<sup>1</sup>. Here the discovery of species is considered in aggregated time windows. This is to help deal with issues such as the publication of monographs which give rise to a large variation in year on year species publication. The base model uses a time window of five years when summarising the data, with 10 years being tried as a measure of validation for the model.

Within each window, the model calculates the total number of species left to be discovered for that window by subtracting the cumulative number of species published prior to that window from the theoretical total number of species to be discovered, so for window i the total number of species left to be described is given by:

![alt text][img1]

As per the original model, the taxonomic effort is then modelled as the product of the number of active taxonomists in the window and the taxonomic efficiency in that window. As per the work of Joppa<sup>1</sup>, this is modelled with as a linear function of the start year of the window. Thus for window i, the taxonomic effort is given by:

![alt text][img2]

The model then states that the estimate for the number of new species published in a given window i is given by:

![alt text][img3]

Thus the model is parameterised by the the coefficients of the efficieny term, and the theoretical total number of species:

![alt text][img4]

## Data

### Species Discovery

The raw data for the project were taken from a [World Checklist of Selected Plant Families (WCSP)][2]<sup>5</sup> download that was made on 5th July 2016 for the Poaceae family. From this, two unaltered comma-seperated value files were extracted, one giving the species data, and the other containing the distribution information.

Before counting the numbers of species published in each time window the data was first filtered so as to only select those currently accepted species. To do this the WCSP species data was filtered to select only entries with accepted taxonomic status, and only entries with a listed rank of species were also included (removing sub-species). Finally any hybrids at the genus and/or species level were removed to leave only natural accpeted species.

The above data set was then summarised, collecting the number of species first published in each time window. Where a species didn't have a year of publication it was excluded. The cumulative number of species up to each time window were also calculated.

### Taxonomists

The number of taxonomists was calculated by taking WCSP data set and collecting the entries for each time window. In this instance the filtering of the species as per above was not used as it was deemed appropriate to keep all of the data as this represents the effort in grass taxonomy at the time. This includes authors whose work is later moved into synonomy or working on various sub-species and hybrids. In general, these authors still represent taxonomic effort at the time. It is however possible to set the script to apply such filters should the user desire.

For the collected data for each time winow, the primary authors are then collected. To these strings the names are split based upon commas, & and the specific taxonomic symbols in and ex. By default the authors after the string 'in' are included as these represent authors on the paper that published the species description, and hence were active at the time of publication (the authors before the 'in' are always included as these are the authors of the description). For the string 'ex' the authors to the right are always included (as these are the authors of the descriptions), but by default the names to the left are excluded as these represent the taxonomist to whom the name is attributed, but this can be historic and so does not necessarily represent taxonomic effort at the time.

## Model Fitting

The method for fitting the model can be selected to be one of two methods inspired by the work of Joppa et al 2010<sup>1,2</sup> (or both). Both methods fit the model parameters by minimising the sum of squared residuals. In the default method employed in the analysis of this project, here referred to as 'Regression Search', these residuals are simply the difference in each window between the estimate of new species that the model gives and the actual number of new species published. This is a measure not used by Joppa et al in any of their published work. The other method, here referred to as 'Gradient Descent Search', instead first log-transforms the model estimate and actual number of species and then calculates the difference in these log values and uses this as the residual for each data point.









### Regression Search

In this method the model is fitted by minimising the sum of the square of residuals given by comparing the model predictions with the actual number of new species discovered in each window. This is a departure from the method employed by Joppa et al as it does not first log transform the estimate and actual species discovered before comparing their difference and using this as a residual. In comparisons, the log transformed method does not appear to create huge relative differences in most instances. However, as will be outlined below, the convergence of this regular residuals model is far quicker and so is the base model for the analysis in this project.




1. Flowering Plants
2. Brazil
3. Hotspots
4. Taxonomists
5. WCSP

[1]: http://www.kew.org
[2]: http://apps.kew.org/wcsp/

[img1]: https://github.com/jonvw28/kew_grasses/Figures/blob/master/Figures/img1.jpg "Species Left to be Discovered"
[img2]: https://github.com/jonvw28/kew_grasses/Figures/blob/master/Figures/img2.jpg "Taxonomiic Effort"
[img3]: https://github.com/jonvw28/kew_grasses/Figures/blob/master/Figures/img3.jpg "Estimate of Species Described"
[img4]: https://github.com/jonvw28/kew_grasses/Figures/blob/master/Figures/img4.jpg "Model Parameters"