# Michael Nairn Subnational Explorer R script to make Machine readable csv file #

# 1st September 2022

# This script should import .csv data files, calculate MAD scores where relevant,
# and then export into one big excel file ready for upload to Subnational Indicators Explorer.


# slightly altered from Henry Partidge code

# remove all data and clear environment

rm(list = ls())


library(tidyverse)

# Local Authority districts (2021)
# Source: ONS Open Geography Portal
# URL: https://geoportal.statistics.gov.uk/datasets/local-authority-districts-may-2021-uk-buc

setwd("D:/Coding_Repos/LUDA/Geoportal codes")

# ensure this file is up to date with latest geoportal boundaries
LADs <- pull(read_csv("Local_Authority_Districts_2021.csv"), LAD21CD)


#### Import metadata

# Metadata and indicators
# Source: ONS
# URL: https://github.com/ONSdigital/LUDA

setwd("D:/Coding_Repos/LUDA/Output")

metadata <- read_excel("metadata.xlsx")


#### Import data ####

folder <- "../../LUDA/Output/Most Recent Year Output"
# this is only including most recent year of output. If want full time series then 
  # "../../LUDA/Output" 
  # Please note necessary change to MAD calculation outlined below.

raw <- folder %>%
  dir(pattern = "*.csv", full.names = T) %>% 
  setNames(nm = .) %>% 
  map_df(~read_csv(.x, col_types = cols(.default = "c")), .id = "Worksheet") %>%
  mutate(Worksheet = str_extract(Worksheet, "(?<=Output/)(.+)(?=\\.)")) %>% 
  select(Worksheet, Polarity, AREACD, AREANM, Geography, Indicator, Category, Period, Measure, Unit, Value)


#### Isolate jitter relevant data #### 

jitter <- raw %>% 
  filter(
    # filter by local authority
    AREACD %in% LADs,
    # exclude indicators that aren't to be normalised
    !Worksheet %in% pull(filter(metadata, Jitter == "exclude"), Worksheet))


#### Drop Welsh names ####
jitter <- jitter %>%
  mutate(AREANM = case_when(str_detect(AREANM, "/") ~ str_remove_all(AREANM, "\\/.*"), TRUE ~ AREANM)) 


#### join metadata ####
jitter <- jitter %>%
  select(-Category) %>% 
  left_join(select(metadata, Worksheet, Category), by = "Worksheet") %>% 
  group_by(Worksheet)


#### Calculate MAD ####

# If doing for all years, will have to group by period

jitter <- jitter %>%
  mutate(
    # reverse polarity
    Value = as.double(Value),
    Value = case_when(Polarity == -1 ~Value*(-1), TRUE ~ Value),
    # median absolute deviation
    MAD = (Value - median(Value, na.rm = TRUE)) / median(abs(Value - median(Value, na.rm = TRUE))*1.4826, na.rm = TRUE),
    Value = case_when(Polarity == -1 ~abs(Value), TRUE ~ Value)) %>% 
  ungroup() %>% 
  relocate(Category, .after = Indicator)



#### Non-jitter plot data ####

other_geographies <- raw %>% 
  filter(
    # exclude local authorities
    !AREACD %in% LADs) %>%
  # join metadata
  select(-Category) %>% 
  left_join(select(metadata, Worksheet, Category), by = "Worksheet") %>% 
  mutate(MAD = as.character(NA)) %>% 
  relocate(Category, .after = Indicator) 

#### Join dataframes ####
csv_output <- bind_rows(
  mutate(jitter, Value = as.character(Value), MAD = as.character(MAD)), 
  other_geographies) %>% 
  # sort as per technical annex 
  arrange(factor(Worksheet, levels = pull(metadata, Worksheet))) %>% 
  select(-c(Worksheet, Polarity))

#### Export output ####

setwd("D:/Coding_Repos/LUDA/Output/Final_Output")

cat("There may be some discrepancies between this data download and the accompanying dataset caused by rounding issues but these should be insignificant and are unlikely to affect any further analysis\n\n", file = "machine_readable.csv")
write_excel_csv(csv_output, "machine_readable.csv", append = TRUE, col_names = TRUE)


