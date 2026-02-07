# Step 1: Data Preparation and Feature Engineering
# Loads raw FIFA 19 data, cleans it, and prepares it for modeling

# Load libraries
library(tidyverse)
library(janitor)
library(readr)

# Load utility functions
source("src/utils.R")

cat("\n=== STEP 1: DATA PREPARATION ===\n\n")

# ================================================================
# Load Raw Data
# ================================================================
cat("Loading raw data...\n")

# Check if data file exists
data_file <- "data/raw/fifa_eda_stats.csv"

if (!file.exists(data_file)) {
  cat("⚠ Data file not found at:", data_file, "\n")
  cat("Please place 'fifa_eda_stats.csv' in the data/raw/ directory\n")
  cat("Attempting interactive file selection...\n")
  
  # Interactive file selection (works in RStudio)
  data_file <- file.choose()
}

# Load and clean column names
master_data <- read_csv(data_file, show_col_types = FALSE) %>%
  clean_names()

cat("✓ Loaded", nrow(master_data), "players with", ncol(master_data), "attributes\n\n")

# ================================================================
# Create Unique Player Identifier
# ================================================================
cat("Creating unique player identifiers...\n")

master_data <- master_data %>%
  mutate(player_id = paste(name, id, sep = "_"))

cat("✓ Player IDs created\n\n")

# ================================================================
# Convert Currency Strings to Numeric Values
# ================================================================
cat("Converting currency values...\n")

master_data$value <- sapply(master_data$value, convert_currency)
master_data$wage <- sapply(master_data$wage, convert_currency)

cat("✓ Currency conversion complete\n")
cat("  - Value range:", 
    format_currency(min(master_data$value, na.rm = TRUE)), "to",
    format_currency(max(master_data$value, na.rm = TRUE)), "\n")
cat("  - Wage range:", 
    format_currency(min(master_data$wage, na.rm = TRUE)), "to",
    format_currency(max(master_data$wage, na.rm = TRUE)), "\n\n")

# ================================================================
# Filter Out Invalid Records
# ================================================================
cat("Filtering out records with missing critical data...\n")

initial_count <- nrow(master_data)

master_data <- master_data %>%
  filter(
    !is.na(overall),
    !is.na(value),
    !is.na(wage),
    !is.na(potential)
  )

removed_count <- initial_count - nrow(master_data)
cat("✓ Removed", removed_count, "records with missing data\n")
cat("  Remaining records:", nrow(master_data), "\n\n")

# ================================================================
# Create Position Groups
# ================================================================
cat("Creating position groups...\n")

master_data <- master_data %>%
  mutate(
    position_group = case_when(
      grepl("GK", position) ~ "GK",
      position %in% c("CB", "LB", "RB", "LCB", "RCB", "LWB", "RWB") ~ "DEF",
      position %in% c("CM", "CDM", "CAM", "LM", "RM", "LCM", "RCM") ~ "MID",
      TRUE ~ "FWD"
    )
  )

# Display position distribution
position_dist <- master_data %>%
  count(position_group) %>%
  arrange(desc(n))

cat("✓ Position groups created:\n")
print(position_dist)
cat("\n")

# ================================================================
# Feature Engineering: Tactical Scores
# ================================================================
cat("Engineering tactical attribute scores...\n")

master_data <- master_data %>%
  mutate(
    # Offensive capabilities
    offensive_score = (finishing + shot_power + long_shots + 
                      positioning + dribbling + sprint_speed) / 6,
    
    # Defensive capabilities
    defensive_score = (marking + standing_tackle + sliding_tackle + 
                      interceptions + strength + heading_accuracy) / 6,
    
    # Goalkeeping capabilities
    goalkeeping_score = (gk_diving + gk_handling + gk_kicking + 
                        gk_positioning + gk_reflexes) / 5,
    
    # Passing and playmaking
    passing_score = (short_passing + long_passing + crossing + vision) / 4,
    
    # Physical attributes
    physical_score = (strength + stamina + aggression) / 3
  )

cat("✓ Tactical scores calculated\n\n")

# ================================================================
# Data Quality Check
# ================================================================
cat("Running data quality checks...\n")

required_cols <- c("player_id", "name", "overall", "potential", "age", 
                  "value", "wage", "position_group")
validate_data(master_data, required_cols)

quality_issues <- check_data_quality(master_data)
if (length(quality_issues) > 0) {
  cat("⚠ Data quality issues found:\n")
  print(quality_issues)
} else {
  cat("✓ No data quality issues detected\n")
}
cat("\n")

# ================================================================
# Save Processed Data
# ================================================================
cat("Saving processed data...\n")

# Create output directory if it doesn't exist
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

# Save processed dataset
write_csv(master_data, "data/processed/master_data_cleaned.csv")

cat("✓ Processed data saved to: data/processed/master_data_cleaned.csv\n")
cat("  Total players:", nrow(master_data), "\n")
cat("  Total features:", ncol(master_data), "\n\n")

# ================================================================
# Summary Statistics
# ================================================================
cat("Dataset Summary:\n")
cat("----------------\n")
cat("Total Players:", nrow(master_data), "\n")
cat("Average Overall Rating:", round(mean(master_data$overall, na.rm = TRUE), 2), "\n")
cat("Average Potential:", round(mean(master_data$potential, na.rm = TRUE), 2), "\n")
cat("Average Age:", round(mean(master_data$age, na.rm = TRUE), 1), "years\n")
cat("Total Market Value:", format_currency(sum(master_data$value, na.rm = TRUE)), "\n")
cat("\n")

cat("=== DATA PREPARATION COMPLETE ===\n\n")

# Make processed data available globally for next steps
assign("master_data", master_data, envir = .GlobalEnv)
