## Details of Data Processing Methods

### *Jonathan Williams*
### *2016*

In counting the number of names in each time window, the raw list of names is first filtered. This is done to address issues such as synonomy and placement of species in new genera. Various methods are supported to answer different questions of interest. For counting taxonomists, the list of names is filtered in the same way, and the authors are taken to be those primary authors on each name in a given window.

 The following 6 methods can be set in the `RunMe.R` script for both taxonomists and species aggregation:
 
| Method Name				| Explanation				|
| -------------------------------------	| ------------------------------------- |
| `"all"`				| This method will simply take all names in the data set|
| `"filtered - not status"`		| This method will filter all of the names to remove those for hybrids and names that are not at the specified taxonomic rank(s) (by defualt this is species)|
| `"filtered - status"`			| This method will apply the filters of the above method and in addition only include names currently of the set taxonomic statuses (by default this will only be accepted names)|
| `"all basionyms"`			| This method will select only names which are basionyms|
| `"basionyms filtered - not status"`	| This method will select only the basionyms and will filter these to remove hybrids and those that are not at the specified taxonomic rank(s) (by defualt this is species)|
| `"basionyms filtered - status"`	| This method will apply the filters of the above method and in addition only include names currently of the set taxonomic statuses (by default this will only be accepted names)|

In addition to the above methods for both data processing pipelines, there is an additional option for filtering specifically for species data aggregation. This option allows for the user to only consider currently accepted species, but ascribes to them the year of publication of their basionym. Whilst this is useful for species data, ascribing years in this way would be misleading for calculating the date of the taxonomic work for each name, hence is only supported in species data aggregation.

| Method Name				| Explanation				|
| -------------------------------------	| ------------------------------------- |
| `"filtered - status - basionym dated"`| This method will select names that are filtered to only include non-hybrid names, of the specified taxonomic ranks and statuses. The names will then have the date of publication of their basionym ascribed to them|

For full details of the filtering options for taxonomic ranks and statuses, see the document [here][link1]

[link1]: https://github.com/jonvw28/kew_grasses/tree/master/Documents/indices.md