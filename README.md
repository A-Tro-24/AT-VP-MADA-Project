# Overview

This repository contains the files, code, and data used for Aidan Troha and Vijay Panthayi's data analysis project/paper done with R/Quarto/Github.
Below are the instructions needed to reproduce this repository and analysis in addition to an outline of the parts of this project and their contents.

## Reproducing This Project

This is where the steps to reproduce this repository/analysis will be.

Example:
* All data goes into the subfolders inside the `data` folder.
* All code goes into the `code` folder or subfolders.
* All results (figures, tables, computed values) go into `results` folder or subfolders.
* All products (manuscripts, supplement, presentation slides, web apps, etc.) go into `products` subfolders.
* See the various `readme.md` files in those folders for some more information.

# Project Part 1: Question/Hypothesis & Suitable Data

## Briefly describe what the data is?
This data set is a cumulative data report on the number of deaths, by state (including Puerto Rico), due to COVID-19, Pneumonia, Influenza, a combination of two of those causes, or all three. The data set divides the data by state, then by sex, then by age group. 

## How it was collected?
Individual state data was reported to NCHS during the collection period. 

## Where you will get (or got) it from?
This data set was obtained directly from the CDC’s online data catalog at data.cdc.gov.
Data: https://data.cdc.gov/NCHS/Provisional-COVID-19-Deaths-by-Sex-and-Age/9bhg-hcku

## How many observations do you have, what was measured?
There are 115,668 observations in this data set. The variables that were measured were the state where the death occurred, the sex of the person who died, and the age group that person falls into. In addition, the data set measured the number of deaths attributed to each of the following: COVID-19, Pneumonia, both COVID-19 and Pneumonia, Influenza, all three, and the total deaths. The reason there are so many observations is because the data set is split into three groups: by total, by year, and by year and month. The group name describes how many observations per state were represented (by total would be a cumulative summary of the by year/by year and month sections).

## Anything else important to report about the data?
According to the data set, many observations were made null if the total number of deaths during the collection period was between 1-9. The CDC notes this is due to being in accordance with NCHS confidentiality standards. Also, for the purpose of our project and report, we will only be using the data which summarizes the total values for the year and each month (only using observations 1-2755; the by total group). This is for the purpose of simplicity while also allowing us to work with a smaller (but still sufficient) data set size.

## Question we want to answer with this data?
We are using this data to answer what factors resulted in the most deaths to COVID, Influenza, and/or Pneumonia. In addition, we can use the fact that the data is separated by state to also analyze geographical influence/correlations as well.

## Outcome of interest?
A statistical representation/test on the significance of each variable on the number of deaths due to COVID, Influenza, and/or Pneumonia.

## Predictors?
The predictors we are focusing on are the following: geographical location, age, and sex.

## Relations/Patterns?
We are looking to see if there are any relationships in the data.

## Data Analysis Plan?
We plan to test the data using some sort of regression analysis or odds ratio to determine the correlation between predictors and outcome.

# Project Part 2: Data Wrangling & Exploration

Place the information for Part 2 here.

# Project Part 3: Beginning Analysis

Place the information for Part 3 here.

# Project Part 4: Completing Analysis

Place the information for Part 4 here.

# Project Part 5: Completed Project and Peer Review

Place the information for Part 5 here.


# THE BELOW WAS FROM THE TEMPLATE REPO FOR FUTURE REFERENCE:
# Template content 

The template comes with a few files that are meant as illustrative examples of the kinds of content you would place in the different folders. See the `readme` files in each folder for more details.

* There is a simple, made-up dataset in the `raw_data` folder. 
* The `processing_code` folder contains several files that load the raw data, perform a bit of cleaning, and save the result in the `processed_data` folder. 
* The `analysis_code` folder contains several files that load the processed data, do an exploratory analysis, and fit a simple model. These files produce figures and some numeric output (tables), which are saved to the `results` folder.
* The `products` folder contains an example `bibtex` and CSL style files for references. Those files are used by the example manuscript and slides.
* The  `manuscript` folder contains a template for a report written as Quarto file. If you access this repository as part of [my Modern Applied Data Science course](https://andreashandel.github.io/MADAcourse/), the sections are guides for your project. If you found your way to this repository outside the course, you might only be interested in seeing how the file pulls in results and references and generates a word document as output, without paying attention to the detailed structure. There is also a sub-folder containing an example template for a supplementary material file.
* The `slides` folder contains a basic example of slides made with Quarto. 


# Getting started

This is a Github template repository. The best way to get it and start using it is [by following these steps.](https://help.github.com/en/articles/creating-a-repository-from-a-template)

Once you got the repository, you can check out the examples by executing them in order. First run the processing code, which will produce the processed data. Then run the analysis scripts, which will take the processed data and produce some results. Then you can run the manuscript, poster and slides example files in any order. Those files pull in the generated results and display them. These files also pull in references from the `bibtex` file and format them according to the CSL style.


