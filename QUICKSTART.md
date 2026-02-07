# Quick Start Guide

Get up and running with the Football Squad Construction project in minutes!

## Prerequisites

Before you begin, ensure you have:

- **R 4.0+** installed ([Download R](https://www.r-project.org/))
- **RStudio** (recommended) ([Download RStudio](https://www.rstudio.com/))
- The **FIFA 19 dataset** (place in `data/raw/`)

## Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/football-squad-construction.git
cd football-squad-construction
```

### Step 2: Install Required Packages

Open R or RStudio and run:

```r
source("install_packages.R")
```

This will automatically install all required packages:
- tidyverse
- janitor
- randomForest
- lpSolve
- caret
- knitr
- And more...

### Step 3: Prepare Your Data

1. Obtain the FIFA 19 Complete Player Dataset
2. Place `fifa_eda_stats.csv` in the `data/raw/` directory

```bash
# Verify the file is in place
ls data/raw/
# Should show: fifa_eda_stats.csv
```

## Running the Analysis

### Option 1: Run Complete Pipeline (Recommended)

Run all analysis steps automatically:

```r
source("main.R")
```

This executes:
1. Data preparation
2. Player valuation
3. Squad optimization
4. Lineup generation
5. Visualizations (optional)

### Option 2: Run Individual Steps

Execute scripts in order:

```r
# Step 1: Data Preparation
source("src/01_data_preparation.R")

# Step 2: Player Valuation
source("src/02_player_valuation.R")

# Step 3: Squad Optimization
source("src/03_squad_optimization.R")

# Step 4: Lineup Generation
source("src/04_lineup_generation.R")

# Optional: Generate Visualizations
source("analysis/exploratory_analysis.R")

# Optional: Model Comparison
source("analysis/model_comparison.R")
```

## Understanding the Outputs

### Generated Files

After running the pipeline, you'll find:

#### `data/processed/`
- `master_data_cleaned.csv` - Cleaned player dataset
- `rf_model.rds` - Trained Random Forest model
- `transfer_shortlist.csv` - Undervalued players
- `test_with_predictions.csv` - Model predictions

#### `data/outputs/`
- `final_25_man_squad.csv` - Your optimized squad!
- `lineup_balanced_442.csv` - Balanced formation
- `lineup_defensive_532.csv` - Defensive formation
- `lineup_offensive_433.csv` - Offensive formation
- `setpiece_specialists.csv` - Set-piece takers
- `impact_substitutes.csv` - Key bench players
- `game_day_playbook.txt` - Complete tactical guide

#### `visualizations/`
- `squad_strengths.png` - Attribute radar chart
- `age_vs_potential.png` - Investment analysis
- `formation_comparison.png` - Tactical options
- `player_importance.png` - Key players ranking
- And more...

## Quick Examples

### View Your Final Squad

```r
# Load the final squad
squad <- read_csv("data/outputs/final_25_man_squad.csv")

# View top players
squad %>%
  arrange(desc(overall)) %>%
  select(name, position, overall, cost) %>%
  head(10)
```

### Check Squad Statistics

```r
# Squad summary
squad %>%
  summarise(
    total_players = n(),
    avg_overall = mean(overall),
    avg_age = mean(age),
    total_cost = sum(cost)
  )
```

### View Starting Lineup

```r
# Load balanced starting XI
lineup <- read_csv("data/outputs/lineup_balanced_442.csv")

# Display by position
lineup %>%
  select(name, position, overall, club) %>%
  arrange(factor(position_group, levels = c("GK", "DEF", "MID", "FWD")))
```

## Customization

### Adjust Budget

Edit `src/03_squad_optimization.R`:

```r
# Change from €2B to your preferred budget
budget <- 3e9  # €3 billion
```

### Modify Squad Size

Edit positional requirements:

```r
target_counts <- list(
  GK = 3,   # Change goalkeeper count
  DEF = 9,  # Change defender count
  MID = 7,  # Change midfielder count
  FWD = 6   # Change forward count
)
# Total should equal your desired squad size
```

### Filter Players

Add filters to `src/02_player_valuation.R`:

```r
transfer_shortlist <- test %>%
  filter(
    value_gap > 0,
    overall >= 80,        # Minimum rating
    age <= 28,           # Maximum age
    potential >= 85      # Minimum potential
  )
```

## Common Issues & Solutions

### Issue: Missing Packages

**Solution:**
```r
# Install specific package
install.packages("package_name")

# Or reinstall all
source("install_packages.R")
```

### Issue: Data File Not Found

**Solution:**
```r
# Check current directory
getwd()

# Should be in project root
# If not, set it:
setwd("/path/to/football-squad-construction")
```

### Issue: ILP Solver Fails

**Solution:** Falls back to Greedy algorithm automatically. To fix:
```r
# Reduce shortlist size
transfer_shortlist <- transfer_shortlist %>%
  filter(overall >= 78)  # More restrictive filter
```

### Issue: Out of Memory

**Solution:**
```r
# Reduce Random Forest trees
rf_model <- randomForest(..., ntree = 100)  # Instead of 200
```

## Next Steps

1. **Explore the Data**: Check out `analysis/exploratory_analysis.R`
2. **Compare Models**: Run `analysis/model_comparison.R`
3. **Customize**: Adjust parameters to your preferences
4. **Visualize**: Generate additional plots
5. **Experiment**: Try different formations and strategies

## Need Help?

- 📖 Read the full [README.md](README.md)
- 🐛 Report issues on GitHub
- 💬 Check [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines
- 📧 Contact project team members

## Success Checklist

- [ ] R and RStudio installed
- [ ] All packages installed successfully
- [ ] FIFA 19 dataset in `data/raw/`
- [ ] Pipeline runs without errors
- [ ] Final squad generated in `data/outputs/`
- [ ] Visualizations created
- [ ] Game day playbook available

## What's Next?

Now that you have your optimized squad:

1. Review the tactical lineups
2. Study the set-piece specialists
3. Plan your transfer strategy
4. Analyze the visualizations
5. Share your results!

---

**Durham Top Dogs F.C.** - Ready to dominate! ⚽🏆
