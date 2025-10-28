# =========================================================================
# 04_LMM_Growth_Modeling.R
# Purpose: Perform Exploratory Data Analysis (EDA) on key variables and 
#          fit the Linear Mixed Model (LMM) to analyze pig growth.
# Key Steps: 1) Load Final Data, 2) start_bw Group EDA, 3) LMM Fitting.
# =========================================================================

# --- 1. Load Required Packages ------------------------------------------
library(dplyr)
library(ggplot2)
library(lme4)     # Core package for fitting Linear Mixed Models
library(lmerTest) # For obtaining p-values and model summaries
library(zoo)      # If any last-minute smoothing is needed


# --- 2. Load Final Model-Ready Dataset -----------------------------------
# Load the dataset created by the 03_Growth_Model_Prep.R script.
Final_Model_Data <- read.csv("Final_Model_Dataset_All_Experiments.csv", header=TRUE)

# Ensure necessary columns are correctly typed (Factor for grouping)
Final_Model_Data <- Final_Model_Data %>%
  mutate(
    date = as.Date(date, format = "%Y-%m-%d"),
    pig_id = as.factor(if_else(!is.na(pig.short), as.character(pig.short), as.character(pig))), # Use the unified pig ID
    pen = as.factor(pen),
    exp = as.factor(exp),
    # start_bw: Assuming this column is available from the 03_ file's merge step
    start_bw = as.factor(start_bw)
  ) %>%
  # Select only the relevant columns for LMM and analysis
  select(date, daynb, exp, pen, pig_id, weight_dol, daily_growth, daily_growthMA_3, daily_growthMA_4, daily_growthMA_5, growth_rate, start_bw)


# --- 3. Exploratory Data Analysis (EDA): start_bw Effect Visualization ---
# Goal: Justify including 'start_bw' as a fixed effect by visualizing 
#       how growth curves differ between starting weight groups (light/heavy).

# 3.1 Data Preparation for Group Visualization (based on user's snippet logic)
# Note: Filter to only 'heavy' and 'light' groups if 'start_bw' contains others
EDA_Data <- Final_Model_Data %>%
  # Filter groups relevant for comparison if needed (e.g., exclude 'medium')
  filter(start_bw %in% c("heavy", "light")) %>% 
  group_by(start_bw, daynb) %>%
  summarize(
    mean_weight = mean(weight_dol, na.rm=T),
    # Calculate Mean +/- SD for visualization (assuming normal distribution proxy)
    min_weight = mean(weight_dol, na.rm=T) - sd(weight_dol, na.rm=T),
    max_weight = mean(weight_dol, na.rm=T) + sd(weight_dol, na.rm=T),
    .groups = 'drop'
  )

# 3.2 Visualization Plot: Weight vs. Day Number by start_bw group
ggplot(EDA_Data, aes(x = daynb, y = mean_weight, color = start_bw, fill = start_bw)) +
  geom_point(size = 3, alpha = 0.5) +
  geom_line(linewidth = 1) +
  # Add shaded ribbon for Standard Deviation (SD) area
  geom_ribbon(aes(ymin = min_weight, ymax = max_weight), alpha = 0.2, color = NA) +
  scale_color_manual(values = c("heavy" = "red", "light" = "blue")) +
  scale_fill_manual(values = c("heavy" = "red", "light" = "blue")) +
  labs(
    title = "Mean Body Weight Trajectories by Starting Body Weight Group",
    subtitle = "Standard Deviation represented by shaded area (across all experiments)",
    x = "Day Number (daynb)",
    y = "Mean Body Weight (Kg)",
    color = "Starting BW Group",
    fill = "Starting BW Group"
  ) +
  theme_minimal() +
  theme(legend.position = "top")


# --- 4. Linear Mixed Model (LMM) Fitting ----------------------------------
# Goal: Model the daily weight (weight_dol) or growth rate (daily_growthMA_X) 
#       as a function of time (daynb) and fixed effects (start_bw, exp).
#       Pig ID and Pen are included as random effects.

# 4.1 Define the Model Formula (Example using Body Weight)
# - Fixed Effects: daynb (time), I(daynb^2) (non-linear growth), start_bw, exp
# - Random Effects: (1|pig_id) (Random intercept for each pig, accounting for pig-to-pig variability)
#                   (1|pen) (Random intercept for each pen, accounting for environmental/pen effects)

# Model 1: Weight as a function of time, quadratic time, and start_bw/exp
Model_BW <- lmer(
  weight_dol ~ daynb + I(daynb^2) + start_bw + exp + (1 | pig_id) + (1 | pen),
  data = Final_Model_Data,
  REML = TRUE # Restricted Maximum Likelihood for unbiased variance estimates
)

# 4.2 Define the Model Formula (Example using Smoothed Growth Rate)
# Note: daily_growthMA_3 is often preferred as the response variable for growth analysis
# Model 2: Smoothed Daily Growth Rate as a function of time and fixed effects
Model_ADG <- lmer(
  daily_growthMA_3 ~ daynb + I(daynb^2) + start_bw + exp + (1 | pig_id) + (1 | pen),
  data = Final_Model_Data,
  REML = TRUE
)


# --- 5. Model Output and Interpretation ----------------------------------

cat("\n--- LMM Model 1: Body Weight (weight_dol) --- \n")
summary(Model_BW)
# anova(Model_BW) # Use anova() for fixed effect significance (via lmerTest)

cat("\n--- LMM Model 2: Smoothed Daily Growth Rate (daily_growthMA_3) --- \n")
summary(Model_ADG)
# anova(Model_ADG) # Use anova() for fixed effect significance (via lmerTest)


# --- 6. Model Diagnostics (Optional but Recommended) ---------------------
# Check residuals for normality and homoscedasticity.

# plot(Model_ADG)
# qqnorm(resid(Model_ADG))
# qqline(resid(Model_ADG))