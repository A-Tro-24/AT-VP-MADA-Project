###########################################################
#                   Exploring the Clean Data              #
#                   Aidan T & Vijay P                     #
###########################################################
library(ggplot2)
dat <- readRDS(here::here("1 Data","Processed","GACOVID_deaths.Rda"))

plot <- ggplot(dat)

plot + geom_histogram(aes(x=age), bins = 45)
plot + geom_bar(aes(x=sex))
plot + geom_bar(aes(x=party_majority))
plot + geom_bar(aes(x=chronic_condition))
