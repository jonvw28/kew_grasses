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

Thus the model is parameterised by the the coefficients of the efficiency term, and the theoretical total number of species:

![alt text][img4]

## Data

### Species Discovery

The raw data for the project were taken from a [World Checklist of Selected Plant Families (WCSP)][2]<sup>5</sup> download that was made on 5th July 2016 for the Poaceae family. From this, two unaltered comma-seperated value files were extracted, one giving the species data, and the other containing the distribution information.

Before counting the numbers of species published in each time window the data was first filtered so as to only select those currently accepted species. To do this the WCSP species data was filtered to select only entries with accepted taxonomic status, and only entries with a listed rank of species were also included (removing sub-species). Finally any hybrids at the genus and/or species level were removed to leave only natural accpeted species.

The above data set was then summarised, collecting the number of species first published in each time window. Where a species didn't have a year of publication it was excluded. The cumulative number of species up to each time window were also calculated.

### Taxonomists

The number of taxonomists was calculated by taking WCSP data set and collecting the entries for each time window. In this instance the filtering of the species as per above was not used as it was deemed appropriate to keep all of the data as this represents the effort in grass taxonomy at the time. This includes authors whose work is later moved into synonomy or working on various sub-species and hybrids. In general, these authors still represent taxonomic effort at the time. It is however possible to set the script to apply such filters should the user desire.

For the collected data for each time winow, the primary authors are then collected. To these strings the names are split based upon commas, & and the specific taxonomic symbols in and ex. By default the string of names is split wherever a comma is found. Also the default is for the authors after the string 'in' are included as these represent authors on the paper that published the species description, and hence were active at the time of publication (the authors before the 'in' are always included as these are the authors of the description). For the string 'ex' the authors to the right are always included (as these are the authors of the descriptions), but by default the names to the left are excluded as these represent the taxonomist to whom the name is attributed, but this can be historic and so does not necessarily represent taxonomic effort at the time. The user is able to change whether there is splitting based on commas, in and ex and whether the above described names are included or not.

## Model Fitting

The method for fitting the model can be selected to be one of two methods inspired by the work of Joppa et al 2010<sup>1,2</sup> (or both). Both methods fit the model parameters by minimising the sum of squared residuals. In the default method employed in the analysis of this project, here referred to as 'Regression Search', these residuals are simply the difference in each window between the estimate of new species that the model gives and the actual number of new species published. This is a measure not used by Joppa et al in any of their published work. The other method, here referred to as 'Gradient Descent Search', instead first log-transforms the model estimate and actual number of species and then calculates the difference in these log values and uses this as the residual for each data point.

Both methods employ an optimization algorithm analogous to that described in Joppa et al 2010<sup>2</sup>. Here the algorithm starts with guesses for the total number of species, and then finds the values of a and b that give the best fitting model for this value of S<sub>T</sub>. The best fitting values of S<sub>T</sub> are then used as to select new possible guesses and the process is repeated. This process is applied iteratively until a final value of S<sub>T</sub> is found.

In both methods the number of guesses per iteration is set by the user, the example being using 500. For the first iteration, the range of guesses is equally spaced between the current number of species published and a user-defined multiple of this number. The defualt multiple is 3. 

Once the methods have found the best fitting a and b for each guess of S<sub>T</sub>, the set of scores for each model is considered, and the models are ranked. From this the top models are selected. The proportion of models selected in each iteration is set by the user, the example default being 0.2. The range of values of S<sub>T</sub> for the selected models is then extended about its midpoint by a factor set by the user. The example default is 1.5, this would result in a range 150% the length of the original range with the same midpoint. The guesses for the next iteration are then equally spaced amongst this range. 

The strecthing of the range at each iteration is applied to allow a greater searching of the parameter space. Should the lower end of the range of new guesses fall below the current number of species recorded, then this current level is used as the lower bound instead. In such a case the guesses are equally spaced between this lower bound and the upper end of the range.

This algorithm is applied iteratively until the range of guesses of S<sub>T</sub> is less than 0.5 in which case the final value reported will be selected to be the best scoring one. This should ensure that the reported best-fitting value of S<sub>T</sub> will be reported to the accuracy of the nearest whole number. The user must also define a maximum number of iterations for the the algorithm to ensure it terminates if it does not converge. The default example is 20 iterations, and a message will be displayed should this maximum be reached.

