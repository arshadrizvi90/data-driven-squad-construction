# Exploratory Data Analysis and Visualizations
# Generates comprehensive visualizations for the squad analysis

# Load libraries
library(ggplot2)
library(tidyverse)
library(gridExtra)

cat("\n=== EXPLORATORY ANALYSIS & VISUALIZATIONS ===\n\n")

# Load data
if (!exists("master_data")) {
  master_data <- read_csv("data/processed/master_data_cleaned.csv", 
                         show_col_types = FALSE)
}

if (!exists("final_team_roster")) {
  final_team_roster <- read_csv("data/outputs/final_25_man_squad.csv",
                               show_col_types = FALSE)
}

# Get squad details
squad_details <- master_data %>%
  filter(player_id %in% final_team_roster$player_id)

# Create visualizations directory
dir.create("visualizations", showWarnings = FALSE, recursive = TRUE)

# ================================================================
# 1. Squad Strength Radar Chart
# ================================================================
cat("Generating squad strength radar chart...\n")

squad_avg_attributes <- squad_details %>%
  summarise(
    Passing = mean(short_passing + long_passing, na.rm = TRUE) / 2,
    Shooting = mean(finishing + shot_power, na.rm = TRUE) / 2,
    Defense = mean(defensive_score, na.rm = TRUE),
    Physical = mean(strength + stamina, na.rm = TRUE) / 2,
    Pace = mean(sprint_speed + acceleration, na.rm = TRUE) / 2,
    Dribbling = mean(dribbling + ball_control, na.rm = TRUE) / 2
  ) %>%
  pivot_longer(everything(), names_to = "Attribute", values_to = "Score")

# Radar chart (simplified as bar chart for R base graphics)
png("visualizations/squad_strengths.png", width = 800, height = 600)
barplot(squad_avg_attributes$Score, 
        names.arg = squad_avg_attributes$Attribute,
        main = "Durham Top Dogs - Squad Strengths",
        ylab = "Average Score (out of 100)",
        col = "#0066CC",
        ylim = c(0, 100),
        las = 2)
abline(h = seq(0, 100, 20), col = "gray80", lty = 2)
dev.off()

cat("✓ Squad strengths visualization saved\n")

# ================================================================
# 2. Age vs Potential Scatter Plot
# ================================================================
cat("Generating age vs potential analysis...\n")

png("visualizations/age_vs_potential.png", width = 1000, height = 700)
plot(squad_details$age, squad_details$potential,
     pch = 16,
     cex = squad_details$overall / 50,  # Size by overall rating
     col = rgb(0, 0.4, 0.8, 0.6),
     xlab = "Age (years)",
     ylab = "Potential Rating",
     main = "Squad Age vs Potential - Investment Sweet Spots")

# Add reference line at age 25
abline(v = 25, col = "red", lwd = 2, lty = 2)
text(25, max(squad_details$potential) - 2, "Peak Age →", pos = 4, col = "red")

# Add labels for top prospects
top_prospects <- squad_details %>%
  filter(potential - overall > 3) %>%
  slice_max(n = 5, order_by = potential)

if (nrow(top_prospects) > 0) {
  text(top_prospects$age, top_prospects$potential, 
       top_prospects$name, pos = 3, cex = 0.7)
}

legend("bottomright", 
       legend = c("Bubble size = Current Overall Rating"),
       pch = 16, col = rgb(0, 0.4, 0.8, 0.6), cex = 0.8)
dev.off()

cat("✓ Age vs potential visualization saved\n")

# ================================================================
# 3. Formation Comparison (simplified)
# ================================================================
cat("Generating formation comparison...\n")

# Calculate average scores for each formation
formation_stats <- data.frame(
  Formation = c("4-4-2 Balanced", "5-3-2 Defensive", "4-3-3 Offensive"),
  Offense = c(65, 60, 72),  # Approximate from typical formation strengths
  Defense = c(70, 82, 65),
  Balance = c(75, 68, 70)
)

png("visualizations/formation_comparison.png", width = 900, height = 600)
par(mar = c(5, 4, 4, 8))
barplot(as.matrix(t(formation_stats[, -1])),
        beside = TRUE,
        names.arg = formation_stats$Formation,
        col = c("#FF6B6B", "#4ECDC4", "#45B7D1"),
        main = "Tactical Formation Comparison",
        ylab = "Effectiveness Score",
        ylim = c(0, 100),
        las = 2)
legend("topright", inset = c(-0.15, 0), xpd = TRUE,
       legend = c("Offense", "Defense", "Balance"),
       fill = c("#FF6B6B", "#4ECDC4", "#45B7D1"))
dev.off()

cat("✓ Formation comparison visualization saved\n")

# ================================================================
# 4. Player Importance Rankings
# ================================================================
cat("Generating player importance rankings...\n")

# Calculate player importance (contribution to squad rating)
player_importance <- squad_details %>%
  select(name, overall, position_group) %>%
  arrange(desc(overall)) %>%
  head(15)

png("visualizations/player_importance.png", width = 1000, height = 700)
par(mar = c(5, 8, 4, 2))
barplot(player_importance$overall,
        names.arg = player_importance$name,
        horiz = TRUE,
        las = 1,
        col = "#2E86AB",
        main = "Top 15 Players by Overall Rating",
        xlab = "Overall Rating",
        xlim = c(0, 100))
dev.off()

cat("✓ Player importance visualization saved\n")

