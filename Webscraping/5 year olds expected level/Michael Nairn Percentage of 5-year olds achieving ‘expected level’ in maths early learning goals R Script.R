#### Michael Nairn Webscraping extraction for Subnational Indicator Explorer Ingestion template R Script ####

# 15th July 2022

# For future iterations, you should just have to run the code to generate an updated output.

# This script should download webscraped data and adapt it ready for upload to Subnational Indicators Explorer.


# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 5: increasing primary school attainment, 90% of children achieving the minimum standard in England"
Metric <- "Percentage of 5-year olds achieving 'expected level' in maths early learning goals"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "EarlyYearsFoundationMaths" 

#### Import data from web ####

# Set Working directory to place webscraped data files into
setwd("D:/Coding_Repos/LUDA/Webscraping/Webscraped Inputs") # please note this path will be specific for your local drive


scraped_data <- "https://www.gov.uk/government/statistics/early-years-foundation-stage-profile-results-2018-to-2019"
  # download all data.

# "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/839563/EYFSP_2019_Tables.xlsx"

filename <- "EYFSP_2019_Tables.xlsx"

tabname <- "Table 3a"


#### Import data into R ####

scraped_data <- read.xlsx(filename, sheet = tabname, startRow = 10)

scraped_data <- scraped_data %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


#### Select columns of interest ####

scraped_values <-  scraped_data %>%
  select(all_of(c("New.LA.code",
                  "LA/region.name",
                  "X55")))


#### Add in extra LUDA variables based off titles given above ####

scraped_values['Category']=Mission 
scraped_values['Indicator']=Metric
scraped_values['Measure']="Percetage"
scraped_values['Unit']="%" # likely a % or £. Be careful.


# No confidence interval or observation status data
scraped_values['Lower Confidence Interval (95%)'] = ""
scraped_values['Upper Confidence Interval (95%)'] = ""
scraped_values['Observation Status'] = ""
scraped_values['Period'] = "2019"

# Not always the case (use view(scraped_values) code to check) but may need to add a "Variable Name " column.
# NORMALLY A COMBINATION OF METRIC AND UNIT. 

scraped_values['Variable Name'] = "Percentage of 5-year olds achieving 'expected level' in maths early learning goals (%)"


#### Define the level of geographical granulation - country/region/LA etc. #### 

# Also define Geography variable.

scraped_geographies <- scraped_values %>% 
  mutate(Geography = case_when(
    substr(as.character(New.LA.code), 1, 3) == "E92" ~ "Country",
    substr(as.character(New.LA.code), 1, 3) == "E12" ~ "Region", 
    substr(as.character(New.LA.code), 1, 3) == "E13" ~ "Region", 
    substr(as.character(New.LA.code), 1, 3) == "W06" ~ "Unitary Authority", #Welsh LAs
    substr(as.character(New.LA.code), 1, 3) == "E06" ~ "Unitary Authority", # English LAs
    substr(as.character(New.LA.code), 1, 3) == "S12" ~ "Council Area",  # this is Scotland only 
    substr(as.character(New.LA.code), 1, 3) == "N09" ~ "Local Government District", # this is NI only. 
    substr(as.character(New.LA.code), 1, 3) == "E07" ~ "Non-metropolitan District",
    substr(as.character(New.LA.code), 1, 3) == "E08" ~ "Metropolitan District",
    substr(as.character(New.LA.code), 1, 3) == "E09" ~ "London Borough", # this is England only. 
    substr(as.character(New.LA.code), 1, 3) == "E10" ~ "County", # this is England only. 
    substr(as.character(New.LA.code), 1, 3) == "E11" ~ "Metropolitan County")) # this is England only. 



#### Rename column names for output files ####

scraped_clean <- rename(scraped_geographies, AREACD = "New.LA.code",
                        AREANM = "LA/region.name",
                        Value = "X55")
                        

# Format AREANM values to title case 

scraped_clean <- scraped_clean %>% 
  mutate(AREANM = tolower(AREANM))

scraped_clean <- scraped_clean %>% 
  mutate(AREANM = toTitleCase(AREANM))


#### Generate Lower and Upper Confidence Interval Values ####

# no need for this metric.


#insert polarity
scraped_clean['Polarity'] = 1

# should be in correct order. If not...

csv_output <- scraped_clean  %>%
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

