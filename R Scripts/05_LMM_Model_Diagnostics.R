# =========================================================================
# 05_LMM_Model_Diagnostics.R
# Purpose: Advanced LMM fitting (Random Slope) and Model Diagnostics 
#          for specific research questions (e.g., Exp 4).
# Key Steps: 1) Load Final Data, 2) Fit LMM with Random Slope, 3) Visualize
#            Predicted vs. Actual Growth Trajectories for model validation.
# NOTE: This script focuses on Exp 4 for demonstration, modify 'exp' as needed.
# =========================================================================

# --- 1. Load Required Packages ------------------------------------------
library(dplyr)
library(ggplot2)
library(lme4)      # Core package for LMM
library(lmerTest)  # For summary
library(zoo)       # For moving average calculation (if needed)

# --- 2. Load Final Model-Ready Dataset -----------------------------------
# Load the dataset created by the 03_Growth_Model_Prep.R script.
Final_Model_Data <- read.csv("Final_Model_Dataset_All_Experiments.csv", header=TRUE) %>%
  mutate(pig_id = as.factor(pig_id), pen = as.factor(pen))


# --- 3. Feature Engineering (Optional: Custom Moving Average for Weight) ---

# Recalculate 3-day MA for Weight 
Final_Model_Data <- Final_Model_Data %>% 
  group_by(pig_id) %>% 
  arrange(daynb) %>% 
  mutate(
    lag1 = lag(weight_dol, 1),
    lag2 = lag(weight_dol, 2),
    lag3 = lag(weight_dol, 3),
    # Calculate 3-day moving average of weight (previous 3 days)
    weightMA = (lag1 + lag2 + lag3) / 3
  ) %>% 
  ungroup() %>%
  # Clean up temporary columns
  select(-lag1, -lag2, -lag3)


# --- 4. Advanced LMM Fitting (Exp 4 Example) -----------------------------

# Filter data for the target experiment (Exp 4)
Exp4_Data_MA <- Final_Model_Data %>% 
  filter(exp == 4) %>%
  # Remove rows where weightMA (response variable) is NA
  filter(!is.na(weightMA)) 

# Model Definition: 
# Response: Smoothed Weight (weightMA)
# Fixed Effects: daynb (Time), gender (Meta Data - assumed to be available from 03 file's merge)
# Random Effects: (1 + daynb | pig_id) 
#   - (1 | pig_id): Random Intercept (each pig starts at a different baseline weight)
#   - (daynb | pig_id): Random Slope (each pig has a different growth rate/slope)
mo4 <- lmer(
  weightMA ~ daynb + gender + (1 + daynb | pig_id), 
  data = Exp4_Data_MA
)

cat("\n--- LMM Exp 4: Weight (weightMA) with Random Slope --- \n")
summary(mo4)


# --- 5. Model Diagnostics: Fitted vs. Actual Plot Generation -------------

# 5.1 Calculate Predictions and Residuals
Exp4_Data_MA$predicted_weight <- predict(mo4, Exp4_Data_MA)
Exp4_Data_MA$residuals <- Exp4_Data_MA$weightMA - Exp4_Data_MA$predicted_weight

# 5.2 Loop and Plot (Generate a plot for each pen showing all pig trajectories)
unique_pens <- unique(Exp4_Data_MA$pen)

# NOTE: The original script saved files to a specific local directory.
# We will just print the plots here for display in the R environment.
# Uncomment 'ggsave' if you need to save the files locally.
for (pen_id in unique_pens) {
  df <- Exp4_Data_MA %>% filter(pen == pen_id)
  
  plot_title <- paste("Exp 4 Pen", pen_id, "- Fitted (Line) vs. Actual (Point) Trajectories")
  
  plot <- ggplot(df, aes(x = daynb)) +
    # Actual Data Points
    geom_point(aes(y = weightMA), alpha=0.6, color="#0072B2") + 
    # Predicted Fitted Line
    geom_line(aes(y = predicted_weight), color="#D55E00", linewidth=1.1) + 
    facet_wrap(~ pig_id, scales = "free_y", nrow = 3) +
    labs(
      title = plot_title, 
      x = "Day Number", 
      y = "Smoothed Weight (weightMA)"
    ) +
    theme_minimal()
  
  # print(plot) 
  
  # Uncomment the following lines to save the plots to a local folder:
  # ggsave(filename = paste("pen_", pen_id, "_fitted_vs_actual.png", sep = ""),
  #        plot = plot, path = "C:/Your/Model/Output/Folder/", dpi = 300, width = 10, height = 7)
}