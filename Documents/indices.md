## Details of Data Indices

### *Jonathan Williams*
### *2016*

Below are the essential indices required in all models and filters

| Input Variable 	| Default 	| Explanation				|
|:---------------------:|:-------------:| ------------------------------------- |
| `id.ind`		| `c(1,2)`	| The indices of the columns containing the plant name IDs in the species and distribution datasets respectively. The defaults are for a WCSP download. The second index is only necessary if the the geographic model is required.|
| `yr.ind`		| `15`		| The index of the column in the species dataset which contains the year of publication|
| `auth.ind`		| `11`		| The index of the primary authors column in the species dataset|

If the user selects a data processing method which makes use of basionym data then the following inputs need to be set:

| Input Variable 	| Default 	| Explanation				|
|:---------------------:|:-------------:| ------------------------------------- |
| `basio.ind`		| `20`		| The index of the column containing the basionym id in the species data set|
| `miss.bas`		| `-9998`	| The value that occurs in this column when a given name is a basionym (like an NA marker)|

If the user selects a data processing method that include filtering then the following inputs will need ot be set. The exact set of methods for filtering can be read [here][link2]

| Input Variable 	| Default 		| Explanation			|
|:---------------------:|:---------------------:| ----------------------------- |
| `stat.ind`		| `17`			| This is the index of the column containing the taxonomic status information in the species dataset|
|`stat.mk`		| `c("A")`		| This is a vector of all the contents of `stat.ind` that are to be kept. Is possible to add as many as the user desires, but unlike for `filt.ind` there is no need to replicate the index in `stat.ind`|
| `rnk.ind`		| `23`			| This is the index of the column containing the taxonomic rank information in the species dataset|
|`rnk.mk`		| `c("Species")`	| This is a vector of all the contents of `rnk.ind` that are to be kept. Is possible to add as many as the user desires, but unlike for `filt.ind` there is no need to replicate the index in `rnk.ind`|
| `hyb.ind`		| `c(4,6)`			| This is the index of the column containing the hybrid status information in the species dataset|
|`hyb.mk`		| `c("×","×")`		| This is a vector of the marks in each column for hybrid status that indicate those data to be removed. Here only one mark is allowed per column, and thus if there are mor ethan one mark in a cloumn, it must be repeated in `hyb.ind` much like `filt.ind`|

[link2]: https://github.com/jonvw28/kew_grasses/tree/master/Documents/data_methods.md