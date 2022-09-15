#### Michael Nairn Webscraping extraction for Subnational Indicator Explorer Ingestion template R Script ####

# 15th July 2022

# For future iterations, you should just have to run the code to generate an updated output.

# This script should download webscraped data and adapt it ready for upload to Subnational Indicators Explorer.


# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 5: increasing primary school attainment, 90% of children achieving the minimum standard in England"
Metric <- "Percentage of young people achieving GCSEs (and equivalent qualifications) in English and maths by age 19"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "GCSEbyAge19" 

#### Import data from web ####

# Set Working directory to place webscraped data files into
setwd("D:/Coding_Repos/LUDA/Webscraping/Webscraped Inputs") # please note this path will be specific for your local drive


scraped_data <- "https://explore-education-statistics.service.gov.uk/find-statistics/level-2-and-3-attainment-by-young-people-aged-19"
  # download all data.

# "https://content.explore-education-statistics.service.gov.uk/api/releases/fb5a30fd-cf4b-45c8-b549-08d9ae5a3ad1/files"

filename <- "level_2_3_ages_16_19_local_authority_district_figures_.csv"

# tabname <- "Table_L1"


#### Import data into R ####

scraped_data <- read.csv(filename)


#### Select relevant rows ####

scraped_values <- filter(scraped_data, characteristic == "Total"
                         & age =="19"
                         & Qualification_level == "Total"
                         &  number_or_percentage == "Percentage") 


#### If not present add in Isles of Scilly and City of London ####

scraped_values <- scraped_values %>% 
  add_row(lad_code = "E09000001", lad_name = "City of London")


#### Add in extra LUDA variables based off titles given above ####

scraped_values['Category']=Mission 
scraped_values['Indicator']=Metric
scraped_values['Measure']="Percentage"
scraped_values['Unit']="%" # likely a % or £. Be careful.


# No confidence interval or observation status data
scraped_values['Lower Confidence Interval (95%)'] = ""
scraped_values['Upper Confidence Interval (95%)'] = ""
scraped_values['Observation Status'] = ""

# Not always the case (use view(scraped_values) code to check) but may need to add a "Variable Name " column.
# NORMALLY A COMBINATION OF METRIC AND UNIT. 

scraped_values['Variable Name'] = "Percentage of young people achieving GCSEs (and equivalent qualifications) in English and maths by age 19 (%)"


#### Define the level of geographical granulation - country/region/LA etc. #### 

# Also define Geography variable.

scraped_geographies <- scraped_values %>% 
  mutate(Geography = case_when(
    geographic_level == "National" ~ "Country", #England
    substr(as.character(region_code), 1, 3) == "E12" ~ "Region", 
    substr(as.character(lad_code), 1, 3) == "E06" ~ "Unitary Authority", # English LAs
    substr(as.character(lad_code), 1, 3) == "E07" ~ "Non-metropolitan District",
    substr(as.character(lad_code), 1, 3) == "E08" ~ "Metropolitan District",
    substr(as.character(lad_code), 1, 3) == "E09" ~ "London Borough",
    substr(as.character(new_la_code), 1, 3) == "E10" ~ "County")) 


# need to add in a country_name (and country_code) column for England (E92000001).

scraped_geographies <- scraped_geographies %>% 
  mutate(country_name = case_when(
    geographic_level == "National" ~ "England"))

scraped_geographies <- scraped_geographies %>% 
  mutate(country_code = case_when(
    geographic_level == "National" ~ "E92000001"))


#### Define area name (AREANM) and area code (AREACD) as across multiple columns ####

scraped_areas <- unite(scraped_geographies, AREANM, c(country_name, region_name, la_name, lad_name, opportunity_area_name),
                      sep = "", remove=FALSE, na.rm = TRUE)


scraped_codes <- unite(scraped_areas, AREACD, c(country_code, region_code, new_la_code, lad_code, opportunity_area_code), 
                       sep = "", remove=FALSE, na.rm = TRUE)


#### Rename column names for output files ####

scraped_clean <- rename(scraped_codes, Period = "time_period",
                        Value = "L2_em")
                        

# Format AREANM values to title case and Period to have a /

scraped_clean <- scraped_clean %>% 
  mutate(AREANM = toTitleCase(AREANM))


#### Generate Lower and Upper Confiudence Interval Values ####

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


# drop Geography NAs
csv_output <- csv_formatted[!is.na(csv_formatted$Geography),]

# remove duplicates
csv_output <- unique(csv_output)


# replace suppressed values (blanks in this case) to N/A
csv_output$Value[csv_output$Value == ""] <- "na"




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

