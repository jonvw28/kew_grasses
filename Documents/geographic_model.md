## Details of Geographic Model Methods

### *Jonathan Williams*
### *2016*

In this method the total number of species globally is first calculated using the regression search method. Following this, the species data is mapped to the distribution data at the desired TDWG level. The distribution data is then filtered to remove any location where there is doubt or only artifically introduced presence of the species. Each species is then classified as endogenous or not at this level. Here endogeny refers to any species that is only present in one region at the given TDWG level.

For each region, the regression search model is then used to predict the total number of endogenous species in that region (regions with fewer than a user-defined cumulative endogenous species to date are excluded as the model is unrelaible with too little data, the example being 50). The same model is then applied to the non-endogenous species.

The predictions for the regions and non-endogenous species are then collated. For regions where the model couldn't be applied, the prediction for total number of species is calculated by finding the ratio of aggregate predictions to aggregate current species recorded for the regions that succeeded and non-endogenous species. This is then used to multiply the current recorded species in these as-yet-unscored regions to get a predicted total of species.

The total number of predicted species across all regions and non-endogenous species is then computed and compared to the earlier global prediction. At this point all of the regional predictions as well as non-endogenous species are scaled by a constant ratio such that the total of the regional analysis is equal to the global total. The final results are then reported, as well as the percentage of the predicted total of species in each region that have so far been recorded. 

To alter the parameters from the defaults, the user can alter the settings in `./Options_Files/geographical_models.R`

| Input Variable 	| Default 		| Explanation			|
|:---------------------:|:---------------------:| ----------------------------- |
| `loc.ind`		| `c(4,6)`		| If a geographic model is being applied then this is where the indices of the columns for each geographic level need to be supplied. Each column should refer to each level set via `levels`, in the same order|
| `levels`		| `c("TDWG1",TDWG2")`	| These are the names for the geographic levels to be used in output filenames (can be any string the user desires). **For a global only model this will need to be set to `NULL`**|
| `n.spec`		| `50`			| For geographic models this is the minimum number of total species recorded to date required in a given region in order for the model to be applied|
| `filt.ind`		| `c(11,12,13,14,15)`	| When using a geographic model this allows filtering of the distribution dataset to remove data for regions where the species is doubtful, or has been introduced. Here the user sets the indices of the columns where filtering is to be applied|
| `filt.mk`		| `c(1,1,1,1,1)`	| Set the content for each column in `filt.ind` which is to be removed. If more than one mark is to be filtered in a given column, then enter that index twice in `filt.ind` and enter the two marks in the corresponding locations in `filt.mk`|