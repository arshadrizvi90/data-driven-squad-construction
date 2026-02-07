# Step 4: Lineup Generation
# Creates chemistry-optimized and tactical lineups from the 25-man squad

# Load libraries
library(dplyr)
library(knitr)

# Load utility functions
source("src/utils.R")

cat("\n=== STEP 4: TACTICAL LINEUP GENERATION ===\n\n")

# ================================================================
# Load Final Squad and Full Data
# ================================================================
cat("Loading final squad and player details...\n")

if (!exists("final_team_roster")) {
  final_team_roster <- read_csv("data/outputs/final_25_man_squad.csv",
                               show_col_types = FALSE)
}

if (!exists("master_data")) {
  master_data <- read_csv("data/processed/master_data_cleaned.csv",
                         show_col_types = FALSE)
}

# Get detailed stats for squad members
squad_details <- master_data %>%
  filter(player_id %in% final_team_roster$player_id)

cat("✓ Squad loaded:", nrow(squad_details), "players\n\n")

# ================================================================
# Chemistry Analysis
# ================================================================
cat("Analyzing squad chemistry...\n")

# Find most common club and nationality
common_club <- squad_details %>%
  count(club) %>%
  slice_max(n = 1, order_by = n, with_ties = FALSE) %>%
  pull(club)

common_nationality <- squad_details %>%
  count(nationality) %>%
  slice_max(n = 1, order_by = n, with_ties = FALSE) %>%
  pull(nationality)

cat("Most common club:", common_club, "\n")
cat("Most common nationality:", common_nationality, "\n\n")

# Calculate chemistry weights for each player
squad_details <- squad_details %>%
  mutate(
    chemistry_weight = (club == common_club) * 3 + 
                      (nationality == common_nationality) * 1,
    selection_score = overall + (chemistry_weight * 5)
  )

# ================================================================
# LINEUP 1: Chemistry-Optimized Starting XI (4-4-2)
# ================================================================
cat("Generating Chemistry-Optimized Starting XI (4-4-2)...\n")

chemistry_xi <- bind_rows(
  squad_details %>% filter(position_group == "GK") %>% 
    slice_max(n = 1, order_by = goalkeeping_score, with_ties = FALSE),
  squad_details %>% filter(position_group == "DEF") %>% 
    slice_max(n = 4, order_by = selection_score, with_ties = FALSE),
  squad_details %>% filter(position_group == "MID") %>% 
    slice_max(n = 4, order_by = selection_score, with_ties = FALSE),
  squad_details %>% filter(position_group == "FWD") %>% 
    slice_max(n = 2, order_by = selection_score, with_ties = FALSE)
)

chemistry_score <- calculate_chemistry(chemistry_xi)

cat("✓ Chemistry XI created\n")
cat("  Total Chemistry Score:", chemistry_score, "\n")
cat("  Average Overall:", round(mean(chemistry_xi$overall), 2), "\n\n")

# Display Chemistry XI
chemistry_xi_display <- chemistry_xi %>%
  select(Name = name, Position = position, Club = club, 
         Nationality = nationality, Overall = overall) %>%
  arrange(factor(chemistry_xi$position_group, levels = c("GK", "DEF", "MID", "FWD")))

cat("⚽ STARTING XI: CHEMISTRY-OPTIMIZED (4-4-2) ⚽\n")
print(kable(chemistry_xi_display, 
           caption = paste("Chemistry Score:", chemistry_score)))
cat("\n")

# ================================================================
# LINEUP 2: Balanced Starting XI (4-4-2)
# ================================================================
cat("Generating Balanced Starting XI (4-4-2)...\n")

balanced_xi <- bind_rows(
  squad_details %>% filter(position_group == "GK") %>% 
    slice_max(n = 1, order_by = goalkeeping_score, with_ties = FALSE),
  squad_details %>% filter(position_group == "DEF") %>% 
    slice_max(n = 4, order_by = overall, with_ties = FALSE),
  squad_details %>% filter(position_group == "MID") %>% 
    slice_max(n = 4, order_by = overall, with_ties = FALSE),
  squad_details %>% filter(position_group == "FWD") %>% 
    slice_max(n = 2, order_by = overall, with_ties = FALSE)
)

