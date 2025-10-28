# =========================================================================
# 03_Growth_Model_Prep.R
# Purpose: Data aggregation, quality verification, and preparation for LMM/Growth Models.
# =========================================================================

# --- 1. Load Required Packages ------------------------------------------
library(dplyr)
library(ggplot2)
library(gridExtra) # For arranging Original vs. Cleaned plots
library(tidyr) 
library(zoo) 

# --- 2. Quality Check: Daily Measurement Coverage (Original vs. Cleaned) ---
# Compares the daily count of unique pigs (measurement coverage) before and after filtering.
# This confirms the impact of the cleaning step on data completeness.

# Define color palette for pens (Used across all experiments)
pen_colors <- c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3", "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999", "#56B4E9")


# --- 2.1 Experiment 2 Coverage Check -------------------------------------
# --- 2.1.1 Original Data Coverage (Load raw file)
BW1 <- read.csv("Exp2 - Pig level camera weight data 221221 - too many pigs.csv", header=TRUE)
BW1$date <- as.Date(BW1$date, format = "%m/%d/%Y")

BW1_original_count <- BW1 %>%
  mutate(date = as.Date(date, format = "%Y-%m-%d")) %>%
  group_by(date, pen) %>%
  summarise(num_pigs = n_distinct(pig.short), .groups = 'drop')

p1 <- ggplot(BW1_original_count, aes(x = date, y = num_pigs, fill = pen)) +
  geom_col() +
  scale_fill_manual(values = pen_colors, name = "Pen") +
  labs(title = "Exp 2 - Original Data (Daily Pig Count)", x = "Date", y = "Number of Pigs") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8), legend.position = "top")


# --- 2.1.2 Cleaned Data Coverage (Load output from 01_ cleaning script)
NBW1 <- read.csv("Exp2_BW_cleaned.csv", header=TRUE)

NBW1_cleaned_count <- NBW1 %>%
  mutate(date = as.Date(date, format = "%Y-%m-%d")) %>%
  group_by(date, pen) %>%
  summarise(num_pigs = n_distinct(pig.short), .groups = 'drop')

p2 <- ggplot(NBW1_cleaned_count, aes(x = date, y = num_pigs, fill = pen)) +
  geom_col() +
  scale_fill_manual(values = pen_colors, name = "Pen") +
  labs(title = "Exp 2 - Cleaned Data (Daily Pig Count)", x = "Date", y = "Number of Pigs") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8), legend.position = "top")

# Arrange the plots to compare coverage
grid.arrange(p1, p2, ncol = 1)


# --- 2.2 Experiment 3 Coverage Check -------------------------------------

# --- 2.2.1 Original Data Coverage (Load raw file)
BW2 <- read.csv("Exp3 - Pig level camera weight data 221221 - too many pigs.csv", header=TRUE)

BW2_original_count <- BW2 %>%
  mutate(date = as.Date(date, format = "%Y-%m-%d")) %>%
  group_by(date, pen) %>%
  summarise(num_pigs = n_distinct(pig), .groups = 'drop') # Note: uses 'pig' not 'pig.short'

p3 <- ggplot(BW2_original_count, aes(x = date, y = num_pigs, fill = pen)) +
  geom_col() +
  scale_fill_manual(values = pen_colors, name = "Pen") +
  scale_x_date(date_labels = "%Y-%m-%d", date_breaks = "1 day") +
  scale_y_continuous(breaks = seq(0, 150, 5)) +
  labs(title = "Exp 3 - Original Data (Daily Pig Count)", x = "Date", y = "Number of Pigs") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8), legend.position = "top")


# --- 2.2.2 Cleaned Data Coverage (Load output from 01_ cleaning script)
NBW2 <- read.csv("Exp3_BW_cleaned.csv", header=TRUE)

NBW2_cleaned_count <- NBW2 %>%
  mutate(date = as.Date(date, format = "%Y-%m-%d")) %>%
  group_by(date, pen) %>%
  summarise(num_pigs = n_distinct(pig), .groups = 'drop') # Note: uses 'pig' not 'pig.short'

p4 <- ggplot(NBW2_cleaned_count, aes(x = date, y = num_pigs, fill = pen)) +
  geom_col() +
  scale_fill_manual(values = pen_colors, name = "Pen") +
  # Keep Exp 3 specific date limits for focused visualization
  scale_x_date(date_labels = "%Y-%m-%d", date_breaks = "1 day", limits = as.Date(c("2022-05-16", "2022-08-24"))) + 
  scale_y_continuous(breaks = seq(0, 115, 5), limits = c(0, 115)) +
  labs(title = "Exp 3 - Cleaned Data (Daily Pig Count)", x = "Date", y = "Number of Pigs") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8), legend.position = "top")

