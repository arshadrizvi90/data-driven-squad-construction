# Step 2: Player Valuation Model
# Random Forest regression to predict player values and identify undervalued talent

# Load libraries
library(randomForest)
library(caret)
library(ggplot2)

# Load utility functions
source("src/utils.R")

cat("\n=== STEP 2: PLAYER VALUATION MODEL ===\n\n")

# ================================================================
# Load Processed Data
# ================================================================
cat("Loading processed data...\n")

if (!exists("master_data")) {
  master_data <- read_csv("data/processed/master_data_cleaned.csv", 
                         show_col_types = FALSE)
}

cat("✓ Data loaded:", nrow(master_data), "players\n\n")

# ================================================================
# Train-Test Split
# ================================================================
cat("Creating train-test split (80-20)...\n")

set.seed(123)  # For reproducibility
train_index <- sample(seq_len(nrow(master_data)), 
                     size = floor(0.8 * nrow(master_data)))

train <- master_data[train_index, ]
test <- master_data[-train_index, ]

cat("✓ Training set:", nrow(train), "players\n")
cat("✓ Test set:", nrow(test), "players\n\n")

# ================================================================
# Random Forest Model Training
# ================================================================
cat("Training Random Forest model...\n")
cat("Features: overall, potential, age, wage, position_group\n")
cat("Target: value\n\n")

# Train the model
rf_model <- randomForest(
  value ~ overall + potential + age + wage + position_group,
  data = train,
  ntree = 200,
  importance = TRUE,
  na.action = na.omit
)

cat("✓ Model training complete\n\n")

# ================================================================
# Model Performance Evaluation
# ================================================================
cat("Evaluating model performance...\n")

# Make predictions on test set
test$predicted_value <- predict(rf_model, test)

# Calculate performance metrics
residuals <- test$value - test$predicted_value
rmse <- sqrt(mean(residuals^2, na.rm = TRUE))
mae <- mean(abs(residuals), na.rm = TRUE)
r_squared <- cor(test$value, test$predicted_value, use = "complete.obs")^2

cat("Model Performance Metrics:\n")
cat("-------------------------\n")
cat("RMSE:", format(rmse, big.mark = ",", scientific = FALSE), "\n")
cat("MAE:", format(mae, big.mark = ",", scientific = FALSE), "\n")
cat("R²:", round(r_squared, 4), "(", round(r_squared * 100, 2), "% variance explained)\n\n")

# Variable importance
cat("Feature Importance:\n")
importance_df <- as.data.frame(importance(rf_model))
importance_df$Feature <- rownames(importance_df)
importance_df <- importance_df %>%
  arrange(desc(`%IncMSE`)) %>%
  select(Feature, `%IncMSE`, IncNodePurity)

print(importance_df, row.names = FALSE)
cat("\n")

# ================================================================
# Calculate Value Gap (Identify Undervalued Players)
# ================================================================
cat("Calculating value gaps to identify undervalued players...\n")

test$value_gap <- test$predicted_value - test$value
test$value_gap_pct <- (test$value_gap / test$value) * 100

# Filter for undervalued players
undervalued_players <- test %>%
  filter(value_gap > 0) %>%
  arrange(desc(value_gap))

cat("✓ Found", nrow(undervalued_players), "undervalued players\n")
cat("  Total potential savings:", 
    format_currency(sum(undervalued_players$value_gap, na.rm = TRUE)), "\n\n")

# Top 10 most undervalued players
cat("Top 10 Most Undervalued Players:\n")
cat("--------------------------------\n")
top_undervalued <- undervalued_players %>%
  select(name, position, overall, value, predicted_value, value_gap) %>%
  head(10) %>%
  mutate(
    value = format_currency(value),
    predicted_value = format_currency(predicted_value),
    value_gap = format_currency(value_gap)
  )

print(top_undervalued, row.names = FALSE)
cat("\n")

# ================================================================
# Create Transfer Shortlist
# ================================================================
cat("Creating transfer shortlist (overall >= 75, positive value gap)...\n")

transfer_shortlist <- test %>%
  filter(value_gap > 0, overall >= 75) %>%
  mutate(
    cost = value,
    value_score = overall / (cost / 1e6)  # Overall rating per million €
  ) %>%
  filter(is.finite(value_score))  # Remove players with cost of 0

cat("✓ Transfer shortlist created:", nrow(transfer_shortlist), "players\n")
cat("  Position breakdown:\n")
print(table(transfer_shortlist$position_group))
cat("\n")

# ================================================================
# Save Model and Results
# ================================================================
cat("Saving model and results...\n")

# Save the trained model
saveRDS(rf_model, "data/processed/rf_model.rds")

# Save test set with predictions
write_csv(test, "data/processed/test_with_predictions.csv")

# Save transfer shortlist
write_csv(transfer_shortlist, "data/processed/transfer_shortlist.csv")

cat("✓ Model saved to: data/processed/rf_model.rds\n")
cat("✓ Predictions saved to: data/processed/test_with_predictions.csv\n")
cat("✓ Transfer shortlist saved to: data/processed/transfer_shortlist.csv\n\n")

# ================================================================
# Generate Diagnostic Plots (Optional)
# ================================================================
cat("Generating diagnostic plots...\n")

# Create visualizations directory
dir.create("visualizations", showWarnings = FALSE)

# Plot 1: Actual vs Predicted Values
png("visualizations/actual_vs_predicted.png", width = 800, height = 600)
plot(test$value, test$predicted_value,
     xlab = "Actual Value (€)",
     ylab = "Predicted Value (€)",
     main = "Random Forest: Actual vs Predicted Player Values",
     pch = 16, col = rgb(0, 0, 1, 0.3))
abline(0, 1, col = "red", lwd = 2)
dev.off()

# Plot 2: Residuals
png("visualizations/residuals.png", width = 800, height = 600)
plot(test$predicted_value, residuals,
     xlab = "Predicted Value (€)",
     ylab = "Residuals (€)",
     main = "Residual Plot",
     pch = 16, col = rgb(0, 0, 1, 0.3))
abline(h = 0, col = "red", lwd = 2)
dev.off()

# Plot 3: Variable Importance
png("visualizations/feature_importance.png", width = 800, height = 600)
varImpPlot(rf_model, main = "Random Forest Feature Importance")
dev.off()

cat("✓ Diagnostic plots saved to visualizations/\n\n")

cat("=== PLAYER VALUATION MODEL COMPLETE ===\n\n")

# Make transfer shortlist available globally for next steps
assign("transfer_shortlist", transfer_shortlist, envir = .GlobalEnv)
assign("rf_model", rf_model, envir = .GlobalEnv)
