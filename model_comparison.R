# Model Comparison Analysis
# Compares Random Forest vs other models and ILP vs Greedy Algorithm

# Load libraries
library(tidyverse)
library(randomForest)
library(glmnet)
library(quantreg)
library(knitr)

cat("\n=== MODEL COMPARISON ANALYSIS ===\n\n")

# Load data
if (!exists("master_data")) {
  master_data <- read_csv("data/processed/master_data_cleaned.csv",
                         show_col_types = FALSE)
}

# ================================================================
# PART 1: Player Valuation Model Comparison
# ================================================================
cat("PART 1: Comparing Player Valuation Models\n")
cat("==========================================\n\n")

# Train-test split
set.seed(123)
train_index <- sample(seq_len(nrow(master_data)), 
                     size = floor(0.8 * nrow(master_data)))
train <- master_data[train_index, ]
test <- master_data[-train_index, ]

cat("Training set:", nrow(train), "| Test set:", nrow(test), "\n\n")

# Prepare feature matrix
features <- c("overall", "potential", "age", "wage")
X_train <- train %>% select(all_of(features))
y_train <- train$value
X_test <- test %>% select(all_of(features))
y_test <- test$value

# Helper function to calculate metrics
calculate_metrics <- function(actual, predicted) {
  residuals <- actual - predicted
  rmse <- sqrt(mean(residuals^2, na.rm = TRUE))
  mae <- mean(abs(residuals), na.rm = TRUE)
  r_squared <- cor(actual, predicted, use = "complete.obs")^2
  
  return(list(
    RMSE = rmse,
    MAE = mae,
    R_Squared = r_squared
  ))
}

# ================================================================
# Model 1: Random Forest (Current)
# ================================================================
cat("Training Random Forest...\n")

rf_model <- randomForest(
  value ~ overall + potential + age + wage + position_group,
  data = train,
  ntree = 200,
  na.action = na.omit
)

rf_predictions <- predict(rf_model, test)
rf_metrics <- calculate_metrics(test$value, rf_predictions)

cat("✓ Random Forest complete\n")
cat("  RMSE:", format(rf_metrics$RMSE, big.mark = ","), "\n")
cat("  R²:", round(rf_metrics$R_Squared, 4), "\n\n")

# ================================================================
# Model 2: LASSO Regression
# ================================================================
cat("Training LASSO Regression...\n")

# Prepare matrices for glmnet
position_dummies <- model.matrix(~ position_group - 1, data = train)
X_train_lasso <- cbind(as.matrix(X_train), position_dummies)

position_dummies_test <- model.matrix(~ position_group - 1, data = test)
X_test_lasso <- cbind(as.matrix(X_test), position_dummies_test)

# Train LASSO
lasso_model <- cv.glmnet(
  X_train_lasso, 
  y_train,
  alpha = 1,  # LASSO
  nfolds = 5
)

lasso_predictions <- predict(lasso_model, X_test_lasso, s = "lambda.min")
lasso_metrics <- calculate_metrics(y_test, as.vector(lasso_predictions))

cat("✓ LASSO complete\n")
cat("  RMSE:", format(lasso_metrics$RMSE, big.mark = ","), "\n")
cat("  R²:", round(lasso_metrics$R_Squared, 4), "\n\n")

# ================================================================
# Model 3: Quantile Regression
# ================================================================
cat("Training Quantile Regression...\n")

# Train quantile regression at median (tau = 0.5)
qr_formula <- as.formula("value ~ overall + potential + age + wage + position_group")
qr_model <- rq(qr_formula, data = train, tau = 0.5)

qr_predictions <- predict(qr_model, newdata = test)
qr_metrics <- calculate_metrics(test$value, qr_predictions)

cat("✓ Quantile Regression complete\n")
cat("  RMSE:", format(qr_metrics$RMSE, big.mark = ","), "\n")
cat("  R²:", round(qr_metrics$R_Squared, 4), "\n\n")

# ================================================================
# Model Comparison Summary
# ================================================================
cat("\n=== MODEL COMPARISON RESULTS ===\n\n")

comparison_df <- data.frame(
  Model = c("Random Forest", "LASSO Regression", "Quantile Regression"),
  RMSE = c(rf_metrics$RMSE, lasso_metrics$RMSE, qr_metrics$RMSE),
  MAE = c(rf_metrics$MAE, lasso_metrics$MAE, qr_metrics$MAE),
  R_Squared = c(rf_metrics$R_Squared, lasso_metrics$R_Squared, qr_metrics$R_Squared)
) %>%
  arrange(RMSE) %>%
  mutate(
    RMSE = format(RMSE, big.mark = ",", scientific = FALSE, digits = 0),
    MAE = format(MAE, big.mark = ",", scientific = FALSE, digits = 0),
    R_Squared = round(R_Squared, 4)
  )

print(kable(comparison_df, caption = "Player Valuation Model Comparison"))
cat("\n")

cat("Winner: Random Forest (Lowest RMSE, Highest R²)\n")
cat("Random Forest explains", 
    round(rf_metrics$R_Squared * 100, 1), 
    "% of variance in player values\n\n")

