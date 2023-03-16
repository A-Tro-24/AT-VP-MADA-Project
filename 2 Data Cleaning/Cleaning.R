###########################################################
#                   Cleaning Raw Data sets                #
#                   Aidan T & Vijay P                     #
###########################################################
library(tidyverse)
# Loads the data into R. The original data is in the "CSV" format
raw_sa <- readr::read_csv(here::here("1 Data", "Raw", 
                                     "Provisional_COVID-19_Deaths_by_Sex_and_Age.csv"))
raw_deaths <- readr::read_csv(here::here("1 Data", "Raw", "deaths.csv"))
raw_gov <- readxl::read_xlsx(here::here("1 Data","Raw", "government_22.xlsx"))
raw_econ <- readxl::read_xlsx(here::here("1 Data", "Raw",
                                         "economics_22.xlsx"),
                              sheet='per_capita_income')

# Provides an overview of the data and data types in the data frame.
dplyr::glimpse(raw_deaths)
dplyr::glimpse(raw_sa)
dplyr::glimpse(raw_gov)
dplyr::glimpse(raw_econ)

# Includes only the data we intend to use for our analysis.
new_sa <- raw_sa %>%
  # Identifies total values for Georgia subjects in the year 2020 only
          dplyr::filter(Year == 2020 & is.na(Month) & 
                        State == "Georgia" & 
                  # Filters out redundancies caused by overlapping age intervals
                        `Age Group` %in% c("Under 1 year","1-4 years","5-14 years","15-24 years",
                                          "25-34 years","35-44 years","45-54 years",
                                          "55-64 years","65-74 years","75-84 years",
                                          "85 years and over") &
                  # Filters out overlaps due to totals rows
                        Sex %in% c("Male","Female")) %>%
  # Rids the dataset of "Notes" section and date variables
          dplyr::select(!c(Footnote,`Data As Of`,`Start Date`,`End Date`,Group,Year,Month,State))

  # Checks that the data was manipulated properly
          dplyr::glimpse(new_sa)

# Removes unwanted "+" symbols from some rows
raw_deaths$age <- gsub('[^[:alnum:] ]','',raw_deaths$age)

# Checks that all values correlate to a county in Georgia
unique(raw_deaths$county)

# Converts the age variable to numeric and capitalizes the county variable
new_deaths <- raw_deaths %>%
          dplyr::mutate(age = as.numeric(age),
                        county = toupper(county)) %>%
# Omits non-residents of Georgia for which we do not have any prior information
          dplyr::filter(county != "NON-GA RESIDENT/UNKNOWN STATE")

# Checks that the data was manipulated properly
          dplyr::glimpse(new_deaths)

# Uses the voting proportions from 2020 to identify party majority in each county
new_gov <- raw_gov %>%
          dplyr::mutate(party_majority = 
                        ifelse(`2020 Votes Cast for President, Democratic Party, Percent`>
                               `2020 Votes Cast for President, Republican Party, Percent`,
                               "Democratic",
                               "Republican")) %>%
          dplyr::select(County,party_majority)

# Identifies the 2020 Per Capita Personal Income by county
new_econ <- raw_econ %>%
          dplyr::select(County,`2020 Per Capita Personal Income`)

# Joins the data from the `new_econ` data frame to the `new_deaths` data frame based on the county variable
join1 <- dplyr::left_join(new_deaths,new_econ,by=c("county"="County"))
# Checks that the join worked
dplyr::glimpse(join1)

# Joins the data from the `new_gov` data frame to the `join1` data frame based on the county variable
join2 <- dplyr::left_join(join1,new_gov,by=c("county"="County"))%>%
  # Reorders the variables in the desired order
dplyr::relocate(county,`2020 Per Capita Personal Income`,party_majority,.before=age)

# Checks that the join worked
glimpse(join2)
# Saves the cleaned data set and stores it in the "2 Data Cleaning" folder
saveRDS(join2, here::here("1 Data","Processed","GACOVID_deaths.Rda"))
