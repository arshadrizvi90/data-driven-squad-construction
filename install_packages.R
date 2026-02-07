# Install Required Packages for Football Squad Construction Project
# Run this script before executing the main analysis

cat("Installing required R packages for Football Squad Construction...\n\n")

# List of required packages
required_packages <- c(
  "tidyverse",
  "janitor",
  "readr",
  "caret",
  "randomForest",
  "knitr",
  "dplyr",
  "lpSolve",
  "ggplot2",
  "magrittr"
)

# Function to install packages if not already installed
install_if_missing <- function(packages) {
  new_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
  
  if(length(new_packages) > 0) {
    cat("Installing the following packages:\n")
    print(new_packages)
    cat("\n")
    install.packages(new_packages, dependencies = TRUE)
    cat("\n✓ Installation complete!\n\n")
  } else {
    cat("✓ All required packages are already installed!\n\n")
  }
}

# Install missing packages
install_if_missing(required_packages)

# Load all packages to verify installation
cat("Verifying package installation...\n")
success <- TRUE

for(pkg in required_packages) {
  tryCatch({
    library(pkg, character.only = TRUE)
    cat("  ✓", pkg, "\n")
  }, error = function(e) {
    cat("  ✗", pkg, "- Failed to load\n")
    success <- FALSE
  })
}

if(success) {
  cat("\n✓ All packages successfully installed and loaded!\n")
  cat("You can now run the analysis scripts.\n")
} else {
  cat("\n✗ Some packages failed to load. Please check error messages above.\n")
}
