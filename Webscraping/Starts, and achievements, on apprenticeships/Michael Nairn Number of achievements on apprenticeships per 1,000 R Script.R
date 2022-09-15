#### Michael Nairn Webscraping extraction for Subnational Indicator Explorer Ingestion template R Script ####

# 21st July 2022

# For future iterations, you should just have to run the code to generate an updated output.

# This script should download webscraped data and adapt it ready for upload to Subnational Indicators Explorer.


# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 6: increasing high-quality skills training in every area in the UK."
Metric <- "Number of achievements on apprenticeships"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "ApprenticeshipCompletions" 


#### Import data from web ####

# Set Working directory to place webscraped data files into
setwd("D:/Coding_Repos/LUDA/Webscraping/Webscraped Inputs") # please note this path will be specific for your local drive


scraped_data <- "https://content.explore-education-statistics.service.gov.uk/api/releases/bd108e73-078e-4f0e-9faa-c1a0cb6b7135/files/a90cd3d0-6741-45ed-ac38-08d9d771ae37"

# "https://explore-education-statistics.service.gov.uk/data-catalogue/further-education-and-skills"
  # Select latest year of release
  # Further education and skills geography - detailed summary
  # Select Dowmload data at bottom. 



filename <- "fes-geography-detailed-summary-2122-q3.csv"


#### Import data into R ####

scraped_data <- read.csv(filename) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 



#### Select relevant rows ####

scraped_values <- filter(scraped_data, apprenticeships_or_further_education == "Apprenticeships"
                         & level_or_type == "Apprenticeships: total"
                         & age_group == "Total") 



#### Add in extra LUDA variables based off titles given above ####

scraped_values['Category']=Mission 
scraped_values['Indicator']=Metric
scraped_values['Measure']="Number"
scraped_values['Unit']="Number" # likely a % or £. Be careful.


# No confidence interval or observation status data
scraped_values['Lower Confidence Interval (95%)'] = ""
scraped_values['Upper Confidence Interval (95%)'] = ""

scraped_values <- scraped_values %>%
  mutate(`Observation Status` = case_when(achievements == "Low" ~ "Value suppressed due to a base value of fewer than 5"))



# Not always the case (use view(scraped_values) code to check) but may need to add a "Variable Name " column.
# NORMALLY A COMBINATION OF METRIC AND UNIT. 

scraped_values['Variable Name'] = "Number of achievements on apprenticeships"


#### Define the level of geographical granulation - country/region/LA etc. #### 

# Also define Geography variable.

scraped_geographies <- scraped_values %>% 
  mutate(Geography = case_when(
    geographic_level == "National" ~ "Country", #England
    geographic_level == "Regional" ~ "Region",
    substr(as.character(new_la_code), 1, 3) == "E06" ~ "Unitary Authority", # English LAs
    substr(as.character(lad_code), 1, 3) == "E07" ~ "Non-metropolitan District",
    substr(as.character(lad_code), 1, 3) == "E06" ~ "Unitary Authority",
    substr(as.character(new_la_code), 1, 3) == "E08" ~ "Metropolitan District",
    substr(as.character(new_la_code), 1, 3) == "E09" ~ "London Borough",
    substr(as.character(new_la_code), 1, 3) == "E10" ~ "County")) 


# need to add in a country_name (and country_code) column for England (E92000001).

scraped_geographies <- scraped_geographies %>% 
  mutate(country_name = case_when(
    geographic_level == "National" ~ "England"))

scraped_geographies <- scraped_geographies %>% 
  mutate(country_code = case_when(
    geographic_level == "National" ~ "E92000001"))


# need to add in a region_name (and regional_code) column for Regions (E92000001).

scraped_geographies <- scraped_geographies %>% 
  mutate(regional_name = case_when(
    geographic_level == "Regional" ~ region_name))

scraped_geographies <- scraped_geographies %>% 
  mutate(regional_code = case_when(
    geographic_level == "Regional" ~ region_code))



#### Define area name (AREANM) and area code (AREACD) as across multiple columns ####

scraped_codes <- unite(scraped_geographies, AREACD, c(country_code, new_la_code, lad_code, regional_code), 
                       sep = "", remove=FALSE, na.rm = TRUE)


scraped_areas <- unite(scraped_codes, AREANM, c(country_name, regional_name, la_name, lad_name),
                       sep = "", remove=FALSE, na.rm = TRUE)


#### Rename column names for output files ####

scraped_clean <- rename(scraped_areas, Period = "time_period",
                        Value = "achievements")


# Format AREANM values to title case 

scraped_clean <- scraped_clean %>% 
  mutate(AREANM = toTitleCase(AREANM))


#### Generate Lower and Upper Confidence Interval Values ####

# no need for this metric.


#insert polarity
scraped_clean['Polarity'] = 1

# should be in correct order. If not...

csv_formatted <- scraped_clean  %>%
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

csv_formatted <- filter(csv_formatted, Period != "202122") 


# drop Geography NAs
csv_output <- csv_formatted[!is.na(csv_formatted$Geography),]

# remove duplicates
csv_output <- unique(csv_output)


# replace suppressed values (X in this case) to N/A
csv_output$Value[csv_output$Value == "Low"] <- "NA"





#### Export Output files ####

# SET WORKING DIRECTORY!! 

setwd("D:/Coding_Repos/LUDA") # please note this path will be specific for your local drive

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

