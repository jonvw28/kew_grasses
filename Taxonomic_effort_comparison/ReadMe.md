## Taxonomic Effort as Compared to Global Scientific Effort

The script in this directory `./Taxonomic_effort_comparison/taxonomy_vs_all_disciplines_JSTOR.R` can be used to compare taxonomic effort with global scientific effort for a time window of interest for the user. The script will collect the number of names published in the [World Checklist of Selected Plant Families][1] for each year in the time window and will also take the number of publications for each year from a [JSTOR data download][2] of the complete archive of JSTOR articles.

The method is specifically set up for these data inouts (once converted to .csv files). But by changing the index references, it's still possible to use other, similar datasets.

The script will output a .csv file of number of taxonomic names published in each year. It will then output a .csv file showing number of taxonimic names published in each year, as well as number of publications on JSTOR. It then contains the ratio of taxonomic names to global JSTOR publications.

### Input Variables

| Input Variable 	| Default 						| Explanation	|
|:---------------------:|:-----------------------------------------------------:| ------------- |
| `start.year`		| `1753`						| The year for which the analysis should start|
| `end.year`		| `2014`						| The year for which the analysis should end
| `tax.year.col`	| `15`							| The index of the column in the taxonomic names dataset which contains the year of publication|
| `tax.id.col`		| `1`							| The index of the column containing the unique plant name IDs in the taxonomic names dataset|
| `sci.year.col`	| `1`							| The index of the column in the scientific publications dataset which contains the year of publication|
| `sci.pubs.col`	| `2`							| The index of the column containing the number of publications in the scientific publications dataset|


### File Location Variables

| Input Variable 	| Default 						| Explanation	|
|:---------------------:|:-----------------------------------------------------:| ------------- |
| `dir.path`		| `"./Data/"`						| The directory location where the input files are|
| `tax.file.name`	| `"08_12/public_checklist_flat_plant_dl_20160705"`	| The name of the WCSP download file for taxonomic names. **NOTE:** Without .csv on the end|
| `baseline.file.name`	| `"08_23/JSTOR_All_authors"`				| The name of the JSTOR download file for taxonomic names. **NOTE:** Without .csv on the end|
| `output.location`	| `"./Output/taxonomy_scientific_comparison"		| The location the user would like the output to be saved in|
| `id.str`		| `"taxonomic_names"`					| The string used to create a subdirectory to store the processes taxonomic names data in|

[1]: http://apps.kew.org/wcsp/
[2]: http://dfr.jstor.org/fsearch/csv?fs=yrm1&view=text&&csv=yr&fmt=csv