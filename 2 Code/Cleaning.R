###########################################################
#                   Cleaning Raw Data sets                #
#                   Aidan T & Vijay P                     #
###########################################################
library(tidyverse)
# Loads the data into R. The original data is in the "CSV" format
raw_deaths <- readr::read_csv(here::here("1 Data", "Raw", "deaths.csv"))
raw_gov <- readxl::read_xlsx(here::here("1 Data","Raw", "government_22.xlsx"))
raw_econ <- readxl::read_xlsx(here::here("1 Data", "Raw",
                                         "economics_22.xlsx"),
                              sheet='per_capita_income')
raw_pop <- readxl::read_xlsx(here::here("1 Data","Raw","population_22.xlsx"),
                             sheet='pop_est_project')
raw_med <- readxl::read_xlsx(here::here("1 Data","Raw","health_22.xlsx"),
                             sheet='hosp_nursing_facilities_day_car')
raw_edu <- readxl::read_xlsx(here::here("1 Data","Raw","education_22.xlsx"),
                             sheet='county_graduates')

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

# Finds the number of deaths in each county
deaths <- new_deaths %>%
          dplyr::group_by(county) %>%
          dplyr::count(county) %>%
          dplyr::rename(`Death Count` = "n")

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
            dplyr::select(County,`2020 Per Capita Personal Income`) %>%
            rename(per_capita_income = `2020 Per Capita Personal Income`)

# Selects for the the projected population for 2020
new_pop <- raw_pop %>%
           dplyr::select(County, `2020 Population Projection`)
# Selects the number of graduates from 2020 and 2019 for each county
new_edu <- raw_edu %>%
           dplyr::select(County,`2020-21 Graduates, Number`,`2019 Graduates`)
# Selects the number of general hospital facilities for each county
new_med <- raw_med %>%
           dplyr::select(County,`2021 General Hospital Facilities`)

# Joins the data from the `deaths` data frame to the `new_pop` data frame based on the county variable
join  <- dplyr::right_join(new_pop,deaths,by=c("County"="county")) %>%
# Adds prominent political party for each county
         dplyr::left_join(new_gov,by=c("County"="County"))%>%
# Adds the number of graduates for each county
         dplyr::left_join(new_edu,by=c("County"="County"))%>%
# Adds the number of healthcare facilities for hear county
         dplyr::left_join(new_med,by=c("County"="County")) %>%
# Adds the per capita income for each county
         dplyr::left_join(new_econ,by=c("County"="County")) %>%
# Creates a new variable for the number of graduates for 2020 so that Clay county is included but assumes 0 graduates
         dplyr::mutate(grad2020 = ifelse(is.na(`2020-21 Graduates, Number`),0,`2020-21 Graduates, Number`),
# Creates a new variable to compare graduation rates from previous years
                       grad_improve = ifelse(is.na(`2019 Graduates`),0,
                                                       ifelse(grad2020 > `2019 Graduates`,1,0)),
                       party_majority = ifelse(party_majority=="Republican",0,1)) %>%
# Removes the extra variables since we created new variables for them
         select(!c(`2020-21 Graduates, Number`,`2019 Graduates`))
# Checks that there are no missing values
anyNA(join)
# Checks that the join worked
glimpse(join)
# Saves the cleaned data set and stores it in the "2 Data Cleaning" folder
saveRDS(join, here::here("1 Data","Processed","GACOVID_deaths.Rda"))

saveRDS(new_deaths, here::here("1 Data","Processed","COVID_death_specs.Rda"))