# Arrange the plots to compare coverage
grid.arrange(p3, p4, ncol = 1)


# --- 2.3 Experiment 4 Coverage Check -------------------------------------

# --- 2.3.1 Original Data Coverage (Load raw file)
BW3 <- read.csv("Exp4 - Pig level camera weight data 221221 - too many pigs.csv", header=TRUE)

BW3_original_count <- BW3 %>%
  mutate(date = as.Date(date, format = "%Y-%m-%d")) %>%
  group_by(date, pen) %>%
  summarise(num_pigs = n_distinct(pig), .groups = 'drop') # Note: uses 'pig' not 'pig.short'

p5 <- ggplot(BW3_original_count, aes(x = date, y = num_pigs, fill = pen)) +
  geom_col() +
  scale_fill_manual(values = pen_colors, name = "Pen") +
  scale_x_date(date_labels = "%Y-%m-%d", date_breaks = "1 day") +
  scale_y_continuous(breaks = seq(0, 150, 5)) +
  labs(title = "Exp 4 - Original Data (Daily Pig Count)", x = "Date", y = "Number of Pigs") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8), legend.position = "top")


# --- 2.3.2 Cleaned Data Coverage (Load output from 01_ cleaning script)
NBW3 <- read.csv("Exp4_BW_cleaned.csv", header=TRUE)

NBW3_cleaned_count <- NBW3 %>%
  mutate(date = as.Date(date, format = "%Y-%m-%d")) %>%
  group_by(date, pen) %>%
  summarise(num_pigs = n_distinct(pig), .groups = 'drop') # Note: uses 'pig' not 'pig.short'

p6 <- ggplot(NBW3_cleaned_count, aes(x = date, y = num_pigs, fill = pen)) +
  geom_col() +
  scale_fill_manual(values = pen_colors, name = "Pen") +
  scale_x_date(date_labels = "%Y-%m-%d", date_breaks = "1 day") +
  scale_y_continuous(breaks = seq(0, 150, 5)) +
  labs(title = "Exp 4 - Cleaned Data (Daily Pig Count)", x = "Date", y = "Number of Pigs") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8), legend.position = "top")

# Arrange the plots to compare coverage
grid.arrange(p5, p6, ncol = 1)


# --- 3. Data Integration (Cleaned BW + Meta Data) and Feature Engineering ---
# This section creates the final model-ready dataset by merging cleaned BW data 
# and pig registration (Meta) data ONLY.

# --- 3.1 Experiment 2 Data Preparation ---
# 1. Load Meta Data (Pig Registration)
PD1 <- read.csv("Exp2 - Pig registration all info combined 220921.csv", header=TRUE)

# 2. Merge Data: NBW1 (Bodyweight, loaded in Sec 2.1) + PD1 (Meta)
Merged_Exp2 <- left_join(NBW1, PD1 %>% select(pig.short, pen, start_bw), by = c("pig.short", "pen"))
# Ensure 'exp' column is added for final combination
Merged_Exp2$exp <- 2


# --- 3.2 Experiment 3 Data Preparation ---
# 1. Load Meta Data (Pig Registration)
PD2 <- read.csv("Exp3 - Pig registration all info combined 220921.csv", header=TRUE)

# 2. Merge Data: NBW2 (Bodyweight, loaded in Sec 2.2) + PD2 (Meta)
# Note: Adjust column name for Exp 3 consistency
names(PD2)[names(PD2) == "pig.short"] <- "pig" 
Merged_Exp3 <- left_join(NBW2, PD2 %>% select(pig, pen, start_bw), by = c("pig", "pen"))
# Ensure 'exp' column is added for final combination
Merged_Exp3$exp <- 3


# --- 3.3 Experiment 4 Data Preparation ---
# 1. Load Meta Data (Pig Registration)
PD3 <- read.csv("Exp4 - Pig registration all info combined 220921.csv", header=TRUE)

# 2. Merge Data: NBW3 (Bodyweight, loaded in Sec 2.3) + PD3 (Meta)
# Note: Adjust column name for Exp 4 consistency
names(PD3)[names(PD3) == "pig.short"] <- "pig" 
Merged_Exp4 <- left_join(NBW3, PD3 %>% select(pig, pen, start_bw), by = c("pig", "pen"))
# Ensure 'exp' column is added for final combination
Merged_Exp4$exp <- 4


# --- 3.4 Combine All Experiments and Final Feature Engineering ---

# Combine all merged datasets into one for final LMM/Growth Model
Final_Model_Data <- bind_rows(Merged_Exp2, Merged_Exp3, Merged_Exp4)

# 3.4.1 Feature Engineering: Growth Calculations (ADG, MA, Lifetime Rate) 

