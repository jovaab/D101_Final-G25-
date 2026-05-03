# 1. Import necessary Libraries
library(dplyr)
library(tidyr)

# 2. Setup Helper Data
# Create state_map to bridge abbreviations (e.g., "NJ") and full names (e.g., "New Jersey")
state_map <- data.frame(
  Petitioner.State = state.abb,
  state_name = state.name
)

# Population data (using built-in R data)
pop_data <- data.frame(
  state_name = state.name,
  population = state.x77[, "Population"] * 1000 
) %>%
  add_row(state_name = "District of Columbia", population = 671803)

# 3. Pivot Election Data
# Converts the data from long (one year per row) to wide (winners as separate columns)
election_wide <- combined_presidential_results %>%
  select(state_name, year, winner) %>%
  pivot_wider(names_from = year, values_from = winner, names_prefix = "winner_")

# 4. Clean and Normalize H-1B Data
# Using h1b.2021.2026 dataset
h1b_normalized <- h1b.2021.2026 %>%
  dplyr::filter(!is.na(Fiscal.Year), !is.na(Petitioner.State), !is.na(New.Employment.Approval)) %>%
  group_by(Petitioner.State, Fiscal.Year) %>%
  summarise(Total_Approvals = sum(New.Employment.Approval, na.rm = TRUE), .groups = 'drop') %>%
  left_join(state_map, by = "Petitioner.State") %>%
  left_join(pop_data, by = "state_name") %>%
  dplyr::filter(!is.na(state_name)) %>%
  mutate(Approvals_Per_100k = (Total_Approvals / population) * 100000)

# --- BIDEN TERM ANALYSIS (2021-2024) ---

# 5. Join with pivoted 2020 results
biden_term_avg <- h1b_normalized %>%
  dplyr::filter(Fiscal.Year >= 2021 & Fiscal.Year <= 2024) %>%
  left_join(election_wide, by = "state_name") %>%
  dplyr::filter(!is.na(winner_2020)) %>%
  group_by(state_name, winner_2020) %>%
  # Using mean to normalize for the 4-year duration
  summarise(Avg_Annual_Rate = mean(Approvals_Per_100k, na.rm = TRUE), .groups = 'drop')

# 6. T-Test for Biden Term
biden_test_results <- t.test(Avg_Annual_Rate ~ winner_2020, data = biden_term_avg)

print("--- Biden Term (2021-2024) T-Test Results ---")
print(biden_test_results)


# --- TRUMP TERM ANALYSIS (2025-2026) ---

# 7. Join with pivoted 2024 results
trump_term_avg <- h1b_normalized %>%
  dplyr::filter(Fiscal.Year >= 2025 & Fiscal.Year <= 2026) %>%
  left_join(election_wide, by = "state_name") %>%
  dplyr::filter(!is.na(winner_2024)) %>%
  group_by(state_name, winner_2024) %>%
  # Using mean to normalize for the 2-year duration
  summarise(Avg_Annual_Rate = mean(Approvals_Per_100k, na.rm = TRUE), .groups = 'drop')

# 8. T-Test for Trump Term
trump_test_results <- t.test(Avg_Annual_Rate ~ winner_2024, data = trump_term_avg)

print("--- Trump Term (2025-2026) T-Test Results ---")
print(trump_test_results)
