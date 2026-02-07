# Data-Driven Football Squad Construction

[![R](https://img.shields.io/badge/R-4.0+-blue.svg)](https://www.r-project.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Project Overview

A comprehensive data science project that applies machine learning and optimization techniques to construct the inaugural 25-man squad for Durham Top Dogs F.C. This project demonstrates a modern "Moneyball" approach to football management, replacing market speculation with empirical evidence.


## Key Features

- **Player Valuation Model**: Random Forest regression to identify undervalued talent
- **Squad Optimization**: Integer Linear Programming (ILP) for optimal 25-man roster selection
- **Tactical Analysis**: Chemistry-optimized lineups for balanced, defensive, and offensive scenarios
- **Game Day Playbook**: Set-piece specialists and impact substitutes
- **Comprehensive Visualizations**: Squad analysis, player comparisons, and value forecasting

## Business Objectives

1. **Identify Undervalued Talent**: Find players whose market value is significantly lower than performance metrics suggest
2. **Ensure Tactical Balance**: Build a positionally complete roster with diverse player styles
3. **Optimize for Cohesion**: Select lineups that maximize player chemistry

## Dataset

- **Source**: FIFA 19 Complete Player Dataset
- **Size**: 18,207 players across 57 attributes
- **Key Features**: 
  - Player demographics (name, age, nationality, club)
  - Performance metrics (overall rating, potential)
  - Financial data (value, wage)
  - 30+ detailed in-game attributes

## Methodology

### 1. Data Preparation
- Currency string conversion (€110.5M → numerical values)
- Position simplification (27 positions → 4 groups: GK, DEF, MID, FWD)
- Feature engineering for chemistry and tactical scores

### 2. Player Valuation (Random Forest)
- **Features**: Overall rating, potential, age, wage, position group
- **Performance**: R² = 0.96, RMSE = 1,015,841
- **Output**: Value gap calculation to identify undervalued players

### 3. Squad Selection (Integer Linear Programming)
- **Objective**: Maximize total overall rating
- **Constraints**:
  - Budget: €2 billion
  - Squad size: 25 players
  - Positional quotas: 3 GK, 8 DEF, 8 MID, 6 FWD
- **Result**: Total squad overall rating of 2065

### 4. Tactical Lineup Generation
- Chemistry optimization based on club (+3) and nationality (+1)
- Three tactical formations:
  - **4-4-2 Balanced**: Highest overall ratings
  - **5-3-2 Defensive**: Optimized defensive attributes
  - **4-3-3 Offensive**: Optimized attacking attributes

## Project Structure

```
football-squad-construction/
├── data/
│   ├── raw/                    # Original FIFA 19 dataset
│   ├── processed/              # Cleaned and transformed data
│   └── outputs/                # Final squad rosters and lineups
├── src/
│   ├── 01_data_preparation.R   # Data cleaning and feature engineering
│   ├── 02_player_valuation.R   # Random Forest model
│   ├── 03_squad_optimization.R # ILP optimization
│   ├── 04_lineup_generation.R  # Tactical lineup creation
│   └── utils.R                 # Helper functions
├── analysis/
│   ├── exploratory_analysis.R  # EDA and visualizations
│   └── model_comparison.R      # Model evaluation
├── visualizations/             # Generated plots and charts
├── reports/
│   └── final_report.pdf        # Complete project report
├── requirements.txt            # R package dependencies
├── .gitignore
├── LICENSE
└── README.md
```

## Installation & Setup

### Prerequisites
- R 4.0 or higher
- RStudio (recommended)

### Install Required Packages

```r
install.packages(c(
  "tidyverse",
  "janitor",
  "readr",
  "caret",
  "randomForest",
  "knitr",
  "dplyr",
  "lpSolve",
  "ggplot2"
))
```

### Running the Analysis

1. Clone the repository:
```bash
git clone https://github.com/yourusername/football-squad-construction.git
cd football-squad-construction
```

2. Place the FIFA 19 dataset in `data/raw/`

3. Run the analysis scripts in order:
```r
source("src/01_data_preparation.R")
source("src/02_player_valuation.R")
source("src/03_squad_optimization.R")
source("src/04_lineup_generation.R")
```

Or run the complete pipeline:
```r
source("main.R")
```

## Key Results

### Final 25-Man Squad
- **Total Cost**: €311.5M (under €2B budget)
- **Total Squad Overall**: 2065
- **Top Players**:
  - Thiago Silva (RCB) - Overall 88
  - Gianluigi Buffon (GK) - Overall 88
  - Arturo Vidal (CAM) - Overall 85

### Model Performance

| Model | RMSE | Notes |
|-------|------|-------|
| Random Forest | 1,015,841 | **Best performance** (96% R²) |
| Quantile Regression | 2,679,287 | |
| LASSO | 2,380,007 | |

### Squad Selection Comparison

| Method | Total Squad Overall | Total Cost |
|--------|---------------------|------------|
| **ILP** | **2065** | €311.5M |
| Greedy Algorithm | 2048 | €305.0M |

## Visualizations

The project includes comprehensive visualizations:
- Squad strength radial charts
- Player age vs. potential analysis
- Formation comparison radar charts
- Player importance rankings
- Value opportunity scatter plots
- Future value forecasting

## Deployment

The model outputs serve as a decision-support tool for:
- Director of Football
- Managerial Staff
- Scouting Department

### Operational Considerations
- **Updates**: Retrain model each transfer window with current data
- **Integration**: Use alongside traditional scouting (video analysis, in-person assessment)
- **Risk Mitigation**: Generate shortlist for further evaluation before final transfer decisions

## Limitations & Future Work

### Current Limitations
- Data from video game simulation (FIFA 19)
- Cannot capture psychological factors (personality, team dynamics)
- Limited to static dataset snapshot

### Future Enhancements
- Real-time market data integration
- Player injury risk modeling
- Performance trajectory forecasting
- Multi-season squad planning
- Youth academy talent identification

## Contributing

This is an academic project. For questions or feedback:
- Submit an issue
- Contact project team members

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## References

1. [LatentView - Transforming Football Scouting with Predictive Analytics](https://www.latentview.com/blog/redefining-football-player-scouting-with-predictive-analytics/)
2. [CallPlaybook - Top 10 Ways AI is Revolutionizing Player Scouting](https://www.callplaybook.com/reports/top-10-ai-scouting-and-recruitment)
3. [Sportmonks - Moneyball and Soccer Data](https://www.sportmonks.com/blogs/moneyball/)
4. [arXiv - Data-Driven Team Selection Using Integer Programming](https://arxiv.org/html/2505.02170v1)

## Acknowledgments

- **Dataset**: EA Sports FIFA 19 Complete Player Dataset

---

**Durham Top Dogs F.C.** - Building Champions Through Data
