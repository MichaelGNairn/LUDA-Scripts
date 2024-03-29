#### Michael Nairn Subnational Statistics Gross Disposable Household Income (GDHI) R Script ####

# 28th July 2022

# This script should download NOMIS data and adapt it ready for upload to Subnational Indicators Explorer.
  # Hopefully I will amend so it can work for other APIs

############## SET WORKING DIRECTORY!! 

setwd("D:/Coding_Repos/LUDA-Scripts")

# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 1: closing the gap in median employment and productivity."
Metric <- "Gross Disposable Household Income (GDHI), per head"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "GDHIperhead"


#### Import data from API ####

# ensure signed into NOMIS, otherwise cuts off at 25000 entries.
 
NOMIS_data <- "https://www.nomisweb.co.uk/api/v01/dataset/NM_185_1.data.csv?geography=2092957697...2092957703,1811939329...1811939332,1811939334...1811939336,1811939338...1811939428,1811939436...1811939442,1811939768,1811939769,1811939443...1811939497,1811939499...1811939501,1811939503,1811939505...1811939507,1811939509...1811939517,1811939519,1811939520,1811939524...1811939570,1811939575...1811939599,1811939601...1811939628,1811939630...1811939634,1811939636...1811939647,1811939649,1811939655...1811939664,1811939667...1811939680,1811939682,1811939683,1811939685,1811939687...1811939704,1811939707,1811939708,1811939710,1811939712...1811939717,1811939719,1811939720,1811939722...1811939730,1811939757...1811939767,2013265921...2013265932&component_of_gdhi=0&measure=2&measures=20100"

NOMIS_data <- read.csv(NOMIS_data) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


# Select only rows that include "values" and confidence interval data. 
# may need to change this?

NOMIS_values <- filter(NOMIS_data, MEASURES_NAME == "Value" | MEASURES_NAME == "Confidence") 

# note no confidence intervals here. See "NOMIS_data" and "NOMIS_values" are identical no. of obs. 


# Define two new columns and separate out values and their confidence intervals
# be careful as MEASURES_NAME changes

NOMIS_values['Value'] = case_when(NOMIS_values$MEASURES_NAME == "Value" ~ NOMIS_values$OBS_VALUE) 
NOMIS_values['Confidence Interval'] = case_when(NOMIS_values$MEASURES_NAME == "Confidence" ~ NOMIS_values$OBS_VALUE) 


#### Add in extra LUDA variables based off titles given above ####

NOMIS_values['Category']=Mission 
NOMIS_values['Indicator']=Metric
NOMIS_values['Measure']="Pounds"
NOMIS_values['Unit']='£' # not necessarily a £. be careful.


#### Define the level of geographical granulation - country/region/LA etc. #### 

# Also define Geography variable.

NOMIS_geographies <- NOMIS_values %>% 
  mutate(Geography = case_when(
    GEOGRAPHY_TYPE == "Countries" ~ "Country", 
    substr(as.character(GEOGRAPHY_CODE), 1, 3) == "E12" ~ "Region",
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
                        'Variable Name' = COMPONENT_OF_GDHI_NAME,
                                     `Observation Status` = OBS_STATUS_NAME)
                
csv_formatted <- csv_formatted %>%
  mutate(`Lower Confidence Interval (95%)` = csv_formatted$Value - csv_formatted$`Confidence Interval`) %>%
  mutate(`Upper Confidence Interval (95%)` = csv_formatted$Value + csv_formatted$`Confidence Interval`)

# insert polarity value 
csv_formatted['Polarity']=1

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
                  "Observation Status",
                  "Polarity")))

# drop Geography NAs
csv_output <- csv_output[!is.na(csv_output$Geography),]
                     


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


