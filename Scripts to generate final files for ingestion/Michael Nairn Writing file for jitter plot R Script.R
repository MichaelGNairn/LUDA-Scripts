# Michael Nairn Subnational Explorer R script to make jitter plot ingestion file file #

# 1st September 2022

# This script should import .csv data files, calculate MAD scores where relevant,
# and then export into one big excel file ready for upload to Subnational Indicators Explorer jitter plot.


# slightly altered from Henry Partidge code

# remove all data and clear environment

rm(list = ls())


library(tidyverse) ; library(readxl)


#### Read in LA geographies ####

# Local Authority districts (2021)
# Source: ONS Open Geography Portal
# URL: https://geoportal.statistics.gov.uk/datasets/local-authority-districts-may-2021-uk-buc

setwd("D:/Coding_Repos/LUDA/Geoportal codes")

# ensure this file is up to date with latest geoportal boundaries
LADs <- pull(read_csv("Local_Authority_Districts_2021.csv"), LAD21CD)



#### Import metadata

# Metadata 
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
  filter(
    # exclude indicators that aren't to be normalised
    !Worksheet %in% pull(filter(metadata, Jitter == "exclude"), Worksheet))

# One-off change for August release # 
# raw_df <- filter(raw,
    # remove FESkillsAchievements
#    Indicator != "19+ Further Education and Skills Achievements (qualifications) excluding community learning, Multiply and bootcamps") %>% 
#  mutate(
    # replace specific value with NA
#    Value = case_when(Worksheet == "RateEmployment" & AREANM == "City of London" ~ "", TRUE ~ Value) 
#   ) 



#### Isolate jitter relevant data #### 

jitter <- raw %>% 
  filter(AREACD %in% LADs)


#### Drop Welsh names ####
jitter <- jitter %>%
  mutate(AREANM = case_when(str_detect(AREANM, "/") ~ str_remove_all(AREANM, "\\/.*"), TRUE ~ AREANM)) 


#### Join metadata ####
jitter <- jitter %>%
  select(-c(Category,Period)) %>% 
  left_join(select(metadata, Worksheet, Shortened, Category, Period), by = "Worksheet")


#### Calculate MAD ####
jitter <- jitter %>%
  mutate(
    # reverse polarity
    Value = as.double(Value),
    Value = case_when(Polarity == -1 ~Value*(-1), TRUE ~ Value),
    # median absolute deviation
    MAD = (Value - median(Value, na.rm = TRUE)) / median(abs(Value - median(Value, na.rm = TRUE))*1.4826, na.rm = TRUE),
    Value = case_when(Polarity == -1 ~abs(Value), TRUE ~ Value)) %>% 
  ungroup() 
  
  
#### Sort as per technical annex ####
jitter <- jitter %>%
  arrange(factor(Worksheet, levels = pull(metadata, Worksheet))) %>%
  select(unique = AREACD, 
         group = AREANM, 
         Geography, Indicator, 
         id = Shortened, 
         Category, Period, Measure,
         unit = Unit, 
         real = Value,
         value = MAD)


#### Export output ####

setwd("D:/Coding_Repos/LUDA/Output/Final_Output")

write_excel_csv(jitter, "jitter_data.csv")


