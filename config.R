# Configuration File for Football Squad Construction
# Edit these parameters to customize your analysis

# ================================================================
# BUDGET SETTINGS
# ================================================================
BUDGET <- 2e9  # Total budget in Euros (€2 billion)

# ================================================================
# SQUAD COMPOSITION
# ================================================================
SQUAD_SIZE <- 25

# Positional Requirements
GOALKEEPERS <- 3
DEFENDERS <- 8
MIDFIELDERS <- 8
FORWARDS <- 6

# ================================================================
# PLAYER FILTERS
# ================================================================
# Minimum overall rating for transfer shortlist
MIN_OVERALL <- 75

# Maximum age for consideration
MAX_AGE <- 35

# Minimum potential for young players
MIN_POTENTIAL <- 70

# Only consider players with positive value gap (undervalued)
REQUIRE_POSITIVE_VALUE_GAP <- TRUE

# ================================================================
# MODEL PARAMETERS
# ================================================================
# Random Forest settings
RF_NTREES <- 200
RF_SEED <- 123

# Train-test split ratio
TRAIN_RATIO <- 0.8

# ================================================================
# CHEMISTRY WEIGHTS
# ================================================================
# Chemistry bonus for same club
SAME_CLUB_BONUS <- 3

# Chemistry bonus for same nationality
SAME_NATIONALITY_BONUS <- 1

# Chemistry importance multiplier for lineup selection
CHEMISTRY_WEIGHT <- 5

# ================================================================
# FORMATION SETTINGS
# ================================================================
# Available formations (uncomment to use)
FORMATIONS <- list(
  balanced = "4-4-2",
  defensive = "5-3-2",
  offensive = "4-3-3"
  # alternative_balanced = "4-3-3"
  # ultra_defensive = "5-4-1"
  # ultra_attacking = "3-4-3"
)

# ================================================================
# OUTPUT SETTINGS
# ================================================================
# Generate visualizations
CREATE_VISUALIZATIONS <- TRUE

# Save detailed logs
VERBOSE_OUTPUT <- TRUE

# Export formats
EXPORT_CSV <- TRUE
EXPORT_TXT <- TRUE

# ================================================================
# ADVANCED SETTINGS
# ================================================================
# ILP solver timeout (seconds)
ILP_TIMEOUT <- 300

# Fall back to greedy if ILP fails
USE_GREEDY_FALLBACK <- TRUE

# Number of top prospects to highlight
N_TOP_PROSPECTS <- 10

# ================================================================
# DATA PATHS (relative to project root)
# ================================================================
PATH_RAW_DATA <- "data/raw/fifa_eda_stats.csv"
PATH_PROCESSED <- "data/processed/"
PATH_OUTPUTS <- "data/outputs/"
PATH_VISUALIZATIONS <- "visualizations/"

# ================================================================
# NOTES
# ================================================================
# - Adjust budget to reflect your club's financial capacity
# - Modify positional requirements based on tactical preferences
# - Increase MIN_OVERALL for elite squads, decrease for budget builds
# - Higher RF_NTREES = better accuracy but slower training
# - Chemistry weights can be adjusted based on importance to your strategy