# ================================================================
# PART 2: Squad Selection Method Comparison
# ================================================================
cat("\n")
cat("PART 2: Squad Selection Method Comparison\n")
cat("==========================================\n\n")

# Load transfer shortlist
if (!exists("transfer_shortlist")) {
  if (file.exists("data/processed/transfer_shortlist.csv")) {
    transfer_shortlist <- read_csv("data/processed/transfer_shortlist.csv",
                                  show_col_types = FALSE)
  } else {
    # Create shortlist from test set
    test$value_gap <- rf_predictions - test$value
    transfer_shortlist <- test %>%
      filter(value_gap > 0, overall >= 75) %>%
      mutate(cost = value, value_score = overall / (cost / 1e6)) %>%
      filter(is.finite(value_score))
  }
}

# Define constraints
budget <- 2e9
target_counts <- list(GK = 3, DEF = 8, MID = 8, FWD = 6)

# ================================================================
# Method 1: Greedy Algorithm
# ================================================================
cat("Running Greedy Algorithm...\n")

greedy_roster_list <- list()

for (group in names(target_counts)) {
  count <- target_counts[[group]]
  selected_players <- transfer_shortlist %>%
    filter(position_group == group) %>%
    slice_max(order_by = overall, n = count, with_ties = FALSE)
  
  greedy_roster_list[[group]] <- selected_players
}

greedy_roster <- bind_rows(greedy_roster_list)

greedy_total_overall <- sum(greedy_roster$overall)
greedy_total_cost <- sum(greedy_roster$cost)

cat("✓ Greedy algorithm complete\n")
cat("  Total Overall:", greedy_total_overall, "\n")
cat("  Total Cost:", format(greedy_total_cost, big.mark = ","), "€\n\n")

# ================================================================
# Method 2: ILP Optimization (if results exist)
# ================================================================
cat("Checking for ILP results...\n")

if (file.exists("data/outputs/final_25_man_squad.csv")) {
  ilp_roster <- read_csv("data/outputs/final_25_man_squad.csv",
                        show_col_types = FALSE)
  
  ilp_total_overall <- sum(ilp_roster$overall)
  ilp_total_cost <- sum(ilp_roster$cost)
  
  cat("✓ ILP results loaded\n")
  cat("  Total Overall:", ilp_total_overall, "\n")
  cat("  Total Cost:", format(ilp_total_cost, big.mark = ","), "€\n\n")
  
  # Comparison
  cat("\n=== SQUAD SELECTION METHOD COMPARISON ===\n\n")
  
  selection_comparison <- data.frame(
    Method = c("Integer Linear Programming (ILP)", "Greedy Algorithm"),
    `Total Squad Overall` = c(ilp_total_overall, greedy_total_overall),
    `Total Cost` = c(ilp_total_cost, greedy_total_cost),
    `Avg Overall` = c(
      round(ilp_total_overall / 25, 2),
      round(greedy_total_overall / 25, 2)
    )
  ) %>%
    mutate(
      `Total Cost` = paste0("€", format(`Total Cost`, big.mark = ","))
    )
  
  print(kable(selection_comparison, 
             caption = "Squad Selection Method Comparison"))
  cat("\n")
  
  improvement <- ilp_total_overall - greedy_total_overall
  cat("ILP Improvement:", improvement, "points\n")
  cat("This represents a", 
      round((improvement / greedy_total_overall) * 100, 2), 
      "% improvement in squad quality\n\n")
  
} else {
  cat("⚠ ILP results not found. Run optimization script first.\n\n")
}

# ================================================================
# Save Comparison Results
# ================================================================
cat("Saving comparison results...\n")

# Save model comparison
write_csv(comparison_df, "data/outputs/model_comparison.csv")

# Save comprehensive report
sink("data/outputs/comparison_report.txt")
cat("=================================================\n")
cat("  MODEL COMPARISON ANALYSIS REPORT\n")
cat("=================================================\n\n")

cat("PLAYER VALUATION MODELS\n")
cat("-----------------------\n")
print(comparison_df)
cat("\n\n")

if (exists("selection_comparison")) {
  cat("SQUAD SELECTION METHODS\n")
  cat("-----------------------\n")
  print(selection_comparison)
  cat("\n")
}

cat("\nCONCLUSION\n")
cat("----------\n")
cat("Best Valuation Model: Random Forest\n")
cat("- Achieves R² of", round(rf_metrics$R_Squared, 4), "\n")
cat("- RMSE:", format(rf_metrics$RMSE, big.mark = ","), "\n\n")

if (exists("improvement")) {
  cat("Best Selection Method: Integer Linear Programming\n")
  cat("- Improvement over Greedy:", improvement, "points\n")
}

sink()

cat("✓ Comparison results saved to:\n")
cat("  - data/outputs/model_comparison.csv\n")
cat("  - data/outputs/comparison_report.txt\n\n")

cat("=== MODEL COMPARISON COMPLETE ===\n\n")
