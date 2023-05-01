###########################################################
#                   Model Fitting                         #
#                   Aidan T & Vijay P                     #
###########################################################
library(tidymodels)
library(poissonreg)
library(sjPlot)
library(ggplot2)
library(glmnet)

set.seed(04272023)

dat <- readRDS(here::here("1 Data","Processed","GACOVID_deaths.Rda"))

data_split <- rsample::initial_split(dat, prop=8/10)
training_data <- rsample::training(data_split)
test_data <- rsample::testing(data_split)

main_mod <- glm(death_count ~ .-County,
            data=training_data,
            family=poisson)

null_mod <- update(main_mod, .~1)

sat_mod <- update(main_mod,.~(.-County)^2)

display(null_mod,detail=TRUE,digits=3)
display(main_mod,detail=TRUE,digits=3)
display(sat_mod,detail=TRUE,digits=3)

lasso_mod_main <- cv.glmnet(model.matrix(main_mod),
                            cbind(training_data$death_count),
                            alpha=1,
                            family=poisson,
                            nfolds=5)
lasso_mod_sat <- cv.glmnet(model.matrix(sat_mod),
                           cbind(training_data$death_count),
                           alpha=1,
                           family=poisson,
                           nfolds=5)
Lmin_main <- lasso_mod_main$lambda.1se
Lmin_sat <- lasso_mod_sat$lambda.1se

pdf(here::here("6 Supplemental Material","Main_Lambda_plot.pdf"))
plot(lasso_mod_main)
dev.off()

pdf(here::here("6 Supplemental Material","Saturated_Lambda_plot.pdf"))
plot(lasso_mod_sat)
dev.off()


coef(lasso_mod_main,s=Lmin_main)
coef(lasso_mod_sat,s=Lmin_sat)

saveRDS(lasso_mod_main,here::here("3 Model Fitting","COVID_LASSO_main.Rda"))
saveRDS(lasso_mod_sat, here::here("3 Model Fitting","COVID_LASSO_sat.Rda"))