The details of how each method optimises the values of a and b in each model is outlined below

### Regression Search

In the regression search method, the conventional residuals are being used. As such, the following expression relates the actual number of species described to the model estimate for each window. The residual term is the rightmost term and it is the sum of the squares of these which the algorithm minimises.

![alt text][img5]

This equation can however be readily arranged to give a linear equation for a and b as is shown below:

![alt text][img6]

This equation can then be used to find a and b directly via linear regression in a manner similar to that used for the log-transform method in Joppa et al 2010<sup>2</sup>. with the residuals e<sub>i</sub> as given below:

![alt text][img7]

In this case the residuals need to be given appropriate weightings in the linear model to ensure that the effective sum of squares being minimised is equivalanet to the overall residuals being minimised in the first equation in this section. Hence in the linear regression to find a and b the weighted least squares is used as below:

![alt text][img8]

![alt text][img9]

By using the built in R function `lm` this process can be applied very efficiently and hence this method is computationally much faster than the gradient descent search outlined below. It is for this efficiency that this method is the default method used in the anaylsis in this project.

### Gradient Descent Search

In order to determine whether the regression search method above produces results that could be compared to the method proposed by Joppa et al 2010<sup>1</sup> in which the residuals are taken as the difference between the logarithms of the model estiamte and actual number of species in each time window it was sought to develop an optimisation method that could fit such a model. Joppa et al suggest three such methods to fit the model as outlined below:

![alt text][img10]

The first of these from 2010<sup>1</sup> uses grid search and gradient descent. This method will find minima of the problem, but is also very inefficient. The second method proposed is also from 2010<sup>2</sup>, and proposes a method very similar to the regression search method outlined here. This involves guessing S<sub>T</sub> and using linear regression to find a and b from re-arrangement. However, when fully evaulated from the above the expression below results.

![alt text][img11]

Even when weightings are applied, the effective residual term still contains an exponential of the residual to be considered in minimising the overall model. As such a normal linear regression of the type in the regression search model for a and b is not equivalent to minimising the overall model with respect to a and b (when considering a case with S<sub>T</sub> fixed). As such this method is rejected as being unable to correctly identify the minimising values of a and b.

The final method proposed by Joppa et al in 2011<sup>3</sup> involves introducing an extra spread parameter and then using a maximum-likelihood estimation method by assuming the residuals are normally distributed. Whilst this method has its merits, it was decided not to replicate the method. This method enables the computation of confidence intervals, but this requires the assumption that the residuals are normally distributed. Not only this, but this model also introduces a spread parameter in order to facilitate this. The model is then optimized with respect to this parameter as well as a, b and S<sub>T</sub>. Given this parameter does not have a direct interpretation in terms of the data there is a risk that such a model will result in overfitting. 

Recall, the final goal of this project is to aid the study of taxonomy and give an idea of the gaps in our knowledge and not to try to precisely predict exact species numbers. In particular, species discovery is an inherently complex process with many confounding factors. Additionally the data set, whilst very detialed, naturally comes with the caveats and limitations of a dataset based on over 250 years of work. As such it was decided to proceed with a parsimonious method, keeping the focus on exploring the data and various filters and thereby reducing the danger of overfitting. As such the first method of gradient descent as outlined above was chosen to address the issue of the logarithmic difference residuals.

### Geographical Methods

### Method Comparison

## Cross Validation

## Utlisiing the Scripts

## References

1. Flowering Plants
2. Brazil
3. Hotspots
4. Taxonomists
5. WCSP

[1]: http://www.kew.org
[2]: http://apps.kew.org/wcsp/

[img1]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img1.jpg "Species Left to be Discovered"
[img2]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img2.jpg "Taxonomiic Effort"
[img3]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img3.jpg "Estimate of Species Described"
[img4]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img4.jpg "Model Parameters"
[img5]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img5.jpg "Regression Search Model"
[img6]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img6.jpg "Regression Search equation"
[img7]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img7.jpg "Regression Search residuals"
[img8]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img8.jpg "Regression Search Least Squares"
[img9]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img9.jpg "Regression Search residual Weightings"
[img10]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img10.jpg "Gradient Descent Search residuals"
[img11]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img11.jpg "Gradient Descent Search residuals"