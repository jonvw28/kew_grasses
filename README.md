# Where are the Missing Grasses?

### *Jonathan Williams*
### *2016*

## Introduction

This repository contains the code used for the project "Where are the Missing Grasses?". This was a summer project based at the [Royal Botanic Garden Kew][1]. The aim of the project was to build on existing work such as Joppa et al 2010<sup>1,2</sup> and 2011<sup>3,4</sup> and to extend it to look at the problem of where we expect the gaps in our knowledge of plant species to be. Here the rate of discovery of new species is assumed to be proportional to both the number of remaining species to be discovered and the taxonomic effort at the time. In this particular project the goal was to apply this model to the grasses family (Poaceae) and to use this to try to determine where we expect the grasses currently unknown to science to be.

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

The raw data for the project were taken from a [World Checklist of Selected Plant Families (WCSP)][2]<sup>5</sup> download that was made on 5th July 2016 for the Poaceae family. From this, two unaltered comma-seperated value files were extracted, one giving the species data, and the other containing the distribution information.

Before counting the numbers of species published in each time window the data was first filtered so as to only select those currently accepted species. To do this the WCSP species data was filtered to select only entries with accepted taxonomic status, and only entries with a listed rank of species were included (removing sub-species). Finally any hybrids at the genus and/or species level were removed to leave only natural accepted species.

The above data set was then summarised, collecting the number of species first published in each time window. Where a species didn't have a year of publication it was excluded. The cumulative number of species up to each time window were also calculated.

### Taxonomists

The number of taxonomists was calculated by taking WCSP data set and collecting the entries for each time window. In this instance the filtering of the species as per above was not used as it was deemed appropriate to keep all of the data: this representing the effort in grass taxonomy at the time. This includes authors whose work is later moved into synonomy or who were working on various sub-species and hybrids. It is however possible to set the script to apply such filters should the user desire.

For the collected data for each time winow, the primary authors are then collected. To these strings the names are split based upon commas, '&' and the specific taxonomic symbols 'in' and 'ex'. By default the string of names is split wherever a comma is found. Also the default is for the authors after the string 'in' to be included as these represent authors on the paper that published the species description, and hence were active at the time of publication (the authors before the 'in' are always included as these are the authors of the description). For the string 'ex' the authors to the right are always included (as these are the authors of the descriptions), but by default the names to the left are excluded as these represent the taxonomist to whom the name is attributed, but this can be historic and so does not necessarily represent taxonomic effort at the time. The user is able to alter these settings.

## Model Fitting

The method for fitting the model can be selected to be one of two methods inspired by the work of Joppa et al 2010<sup>1,2</sup> (or both). Both methods fit the model parameters by minimising the sum of squared residuals. In the default method employed in the analysis of this project, here referred to as 'Regression Search', these residuals are simply the difference in each window between the estimate of new species that the model gives and the actual number of new species published. This is a measure not used by Joppa et al in any of their published work. The other method, here referred to as 'Gradient Descent Search', instead first log-transforms the model estimate and actual number of species and then calculates the difference in these log values and uses this as the residual for each data point.

Both methods employ an optimization algorithm analogous to that described in Joppa et al 2010<sup>2</sup>. Here the algorithm starts with guesses for the total number of species, and then finds the values of a and b that give the best fitting model for this value of S<sub>T</sub>. The best fitting values of S<sub>T</sub> are then used to select new possible guesses and the process is repeated. This process is applied iteratively until a final value of S<sub>T</sub> is found.

In both methods the number of guesses per iteration is set by the user, the example being using 500. For the first iteration, the range of guesses is equally spaced between the current number of species published and a user-defined multiple of this number. The defualt multiple is 3. 

Once the methods have found the best fitting a and b for each guess of S<sub>T</sub>, the set of scores for each model is considered, and the models are ranked. From this the top models are selected. The proportion of models selected in each iteration is set by the user, the example default being 0.2. The range of values of S<sub>T</sub> for the selected models is then extended about its midpoint by a factor set by the user. The example default is 1.5 and this would result in a range 150% the length of the original range with the same midpoint. The guesses for the next iteration are then equally spaced amongst this range. 

The strecthing of the range at each iteration is applied to allow a greater searching of the parameter space. Should the lower end of the range of new guesses fall below the current number of species recorded, then this current level is used as the lower bound instead. In such a case the guesses are equally spaced between this lower bound and the upper end of the range.

This algorithm is applied iteratively until the range of guesses of S<sub>T</sub> is less than 0.5 in which case the final value reported will be selected to be the best scoring one. This should ensure that the reported best-fitting value of S<sub>T</sub> will be reported to the accuracy of the nearest whole number. The user must also define a maximum number of iterations for the the algorithm to ensure it terminates if it does not converge. The default example is 20 iterations, and a message will be displayed should this maximum be reached.

