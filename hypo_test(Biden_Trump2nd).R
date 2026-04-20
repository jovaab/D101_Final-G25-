# 1. Import necessary Libraries
library(dplyr)
library(tidyr)

# 2. Add State Population Data
# Using built-in R state data for quick normalization
pop_data <- data.frame(
  state_name = state.name,
  population = state.x77[, "Population"] * 1000 # state.x77 stores in 1000s
) %>%
  # Add DC manually since it's not in the state.name dataset
  add_row(state_name = "District of Columbia", population = 671803)

# 3. Clean, Aggregate, and Normalize
h1b_normalized <- h1b_data %>%
  dplyr::filter(!is.na(Fiscal.Year), !is.na(Petitioner.State), !is.na(New.Employment.Approval)) %>%
  group_by(Petitioner.State, Fiscal.Year) %>%
  summarise(Total_Approvals = sum(New.Employment.Approval, na.rm = TRUE), .groups = 'drop') %>%
  left_join(state_map, by = "Petitioner.State") %>%
  left_join(pop_data, by = "state_name") %>%
  dplyr::filter(!is.na(state_name)) %>%
  # Calculate the Per Capita Rate
  mutate(Approvals_Per_100k = (Total_Approvals / population) * 100000)

# 4. Prepare Election Data
# 5. Split and Merge (Biden)
biden_term_norm <- h1b_normalized %>%
  dplyr::filter(Fiscal.Year >= 2021 & Fiscal.Year <= 2024) %>%
  left_join(election_2020, by = "state_name") %>%
  dplyr::filter(!is.na(winner_2020))

# 6. Conduct T-Test on Normalized Rates
biden_test_norm <- t.test(Approvals_Per_100k ~ winner_2020, data = biden_term_norm)

print("Biden Term Normalized (Per 100k) T-Test:")
print(biden_test_norm)

# 7. Split and Merge (Trump)
trump_term_norm <- h1b_normalized %>%
  dplyr::filter(Fiscal.Year >= 2025 & Fiscal.Year <= 2026) %>%
  left_join(election_2024, by = "state_name") %>%
  dplyr::filter(!is.na(winner_2024))

#8. Conduct T-Test on Normalized Rates
trump_test_norm <- t.test(Approvals_Per_100k ~ winner_2024, data = trump_term_norm)

print("Trump Term (2025-2026) PER CAPITA T-Test Results:")
print(trump_test_norm)
