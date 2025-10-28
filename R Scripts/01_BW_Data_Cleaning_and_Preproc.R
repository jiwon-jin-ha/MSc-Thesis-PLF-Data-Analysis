# =========================================================================
# 01_BW_Data_Cleaning_and_Preproc.R
# Purpose: Implement and visualize the data cleaning process for 
#          Experiments 2, 3, and 4 (Individual Pig BW Data).
# Key Cleaning Rules: 1) nb.pictures >= 30, 2) Misplacement Pig Removal.
# =========================================================================

# --- 1. Load Required Packages ------------------------------------------
library(kableExtra) # For creating data summary tables
library(ggplot2)    # For visualization and quality checks
library(dplyr)      # For data manipulation (e.g., filtering, summarizing)


# --- 2. Data Quality Summary Table ---------------------------------------
# This table summarizes the data loss (%) due to the 'Less than 30 pictures per day' rule across experiments.
my_data <- matrix(c("", "Exp2", "Exp3", "Exp4",
                    "Observation days", 85, 101, 83,
                    "Total data", 8693, 9529, 8675,
                    "<30", 8, 607, 69,
                    "% of total data", "0.09%", "6.37%", "0.8%"), ncol = 4, byrow = TRUE)

kable(my_data, align = "c", col.names = NULL) %>%
  kable_styling(font_size = 15)


# --- 3. Experiment 2 Data Cleaning & Quality Check -----------------------

# NOTE: The absolute path (setwd) is removed for GitHub portability.
# Raw data CSV file must be placed in the working directory to run this code.

# 3.1 Data Load and Initial Preprocessing
BW1 <- read.csv("Exp2 - Pig level camera weight data 221221 - too many pigs.csv", header=TRUE)

# Convert character column to Date format for time-series analysis (Format: MM/DD/YYYY)
BW1$date <- as.Date(BW1$date, format = "%m/%d/%Y")


# 3.2 Filtering Rule Application & Initial Cleaned Data Creation
# Apply the key data cleaning rule: filter out observations with less than 30 pictures (low quality)
less_than_30_1 <- subset(BW1, nb.pictures < 30)
NBW1 <- subset(BW1, nb.pictures >= 30) # Initial cleaned dataset for Exp 2


# 3.3 QA Check: Exp 2 Misplacement Pig Detection
PD1 <- read.csv("Exp2 - Pig registration all info combined 220921.csv", header=TRUE)

# Prepare Meta Data: create a list of officially registered pig-pen combinations
new_PD1 <- PD1 %>% select(pig.short, pen) %>% mutate(is_registered = "yes")

# Merge: Merge the cleaned camera data (NBW1) with the official registration list (new_PD1).
merged_check1 <- left_join(NBW1, new_PD1, by = c("pig.short", "pen"))

# Identify Misplaced Pigs
misplaced_pigs_exp2 <- merged_check1[is.na(merged_check1$is_registered), ]

# Report and Action
cat("\n--- QA Check Result: Exp 2 Misplaced Pigs ---\n")
if (nrow(misplaced_pigs_exp2) > 0) {
  cat(paste("Total", nrow(misplaced_pigs_exp2), "observations from", 
            length(unique(misplaced_pigs_exp2$pig.short)), "pigs are misplaced/unregistered."))
  NBW1 <- merged_check1 %>% filter(!is.na(is_registered)) %>% select(-is_registered)
  cat("\nAction: Misplaced observations removed from NBW1.\n")
} else {
  cat("No misplaced pig observations found in Exp 2.\n")
  NBW1 <- merged_check1 %>% select(-is_registered)
}
cat("----------------------------------------------\n")

# 3.4 Data Quality Visualization: Weight vs. Picture Count (Exp 2) 
# Visualization to check the distribution and quality of the remaining data points.
my_colors <- c("#FEE391", "#FEC44F", "#FE9929", "#EC7014", "#CC4C02")

ggplot(NBW1, aes(x = date, y = weight_dol, color = nb.pictures)) + 
geom_point(size = 3, alpha = 0.5) +
  scale_color_gradientn(colors = my_colors,
                        limits = c(30, max(NBW1$nb.pictures, na.rm=T)), 
                        breaks = c(30, 50, 70), 
                        na.value = "#2C3E50") +
  labs(title = "Exp 2 - Weight of Pigs by Date (Cleaned Data)",
       x = "Date",
       y = "Weight",
       color = "Number of Pictures") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8), legend.position = "top")


