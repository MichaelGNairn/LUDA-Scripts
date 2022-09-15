#### Michael Nairn Subnational Statistics Proportion of children in workless households R Script ####

# 11th July 2022

# This script should download NOMIS data and adapt it ready for upload to Subnational Indicators Explorer.
  # Hopefully I will amend so it can work for other APIs

############## SET WORKING DIRECTORY!! 

setwd("D:/Coding_Repos/LUDA")

# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 1: closing the gap in median employment and productivity."
Metric <- "Proportion of children in workless households"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "ChildrenWorklessHouseholds"


#### Import data from API ####

# ensure signed into NOMIS, otherwise cuts off at 25000 entries.
 
NOMIS_data <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_137_1.data.csv?geography=2092957697...2092957703,1820327937...1820328307,2013265921...2013265932&households_children=2&eastatus=3&depchild=1&housetype=0&measures=20301"

NOMIS_data <- read.csv(NOMIS_data) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


# Select only rows that include "percent" and confidence interval data. 
# may need to change this?

NOMIS_values <- filter(NOMIS_data, MEASURES_NAME == "Percent" | MEASURES_NAME == "Confidence") 

# Define two new columns and separate out values and their confidence intervals

NOMIS_values['Value'] = case_when(NOMIS_values$MEASURES_NAME == "Percent" ~ NOMIS_values$OBS_VALUE) 
NOMIS_values['Confidence Interval'] = case_when(NOMIS_values$MEASURES_NAME == "Confidence" ~ NOMIS_values$OBS_VALUE) 

# note no confidence intervals here. See "NOMIS_data" and "NOMIS_values" are identical no. of obs. 


#### Add in extra LUDA variables based off titles given above ####

NOMIS_values['Category']=Mission 
NOMIS_values['Indicator']=Metric
NOMIS_values['Measure']='Percentage'
NOMIS_values['Unit']='%' # not necessarily a £. be careful.

# below is specific for this metric as no confidence intervals
NOMIS_values['Variable Name'] = "Proportion of children in workless households"


#### Define the level of geographical granulation - country/region/LA etc. #### 

# Also define Geography variable.

NOMIS_geographies <- NOMIS_values %>% 
  mutate(Geography = case_when(
    GEOGRAPHY_TYPE == "Countries" ~ "Country", 
    GEOGRAPHY_TYPE == "Regions" ~ "Region",
    substr(as.character(GEOGRAPHY_CODE), 1, 3) == "W06" ~ "Unitary Authority", #Welsh LAs
    substr(as.character(GEOGRAPHY_CODE), 1, 3) == "E06" ~ "Unitary Authority", # English LAs
    substr(as.character(GEOGRAPHY_CODE), 1, 3) == "S12" ~ "Council Area",  # this is Scotland only 
    substr(as.character(GEOGRAPHY_CODE), 1, 3) == "N09" ~ "Local Government District", # this is NI only. 
    substr(as.character(GEOGRAPHY_CODE), 1, 3) == "E07" ~ "Non-metropolitan District",
    substr(as.character(GEOGRAPHY_CODE), 1, 3) == "E08" ~ "Metropolitan District",
    substr(as.character(GEOGRAPHY_CODE), 1, 3) == "E09" ~ "London Borough",
    substr(as.character(GEOGRAPHY_CODE), 1, 3) == "E10" ~ "County")) # this is England only. 


# Format DATE_CODE so it only first 4 numbers (e.g. 2020) and call "Period"
  # Format GEOGRAPHY_CODE values to title case and call "AREANM"

NOMIS_clean <- NOMIS_geographies %>% 
  mutate(Period = substr(DATE_CODE, 1, 4)) %>%
  mutate(AREANM = toTitleCase(GEOGRAPHY_NAME))
        
# may be further cleaning to do here?



#### rename and select variables for output csv. ####

csv_formatted <- rename(NOMIS_clean, AREACD = GEOGRAPHY_CODE,
                                    `Observation Status` = OBS_STATUS_NAME) %>% 
                 select(all_of(c("AREACD",
                                 "AREANM",
                                 "Geography",
                                 "Category",
                                 "Indicator",
                                 "Period",
                                 "Variable Name",
                                 "Value",
                                 "Measure",
                                 "Unit",
                                 "Confidence Interval",
                                 "Observation Status")))


#### Generate Lower and Upper Confiudence Interval Values ####

csv_formatted <- csv_formatted %>%
  mutate(`Lower Confidence Interval (95%)` = csv_formatted$Value - csv_formatted$`Confidence Interval`) %>%
  mutate(`Upper Confidence Interval (95%)` = csv_formatted$Value + csv_formatted$`Confidence Interval`)

#insert polarity
csv_formatted['Polarity'] = -1


# should be in correct order. If not...

csv_output <-  csv_formatted %>%
  select(all_of(c("AREACD",
                  "AREANM",
                  "Geography",
                  "Indicator",
                  "Category",
                  "Period",
                  "Variable Name",
                  "Value",
                  "Measure",
                  "Unit",
                  "Lower Confidence Interval (95%)",
                  "Upper Confidence Interval (95%)",
                  "Observation Status")))



#### Export Output files ####

output_folder <- "Output"

existing_files <- list.files()
output_folder_exists <- ifelse(output_folder %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create(output_folder)
}


date <- Sys.Date()

# we add the date to the output file so that old outputs are not automatically overwritten.
# However, it shouldn't matter if they are overwritten, as files can easily be recreated with the code.
# We may want to review the decision to add date to the filename.
csv_filename <- paste0(Metric_short, ".csv")
qa_filename <- paste0(Metric, ".html")


write.csv(csv_output, paste0(output_folder, "/", csv_filename), row.names = FALSE)

# # If you have a QA document written in Rmarkdown this is how you can run it and save it
# rmarkdown::render('type_1_checks.Rmd', output_file = paste0(output_folder, "/", qa_filename))

message(paste0("The csv and QA file have been created and saved in '", paste0(getwd(), "/", output_folder, "'"),
               " as ", csv_filename, "and ", qa_filename, "'\n\n"))

# so we end on the same directory as we started 
setwd("..")


