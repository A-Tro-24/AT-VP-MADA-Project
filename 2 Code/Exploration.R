###########################################################
#                   Exploring the Clean Data              #
#                   Aidan T & Vijay P                     #
###########################################################
library(ggplot2)
# Imports the data to this R script
dat1 <- readRDS(here::here("1 Data","Processed","GACOVID_deaths.Rda"))
dat2 <- readRDS(here::here("1 Data","Processed","COVID_death_specs.Rda"))
# Creates a general plot using the data we have accumulated
plot1 <- ggplot(dat1)
plot2 <- ggplot(dat2)
# Plots a histogram showing the distribution of COVID deaths by age
plot2 + geom_histogram(aes(x=age), bins = 45)
# Plots the number of COVID deaths by sex
plot2 + geom_bar(aes(x=sex))
# Plots the number of COVID deaths by majority party
plot2 + geom_bar(aes(x=party_majority))
# Plots the number of COVID deaths by whether the subject was known to
# have had a pre-existing chronic condition
plot2 + geom_bar(aes(x=chronic_condition))
# Plots the number of COVID deaths by race
plot2 + geom_bar(aes(x=race, fill=ethnicity),position="stack") +
       theme(axis.text.x = element_text(angle = 90))
