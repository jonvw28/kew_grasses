# Where are the Missing Grasses?

### *Jonathan Williams*
### *2016*

## Introduction

This repository contains the code used for the project "Where are the Missing Grasses?". This was a summer project based at the Royal Botanic Garden Kew. The aim of the project was to build on existing work such as Joppa et al 2010<sup>1,2</sup> and 2011<sup>3,4</sup>. Here the rate of discovery of new species is assumed to be proportional to both the number of remaining species to be discovered and the number of taxonomists working at the time. In this particular project the goal was to apply this model to the grasses family (Poaceae) and to use this to try to determine where we expect the grasses currently unknown to science to be.

## Model

The base of the model is that as has been introduced and used by Joppa et al 2010<sup>1</sup>. Here the discovery of species is considered in aggregated time windows. This is to help deal with issues such as the publication of monographs which give rise to a large variation in year on year species publication. The base model uses a time window of five years when summarising the data, with 10 years being tried as a measure of validation for the model.

Within each window, the model calculates the total number of species left to be discovered for that window by subtracting the cumulative number of species published prior to that window from the theoretical total number of species to be discovered, so for window i the total number of species left to be described is given by:

![alt text][img1]


Within each window the number of species newly published are simply taken from publication dates as per the [World Checklist of Select Plants][1]<sup>5</sup> download that was made on 5th July 2016.



1. Flowering Plants
2. Brazil
3. Hotspots
4. Taxonomists
5. WCSP

[1]: http://apps.kew.org/wcsp/home.do

[img1]: http://www.sciweavers.org/download/Tex2Img_1471269938.jpg "Species left to be discovered"