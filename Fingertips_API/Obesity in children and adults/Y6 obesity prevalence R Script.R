#### Michael Nairn Subnational Statistics obesity prevalence R Script ####

# 25th July 2022

# This script should download Fingertips data and adapt it ready for upload to Subnational Indicators Explorer.


############## SET WORKING DIRECTORY!! 

setwd("D:/Coding_Repos/LUDA-Scripts")

# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 7: narrowing the gap in HLE between areas, increasing HLE by five years by 2035"
Metric <- "Obesity prevalence - Year 6 children"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "Overweight_year6"


#### Import data from API ####

# Reception: Prevalence of overweight (including obesity) code is 20601.

# Year 6: Prevalence of overweight (including obesity) code is 20602.

# Percentage of adults (aged 18+) classified as overweight or obese code is 93088.

# Set Working directory to place webscraped data files into
# setwd("D:/Coding_Repos/LUDA-Scripts/Webscraping/Webscraped Inputs") # please note this path will be specific for your local drive


Fingertips_data <- "https://fingertips.phe.org.uk/b01736ff-6371-4c2c-b0cf-00cf07a41902"

filename <- "Year 6 obesity.csv"

Fingertips_data <-read.csv(filename)

Fingertips_data <- Fingertips_data %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


#### Select only rows that include "Persons", not disaggregated by sex. ####
# may need to change this for each API

Fingertips_values <- filter(Fingertips_data, Sex == "Persons" & Category == "" & Age == "10-11 yrs") 


#### Add in extra LUDA variables based off titles given above ####

Fingertips_values['Category']=Mission 
Fingertips_values['Indicator']=Metric
Fingertips_values['Measure']="Percentage"
Fingertips_values['Unit']="%" # likely a % or £. Be careful.


# Not always the case (use view(Fingertips_values) code to check) but may need to add a "Variable Name " column.
# NORMALLY A COMBINATION OF METRIC AND UNIT. 

Fingertips_values['Variable Name'] = "Obesity prevalence - Year 6 children (%)"

Fingertips_values$Area.Name <- gsub("Ca-", "", as.character(Fingertips_values$Area.Name))

Fingertips_values$Area.Name <- gsub(" ua", "", as.character(Fingertips_values$Area.Name))

Fingertips_values$Area.Name <- gsub(" region", "", as.character(Fingertips_values$Area.Name))

#### Define the level of geographical granulation - country/region/LA etc. #### 
# This indicator is England only.
# Also define Geography variable.

Fingertips_geographies <- Fingertips_values %>% 
  mutate(Geography = case_when(
    substr(as.character(Area.Code), 1, 3) == "E92" ~ "Country", 
    substr(as.character(Area.Code), 1, 3) == "E12" ~ "Region",
    substr(as.character(Area.Code), 1, 3) == "E06" ~ "Unitary Authority", # English LAs
    substr(as.character(Area.Code), 1, 3) == "E07" ~ "Non-metropolitan District",
    substr(as.character(Area.Code), 1, 3) == "E08" ~ "Metropolitan District",
    substr(as.character(Area.Code), 1, 3) == "E09" ~ "London Borough",
    substr(as.character(Area.Code), 1, 3) == "E10" ~ "County",
    substr(as.character(Area.Code), 1, 3) == "E45" ~ "Public Health England centre",
    substr(as.character(Area.Code), 1, 3) == "E47" ~ "Combined authorities",
    substr(as.character(Area.Code), 1, 3) == "E54" ~ "STP"))  



# Format GEOGRAPHY_CODE values to title case and call "AREANM"

Fingertips_clean <- Fingertips_geographies %>% 
  mutate(AREANM = toTitleCase(Area.Name))

#### Format Time.period to be numeric ####

Fingertips_clean$Time.period <- gsub("/", "", as.character(Fingertips_clean$Time.period))

# insert polarity value 
Fingertips_clean['Polarity']=-1

#### rename and select variables for output csv. ####

csv_formatted <- rename(Fingertips_clean, AREACD = Area.Code,
                        Period = Time.period,
                        `Observation Status` = Value.note,
                        'Lower Confidence Interval (95%)' = Lower.CI.95.0.limit,
                        'Upper Confidence Interval (95%)' = Upper.CI.95.0.limit) %>% #Value.note
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

# should be in correct order. 


# removes NAs from Geography column - unwanted granulations
csv_formatted <- csv_formatted %>% 
  na.omit(csv_formatted$Geography) 

# For August 2022 iteration, remove 2020/21 data as well. 
# This is because here is only country and regional data, not lower geographical levels.
# https://fingertips.phe.org.uk/profile/national-child-measurement-programme
# May not be necessary for next iteration, dependent upon new data

csv_output <- filter(csv_formatted, Period != "202021") 



#### Export Output files ####

# SET WORKING DIRECTORY!! 

e.g. setwd("D:/Coding_Repos/LUDA-Scripts") # please note this path will be specific for your local drive

output_folder <- "Output"

existing_files <- list.files()
output_folder_exists <- ifelse(output_folder %in% existing_files, TRUE, FALSE)

if (output_folder_exists == FALSE) {
  dir.create(output_folder)
}


date <- Sys.Date()

# we could add the date to the output file so that old outputs are not automatically overwritten.
# However, it shouldn't matter if they are overwritten, as files can easily be recreated with the code.
csv_filename <- paste0(Metric_short, ".csv")
qa_filename <- paste0(Metric, ".html")


write.csv(csv_output, paste0(output_folder, "/", csv_filename), row.names = FALSE)

# # If you have a QA document written in Rmarkdown this is how you can run it and save it
# rmarkdown::render('type_1_checks.Rmd', output_file = paste0(output_folder, "/", qa_filename))

message(paste0("The csv and QA file have been created and saved in '", paste0(getwd(), "/", output_folder, "'"),
               " as ", csv_filename, "and ", qa_filename, "'\n\n"))

# so we end on the same directory as we started 
setwd("..")

