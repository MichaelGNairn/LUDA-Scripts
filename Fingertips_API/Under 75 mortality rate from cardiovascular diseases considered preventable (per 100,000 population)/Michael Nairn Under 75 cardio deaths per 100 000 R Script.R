#### Michael Nairn Subnational Statistics Under 75 cardio death rate R Script ####

# 2nd September 2022

# This script should download Fingertips data and adapt it ready for upload to Subnational Indicators Explorer.
  # Hopefully I will amend so it can work for other APIs

############## SET WORKING DIRECTORY!! 

setwd("D:/Coding_Repos/LUDA")

# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 7: narrowing the gap in HLE between areas, increasing HLE by five years by 2035."
Metric <- "Under 75 mortality rate from cardiovascular diseases considered preventable (per 100,000 population)"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "Under75MortalityRate" 


#### Import data from API ####

# Under 75 mortality rate from cardiovascular diseases considered preventable (per 100,000 population) is code 93722


# Set Working directory to place webscraped data files into
setwd("D:/Coding_Repos/LUDA/Webscraping/Webscraped Inputs") # please note this path will be specific for your local drive


Fingertips_data <- "blob:https://fingertips.phe.org.uk/13c46515-af03-45a8-b20c-62789e81ff94"


filename <- "u75 cardio.csv"

Fingertips_data <- read.csv(filename) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


#### Select only rows that include "Persons", not disaggregated by sex. ####
  # may need to change this for each API

Fingertips_values <- filter(Fingertips_data, Sex == "Persons" & Category == "") 




#### Add in extra LUDA variables based off titles given above ####

Fingertips_values['Category']=Mission 
Fingertips_values['Indicator']=Metric
Fingertips_values['Measure']="Rate per 100, 000 population"
Fingertips_values['Unit']='per 100, 000 population' # not necessarily a proportion. be careful.


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
    substr(as.character(Area.Code), 1, 3) == "E47" ~ "Combined authorities"))  


# Format DATE_CODE so it only first 4 numbers (e.g. 2020) and call "Period"
  # Format GEOGRAPHY_CODE values to title case and call "AREANM"

Fingertips_clean <- Fingertips_geographies %>% 
    mutate(AREANM = toTitleCase(Area.Name))

#### Format Time.period to be numeric ####

Fingertips_clean$Time.period <- gsub(" - ", "", as.character(Fingertips_clean$Time.period))



#### rename and select variables for output csv. ####

csv_formatted <- rename(Fingertips_clean, AREACD = Area.Code,
                        Period = Time.period,
                        `Variable Name` = Indicator.Name,
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
                                 "Observation Status")))


# remove unwanted geography granulations
csv_formatted <- csv_formatted[!is.na(csv_formatted$Geography),]

# insert polarity value 
csv_formatted['Polarity']=-1


# should be in correct order. If not

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


# remove duplications
csv_output <- unique(csv_output)

# replace suppressed values (blanks in this case) to N/A
csv_output$Value[csv_output$Value == ""] <- "NA"



#### Export Output files ####

setwd("D:/Coding_Repos/LUDA")

output_folder <- "Output"

existing_files <- list.files()s
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

