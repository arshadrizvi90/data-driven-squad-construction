# Step 3: Squad Optimization
# Integer Linear Programming to select optimal 25-man squad

# Load libraries
library(lpSolve)
library(dplyr)
library(knitr)

# Load utility functions
source("src/utils.R")

cat("\n=== STEP 3: SQUAD OPTIMIZATION (ILP) ===\n\n")

# ================================================================
# Load Transfer Shortlist
# ================================================================
cat("Loading transfer shortlist...\n")

if (!exists("transfer_shortlist")) {
  transfer_shortlist <- read_csv("data/processed/transfer_shortlist.csv",
                                show_col_types = FALSE)
}

cat("✓ Shortlist loaded:", nrow(transfer_shortlist), "candidates\n")
cat("  Position breakdown:\n")
print(table(transfer_shortlist$position_group))
cat("\n")

# ================================================================
# Define Squad Requirements
# ================================================================
cat("Squad Requirements:\n")
cat("-------------------\n")

budget <- 2e9  # €2 billion
squad_size <- 25

target_counts <- list(
  GK = 3,
  DEF = 8,
  MID = 8,
  FWD = 6
)

cat("Budget:", format_currency(budget), "\n")
cat("Squad Size:", squad_size, "players\n")
cat("Position Requirements:\n")
for (pos in names(target_counts)) {
  cat("  -", pos, ":", target_counts[[pos]], "\n")
}
cat("\n")

# ================================================================
# Integer Linear Programming Optimization
# ================================================================
cat("Setting up ILP optimization model...\n")
cat("Objective: Maximize total squad overall rating\n")
cat("Subject to: Budget, squad size, and position constraints\n\n")

# Prepare data matrices
n_players <- nrow(transfer_shortlist)

# Objective function: maximize sum of overall ratings
objective_coeffs <- transfer_shortlist$overall

# Budget constraint
budget_constraint <- transfer_shortlist$cost

# Position constraints (create binary indicator matrices)
gk_indicator <- as.integer(transfer_shortlist$position_group == "GK")
def_indicator <- as.integer(transfer_shortlist$position_group == "DEF")
mid_indicator <- as.integer(transfer_shortlist$position_group == "MID")
fwd_indicator <- as.integer(transfer_shortlist$position_group == "FWD")

# Combine all constraints into a matrix
constraint_matrix <- rbind(
  rep(1, n_players),           # Total squad size = 25
  budget_constraint,           # Total cost <= budget
  gk_indicator,                # GK = 3
  def_indicator,               # DEF = 8
  mid_indicator,               # MID = 8
  fwd_indicator                # FWD = 6
)

# Constraint directions
constraint_dirs <- c(
  "=",   # Squad size exactly 25
  "<=",  # Budget constraint
  "=",   # GK exactly 3
  "=",   # DEF exactly 8
  "=",   # MID exactly 8
  "="    # FWD exactly 6
)

# Right-hand side values
constraint_rhs <- c(
  squad_size,
  budget,
  target_counts$GK,
  target_counts$DEF,
  target_counts$MID,
  target_counts$FWD
)

cat("Running ILP solver...\n")

# Solve the ILP problem
ilp_solution <- lp(
  direction = "max",
  objective.in = objective_coeffs,
  const.mat = constraint_matrix,
  const.dir = constraint_dirs,
  const.rhs = constraint_rhs,
  all.bin = TRUE  # Binary decision variables (0 or 1)
)

# ================================================================
# Extract and Validate Solution
# ================================================================
cat("✓ ILP optimization complete\n\n")

