library(rstanarm)
library(bayesplot)
library(dplyr)

# 1. Define the Prior based on your Biden Term results
# We use the mean difference (~29.4) as the center of our prior belief
biden_prior_diff <- 29.4 

# 2. Run the Bayesian Model for Trump's 2nd Term
# We use stan_glm, which is a Bayesian version of a linear model
# This updates the 'Biden Prior' with 'Trump Evidence'
trump_bayesian_model <- stan_glm(
  Avg_Annual_Rate ~ winner_2024, 
  data = trump_term_avg,
  prior = normal(location = biden_prior_diff, scale = 10), # 'scale' is the uncertainty of the prior
  seed = 123,
  refresh = 0
)

# 3. View the Results
summary(trump_bayesian_model)

# 4. Calculate the "Probability of Superiority"
# This tells you: "What is the probability that Dem states have higher rates?"
posterior_samples <- as.data.frame(trump_bayesian_model)
# Note: winner_2024GOP represents the difference between GOP and DEM
prob_dem_higher <- sum(posterior_samples$winner_2024GOP < 0) / nrow(posterior_samples)

print(paste("Probability that Democratic states have higher approval rates:", 
            round(prob_dem_higher * 100, 2), "%"))

# 5. Visualize the Posterior Distribution
mcmc_areas(trump_bayesian_model, 
           pars = "winner_2024GOP", 
           prob = 0.95) +
  ggtitle("Posterior Distribution of the Difference (GOP vs DEM)") +
  theme_minimal()