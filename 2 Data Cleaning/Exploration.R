###########################################################
#                   Exploring the Clean Data              #
#                   Aidan T & Vijay P                     #
###########################################################
library(ggplot2)
# Imports the data to this R script
dat <- readRDS(here::here("1 Data","Processed","GACOVID_deaths.Rda"))
# Creates a general plot using the data we have accumulated
plot <- ggplot(dat)
# Plots a histogram showing the distribution of COVID deaths by age
plot + geom_histogram(aes(x=age), bins = 45)
# Plots a histogram showing the distribution of COVID deaths by per capita income
plot + geom_histogram(aes(x=per_capita_income/1000), bins = 45) +
       labs(title = "Distribution of COVID Deaths in Georgia by per Capita Income",
            xlab = "per Capita Income (in thousands of $)",
            ylab = "# of Deaths")
# Plots the number of COVID deaths by sex
plot + geom_bar(aes(x=sex))
# Plots the number of COVID deaths by majority party
plot + geom_bar(aes(x=party_majority))
# Plots the number of COVID deaths by whether the subject was known to
# have had a pre-existing chronic condition
plot + geom_bar(aes(x=chronic_condition))
# Plots the number of COVID deaths by race
plot + geom_bar(aes(x=race, fill=ethnicity),position="stack") +
       theme(axis.text.x = element_text(angle = 90))