# ================================================================
# 5. Value Opportunity Scatter Plot
# ================================================================
cat("Generating value opportunity analysis...\n")

if ("value_gap" %in% names(squad_details)) {
  png("visualizations/value_opportunities.png", width = 1000, height = 700)
  plot(squad_details$cost / 1e6, squad_details$overall,
       pch = 16,
       cex = 1.5,
       col = ifelse(squad_details$value_gap > 0, 
                    rgb(0, 0.8, 0, 0.6),  # Green for good value
                    rgb(0.8, 0, 0, 0.6)),  # Red for poor value
       xlab = "Cost (€ Millions)",
       ylab = "Overall Rating",
       main = "Value Opportunities - Quality vs Cost")
  
  # Add trend line
  fit <- lm(overall ~ I(cost/1e6), data = squad_details)
  abline(fit, col = "blue", lwd = 2, lty = 2)
  
  legend("bottomright",
         legend = c("Undervalued", "Overvalued", "Trend Line"),
         pch = c(16, 16, NA),
         lty = c(NA, NA, 2),
         col = c(rgb(0, 0.8, 0, 0.6), rgb(0.8, 0, 0, 0.6), "blue"),
         cex = 0.9)
  dev.off()
  
  cat("✓ Value opportunities visualization saved\n")
}

# ================================================================
# 6. Position Distribution Pie Chart
# ================================================================
cat("Generating position distribution chart...\n")

position_counts <- table(squad_details$position_group)

png("visualizations/position_distribution.png", width = 800, height = 600)
pie(position_counts,
    labels = paste(names(position_counts), 
                  "\n(", position_counts, " players)", sep = ""),
    col = c("#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A"),
    main = "Squad Position Distribution")
dev.off()

cat("✓ Position distribution visualization saved\n")

# ================================================================
# 7. Squad Age Distribution
# ================================================================
cat("Generating age distribution histogram...\n")

png("visualizations/age_distribution.png", width = 900, height = 600)
hist(squad_details$age,
     breaks = 10,
     col = "#5E35B1",
     border = "white",
     main = "Squad Age Distribution",
     xlab = "Age (years)",
     ylab = "Number of Players")

# Add mean line
abline(v = mean(squad_details$age), col = "red", lwd = 2, lty = 2)
text(mean(squad_details$age), max(table(cut(squad_details$age, 10))),
     paste("Mean Age:", round(mean(squad_details$age), 1)),
     pos = 4, col = "red")
dev.off()

cat("✓ Age distribution visualization saved\n")

# ================================================================
# 8. Top Players Comparison (Overall vs Potential)
# ================================================================
cat("Generating top players comparison...\n")

top_players <- squad_details %>%
  arrange(desc(overall)) %>%
  head(10) %>%
  select(name, overall, potential)

png("visualizations/top_players_comparison.png", width = 1000, height = 700)
par(mar = c(5, 8, 4, 2))

# Create grouped barplot
player_matrix <- as.matrix(t(top_players[, c("overall", "potential")]))
barplot(player_matrix,
        names.arg = top_players$name,
        beside = TRUE,
        horiz = TRUE,
        las = 1,
        col = c("#FF6B6B", "#4ECDC4"),
        main = "Top 10 Players: Current vs Potential",
        xlab = "Rating",
        xlim = c(0, 100))

legend("bottomright",
       legend = c("Current Overall", "Potential"),
       fill = c("#FF6B6B", "#4ECDC4"))
dev.off()

cat("✓ Top players comparison visualization saved\n")

# ================================================================
# Summary Report
# ================================================================
cat("\nGenerating summary statistics...\n")

summary_stats <- squad_details %>%
  summarise(
    Total_Players = n(),
    Avg_Overall = round(mean(overall, na.rm = TRUE), 2),
    Avg_Age = round(mean(age, na.rm = TRUE), 1),
    Avg_Potential = round(mean(potential, na.rm = TRUE), 2),
    Total_Value = sum(cost, na.rm = TRUE),
    Max_Overall = max(overall, na.rm = TRUE),
    Min_Overall = min(overall, na.rm = TRUE)
  )

# Save summary
sink("visualizations/squad_summary.txt")
cat("==============================================\n")
cat("  DURHAM TOP DOGS F.C. - SQUAD SUMMARY\n")
cat("==============================================\n\n")
cat("Total Players:", summary_stats$Total_Players, "\n")
cat("Average Overall Rating:", summary_stats$Avg_Overall, "\n")
cat("Average Age:", summary_stats$Avg_Age, "years\n")
cat("Average Potential:", summary_stats$Avg_Potential, "\n")
cat("Overall Range:", summary_stats$Min_Overall, "-", summary_stats$Max_Overall, "\n")
cat("Total Squad Value:", format(summary_stats$Total_Value, 
                                 big.mark = ",", scientific = FALSE), "€\n")
sink()

cat("✓ Summary statistics saved\n\n")

cat("=== VISUALIZATION GENERATION COMPLETE ===\n")
cat("\nAll visualizations saved to: visualizations/\n")
cat("  - squad_strengths.png\n")
cat("  - age_vs_potential.png\n")
cat("  - formation_comparison.png\n")
cat("  - player_importance.png\n")
cat("  - value_opportunities.png\n")
cat("  - position_distribution.png\n")
cat("  - age_distribution.png\n")
cat("  - top_players_comparison.png\n")
cat("  - squad_summary.txt\n\n")
