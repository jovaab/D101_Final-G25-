H-1B Approval Analysis by Political Affiliation

This R script analyzes the relationship between US Presidential election results and H-1B visa approval numbers across different states. It compares approval counts during specific fiscal terms (Biden and Trump) to determine if there is a statistically significant difference in approvals between "Red" and "Blue" states.

## Features
Data Integration: Merges historical H-1B petition data with presidential election results.

State Mapping: Automatically maps state abbreviations (e.g., "CA") to full names (e.g., "California") for seamless dataset joining.

Temporal Filtering: Splits data into two distinct periods:

Biden Term: Fiscal Years 2021–2024 (linked to 2020 election results).

Trump Term: Fiscal Years 2025–2026 (linked to 2024 election results).

Statistical Analysis: Performs independent samples Welch T-Tests to compare approval means between states won by different parties.

## Requirements
Libraries
You will need the following R packages installed:

dplyr: For data manipulation and filtering.

tidyr: For data tidying.

ggplot2: Included for visualization (though currently used for backend structure).

Required Files
The script expects two CSV files in the working directory:

h1b_clean_utf8.csv: Must contain Fiscal.Year, Petitioner.State, and Total.Approvals.

combined_presidential_results.csv: Must contain year, state_name, and winner.

## Script Logic
Preprocessing: Filters out missing values and aggregates total approvals by state and fiscal year.

Joining: Uses a lookup table to align H-1B state codes with election state names.

Segmentation: * Links 2020 election winners to approvals from 2021 to 2024.

Links 2024 election winners to approvals from 2025 to 2026.

Testing: Executes t.test() to check if the winner variable significantly impacts Total_Approvals.

## Usage
Place your data files in your R project folder.

Open the script in RStudio.

Run the script to output the T-test results to the console.

Note: The T-test assumes the data follows a normal distribution and compares the means of two groups (Democratic vs. Republican states). Ensure your Total.Approvals column is numeric.

## Output Interpretation
The script prints two sets of results. Focus on the p-value:

p < 0.05: There is a statistically significant difference in H-1B approvals between states won by different parties during that term.

p > 0.05: No significant difference was detected.
