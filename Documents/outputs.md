## Details of name Splitting Methods

### *Jonathan Williams*
### *2016*

Within the output directory, where appropriate, the below directories will be be created and populated with the relevant information for each model. For geographic models, there will be a subdirectory within each of these for each geographic level. These names can be altered by editing the file `./Options_Files/output_options.R`

The first sub-directory will be filled with aggregated species discovery data, broken down by each time window and with an additional file for each geographic level of interest showing this breakdown by region.

Next of these will be a subdirectory created and populated with aggregated taxonomist data. Here there will be a summary file, with a breakdown by time window. There is also a detailed breakdown file showing the names of all authors in each time window, and how many papers they authored, broken down by number of co-authors. This analysis is then repeated at each geographic level where appropriate. Here there is a summary file with regional summary data broken down by time window. There is then an additional file for each region with the full author breakdown as per the overall data analysis.

For each model that is fitted, there is also a sub-directory created. Within each of these there is a model summary file showing the key model parameters. There is then a full model file showing the estimates for each time window. There are also three plots completed. One shows the squared residuals score for the best fitting model for the initial guesses of S<sub>T</sub>. Another shows the trends in number of taxonomists and new species discovered over time, with the model fit overlaid. The final plot shows the number of species per taxonomist with the fitted model theoretical species per taxonomist overlaid. Within this directory, if appropriate, there are then subdirectories containing the same information for the models fitted for different regions.

Finally the scripts output a csv file showing the regional predictions and percentage of species seen at each geographic lebvel if appropriate, at the top level output directory.

| Input Variable 	| Default 						| Explanation |
|:---------------------:|:-----------------------------------------------------:| ----------- |	
| `spec.dir`		| `"species_data"`					| Name for the sub-directory within the output directory in which the aggregated species data will go|
| `tax.dir`		| `"taxon_data"`						| Name for the sub-directory within the output directory in which the aggregated taxonomist data will go|
| `reg.dir`		| `"regression_search"`					| Name for the sub-directory within the output directory in which the regression search results will go|
| `regcv.dir`		| `"regression_search_cross_validation"`		| Name for the sub-directory within the output directory in which the regression search cross validation results will go (if selected)|
| `grad.dir`		| `"grad_descent_search"`			| Name for the sub-directory within the output directory in which the gradient descent search results will go (if selected)|
