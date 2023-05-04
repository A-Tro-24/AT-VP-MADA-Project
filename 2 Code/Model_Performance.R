###########################################################
#                   Model Evaluation                      #
#                     Aidan T                             #
###########################################################

library(xtable)
library(tidymodels)
library(poissonreg)
library(sjPlot)
library(ggplot2)

set.seed(04272023)

dat <- readRDS(here::here("1 Data","Processed","GACOVID_deaths.Rda"))

test <- readRDS(here::here("1 Data","Processed","Test_Data.Rda"))

lasso_main <- readRDS(here::here("3 Model Fitting","GA_COVID_LASSO_MAIN.Rda"))
lasso_sat <- readRDS(here::here("3 Model Fitting","GA_COVID_LASSO_SAT.Rda"))

test_main <- lasso_main %>%
             fit(data=test)
(test_sat <- lasso_sat %>%
            fit(data=test))

test_main_pred <- augment(test_main,test)
test_sat_pred <- augment(test_sat,test)