cat("✓ Balanced XI created\n")
cat("  Average Overall:", round(mean(balanced_xi$overall), 2), "\n\n")

balanced_xi_display <- balanced_xi %>%
  select(Name = name, Position = position, Club = club, Overall = overall) %>%
  arrange(factor(balanced_xi$position_group, levels = c("GK", "DEF", "MID", "FWD")))

cat("⚽ STARTING XI: BALANCED (4-4-2) ⚽\n")
print(kable(balanced_xi_display))
cat("\n")

# ================================================================
# LINEUP 3: Defensive Starting XI (5-3-2)
# ================================================================
cat("Generating Defensive Starting XI (5-3-2)...\n")

defensive_xi <- bind_rows(
  squad_details %>% filter(position_group == "GK") %>% 
    slice_max(n = 1, order_by = goalkeeping_score, with_ties = FALSE),
  squad_details %>% filter(position_group == "DEF") %>% 
    slice_max(n = 5, order_by = defensive_score, with_ties = FALSE),
  squad_details %>% filter(position_group == "MID") %>% 
    slice_max(n = 3, order_by = defensive_score, with_ties = FALSE),
  squad_details %>% filter(position_group == "FWD") %>% 
    slice_max(n = 2, order_by = overall, with_ties = FALSE)
)

cat("✓ Defensive XI created\n")
cat("  Average Defensive Score:", 
    round(mean(defensive_xi$defensive_score, na.rm = TRUE), 2), "\n\n")

defensive_xi_display <- defensive_xi %>%
  select(Name = name, Position = position, Club = club, Overall = overall,
         `Defensive Score` = defensive_score) %>%
  arrange(factor(defensive_xi$position_group, levels = c("GK", "DEF", "MID", "FWD")))

cat("🛡 STARTING XI: DEFENSIVE (5-3-2) 🛡\n")
print(kable(defensive_xi_display))
cat("\n")

# ================================================================
# LINEUP 4: Offensive Starting XI (4-3-3)
# ================================================================
cat("Generating Offensive Starting XI (4-3-3)...\n")

offensive_xi <- bind_rows(
  squad_details %>% filter(position_group == "GK") %>% 
    slice_max(n = 1, order_by = goalkeeping_score, with_ties = FALSE),
  squad_details %>% filter(position_group == "DEF") %>% 
    slice_max(n = 4, order_by = overall, with_ties = FALSE),
  squad_details %>% filter(position_group == "MID") %>% 
    slice_max(n = 3, order_by = offensive_score, with_ties = FALSE),
  squad_details %>% filter(position_group == "FWD") %>% 
    slice_max(n = 3, order_by = offensive_score, with_ties = FALSE)
)

cat("✓ Offensive XI created\n")
cat("  Average Offensive Score:", 
    round(mean(offensive_xi$offensive_score, na.rm = TRUE), 2), "\n\n")

offensive_xi_display <- offensive_xi %>%
  select(Name = name, Position = position, Club = club, Overall = overall,
         `Offensive Score` = offensive_score) %>%
  arrange(factor(offensive_xi$position_group, levels = c("GK", "DEF", "MID", "FWD")))

cat("⚡ STARTING XI: OFFENSIVE (4-3-3) ⚡\n")
print(kable(offensive_xi_display))
cat("\n")

# ================================================================
# GAME DAY PLAYBOOK: Set-Piece Specialists
# ================================================================
cat("Identifying set-piece specialists...\n")

specialists <- tribble(
  ~Role, ~Player,
  "Penalty Taker", 
    (squad_details %>% slice_max(n = 1, order_by = (penalties + composure)))$name,
  "Direct Free Kick", 
    (squad_details %>% slice_max(n = 1, order_by = (fk_accuracy + curve + shot_power)))$name,
  "Corner Kicks", 
    (squad_details %>% slice_max(n = 1, order_by = (crossing + curve)))$name,
  "Long Throw-Ins",
    (squad_details %>% slice_max(n = 1, order_by = strength))$name
)

