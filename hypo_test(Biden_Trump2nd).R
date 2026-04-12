# Load necessary libraries
library(dplyr)
library(tidyr)
library(ggplot2)

# 1. Load the datasets
h1b_data <- read.csv("h1b_clean_utf8.csv")
election_data <- read.csv("combined_presidential_results.csv")

# 2. Define state mapping (Abbreviation to Full Name)
state_map <- data.frame(
  state_name = c(
    "Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", 
    "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", 
    "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", 
    "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", 
    "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", 
    "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", 
    "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", 
    "Wisconsin", "Wyoming", "District of Columbia"
  ),
  Petitioner.State = c(
    "AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", 
    "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", 
    "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", 
    "UT", "VT", "VA", "WA", "WV", "WI", "WY", "DC"
  )
)

# 3. Clean and Aggregate H1B Data
h1b_clean <- h1b_data %>%
  filter(!is.na(Fiscal.Year), !is.na(Petitioner.State), !is.na(Total.Approvals)) %>%
  group_by(Petitioner.State, Fiscal.Year) %>%
  summarise(Total_Approvals = sum(Total.Approvals), .groups = 'drop') %>%
  left_join(state_map, by = "Petitioner.State") %>%
  filter(!is.na(state_name))

# 4. Prepare Election Data
election_2020 <- election_data %>% 
  filter(year == 2020) %>% 
  select(state_name, winner_2020 = winner)

election_2024 <- election_data %>% 
  filter(year == 2024) %>% 
  select(state_name, winner_2024 = winner)

# 5. Split and Merge by Periods
# Biden Term (2021-2024)
biden_term <- h1b_clean %>%
  filter(Fiscal.Year >= 2021 & Fiscal.Year <= 2024) %>%
  left_join(election_2020, by = "state_name") %>%
  filter(!is.na(winner_2020))

# Trump Term (2025-2026)
trump_term <- h1b_clean %>%
  filter(Fiscal.Year >= 2025 & Fiscal.Year <= 2026) %>%
  left_join(election_2024, by = "state_name") %>%
  filter(!is.na(winner_2024))

# 6. Conduct Independent Samples T-Tests
# Biden Term Test
biden_test <- t.test(Total_Approvals ~ winner_2020, data = biden_term)
print("Biden Term (2021-2024) T-Test Results:")
print(biden_test)

# Trump Term Test
trump_test <- t.test(Total_Approvals ~ winner_2024, data = trump_term)
print("Trump Term (2025-2026) T-Test Results:")
print(trump_test)

