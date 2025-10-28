# =========================================================================
# 02_Climate_Data_Processing.R
# Purpose: Demonstrate multi-modal sensor data integration and processing.
#
# NOTE: This script showcases the capacity to load, merge, clean, and restructure 
# external environmental sensor data (CO2, Temp, Hum). The processed data was
# NOT used in the final LMM growth analysis but demonstrates advanced R skills.
# =========================================================================

# --- 1. Setup and Package Loading ------------------------------------------

rm(list=ls())
## NOTE: All setwd() commands have been removed for GitHub portability.
## The working directory must contain:
## 1) All "Omni-Sensordata" CSV files.
## 2) The "Sensor ID overview.csv" file.

# Load necessary packages
library(tidyverse)
library(lubridate)
library(data.table)
library(readxl)

# --- 2. Define Experiment Parameters and Arrival Date ----------------------
# NOTE: Only one of the experiment blocks should be executed at a time, 
# as the 'arrival.date' is overwritten by subsequent blocks.

## Experiment 4 Parameters (Example used for final filter) ##
# The experiment lasted from d1 to d83 (i.e. 15-09-2022 to 06-12-2022)
arrival.date <- strptime("2022-09-15", format="%Y-%m-%d")

# # Experiment 2 Parameters #
# arrival.date <- strptime("2021-09-03", format="%Y-%m-%d")

# # Experiment 3 Parameters #
# arrival.date <- strptime("2022-05-12", format="%Y-%m-%d")


# --- 3. Import and Initial Data Transformation (Long Format Prep) -----------

# 3.1 Import all raw sensor files using file iteration
file_list <- list.files(pattern="Omni-Sensordata", recursive=FALSE)

# Use do.call(rbind, Map('cbind', ...)) for robust import and row-binding of multiple CSVs
# NOTE: sep=";" is crucial due to the DANISH format of the raw data.
climate.prep <- setNames(do.call(rbind,Map('cbind', lapply(file_list, read.csv, sep=";", header=FALSE))), 
                         nm=c("datetime", "device.id", "type", "value"))

# 3.2 Clean and transform into a standardized format
climate.prep2 <- climate.prep %>%
  filter(datetime != "SensorData") %>% # Remove header rows found in concatenated files
  mutate(
    date = strptime(str_sub(datetime, end=10), format="%Y-%m-%d"),
    # Calculate Day Number relative to the experiment's arrival date
    daynb = as.integer(difftime(date, arrival.date, unit="days")+1), 
    datetime2 = str_replace(datetime, "T", " "),
    datetime2 = str_remove(datetime2, "Z"),
    date.time = strptime(datetime2, format="%Y-%m-%d %H:%M:%S")
  ) %>%
  select(c(date, daynb, date.time, device.id, type, value))


# --- 4. Device ID and Pen Mapping (Data Integration) -----------------------

# Load device metadata and map device.id to pen/compartment
# The 'Sensor ID overview.csv' file must be accessible in the working directory.
devices_overview <- read.csv("Sensor ID overview.csv", sep="\t")

# Function to process and filter the device overview data
process_devices <- function(exp_nb) {
  devices_overview %>%
    setNames(nm=c("experiment", "compartment", "pen", "device.nb", "type", "device.id")) %>%
    filter(type == "climate") %>%
    mutate(
      experiment = as.character(exp_nb),
      pen = paste(pen, experiment, sep=".")
    ) %>%
    select(c("experiment", "compartment", "pen", "device.id"))
}

# Run the function for all experiments and combine the device metadata
devices <- bind_rows(
  process_devices("2"),
  process_devices("3"),
  process_devices("4")
) %>%
  # Filter to keep only the latest experiment number for each pen/device combination
  # This part of the logic needs refinement based on the original data structure, but keeps the original intent.
  distinct()


# --- 5. Merge, Clean, and Apply Sensor Filter Rules --------------------------

climate.long <- climate.prep2 %>%
  merge(devices, by="device.id", all=T) %>%
  filter(!is.na(pen)) %>% # Filter out devices not mapped to a known pen/experiment
  arrange(daynb, compartment, type) %>%
  distinct() %>%
  # Filter based on Experiment 4's official duration (Day 1 to 83)
  filter(daynb >= 1 & daynb <= 83) %>% 
  
  # Apply domain-specific filters to remove known faulty sensor readings (Crucial step for data quality)
  filter(!(type == "CO2-01" & compartment == "A") &
           !(type == "Hum-01" & compartment == "F" & daynb <= 2) &
           !(type == "CO2-01" & compartment == "B" & daynb >= 45))


# --- 6. Data Structure Conversion (Long to Wide Format) --------------------

# Pivot the data from Long format (one row per sensor value) to Wide format 
# (one row per date/pen with separate columns for each sensor type: CO2, Hum, Temp, Amm)
climate.wide <- climate.long %>%
  distinct() %>% # Remove introduced duplicate rows
  mutate(date.time = as.character(date.time)) %>%
  pivot_wider(id_cols=c("pen", "date", "compartment", "experiment", "daynb", "date.time"),
              names_from = "type",
              values_from = "value") %>%
  rename("co2" = "CO2-01",
         "hum" = "Hum-01",
         "temp" = "Temp-01",
         "amm" = "Ammonia") %>%
  distinct() %>%
  arrange(pen, date.time)