# --- 4. Experiment 3 Data Cleaning & Quality Check -----------------------

# 4.1 Data Load and Initial Preprocessing
BW2 <- read.csv("Exp3 - Pig level camera weight data 221221 - too many pigs.csv", header=TRUE)

# Convert character column to Date format (Format: YYYY-MM-DD)
BW2$date <- as.Date(BW2$date, format = "%Y-%m-%d")


# 4.2 Filtering Rule Application & Initial Cleaned Data Creation 
less_than_30_2 <- subset(BW2, nb.pictures < 30)
NBW2 <- subset(BW2, nb.pictures >= 30) # Initial cleaned dataset for Exp 3 


# 4.3 QA Check: Exp 3 Misplacement Pig Detection
PD2 <- read.csv("Exp3 - Pig registration all info combined 220921.csv", header=TRUE)
PD2$pen <- sub("\\.3", "", PD2$pen) 
names(PD2)[names(PD2) == "pig.short"] <- "pig" 

new_PD2 <- PD2 %>% select(pig, pen) %>% mutate(is_registered = "yes")
merged_check2 <- left_join(NBW2, new_PD2, by = c("pig", "pen"))
misplaced_pigs_exp3 <- merged_check2[is.na(merged_check2$is_registered), ]

# Report and Action
cat("\n--- QA Check Result: Exp 3 Misplaced Pigs ---\n")
if (nrow(misplaced_pigs_exp3) > 0) {
  cat(paste("Total", nrow(misplaced_pigs_exp3), "observations from", 
            length(unique(misplaced_pigs_exp3$pig)), "pigs are misplaced/unregistered."))
  NBW2 <- merged_check2 %>% filter(!is.na(is_registered)) %>% select(-is_registered)
  cat("\nAction: Misplaced observations removed from NBW2.\n")
} else {
  cat("No misplaced pig observations found in Exp 3.\n")
  NBW2 <- merged_check2 %>% select(-is_registered)
}
cat("----------------------------------------------\n")

# 4.4 Data Quality Visualization: Weight vs. Picture Count (Exp 3) 
my_colors <- c("#FEE391", "#FEC44F", "#FE9929", "#EC7014", "#CC4C02")

ggplot(NBW2, aes(x = date, y = weight_dol, color = nb.pictures)) + 
geom_point(size = 3, alpha = 0.5) +
  scale_color_gradientn(colors = my_colors,
                        limits = c(30, max(NBW2$nb.pictures, na.rm=T)), 
                        breaks = c(30, 50, 70), 
                        na.value = "#2C3E50") +
  labs(title = "Exp 3 - Weight of Pigs by Date (Cleaned Data)", 
       x = "Date",
       y = "Weight",
       color = "Number of Pictures") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8), legend.position = "top")


# --- 5. Experiment 4 Data Cleaning & Quality Check -----------------------

# 5.1 Data Load and Initial Preprocessing
BW3 <- read.csv("Exp4 - Pig level camera weight data 221221 - too many pigs.csv", header=TRUE)

# Convert character column to Date format (Format: YYYY-MM-DD)
BW3$date <- as.Date(BW3$date, format = "%Y-%m-%d")


# 5.2 Filtering Rule Application & Initial Cleaned Data Creation 
less_than_30_3 <- subset(BW3, nb.pictures < 30)
NBW3 <- subset(BW3, nb.pictures >= 30) # Initial cleaned dataset for Exp 4 


# 5.3 QA Check: Exp 4 Misplacement Pig Detection 
PD3 <- read.csv("Exp4 - Pig registration all info combined 220921.csv", header=TRUE)

# Prepare Meta Data: create a list of officially registered pig-pen combinations
new_PD3 <- PD3 %>% select(pig.short, pen) %>% mutate(is_registered = "yes")

# Merge: Merge the cleaned camera data (NBW3) with the official registration list (new_PD3).
merged_check3 <- left_join(NBW3, new_PD3, by = c("pig.short", "pen"))

# Identify Misplaced Pigs
misplaced_pigs_exp4 <- merged_check3[is.na(merged_check3$is_registered), ]

