###########################################################
#                   Model Fitting                         #
#                     Aidan T                             #
###########################################################

library(xtable)
library(tidymodels)
library(poissonreg)
library(sjPlot)
library(ggplot2)
# Sets the seed of reproducibility
set.seed(04272023)
# Imports the data
dat <- readRDS(here::here("1 Data","Processed","GACOVID_deaths.Rda"))
# Generates the data splitting format, the training data, and the test data
data_split <- rsample::initial_split(dat, prop=8/10)
training_data <- rsample::training(data_split)
test_data <- rsample::testing(data_split)
# Saves the test data for model diagnostics
saveRDS(test_data, here::here("1 Data","Processed","Test_Data.Rda"))
# Generates the cross validation scheme to include 5 folds and 5 repeats
folds <- rsample::vfold_cv(training_data,v=5,repeats=5)

# Generates the main model with the 6 main predictors
main_rec <- recipes::recipe(death_count ~ .,
                           data=training_data[2:8]) %>%
            recipes::step_dummy(all_nominal())
# Generates the saturated model with all predictors and their interaction terms
sat_rec <- recipes::recipe(death_count ~ party_majority+hospital_cap+
                                         per_capita_income+grad2020+grad_improve,
                           data=training_data[2:8]) %>%
           recipes::step_dummy(all_nominal()) %>%
           recipes::step_interact(terms = ~ recipes::all_predictors()^2)
# Sets the scheme for a Poisson model
poi_mod <- poisson_reg() %>%
           set_engine("glm")
# Sets the scheme for a main effects model
main_wf <- workflow() %>%
           add_recipe(main_rec)
# Sets the scheme for a saturated model including all main predictors and their
# interactions
sat_wf <- workflow() %>%
          add_recipe(sat_rec)
# Generates the necessary lambda values to test using the `glmnet` package
# Performs this step for only the main effects model and the saurated model
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
# Saves the plot that presents the lambda which minimizes the deviance for
# the main effects model
pdf(here::here("6 Supplemental Material","Main_Lambda_plot.pdf"))
plot(lasso_mod_main)
dev.off()
# Saves the plot that presents the lambda which minimizes the deviance for 
# the saturated model
pdf(here::here("6 Supplemental Material","Saturated_Lambda_plot.pdf"))
plot(lasso_mod_sat)
dev.off()
# Extracts the set of generated lambda values for both models
lasso_grid_main <- lasso_mod_main$lambda
lasso_grid_sat <- lasso_mod_sat$lambda
# Generates the scheme for a lasso object prior to tuning
lasso_mod <- poisson_reg(penalty = tune(),mixture=1) %>%
             set_engine("glmnet")
# Applies the main effects model and the saturated model to the lasso workflow,
# separately
lasso_main_wf <- main_wf %>%
                 add_model(lasso_mod)
lasso_sat_wf <- sat_wf %>%
                add_model(lasso_mod)
# Tunes the respective lasso workflows according to the lambda values saved prior
tune_lasso_main <- lasso_main_wf %>%
                   tune_grid(resample=folds,
                             grid=lasso_grid_main,
                             control=control_grid(save_pred=TRUE))
tune_lasso_sat <- lasso_sat_wf %>%
                  tune_grid(resample=folds,
                            grid=lasso_grid_sat,
                            control=control_grid(save_pred=TRUE))
# Selects the best model according to the model for each workflow with the best 
# RMSE
best_lasso_main <- tune_lasso_main %>%
                   select_best()
best_lasso_sat <- tune_lasso_sat %>%
                  select_best()
# Finalizes the workflow according to the best model
final_lasso_main <- lasso_main_wf %>%
                    finalize_workflow(best_lasso_main)
final_lasso_sat <- lasso_sat_wf %>%
                   finalize_workflow(best_lasso_sat)
# Saves each workflow as an R object
saveRDS(final_lasso_main, here::here("3 Model Fitting","GA_COVID_LASSO_MAIN.Rda"))
saveRDS(final_lasso_sat, here::here("3 Model Fitting","GA_COVID_LASSO_SAT.Rda"))