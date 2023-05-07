###########################################################
#                   Model Evaluation                      #
#                     Aidan T                             #
###########################################################

library(xtable)
library(tidymodels)
library(poissonreg)
library(sjPlot)
library(ggplot2)
library(visreg)
library(ggiraphExtra)
library(grid)
# Sets the seed for reproducibility
set.seed(04272023)
# Imports the test data
test <- readRDS(here::here("1 Data","Processed","Test_Data.Rda"))
# Imports the model workflows
lasso_main <- readRDS(here::here("3 Model Fitting","GA_COVID_LASSO_MAIN.Rda"))
lasso_sat <- readRDS(here::here("3 Model Fitting","GA_COVID_LASSO_SAT.Rda"))
# Fits each model to the test data
test_main <- lasso_main %>%
             fit(data=test)
test_sat <- lasso_sat %>%
            fit(data=test)
# Duplicates the test data and adds new columns for the residual and the squared
# residual
test_main_pred <- augment(test_main,test) %>%
                  mutate(res = death_count - .pred,
                         res2 = res^2)
test_sat_pred <- augment(test_sat,test) %>%
                 mutate(res = death_count - .pred,
                        res2 = res^2)
# Organizes the coefficients of the model into a table
knitr::kable(tidy(test_main))
knitr::kable(tidy(test_sat))
# Compares and organizes the RMSE for each of the main effects model and the 
# saturated model
saveRDS(data.frame("RMSE for Main Model" = 
                   c(sqrt(sum(test_main_pred$res2)/(nrow(test_main_pred)-1))),
                   "RMSE for Main Model and Interactions" = 
                   c(sqrt(sum(test_sat_pred$res2)/(nrow(test_sat_pred)-1)))),
        here::here("4 Products","Figures","RMSE_results.Rda"))

# Compares the fit of the main effects lasso model to the original data
ggsave(here::here("4 Products","Figures","Model_Eval1.pdf"),
       ggpubr::ggarrange(
                  ggplot(data=test_main_pred, aes(death_count,.pred)) +
                  geom_point(aes(color=party_majority,
                                 size=log(pop_projection))) +
                  geom_abline(linetype = "dashed") +
                  labs(x="Observed Number of Deaths \n Attributed to COVID-19",
                       y="Predicted Number of Deaths from the Main Effects Model") +
                  theme(legend.position = "none",
                        legend.box="vertical") +
                  guides(color = guide_legend("Party Majority",order = 1),
                         size = guide_legend("Log Population Size",order = 2)) +
                  scale_color_manual(values=c("blue","red")),
# Compares the fit of the saturated lasso model to the original data
                  ggplot(data=test_sat_pred, aes(death_count,.pred)) +
                  geom_point(aes(color=party_majority,
                                 size=log(pop_projection))) +
                  geom_abline(linetype = "dashed") +
                  labs(x="Observed Number of Deaths \n Attributed to COVID-19",
                       y="Predicted Number of Deaths from the Saturated Model",
                       fill = "Party Majority (>50%)") +
                  theme(legend.position = "none",
                        legend.box="vertical") +
                  guides(color = guide_legend("Party Majority",order = 1),
                         size = guide_legend("Log Population Size",order = 2)) +
                  scale_color_manual(values=c("blue","red")),
        ncol=2,common.legend = TRUE,legend="bottom"))
# Plots the residuals and 2 standard deviations away from 0 for the main effects
# model
ggsave(here::here("4 Products","Figures","Model_Eval2.pdf"),
       ggpubr::ggarrange(
               ggplot(data=test_main_pred, aes(death_count,res)) +
               geom_point(aes(color=party_majority,size=log(pop_projection))) +
               geom_hline(yintercept=0, color="red") +
               geom_hline(yintercept=
                          2*sqrt(sum(test_main_pred$res2)/(nrow(test_main_pred))),
                          linetype="dashed",color="blue") +
               geom_hline(yintercept=
                          -2*sqrt(sum(test_main_pred$res2)/(nrow(test_main_pred))),
                          linetype="dashed",color="blue") +
               labs(x = "Observed Number of Deaths \n Attributed to COVID-19",
                    y = "Main Effects Model Residual") +
               theme(legend.box = "vertical") +
               guides(color = guide_legend("Party Majority",order = 1),
                      size = guide_legend("Log Population Size",order = 2)) +
               scale_color_manual(values=c("blue","red")),
# Plots the residuals and 2 standard deviations away from 0 for the saturated
# model
               ggplot(data=test_sat_pred, aes(death_count,res)) +
               geom_point(aes(color=party_majority,size=log(pop_projection))) +
               geom_hline(yintercept=0,color="red") +
               geom_hline(yintercept=
                          2*sqrt(sum(test_sat_pred$res2)/(nrow(test_sat_pred))),
                          linetype="dashed",color="blue") +
               geom_hline(yintercept=
                          -2*sqrt(sum(test_sat_pred$res2)/(nrow(test_sat_pred))),
                          linetype="dashed",color="blue") +
               labs(x = "Observed Number of Deaths \n Attributed to COVID-19",
                    y = "Saturated Model Residual") +
               theme(legend.box = "vertical") +
               guides(color = guide_legend("Party Majority",order = 1),
                      size = guide_legend("Log Population Size",order = 2)) +
               scale_color_manual(values=c("blue","red")),
       ncol=2,common.legend=TRUE,legend="bottom"))
# Initiates a plot centering on the saturated model
plot <- ggplot(data=test_sat_pred)
# Demonstrates the model fit compared to the original data as a scatter plot
# while comparing number of graduates to COVID deaths
ggsave(here::here("4 Products","Figures","Mod_Effects.pdf"),
       ggpubr::ggarrange(
       plot + geom_point(aes(x=hospital_cap,y=death_count)) + 
       geom_smooth(aes(x=hospital_cap,y=.pred)) +
       labs(x = "Hospital Bed Capacity \n by County in Georgia",
            y = "COVID Deaths by County in Georgia"),
# Demonstrates the model fit compared to the original data as a scatter plot
# while comparing number of available hospital beds to COVID deaths
       plot + geom_point(aes(per_capita_income,y=death_count)) + 
       geom_smooth(aes(x=per_capita_income,y=.pred)) +
       labs(x = "Log Per Capita Income \n by County in Georgia",
            y = "COVID Deaths by County in Georgia"),
# Demonstrates the model fit compared to the original data as a scatter plot
# while comparing logged per capita income to COVID deaths
       plot + geom_point(aes(grad2020,y=death_count)) + 
       geom_smooth(aes(x=grad2020,y=.pred)) +
       labs(x = "Number of Graduates \n by County in Georgia",
            y = "COVID Deaths by County in Georgia")))
