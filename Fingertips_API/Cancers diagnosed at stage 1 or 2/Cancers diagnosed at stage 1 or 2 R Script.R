#### Michael Nairn Subnational Statistics Cancers diagnosed at stage 1 or 2 R Script ####

# 30th July 2022

# This script should download Fingertips data and adapt it ready for upload to Subnational Indicators Explorer.
  # Hopefully I will amend so it can work for other APIs

############## SET WORKING DIRECTORY!! 

# e.g. setwd("D:/Coding_Repos/LUDA-Scripts")

# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 7: narrowing the gap in HLE between areas, increasing HLE by five years by 2035."
Metric <- "Cancer diagnosis at stage 1 & 2"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "CancerDiagnosis" 


#### Import data from API ####

# % of Cancers diagnosed at stage 1 & 2 is code 93671.

# Set Working directory to place webscraped data files into
# setwd("D:/Coding_Repos/LUDA-Scripts/Webscraping/Webscraped Inputs") # please note this path will be specific for your local drive


Fingertips_data <- "https://fingertips.phe.org.uk/2c978a4c-4012-49fb-8d6c-b9c05c08116f"

filename <- "cancer.csv"

Fingertips_data <- read.csv(filename) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


#### Select only rows that include "Persons", not disaggregated by sex or category. ####
  # may need to change this for each API

Fingertips_values <- filter(Fingertips_data, Sex == "Persons" & Category.Type == "") 


#### Add in extra LUDA variables based off titles given above ####

Fingertips_values['Category']=Mission 
Fingertips_values['Indicator']=Metric
Fingertips_values['Measure']="Percentage"
Fingertips_values['Unit']='%' # not necessarily a %. be careful.


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
    substr(as.character(Area.Code), 1, 3) == "E47" ~ "Combined authorities",
    substr(as.character(Area.Code), 1, 3) == "E54" ~ "STP"))  


# Format DATE_CODE so it only first 4 numbers (e.g. 2020) and call "Period"
  # Format GEOGRAPHY_CODE values to title case and call "AREANM"

Fingertips_clean <- Fingertips_geographies %>% 
  mutate(AREANM = toTitleCase(Area.Name))

Fingertips_clean$AREANM <- gsub("Ca-", "", Fingertips_clean$AREANM)

Fingertips_clean$AREANM <- gsub(" ua", "", Fingertips_clean$AREANM)

Fingertips_clean$AREANM <- gsub(" region", "", Fingertips_clean$AREANM)


# insert polarity value 
Fingertips_clean['Polarity']=1

#### rename and select variables for output csv. ####

csv_formatted <- rename(Fingertips_clean, AREACD = Area.Code,
                        `Variable Name` = Indicator.Name,
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

# drop Geography NAs
csv_formatted <- csv_formatted[!is.na(csv_formatted$Geography),]


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

# replace suppressed values (blanks in this case) to N/A
csv_output$Value[csv_output$Value == ""] <- "NA"

# For this iteration (August 2022) remove 2019 data. 
csv_output <- filter(csv_output, Period != "2019")

  
#### Export Output files ####

############## SET WORKING DIRECTORY!! 

e.g. setwd("D:/Coding_Repos/LUDA-Scripts") # please note this path will be specific for your local drive

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