The details of how each method optimises the values of a and b in each model is outlined below

### Regression Search

In the regression search method, the conventional residuals are being used. As such, the following expression relates the actual number of species described to the model estimate for each window. The residual term is the right-most term and it is the sum of the squares of these which the algorithm minimises.

![alt text][img5]

This equation can however be readily arranged to give a linear equation for a and b as is shown below:

![alt text][img6]

This equation can then be used to find a and b directly via linear regression in a manner similar to that used for the log-transform method in Joppa et al 2010<sup>2</sup>. with the residuals e<sub>i</sub> as given below:

![alt text][img7]

In this case the residuals need to be given appropriate weightings in the linear model to ensure that the effective sum of squares being minimised is equivalanet to the overall sum of squared residuals being minimised in the first equation in this section. Hence in the linear regression to find a and b the weighted least squares is used as below:

![alt text][img8]

![alt text][img9]

By using the built in R function `lm` this process can be applied very efficiently and hence this method is computationally much faster than the gradient descent search outlined below. It is for this efficiency that this method is the default method used in the anaylsis in this project.

### Gradient Descent Search

#### Motivation

In order to determine whether the regression search method above produces results that could be compared to the method proposed by Joppa et al 2010<sup>1</sup> in which the residuals are taken as the difference between the logarithms of the model estimate and actual number of species in each time window it was sought to develop an optimisation method that could fit such a model. Joppa et al suggest three such methods to fit the model as outlined below:

![alt text][img10]

The first of these from 2010<sup>1</sup> uses grid search and gradient descent. This method will find minima of the problem, but is also very inefficient. The second method proposed is also from 2010<sup>2</sup>, and proposes a method very similar to the regression search method outlined here. This involves guessing S<sub>T</sub> and using linear regression to find a and b from re-arrangement. However, when fully evaulated from the above the expression below results.

![alt text][img11]

Even when weightings are applied, the effective residual term still contains an exponential of the residual to be considered in minimising the overall model. As such a normal linear regression of the type in the regression search model for a and b is not equivalent to minimising the overall model with respect to a and b (when considering a case with S<sub>T</sub> fixed). As such this method is rejected as being unable to correctly identify the minimising values of a and b.

The final method proposed by Joppa et al in 2011<sup>3</sup> involves introducing an extra spread parameter and then using a maximum-likelihood estimation method by assuming the residuals are normally distributed. Whilst this method has its merits, it was decided not to replicate the method. This method enables the computation of confidence intervals, but this requires the assumption that the residuals are normally distributed. Not only this, but this model also introduces a spread parameter in order to facilitate this. The model is then optimized with respect to this parameter as well as a, b and S<sub>T</sub>. Given this parameter does not have a direct interpretation in terms of the data there is a risk that such a model will result in overfitting. 

Recall, the final goal of this project is to aid the study of taxonomy and give an idea of the gaps in our knowledge and not to try to precisely predict exact species numbers. In particular, species discovery is an inherently complex process with many confounding factors. Additionally the data set, whilst very detailed, naturally comes with the caveats and limitations of a dataset based on over 250 years of work. As such it was decided to proceed with a parsimonious method, keeping the focus on exploring the data and various filters and thereby reducing the danger of overfitting. As such the first method of gradient descent as outlined above was chosen to address the issue of the logarithmic difference residuals.

#### Methodology

Owing the large differences in magnitude between the parameters a, b and S<sub>T</sub> it was decided not to use tehe method of steepest descent for all 3 parameters simultaneously (as per Joppa et al 2010<sup>1</sup>). This was because a small change in a or b had a much more drastic change than an equivalent change in S<sub>T</sub>. Instead, the gradient descent search method here developed works in the same way as the regression search method, only where the linear regression is used to find a and b for each guess of S<sub>T</sub>, this method instead uses steepest descent to find a and b, with S<sub>T</sub> fixed.

The method of steepest descent starts from a guess of the parameters, and then by following the direction of steepest gradient of the least-squares function with respect to the parameters it takes a step towards a guess that reduces the error. In order to facilitate faster descent, scaling of the model variables is recommended, and this is included in the implementation presented here, with scaling to apply to taxonomist and species numbers set by the user (year is automatically scaled).

To further support rapid convergence, for each guess of S<sub>T</sub> in the gradient descent search method, a grid search is first used for the values of a and b. Here a range of possible values are scored and gradient descent starts from the best scoring combination of these. The user can control this grid search by setting the number of guesses to try for a and b respectively, as well as setting the range over which to space these values. The default ranges are [-0.1,0.1] with 100 guesses in each case.

