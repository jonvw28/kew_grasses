## Details of Model Fitting Methods

### *Jonathan Williams*
### *2016*

Both methods employ an optimization algorithm analogous to that described in Joppa et al 2010<sup>2</sup>. Here the algorithm starts with guesses for the total number of species, and then finds the values of a and b that give the best fitting model for this value of S<sub>T</sub>. The best fitting values of S<sub>T</sub> are then used to select new possible guesses and the process is repeated. This process is applied iteratively until a final value of S<sub>T</sub> is found.

In both methods the number of guesses per iteration is set by the user, the example being using 500. For the first iteration, the range of guesses is equally spaced between the current number of species published and a user-defined multiple of this number. The defualt multiple is 3. 

Once the methods have found the best fitting a and b for each guess of S<sub>T</sub>, the set of scores for each model is considered, and the models are ranked. From this the top models are selected. The proportion of models selected in each iteration is set by the user, the example default being 0.2. The range of values of S<sub>T</sub> for the selected models is then extended about its midpoint by a factor set by the user. The example default is 1.5 and this would result in a range 150% the length of the original range with the same midpoint. The guesses for the next iteration are then equally spaced amongst this range. 

The strecthing of the range at each iteration is applied to allow a greater searching of the parameter space. Should the lower end of the range of new guesses fall below the current number of species recorded, then this current level is used as the lower bound instead. In such a case the guesses are equally spaced between this lower bound and the upper end of the range.

This algorithm is applied iteratively until the range of guesses of S<sub>T</sub> is less than 0.5 in which case the final value reported will be selected to be the best scoring one. This should ensure that the reported best-fitting value of S<sub>T</sub> will be reported to the accuracy of the nearest whole number. The user must also define a maximum number of iterations for the the algorithm to ensure it terminates if it does not converge. The default example is 20 iterations, and a message will be displayed should this maximum be reached.

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

## Utilising the Scripts

When simply using the `RunMe.R` the default values for these methods will be used. The choice of which method(s) to be applied can be set within the RunMe.R file. Should the user wish to alter the parameters from the default, they can do so by altering the settings within the following two files. Each table explains the parameters within each file.

`./Options_Files/search_parameters.R`

| Input Variable 	| Default 	| Explanation				|
|:---------------------:|:-------------:| ------------------------------------- |
| `mult`		| `3`		| The multiple of the current cumulative number of species which should be the upper bound for the first round of guesses|
| `guess.n`		| `500`		| The number of guesses that should be scored per iteration of S<sub>T</sub> search|
| `ratio`		| `0.2`		| The proportion of guesses that should be kept between iterations once their scores have been ranked.|
| `stretch`		| `1.5`		| The stretch factor that should be applied to the range of guesses brought forward to the next iteration|
| `max.it`		| `20`		| Maximum number of iterations that hsould be completed of the S<sub>T</sub> search method|

`./Options_files/gradient_descent.R`

These will only be used if the Gradient Search Descent method is selected by the user.

| Input Variable 	| Default 	| Explanation				|
|:---------------------:|:-------------:| ------------------------------------- |
| `scale`		| `c(100,1000)`	| The scaling factor to be used to re-scale the taxonomist numbers and species numbers respectively. A factor of 10 would mean dividing the level of that variable by 10. Years are automatically scaled to fill the range [0,1]|
| `ab.guesses`		| `c(100,100)`	| The number of initial guesses of a and b to be considered in the grid search.
| `rng.a`		| `c(-0.1,0.1)`	| The range over which to space the initial guesses for a. **NOTE:** this number will be applied to the rescaled data, but the outputted a will be adjusted to apply to the raw input data|
| `rng.b`		| `c(-0.1,0.1)`	| The range over which to space the initial guesses for b. **NOTE:** this number will be applied to the rescaled data, but the outputted b will be adjusted to apply to the raw input data|
| `alpha`		| `0.01`	| Default step-size for the gradient descent|
| `min.alp`		| `2e-14`	| Minimum step-size allowed in the adaptive step-size algorithm|
| `grad.rat`		| `1e-4`	| Ratio of the magnitudes of the gradient to the magnitudes of the parameters at which gradient descent will stop|
| `max.grad`		| `500`		| The maximum number of steps that each gradient descent will be aloowed to take|


## References
1. [**How many specues of flowering plants are there?**][4] Lucas N. Joppa, David L. Roberts, Stuart L. Pimm; Proc. R. Soc. B 2010 -; DOI: 10.1098/rspb.2010.1004. Published 7 July 2010 
2. [**How many endangered species remian to be discovered in Brazil?**][5] Pimm, SL; Jenkins, CN; Joppa, LN; Roberts, DL; Russell, GJ; Natureza a Conservacao 2010; DOI: 10.4322/natcon.00801011
3. [**Biodiversity hotspots house most undiscovered plant species**][6] Lucas N. Joppa, David L. Roberts, Norman Myers, and Stuart L. Pimm; PNAS 2011 108 (32) 13171-13176; published ahead of print July 5, 2011, doi:10.1073/pnas.1109389108

[4]: http://rspb.royalsocietypublishing.org/content/early/2010/07/07/rspb.2010.1004#fn-group-1
[5]: http://doi.editoracubo.com.br/10.4322/natcon.00801011
[6]: http://www.pnas.org/content/108/32/13171.full


[img5]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img5.jpg "Regression Search Model"
[img6]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img6.jpg "Regression Search equation"
[img7]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img7.jpg "Regression Search residuals"
[img8]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img8.jpg "Regression Search Least Squares"
[img9]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img9.jpg "Regression Search residual Weightings"
[img10]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img10.jpg "Gradient Descent Search residuals"
[img11]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img11.jpg "Gradient Descent Search residuals"
[img12]: https://github.com/jonvw28/kew_grasses/blob/master/Figures/img12.jpg "Gradient Descent Method"