# Report and Action
cat("\n--- QA Check Result: Exp 4 Misplaced Pigs ---\n")
if (nrow(misplaced_pigs_exp4) > 0) {
  cat(paste("Total", nrow(misplaced_pigs_exp4), "observations from", 
            length(unique(misplaced_pigs_exp4$pig.short)), "pigs are misplaced/unregistered."))
  NBW3 <- merged_check3 %>% filter(!is.na(is_registered)) %>% select(-is_registered)
  cat("\nAction: Misplaced observations removed from NBW3.\n")
} else {
  cat("No misplaced pig observations found in Exp 4.\n")
  NBW3 <- merged_check3 %>% select(-is_registered)
}
cat("----------------------------------------------\n")

# 5.4 Data Quality Visualization: Weight vs. Picture Count (Exp 4) 
my_colors <- c("#FEE391", "#FEC44F", "#FE9929", "#EC7014", "#CC4C02")

ggplot(NBW3, aes(x = date, y = weight_dol, color = nb.pictures)) + 
geom_point(size = 3, alpha = 0.5) +
  scale_color_gradientn(colors = my_colors,
                        limits = c(30, max(NBW3$nb.pictures, na.rm=T)), 
                        breaks = c(30, 50, 70), 
                        na.value = "#2C3E50") +
  labs(title = "Exp 4 - Weight of Pigs by Date (Cleaned Data)", 
       x = "Date",
       y = "Weight",
       color = "Number of Pictures") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8), legend.position = "top")


# --- 6. Quality Visualization: Pen-Level Iteration (Exp 2 Example) -------
# Demonstrates code automation by generating a separate quality plot for each pen 
# using a for-loop, avoiding repetitive code blocks.

# Get unique pen names
pen_names <- unique(NBW1$pen) 

# Define the colors for each range
my_colors <- c("#FEE391", "#FEC44F", "#FE9929", "#EC7014", "#CC4C02")
opposite_color <- "#2C3E50"

# Loop over pens and create a plot for each pen (uncomment to run)
# for (pen_name in pen_names) {
#   
#   # Subset data for the current pen
#   pen_data <- filter(NBW1, pen == pen_name) 
#   
#   # Create the plot with manual color scale
#   pen_plot <- ggplot(pen_data, aes(x = date, y = weight_dol, color = nb.pictures)) +
#     geom_point(size = 3, alpha = 0.5) +
#     scale_color_gradientn(colors = my_colors, 
#                           limits = c(30, max(pen_data$nb.pictures, na.rm=T)), 
#                           breaks = c(30, 50, 70), 
#                           na.value = opposite_color) +
#     labs(title = paste("Exp 2", pen_name, "- Weight of Pigs by Date (Cleaned Quality)"), 
#          x = "Date",
#          y = "Weight",
#          color = "Number of Pictures") +
#     theme_minimal() +
#     scale_x_date(date_labels = "%Y-%m-%d", date_breaks = "1 day") +
#     theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8), legend.position = "top")
#   
#   # Modify the legend labels
#   pen_plot <- pen_plot + guides(color = guide_colorsteps(
#     title = "Number of Pictures",
#     values = c(30, 50, 70), 
#     colors = c("#FEC44F", "#FE9929", "#EC7014") 
#   ))
#   
#   # print(pen_plot) # Uncomment to display plots in R environment
# }


# --- 7. Final Anomaly Correction (Thesis Methodology: Section 2.3) -------
# This phase applies the domain-specific smoothing and correction rules 
# defined in the thesis (2.3 Data cleaning). This custom function should be 
# applied to the *fully cleaned* datasets (NBW1, NBW2, NBW3).

# The process involves:
# 1) Checking for consistent weight trends across all pigs in a pen.
# 2) Identifying and flagging extreme daily growth outliers (>4kg/day).
# 3) Applying a modification method (e.g., gap-filling) to correct outliers.
#
# NOTE: The custom function code for the final modification method is omitted 
# for brevity and proprietary reasons. The inclusion of this section documents 
# the implementation of domain knowledge-based anomaly correction.


# --- 8. Export Cleaned Datasets  ------------------------------------------
# Export the final cleaned datasets for use in the 03_Growth_Model_Prep.R script.

# write.csv(NBW1, "Exp2_BW_cleaned.csv", row.names = FALSE)
# write.csv(NBW2, "Exp3_BW_cleaned.csv", row.names = FALSE)
# write.csv(NBW3, "Exp4_BW_cleaned.csv", row.names = FALSE)