if (ilp_solution$status == 0) {
  cat("Optimization Status: OPTIMAL SOLUTION FOUND\n\n")
  
  # Extract selected players
  selected_indices <- which(ilp_solution$solution == 1)
  final_team_roster <- transfer_shortlist[selected_indices, ]
  
  # Calculate squad statistics
  total_overall <- sum(final_team_roster$overall)
  total_cost <- sum(final_team_roster$cost)
  total_value_gap <- sum(final_team_roster$value_gap)
  avg_overall <- mean(final_team_roster$overall)
  avg_age <- mean(final_team_roster$age)
  
  cat("Squad Statistics:\n")
  cat("-----------------\n")
  cat("Total Squad Overall Rating:", total_overall, "\n")
  cat("Average Overall Rating:", round(avg_overall, 2), "\n")
  cat("Total Cost:", format_currency(total_cost), "\n")
  cat("Budget Remaining:", format_currency(budget - total_cost), "\n")
  cat("Total Value Gap (Savings):", format_currency(total_value_gap), "\n")
  cat("Average Age:", round(avg_age, 1), "years\n")
  cat("Total Players:", nrow(final_team_roster), "\n\n")
  
  # Verify position requirements
  cat("Position Distribution:\n")
  position_check <- table(final_team_roster$position_group)
  print(position_check)
  cat("\n")
  
  # Validation
  all_positions_met <- all(
    position_check["GK"] == target_counts$GK,
    position_check["DEF"] == target_counts$DEF,
    position_check["MID"] == target_counts$MID,
    position_check["FWD"] == target_counts$FWD
  )
  
  if (all_positions_met) {
    cat("✓ All position requirements met\n")
  } else {
    cat("⚠ Warning: Position requirements not fully met\n")
  }
  
  if (total_cost <= budget) {
    cat("✓ Budget constraint satisfied\n")
  } else {
    cat("⚠ Warning: Budget exceeded\n")
  }
  cat("\n")
  
} else {
  cat("⚠ ERROR: Optimization failed with status:", ilp_solution$status, "\n")
  cat("Falling back to greedy algorithm...\n\n")
  
  # Greedy fallback algorithm
  final_team_roster_list <- list()
  
  for (group in names(target_counts)) {
    count <- target_counts[[group]]
    selected_players <- transfer_shortlist %>%
      filter(position_group == group) %>%
      slice_max(order_by = overall, n = count, with_ties = FALSE)
    
    final_team_roster_list[[group]] <- selected_players
  }
  
  final_team_roster <- bind_rows(final_team_roster_list)
  
  total_overall <- sum(final_team_roster$overall)
  total_cost <- sum(final_team_roster$cost)
}

# ================================================================
# Display Final 25-Man Squad
# ================================================================
cat("=== DURHAM TOP DOGS: FINAL 25-MAN SQUAD ===\n\n")

final_squad_display <- final_team_roster %>%
  select(Name = name, Position = position, Overall = overall, 
         `Value Score` = value_score, Cost = cost) %>%
  arrange(desc(Overall)) %>%
  mutate(Cost = sapply(Cost, format_currency))

print(kable(final_squad_display, 
           caption = paste("Durham Top Dogs: 25-Man Squad (Budget: €2B)")))
cat("\n")

# ================================================================
# Save Final Squad
# ================================================================
cat("Saving final squad...\n")

# Save full squad data
write_csv(final_team_roster, "data/outputs/final_25_man_squad.csv")

# Save display-friendly version
write_csv(final_squad_display, "data/outputs/final_squad_display.csv")

cat("✓ Final squad saved to: data/outputs/final_25_man_squad.csv\n")
cat("✓ Display version saved to: data/outputs/final_squad_display.csv\n\n")

# ================================================================
# Comparison with Greedy Algorithm (if ILP was used)
# ================================================================
if (ilp_solution$status == 0) {
  cat("Comparing ILP vs Greedy Algorithm:\n")
  cat("----------------------------------\n")
  
  # Run greedy for comparison
  greedy_roster_list <- list()
  for (group in names(target_counts)) {
    count <- target_counts[[group]]
    selected <- transfer_shortlist %>%
      filter(position_group == group) %>%
      slice_max(order_by = overall, n = count, with_ties = FALSE)
    greedy_roster_list[[group]] <- selected
  }
  greedy_roster <- bind_rows(greedy_roster_list)
  
  greedy_overall <- sum(greedy_roster$overall)
  greedy_cost <- sum(greedy_roster$cost)
  
  cat("ILP Method:\n")
  cat("  Total Overall:", total_overall, "\n")
  cat("  Total Cost:", format_currency(total_cost), "\n")
  cat("\n")
  cat("Greedy Method:\n")
  cat("  Total Overall:", greedy_overall, "\n")
  cat("  Total Cost:", format_currency(greedy_cost), "\n")
  cat("\n")
  cat("ILP Improvement:", total_overall - greedy_overall, "points\n\n")
}

cat("=== SQUAD OPTIMIZATION COMPLETE ===\n\n")

# Make final roster available globally for next steps
assign("final_team_roster", final_team_roster, envir = .GlobalEnv)