Final_Model_Data <- Final_Model_Data %>% 
  # Use 'pig.short' if available, otherwise use 'pig' for grouping
  mutate(pig_id = if_else(!is.na(pig.short), as.character(pig.short), as.character(pig))) %>%
  group_by(pig_id) %>% 
  arrange(date) %>% 
  
  # 1. Daily Growth Calculation (ADG)
  mutate(daily_growth = weight_dol - lag(weight_dol)) %>% 
  
  # 2. Moving Average Calculations (MA) 
  mutate(
    daily_growthMA_3 = rollmean(daily_growth, k = 3, fill = NA, align = "right"),
    daily_growthMA_4 = rollmean(daily_growth, k = 4, fill = NA, align = "right"),
    daily_growthMA_5 = rollmean(daily_growth, k = 5, fill = NA, align = "right")
  ) %>%
  
  # 3. LIFETIME Growth Rate Calculation (LADG) 
  mutate(
    start_weight = first(weight_dol, na.rm=T),
    end_weight = last(weight_dol, na.rm=T),
    number_of_days = max(daynb, na.rm=T) - min(daynb, na.rm=T),
    growth_rate = (end_weight - start_weight) / number_of_days 
  ) %>%
  ungroup() %>%
  
  # Remove temporary columns
  select(-pig_id, -start_weight, -end_weight, -number_of_days) 

# Export the final model-ready dataset 
# write.csv(Final_Model_Data, "Final_Model_Dataset_All_Experiments.csv", row.names = FALSE)


# --- 4. Final Quality Check: Individual Growth Trajectories ---------------
# Verifies the cleaned data quality by visualizing the growth trajectory of 
# every single pig within each pen (Ultimate domain-knowledge validation).

# --- 4.1 Exp 2 Individual Growth Plot (Uses NBW1) ---
NBW1$pig.short <- as.factor(NBW1$pig.short)
NBW1$date <- as.Date(NBW1$date)

plot_pen_exp2 <- function(pen_num) {
  pen_data <- subset(NBW1, pen == pen_num)
  ggplot(pen_data, aes(x = date, y = weight_dol, color = pig.short)) +
    geom_line(aes(group = pig.short)) +
    ggtitle(paste("Exp 2 - Growth Trajectories (Pen", pen_num, ")")) +
    xlab("Date") + ylab("Weight") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8)) +
    scale_color_discrete(name = "Pig ID")
}
pen_plots_exp2 <- lapply(unique(NBW1$pen), plot_pen_exp2)
# gridExtra::grid.arrange(grobs = pen_plots_exp2, ncol = 1) # Uncomment to display all plots


# --- 4.2 Exp 3 Individual Growth Plot (Uses NBW2) ---
NBW2$pig <- as.factor(NBW2$pig)
NBW2$date <- as.Date(NBW2$date)

plot_pen_exp3 <- function(pen_num) {
  pen_data <- subset(NBW2, pen == pen_num)
  ggplot(pen_data, aes(x = date, y = weight_dol, color = pig)) +
    geom_line(aes(group = pig)) +
    ggtitle(paste("Exp 3 - Growth Trajectories (Pen", pen_num, ")")) +
    xlab("Date") + ylab("Weight") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8)) +
    scale_color_discrete(name = "Pig ID")
}
pen_plots_exp3 <- lapply(unique(NBW2$pen), plot_pen_exp3)
# gridExtra::grid.arrange(grobs = pen_plots_exp3, ncol = 1) # Uncomment to display all plots


# --- 4.3 Exp 4 Individual Growth Plot (Uses NBW3) ---
NBW3$pig.short <- as.factor(NBW3$pig.short)
NBW3$date <- as.Date(NBW3$date)

plot_pen_exp4 <- function(pen_num) {
  pen_data <- subset(NBW3, pen == pen_num)
  min_date <- min(pen_data$date); max_date <- max(pen_data$date)
  
  ggplot(pen_data, aes(x = date, y = weight_dol, color = pig.short)) +
    geom_line(aes(group = pig.short)) +
    ggtitle(paste("Exp 4 - Growth Trajectories (Pen", pen_num, ")")) +
    xlab("Date") + ylab("Weight") +
    theme_minimal() +
    scale_x_date(date_labels = "%Y-%m-%d", date_breaks = "1 day") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8)) +
    scale_x_date(expand = c(0,0), limits = c(min_date, max_date)) +
    scale_color_discrete(name = "Pig ID")
}
pen_plots_exp4 <- lapply(unique(NBW3$pen), plot_pen_exp4)
# gridExtra::grid.arrange(grobs = pen_plots_exp4, ncol = 1) # Uncomment to display all plots