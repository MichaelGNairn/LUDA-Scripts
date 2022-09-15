#### Michael Nairn Webscraping extraction for Subnational Indicator Explorer Ingestion template R Script ####

# 15th July 2022

# For future iterations, you should just have to run the code to generate an updated output.

# This script should download webscraped data and adapt it ready for upload to Subnational Indicators Explorer.


# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 5: increasing primary school attainment, 90% of children achieving the minimum standard in England"
Metric <- "Percentage of pupils meeting the expected standard in reading, writing and maths by end of primary school"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "KS2Attainment" 

#### Import data from web ####

# Set Working directory to place webscraped data files into
setwd("D:/Coding_Repos/LUDA/Webscraping/Webscraped Inputs") # please note this path will be specific for your local drive


scraped_data <- "https://www.gov.uk/government/statistics/national-curriculum-assessments-key-stage-2-2019-revised"
# "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/851791/KS2-Revised_tables_2019.xlsx"

filename <- "KS2-Revised_tables_2019.xlsx"

tabname <- "Table_L1"


#### Import data into R ####

scraped_data <- read.xlsx(filename, sheet = tabname, startRow = 5)


#### select columns ####

scraped_values <-  scraped_data %>%
  select(all_of(c("LA.code",
                  "Region",
                  "X3",
                  "Percentage.of.pupils.reaching.the.expected.standard.in.reading,.writing.and.maths3")))


#### Add in extra LUDA variables based off titles given above ####

scraped_values['Category']=Mission 
scraped_values['Indicator']=Metric
scraped_values['Measure']="Percentage"
scraped_values['Unit']="%" # likely a % or £. Be careful.
scraped_values['Period']="2019"

# No confidence interval or observation status data
scraped_values['Lower Confidence Interval (95%)'] = ""
scraped_values['Upper Confidence Interval (95%)'] = ""
scraped_values['Observation Status'] = ""

# Not always the case (use view(scraped_values) code to check) but may need to add a "Variable Name " column.
# NORMALLY A COMBINATION OF METRIC AND UNIT. 

scraped_values['Variable Name'] = "Percentage of pupils meeting the expected standard in reading, writing and maths by end of primary school (%)"

scraped_values <- scraped_values[-1,] 

#### Define the level of geographical granulation - country/region/LA etc. #### 

# Also define Geography variable.

scraped_geographies <- scraped_values %>% 
  mutate(Geography = case_when(
    substr(as.character(LA.code), 1, 3) == "E92" ~ "Country", #England
    substr(as.character(LA.code), 1, 3) == "E12" ~ "Region", 
    substr(as.character(LA.code), 1, 3) == "W06" ~ "Unitary Authority", #Welsh LAs
    substr(as.character(LA.code), 1, 3) == "E06" ~ "Unitary Authority", # English LAs
    substr(as.character(LA.code), 1, 3) == "S12" ~ "Council Area",  # this is Scotland only 
    substr(as.character(LA.code), 1, 3) == "N09" ~ "Local Government District", # this is NI only. 
    substr(as.character(LA.code), 1, 3) == "E07" ~ "Non-metropolitan District",
    substr(as.character(LA.code), 1, 3) == "E08" ~ "Metropolitan District",
    substr(as.character(LA.code), 1, 3) == "E09" ~ "London Borough",
    substr(as.character(LA.code), 1, 3) == "E10" ~ "County",
    substr(as.character(LA.code), 1, 3) == "E13" ~ "Inner and Outer London")) # this is England only. 

scraped_geographies <- scraped_geographies %>% 
  mutate(AREANM = case_when(
    substr(as.character(LA.code), 1, 3) == "E92" ~ "England", 
    substr(as.character(LA.code), 1, 3) == "E12" ~ Region,
    substr(as.character(LA.code), 1, 3) == "E13" ~ Region,
    substr(as.character(LA.code), 1, 3) == "W06" ~ X3, 
    substr(as.character(LA.code), 1, 3) == "E06" ~ X3, 
    substr(as.character(LA.code), 1, 3) == "S12" ~ X3,  
    substr(as.character(LA.code), 1, 3) == "N09" ~ X3, 
    substr(as.character(LA.code), 1, 3) == "E07" ~ X3,
    substr(as.character(LA.code), 1, 3) == "E08" ~ X3,
    substr(as.character(LA.code), 1, 3) == "E09" ~ X3,
    substr(as.character(LA.code), 1, 3) == "E11" ~ X3,
    substr(as.character(LA.code), 1, 3) == "E10" ~ X3))



#### Rename column names for output files ####

scraped_clean <- rename(scraped_geographies, AREACD = LA.code,
                        Value = "Percentage.of.pupils.reaching.the.expected.standard.in.reading,.writing.and.maths3")
                        

# Format AREANM values to title case 

scraped_clean <- scraped_clean %>% 
  mutate(AREANM = toTitleCase(AREANM))


# Remove numbers from AREANM column

scraped_clean$AREANM <- gsub("[0-9]+", "", as.character(scraped_clean$AREANM))



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


csv_output <- (na.omit(csv_formatted)) # removes NAs - especially if CIs


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