After the grid search, the gradient descent then begins from the best scoring pairing of a and b. For each step of gradient descent, the step maximising the reduction in the sum of squared-residuals is taken by calculating the partial derivative of this with respect to a and b and altering the parameters by this scaled by a step-size parameter. The default step size parameter, alpha, is set by the user with the default being 0.01.

![alt text][img12]

In order to facilitate faster convergence, this implementation uses an adaptive step size. Initially, each gradient descent step is considered using the default step size. The partial derivatives of the error function at the new values for a and b are then calculated. If the sign of both derivatives don't change then the step is taken (as this is assumed to mean that a fixed point has not been crossed). If however either of the derivatives changes sign, then an alternative step size parameter of half the current step size is considered. The process is then repeated to calculate and compare the signs of the derivatives. Should the signs of the halved step size no longer change, then the step is taken with the full step size. If not, the nominal step size is then set to the halved step size, and the halving process is applied again. This process is then applied iteratively until a small enough step size is found, or until a user-definied minimum step size is considered, the example default being 2e-14. In this case the algorithm stops, outputting the current values for a and b.

The reason that the larger of the two options is used in the halving process above is because this always ensures when an adaptive step size is used, it forces the step to cross the fixed-point. This enables faster convergence, as otherwise the method would only ever be able to approach a fixed-point from one side, effectively requiring asymptotic convergence.

The only exception to the above routine in each step is where the initial gradient and step size combination would cause a negative prediction for species discovery in any of the time windows. Given the logarithmic transformation, this causes an error, and so in such cases the effective step size is reduced until the predictions are all non-negative. This is achieved by rescaling the gradient. This reduced gradient is then used in the normal way as outlined above with the adaptive step size.

The process of gradient descent is then repeated until the partial derivatives have a magnitude less than a user-defined multiple of the magnitudes of the parameters a and b respectively. The deault ration being 1e-4. At this point the values of a and b are reported and the algorithm moves on to the next guess for S<sub>T</sub>. The user also sets a maximum number of gradient descent steps, that if reached for a given guess, causes the gradient descent to terminate and report the current values of a and b, as well as outputting a warning. The defualt maximum is 500 steps. 

From the above methods the scores for each guess of S<sub>T</sub> can then be calculated and the searching method as used in the regression search can be used to find the best guess for S<sub>T</sub>.

This method requires a huge number of computations for the gradient descent approach. As such it can be computationally very inefficeint (even with caching and vectorisation) and hence is not the preferred method for the project analysis.

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

There are two scripts in this repository which can be used to re-create the analysis described above. Both scripts will require the input of a .csv file of a download of WCSP data and a posisble extra .csv file of the distribution data from the WCSP. These files should be located a directory at the same level as the downloaded repository. That is to say you should have a structure of this form './location/kew_grasses' with your data in a directory of the form './location/data' or similar.

The user should then decide whether they desire a geographic breakdown, and whether they want the analysis to be on the entire dataset or if they would like it subsetted in some way. The table below shows which script to use in which case, and which csv files will be needed.

| Model Desired 		| Script 				| Required .csv 		|
|:-----------------------------:|:-------------------------------------:|:-----------------------------:|
| Global only - Entire Dataset	| complete_pipeline_whole_dataset.r	| Species Data only		|
| Global only - Subsets		| complete_pipeline_filter.r		| Species Data only		|
| Geographic - Entire Dataset 	| complete_pipeline_whole_dataset.r	| Species Data and Distribution	|
| Geographic - Subsets		| complete_pipeline_filter.r		| Species Data and Distribution	|

With knowledge of the required script and the input files in place the user should then load the script they need and edit any of the input variables as explained in the table below. Any non-essential input variables can be left as they are, but are left for the user to alter should they wish to do so.

### Essential inputs

| Input Variable 	| Default 		| Explanation |
|:---------------------:|:---------------------:| ----------- |		
| setwd			| "~/Kew Summer"	| This is where the user can set the parent directory within which the "kew_grasses" directory (and .csv files (or their directory) are)|
| global.cv		| FALSE			| When set to TRUE this will run the cross-validation regime on the complete data set (or on each subset in complete_pipeline_filter.r)	|
| global.gradient	| FALSE			| When set to TRUE this will run the gradient descent search method on the complete data set (or on each subset in complete_pipeline_filter.r)	|


## References

1. Flowering Plants
2. Brazil
3. Hotspots
4. Taxonomists
5. WCSP

[1]: http://www.kew.org/
[2]: http://apps.kew.org/wcsp/
[3]: http://www.tdwg.org/

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
[img12]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img12.jpg "Gradient Descent Method"