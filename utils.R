# Utility Functions for Football Squad Construction
# Helper functions used across multiple scripts

# ================================================================
# Currency Conversion Function
# ================================================================
# Converts FIFA currency strings (€110.5M, €5K) to numeric values

convert_currency <- function(x) {
  if (is.na(x) || x == "") { 
    return(NA) 
  }
  
  # Clean data and handle 'M' or 'K' multipliers
  x <- gsub("€", "", x)
  x <- gsub(" ", "", x)
  
  if (grepl("M", x, ignore.case = TRUE)) {
    return(as.numeric(gsub("M", "", x, ignore.case = TRUE)) * 1e6)
  } else if (grepl("K", x, ignore.case = TRUE)) {
    return(as.numeric(gsub("K", "", x, ignore.case = TRUE)) * 1e3)
  } else {
    return(as.numeric(x))
  }
}

# ================================================================
# Position Grouping Function
# ================================================================
# Simplifies detailed positions into 4 main groups

assign_position_group <- function(position) {
  case_when(
    grepl("GK", position) ~ "GK",
    position %in% c("CB", "LB", "RB", "LCB", "RCB", "LWB", "RWB") ~ "DEF",
    position %in% c("CM", "CDM", "CAM", "LM", "RM", "LCM", "RCM") ~ "MID",
    TRUE ~ "FWD"
  )
}

# ================================================================
# Chemistry Calculation Function
# ================================================================
# Calculates team chemistry based on shared clubs and nationalities

calculate_chemistry <- function(lineup_df) {
  score <- 0
  
  # Generate all unique pairs of players
  player_pairs <- combn(lineup_df$player_id, 2, simplify = FALSE)
  
  for (pair in player_pairs) {
    player1 <- lineup_df %>% filter(player_id == pair[1])
    player2 <- lineup_df %>% filter(player_id == pair[2])
    
    # Same club: +3 chemistry
    if (player1$club == player2$club) {
      score <- score + 3
    } 
    # Same nationality: +1 chemistry
    else if (player1$nationality == player2$nationality) {
      score <- score + 1
    }
  }
  
  return(score)
}

# ================================================================
# Tactical Score Calculations
# ================================================================
# Calculate various tactical attribute scores

calculate_offensive_score <- function(df) {
  df %>%
    mutate(
      offensive_score = (finishing + shot_power + long_shots + 
                        positioning + dribbling + sprint_speed) / 6
    )
}

calculate_defensive_score <- function(df) {
  df %>%
    mutate(
      defensive_score = (marking + standing_tackle + sliding_tackle + 
                        interceptions + strength + heading_accuracy) / 6
    )
}

calculate_goalkeeping_score <- function(df) {
  df %>%
    mutate(
      goalkeeping_score = (gk_diving + gk_handling + gk_kicking + 
                          gk_positioning + gk_reflexes) / 5
    )
}

# ================================================================
# Value Gap Calculation
# ================================================================
# Identifies undervalued players

calculate_value_gap <- function(predicted_value, actual_value) {
  predicted_value - actual_value
}

# ================================================================
# Player Summary Statistics
# ================================================================
# Generate summary statistics for a squad

squad_summary_stats <- function(squad_df) {
  list(
    total_players = nrow(squad_df),
    avg_overall = mean(squad_df$overall, na.rm = TRUE),
    avg_age = mean(squad_df$age, na.rm = TRUE),
    total_cost = sum(squad_df$value, na.rm = TRUE),
    position_breakdown = table(squad_df$position_group),
    avg_potential = mean(squad_df$potential, na.rm = TRUE)
  )
}

# ================================================================
# Format Currency for Display
# ================================================================
# Converts numeric values back to readable currency format

format_currency <- function(value) {
  if (is.na(value)) return("€0")
  
  if (value >= 1e6) {
    paste0("€", format(value / 1e6, digits = 3, nsmall = 1), "M")
  } else if (value >= 1e3) {
    paste0("€", format(value / 1e3, digits = 3, nsmall = 1), "K")
  } else {
    paste0("€", format(value, big.mark = ","))
  }
}

# ================================================================
# Data Validation Functions
# ================================================================

# Check for missing critical columns
validate_data <- function(df, required_cols) {
  missing_cols <- setdiff(required_cols, names(df))
  
  if (length(missing_cols) > 0) {
    stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
  }
  
  return(TRUE)
}

# Check for data quality issues
check_data_quality <- function(df) {
  issues <- list()
  
  # Check for NA values in critical columns
  critical_cols <- c("overall", "value", "wage", "age")
  for (col in critical_cols) {
    if (col %in% names(df)) {
      na_count <- sum(is.na(df[[col]]))
      if (na_count > 0) {
        issues[[col]] <- paste0(na_count, " NA values")
      }
    }
  }
  
  return(issues)
}

# ================================================================
# Export Results Functions
# ================================================================

# Save squad to CSV
export_squad <- function(squad_df, filename) {
  filepath <- file.path("data/outputs", filename)
  write_csv(squad_df, filepath)
  cat("✓ Squad exported to:", filepath, "\n")
}

# Save lineup to CSV
export_lineup <- function(lineup_df, filename) {
  filepath <- file.path("data/outputs", filename)
  write_csv(lineup_df, filepath)
  cat("✓ Lineup exported to:", filepath, "\n")
}

cat("✓ Utility functions loaded successfully\n")