cat("✓ Set-piece specialists identified\n\n")

cat("🎯 SET-PIECE SPECIALISTS 🎯\n")
print(kable(specialists))
cat("\n")

# ================================================================
# GAME DAY PLAYBOOK: Impact Substitutes
# ================================================================
cat("Identifying impact substitutes...\n")

# Exclude balanced XI players from bench
bench_players <- squad_details %>%
  filter(!player_id %in% balanced_xi$player_id)

substitutes <- tribble(
  ~Role, ~Player,
  "Offensive Spark (Chasing Goal)", 
    (bench_players %>% filter(position_group %in% c("FWD", "MID")) %>% 
     slice_max(n = 1, order_by = offensive_score))$name,
  "Defensive Closer (Protecting Lead)", 
    (bench_players %>% filter(position_group %in% c("DEF", "MID")) %>% 
     slice_max(n = 1, order_by = defensive_score))$name,
  "Fresh Legs (Late Game Energy)",
    (bench_players %>% filter(position_group %in% c("MID", "FWD")) %>%
     slice_max(n = 1, order_by = stamina))$name
)

cat("✓ Impact substitutes identified\n\n")

cat("⚡ IMPACT SUBSTITUTES ⚡\n")
print(kable(substitutes))
cat("\n")

# ================================================================
# Save All Lineups and Playbook
# ================================================================
cat("Saving lineups and game day playbook...\n")

# Save lineups
write_csv(chemistry_xi, "data/outputs/lineup_chemistry_442.csv")
write_csv(balanced_xi, "data/outputs/lineup_balanced_442.csv")
write_csv(defensive_xi, "data/outputs/lineup_defensive_532.csv")
write_csv(offensive_xi, "data/outputs/lineup_offensive_433.csv")

# Save playbook components
write_csv(specialists, "data/outputs/setpiece_specialists.csv")
write_csv(substitutes, "data/outputs/impact_substitutes.csv")

# Create comprehensive game day playbook
playbook <- list(
  chemistry_xi = chemistry_xi_display,
  balanced_xi = balanced_xi_display,
  defensive_xi = defensive_xi_display,
  offensive_xi = offensive_xi_display,
  specialists = specialists,
  substitutes = substitutes
)

# Save playbook summary
sink("data/outputs/game_day_playbook.txt")
cat("==============================================\n")
cat("  DURHAM TOP DOGS F.C. - GAME DAY PLAYBOOK\n")
cat("==============================================\n\n")
cat("Chemistry-Optimized XI (4-4-2)\n")
print(kable(chemistry_xi_display))
cat("\n\nBalanced XI (4-4-2)\n")
print(kable(balanced_xi_display))
cat("\n\nDefensive XI (5-3-2)\n")
print(kable(defensive_xi_display))
cat("\n\nOffensive XI (4-3-3)\n")
print(kable(offensive_xi_display))
cat("\n\nSet-Piece Specialists\n")
print(kable(specialists))
cat("\n\nImpact Substitutes\n")
print(kable(substitutes))
sink()

cat("✓ All lineups saved to data/outputs/\n")
cat("✓ Game day playbook saved to: data/outputs/game_day_playbook.txt\n\n")

cat("=== LINEUP GENERATION COMPLETE ===\n\n")

# Summary
cat("Summary of Generated Lineups:\n")
cat("-----------------------------\n")
cat("1. Chemistry-Optimized (4-4-2) - Max team cohesion\n")
cat("2. Balanced (4-4-2) - Best overall ratings\n")
cat("3. Defensive (5-3-2) - Protect a lead\n")
cat("4. Offensive (4-3-3) - Chase a goal\n")
cat("\nPlus: Set-piece specialists and impact substitutes\n\n")
