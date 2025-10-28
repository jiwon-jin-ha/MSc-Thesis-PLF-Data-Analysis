# =========================================================================
# 06_Results_Visualization.R
# Purpose: Generate high-quality figures for final reporting, focusing on 
#          overall experimental results and data variability comparison.
# Key Figures: 1) Pen-level Mean Weight Trajectories. 
#              2) Experiment-level Standard Deviation (Variability) Comparison.
# =========================================================================

# --- 1. Load Required Packages ------------------------------------------
library(dplyr)
library(ggplot2)
library(tidyr)


# --- 2. Load Final Model-Ready Dataset -----------------------------------
Final_Model_Data <- read.csv("Final_Model_Dataset_All_Experiments.csv", header=TRUE) %>%
  mutate(
    pig_id = as.factor(pig_id), 
    pen = as.factor(pen),
    exp = as.factor(exp)
  )

# Define Pen and Experiment Colors (Using colors from the original script)
Pen_colors <- c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00", 
                "#A65628", "#F781BF", "#999999", "#56B4E9", "#2CA02C", 
                "#6A3D9A", "#B15928") # Added more colors for safety

Exp_colors <- c("2" = "#1B9E77", "3" = "#D95F02", "4" = "#7570B3")


# =========================================================================
# Figure 1: Mean Body Weight for Each Pen (Overall Pattern)
# =========================================================================

# Calculate mean weight for each pen and daynb across all experiments
mean_sd_data_pen <- Final_Model_Data %>%
  group_by(exp, pen, daynb) %>%
  summarize(
    mean_weight = mean(weight_dol, na.rm=T),
    sd_weight = sd(weight_dol, na.rm=T),
    .groups = 'drop'
  )

# Plotting
ggplot(mean_sd_data_pen, aes(x = daynb, y = mean_weight, color = pen, group = pen)) +
  geom_point(size = 2.5, alpha = 0.6) +
  geom_line(linewidth = 1) +
  # Use facet_wrap to separate the visualization by experiment
  facet_wrap(~ exp, scales = "free_x", ncol = 1) +
  scale_color_manual(values = Pen_colors, name = "Pen ID") +
  labs(
    title = "Mean Body Weight Trajectories for Each Pen (Exp 2, 3, 4)",
    x = "Day Number (daynb)",
    y = "Mean Body Weight (Kg)"
  ) +
  theme_minimal() +
  theme(legend.position = "right", 
        plot.title = element_text(face = "bold"),
        axis.text.x = element_text(angle = 45, hjust = 1))


# =========================================================================
# Figure 2: Standard Deviation of Body Weight (Variability Comparison)
# =========================================================================

# Calculate SD for each experiment and daynb
sd_data_exp <- Final_Model_Data %>%
  group_by(exp, daynb) %>%
  summarize(
    sd_weight = sd(weight_dol, na.rm=T),
    .groups = 'drop'
  )

# Plotting
ggplot(sd_data_exp, aes(x = daynb, y = sd_weight, color = exp)) +
  geom_line(linewidth = 1.5) + 
  scale_color_manual(values = Exp_colors, name = "Experiment") +
  labs(
    title = "Standard Deviation of Body Weight: Comparison Across Experiments",
    subtitle = "Higher SD indicates greater variability or noise in weight measurements.",
    x = "Day Number (daynb)",
    y = "Standard Deviation (kg)"
  ) +
  scale_x_continuous(breaks = seq(min(sd_data_exp$daynb), max(sd_data_exp$daynb), by = 5)) +
  # Adjust y-limits based on typical SD range in pig body weight data
  scale_y_continuous(breaks = seq(4, 10, by = 0.5), limits = c(4, 10)) +  
  theme_minimal() +
  theme(legend.position = "top", 
        plot.title = element_text(face = "bold"))