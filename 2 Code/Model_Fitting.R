###########################################################
#                   Model Fitting                         #
#                     Aidan T                             #
###########################################################

library(xtable)
library(tidymodels)
library(poissonreg)
library(sjPlot)
library(ggplot2)

set.seed(04272023)

dat <- readRDS(here::here("1 Data","Processed","GACOVID_deaths.Rda"))

data_split <- rsample::initial_split(dat, prop=8/10)
training_data <- rsample::training(data_split)
test_data <- rsample::testing(data_split)

saveRDS(test_data, here::here("1 Data","Processed","Test_Data.Rda"))

folds <- rsample::vfold_cv(training_data,v=5,repeats=5)

null_rec <- recipes::recipe(death_count ~ 1,
                            data=training_data[2:8])

main_rec <- recipes::recipe(death_count ~ .,
                           data=training_data[2:8]) %>%
            recipes::step_dummy(all_nominal())

sat_rec <- recipes::recipe(death_count ~ .,
                           data=training_data[2:8]) %>%
           recipes::step_dummy(all_nominal()) %>%
           recipes::step_interact(terms = ~ .^2)

poi_mod <- poisson_reg() %>%
           set_engine("glm")

null_wf <- workflow() %>%
           add_recipe(null_rec) %>%
           add_model(poi_mod)

main_wf <- workflow() %>%
           add_recipe(main_rec)

sat_wf <- workflow() %>%
          add_recipe(sat_rec)

lasso_mod_main <- glmnet::cv.glmnet(model.matrix(glm(death_count ~ .-County,
                                                     family=poisson,
                                                     data=training_data)),
                                    cbind(training_data$death_count),
                                    alpha=1,
                                    family=poisson,
                                    nfolds=5)
lasso_mod_sat <- glmnet::cv.glmnet(model.matrix(glm(death_count ~ .-County + (.-County)^2,
                                                    family=poisson,
                                                    data=training_data)),
                                   cbind(training_data$death_count),
                                   alpha=1,
                                   family=poisson,
                                   nfolds=5)

pdf(here::here("6 Supplemental Material","Main_Lambda_plot.pdf"))
plot(lasso_mod_main)
dev.off()

pdf(here::here("6 Supplemental Material","Saturated_Lambda_plot.pdf"))
plot(lasso_mod_sat)
dev.off()

lasso_grid_main <- lasso_mod_main$lambda
lasso_grid_sat <- lasso_mod_sat$lambda

lasso_mod <- poisson_reg(penalty = tune(),mixture=1) %>%
                   set_engine("glmnet")

lasso_main_wf <- main_wf %>%
                 add_model(lasso_mod)
lasso_sat_wf <- sat_wf %>%
                add_model(lasso_mod)

tune_lasso_main <- lasso_main_wf %>%
                   tune_grid(resample=folds,
                             grid=lasso_grid_main,
                             control=control_grid(save_pred=TRUE))
tune_lasso_sat <- lasso_sat_wf %>%
                  tune_grid(resample=folds,
                            grid=lasso_grid_sat,
                            control=control_grid(save_pred=TRUE))

best_lasso_main <- tune_lasso_main %>%
                   select_best()
best_lasso_sat <- tune_lasso_sat %>%
                  select_best()

final_lasso_main <- lasso_main_wf %>%
                    finalize_workflow(best_lasso_main)
final_lasso_sat <- lasso_sat_wf %>%
                   finalize_workflow(best_lasso_sat)
saveRDS(final_lasso_main, here::here("3 Model Fitting","GA_COVID_LASSO_MAIN.Rda"))
saveRDS(final_lasso_sat, here::here("3 Model Fitting","GA_COVID_LASSO_SAT.Rda"))
