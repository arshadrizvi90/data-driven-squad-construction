# Main Pipeline Script for Football Squad Construction
# This script runs the complete analysis from data preparation to final outputs

# Author: Team 41C
# Date: 2025
# Description: Automated pipeline for building Durham Top Dogs F.C. squad

cat("\n")
cat("================================================================\n")
cat("  DURHAM TOP DOGS F.C. - SQUAD CONSTRUCTION PIPELINE\n")
cat("  Data-Driven Football Team Building\n")
cat("================================================================\n\n")

# Set working directory to project root
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Load required libraries
cat("Loading required libraries...\n")
suppressPackageStartupMessages({
  library(tidyverse)
  library(janitor)
  library(readr)
  library(caret)
  library(randomForest)
  library(knitr)
  library(dplyr)
  library(lpSolve)
})
cat("✓ Libraries loaded successfully\n\n")

# Create output directories if they don't exist
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
dir.create("data/outputs", recursive = TRUE, showWarnings = FALSE)
dir.create("visualizations", recursive = TRUE, showWarnings = FALSE)

# ================================================================
# STEP 1: Data Preparation
# ================================================================
cat("STEP 1: Data Preparation & Cleaning\n")
cat("------------------------------------\n")

if(file.exists("src/01_data_preparation.R")) {
  source("src/01_data_preparation.R")
  cat("✓ Data preparation complete\n\n")
} else {
  cat("⚠ Warning: Data preparation script not found. Skipping...\n\n")
}

# ================================================================
# STEP 2: Player Valuation Model
# ================================================================
cat("STEP 2: Player Valuation (Random Forest)\n")
cat("-----------------------------------------\n")

if(file.exists("src/02_player_valuation.R")) {
  source("src/02_player_valuation.R")
  cat("✓ Player valuation model complete\n\n")
} else {
  cat("⚠ Warning: Player valuation script not found. Skipping...\n\n")
}

# ================================================================
# STEP 3: Squad Optimization
# ================================================================
cat("STEP 3: Squad Optimization (ILP)\n")
cat("---------------------------------\n")

if(file.exists("src/03_squad_optimization.R")) {
  source("src/03_squad_optimization.R")
  cat("✓ Squad optimization complete\n\n")
} else {
  cat("⚠ Warning: Squad optimization script not found. Skipping...\n\n")
}

# ================================================================
# STEP 4: Lineup Generation
# ================================================================
cat("STEP 4: Tactical Lineup Generation\n")
cat("-----------------------------------\n")

if(file.exists("src/04_lineup_generation.R")) {
  source("src/04_lineup_generation.R")
  cat("✓ Lineup generation complete\n\n")
} else {
  cat("⚠ Warning: Lineup generation script not found. Skipping...\n\n")
}

# ================================================================
# STEP 5: Exploratory Analysis & Visualizations (Optional)
# ================================================================
cat("STEP 5: Generating Visualizations (Optional)\n")
cat("--------------------------------------------\n")

if(file.exists("analysis/exploratory_analysis.R")) {
  source("analysis/exploratory_analysis.R")
  cat("✓ Visualizations generated\n\n")
} else {
  cat("⚠ Info: Exploratory analysis script not found. Skipping...\n\n")
}

# ================================================================
# Pipeline Complete
# ================================================================
cat("================================================================\n")
cat("  PIPELINE COMPLETE!\n")
cat("================================================================\n\n")
cat("Final outputs can be found in:\n")
cat("  - data/outputs/         (Squad rosters and lineups)\n")
cat("  - visualizations/       (Charts and graphs)\n\n")
cat("Durham Top Dogs F.C. - Ready to compete!\n")
cat("================================================================\n\n")
