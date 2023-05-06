###########################################################
#                   Exploring the Clean Data              #
#                   Aidan T & Vijay P                     #
###########################################################
library(tidyverse)
library(ggplot2)
# Imports the data to this R script
dat1 <- readRDS(here::here("1 Data","Processed","GACOVID_deaths.Rda")) %>% 
        mutate(party_majority = factor(party_majority),
               grad_improve = factor(grad_improve, 
                                     labels = c("Not Improved","Improved")))
# Generates the basis of a plot using the imported data frame
plot1 <- ggplot(dat1)

# Uses the base plot to compare the projected population to COVID deaths as a scatter plot and 
# and generates a trendline
plot1 + geom_point(aes(x=pop_projection,y=death_count)) + 
        geom_smooth(aes(x=pop_projection,y=death_count)) +
        labs(x="Projected Population by Gounty in Georgia",
             y="Deaths Attributed to COVID-19")
ggsave(here::here("4 Products","Figures","Exploration1.pdf"))

# Uses the base plot to generate a box plot comparing the distribution of COVID deaths between 
# counties with Republican vs Democrat political majorities
plot1 + geom_boxplot(aes(x=party_majority,y=death_count)) +
        labs(x="Popular Party by County",
             y="Deaths Attributed to COVID-19")
ggsave(here::here("4 Products","Figures","Exploration2.pdf"))

# Uses the base plot to generate a scatter plot comparing the number of hospital beds available
# to the number of COVID deaths and generates a trendline
plot1 + geom_point(aes(x=hospital_cap,y=death_count)) +
        geom_smooth(aes(x=hospital_cap,y=death_count)) +
        labs(x="Hospital Bed Capacity by County",
             y="Deaths Attributed to COVID-19")
ggsave(here::here("4 Products","Figures","Exploration3.pdf"))

# Uses the base plot to generate a scatter plot and trendline comparing the logged per capita
# income to the number of COVID deaths
plot1 + geom_point(aes(x=per_capita_income,y=death_count)) +
        geom_smooth(aes(x=per_capita_income,y=death_count)) +
        labs(x="Log Per Capita Income by County",
             y="Deaths Attributed to COVID-19")
ggsave(here::here("4 Products","Figures","Exploration4.pdf"))

# Uses the base plot to generate a scatter plot and trendline comparing the number of high school
# grduates to the number of COVID deaths
plot1 + geom_point(aes(x=grad2020,y=death_count)) +
        geom_smooth(aes(x=grad2020,y=death_count))  +
        labs(x="Number of High School Graduates by County",
             y="Deaths Attributed to COVID-19")
ggsave(here::here("4 Products","Figures","Exploration5.pdf"))

# Uses the base plot to generate a box plot of comparing the distributions of COVID deaths between
# counties with improved graduates rates vs counties with unimproved graduation rates
plot1 + geom_boxplot(aes(x=grad_improve,y=death_count)) +
        labs(x="Status of High School Graduation Rates",
             y="Deaths Attributed to COVID-19")
ggsave(here::here("4 Products","Figures","Exploration6.pdf"))