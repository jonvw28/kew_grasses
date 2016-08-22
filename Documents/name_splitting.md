## Details of name Splitting Methods

### *Jonathan Williams*
### *2016*

The primary author name strings are split based upon commas, '&' and the specific taxonomic symbols 'in' and 'ex'. By default the string of names is split wherever a comma is found. Also the default is for the authors after the string 'in' to be included as these represent authors on the paper that published the species description, and hence were active at the time of publication (the authors before the 'in' are always included as these are the authors of the description). For the string 'ex' the authors to the right are always included (as these are the authors of the descriptions), but by default the names to the left are excluded as these represent the taxonomist to whom the name is attributed, but this can be historic and so does not necessarily represent taxonomic effort at the time. The user is able to alter these settings by altering the variables in the script `./Option_Files/name_formattin.R`

| Input Variable 	| Default 	| Explanation				|
|:---------------------:|:-------------:| ------------------------------------- |
| `comma`		| `TRUE`	| If set to `TRUE` then the string of author names will be split on the string `','`|
| `in.tag`		| `TRUE`	| If set to `TRUE` then the string of author names will be split on the string `'in'`|
| `in.inc`		| `TRUE`	| If set to `TRUE` then names to the right of the string `'in'` will be included|
| `ex.tag`		| `TRUE`	| If set to `TRUE` then the string of author names will be split on the stirng `'ex'`|
| `ex.inc`		| `FALSE`	| If set to `TRUE` then names to the left of the string `'ex'` will be included| 