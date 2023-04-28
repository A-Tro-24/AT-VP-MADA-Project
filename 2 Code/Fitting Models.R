###########################################################
#                   Model Fitting                         #
#                   Aidan T & Vijay P                     #
###########################################################
library(tidymodels)
library(poissonreg)

set.seed(04272023)

dat <- readRDS(here::here("1 Data","Processed","GACOVID_deaths.Rda"))

data_split <- rsample::initial_split(dat, prop=8/10)
training_data <- rsample::training(data_split)
test_data <- rsample::testing(data_split)
folds <- rsample::vfold_cv(training_data,v=3,repeats=3)

main_rec <- recipes::recipe(`Death Count` ~ party_majority+`2021 General Hospital Facilities`+per_capita_income+grad2020+grad_improve,
                            data=dat) %>%
            recipes::step_dummy(all_nominal())

pois_mod <- poisson_reg(mode="regression",
                        engine="glm")

pois_wf <- workflow() %>%
           add_recipe(main_rec)

pois_mod <- pois_wf %>%
            add_model(pois_mod)

null_resamp <- fit_resamples(pois_mod, folds, metrics = metric_set(rmse),
                             control = control_resamples(save_pred = TRUE))
null_resamp %>% collect_metrics()

lasso_mod <- poisson_reg(penalty = tune(), mixture = 1) %>%
             set_engine("glmnet")

lasso_grid <- tibble::tibble(penalty=10^seq(-5,0,length.out=20))

lasso_wf <- pois_wf %>%
            add_model(lasso_mod)

lasso_tune_res <- lasso_wf %>%
                  tune_grid(resample=folds,
                            grid = lasso_grid,
                            control = control_grid(save_pred = TRUE),
                            metrics = metric_set(rmse))
lasso_tune_res %>% autoplot()

lasso_best <- lasso_tune_res %>%
              select_best()
final_lasso <- lasso_wf %>%
               finalize_workflow(lasso_best)

final_fit <- final_lasso %>%
             fit(training_data) %>%
             augment(training_data)

ggplot(aes(`Death Count`,.pred),data=final_fit) +
  geom_jitter()

final_fit %>%
  mutate(res = `Death Count` - .pred) %>%
  ggplot(aes(.pred,res)) +
  geom_jitter()

saveRDS(final_lasso, here::here("3 Model Fitting","COVID_LASSO.Rda"))
