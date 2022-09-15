#### Michael Nairn Webscraping extraction for Subnational Indicator Explorer Ingestion template R Script ####

# 15th July 2022

# For future iterations, you should just have to run the code to generate an updated output.

# This script should download webscraped data and adapt it ready for upload to Subnational Indicators Explorer.


# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 7: narrowing the gap in HLE between areas, increasing HLE by five years by 2035"
Metric <- "Female Healthy Life Expectancy (HLE)"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "HLEFemale" 


#### Import data from web ####

# Set Working directory to place webscraped data files into
setwd("D:/Coding_Repos/LUDA/Webscraping/Webscraped Inputs") # please note this path will be specific for your local drive


scraped_data <- "https://www.ons.gov.uk/peoplepopulationandcommunity/healthandsocialcare/healthandlifeexpectancies/datasets/healthstatelifeexpectancyallagesuk"

scraped_data <- "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/healthandsocialcare/healthandlifeexpectancies/datasets/healthstatelifeexpectancyallagesuk/current/reftablehsle1820new.xlsx"

filename <- "reftablehsle1820new.xlsx"


#### Import data into R ####

tabname <- "HLE - all data"

scraped_data <- read_excel(filename, sheet = tabname, skip = 1) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


#### Filter by sex = Female, age = <1, and rename and select relevant columns ####

scraped_data <- filter(scraped_data, Sex == "Female" & `Age group` == "<1")

scraped_values <- rename(scraped_data, AREACD = "Area code",
                             AREANM = "Area name",
                             Value = "Healthy life expectancy (HLE)",
                             'Lower Confidence Interval (95%)' = "HLE lower confidence interval",
                             'Upper Confidence Interval (95%)' = "HLE upper confidence interval")

scraped_values <- scraped_values %>%
  select(all_of(c("AREACD",
                  "AREANM",
                  "Value",
                  "Period",
                  "Lower Confidence Interval (95%)",
                  "Upper Confidence Interval (95%)")))


#### If not present add in Isles of Scilly and City of London ####

scraped_values <- scraped_values %>% 
  add_row(AREACD = "E06000053", AREANM = "Isles of Scilly") %>%
  add_row(AREACD = "E09000001", AREANM = "City of London")


#### Add in extra LUDA variables based off titles given above ####

scraped_values['Category']=Mission 
scraped_values['Indicator']=Metric
scraped_values['Measure']="Years" 
scraped_values['Unit']="yrs" 


# No observation status data
scraped_values['Observation Status'] = ""

# Not always the case (use view(scraped_values) code to check) but may need to add a "Variable Name " column.
# NORMALLY A COMBINATION OF METRIC AND UNIT. 

scraped_values['Variable Name'] = "Female Healthy Life Expectancy (years)"


#### Define the level of geographical granulation - country/region/LA etc. #### 

# Also define Geography variable.

scraped_geographies <- scraped_values %>% 
  mutate(Geography = case_when(
    substr(as.character(AREACD), 2, 3) == "92" ~ "Country", 
    substr(as.character(AREACD), 1, 3) == "K02" ~ "Country", 
    substr(as.character(AREACD), 1, 3) == "W06" ~ "Unitary Authority", #Welsh LAs
    substr(as.character(AREACD), 1, 3) == "W11" ~ "Welsh Health Board", 
    substr(as.character(AREACD), 1, 3) == "E06" ~ "Unitary Authority", # English LAs
    substr(as.character(AREACD), 1, 3) == "S12" ~ "Council Area",  # this is Scotland only 
    substr(as.character(AREACD), 1, 3) == "N09" ~ "Local Government District", # this is NI only. 
    substr(as.character(AREACD), 1, 3) == "E07" ~ "Non-metropolitan District",
    substr(as.character(AREACD), 1, 3) == "E08" ~ "Metropolitan District",
    substr(as.character(AREACD), 1, 3) == "E09" ~ "London Borough",
    substr(as.character(AREACD), 1, 3) == "E10" ~ "County",
    substr(as.character(AREACD), 1, 3) == "E11" ~ "Metropolitan County",
    substr(as.character(AREACD), 1, 3) == "E12" ~ "Region",
    substr(as.character(AREACD), 1, 3) == "E47" ~ "Combined Authority")) 


# Format AREANM values to title case 

scraped_clean <- scraped_geographies %>% 
  mutate(AREANM = toTitleCase(AREANM))


#### Format Time.period to be numeric ####

scraped_clean$Period <- gsub("-", "", as.character(scraped_clean$Period))




#### Generate Lower and Upper Confiudence Interval Values ####

# no need for this metric.

#insert polarity
scraped_clean['Polarity'] = 1

# should be in correct order. If not...

csv_output <-  scraped_clean %>%
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

