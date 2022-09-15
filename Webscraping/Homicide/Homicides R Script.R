#### Michael Nairn Webscraping extraction for Subnational Indicator Explorer Ingestion template R Script ####

# 15th July 2022

# For future iterations, you should just have to run the code to generate an updated output.

# This script should download webscraped data and adapt it ready for upload to Subnational Indicators Explorer.


# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 11: reduction in measurable crime, focusing on most deprived areas"
Metric <- "Homicide"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "Homicide" 


#### Import data from web ####

# Set Working directory to place webscraped data files into
setwd("D:/Coding_Repos/LUDA-Scripts/Webscraping/Webscraped Inputs") # please note this path will be specific for your local drive


scraped_data <- "https://www.ons.gov.uk/peoplepopulationandcommunity/crimeandjustice/datasets/appendixtableshomicideinenglandandwales"

scraped_data <- "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/crimeandjustice/datasets/appendixtableshomicideinenglandandwales/current/homicideyemar21appendixtablescorrected1.xlsx"

filename <- "homicideyemar21appendixtablescorrected1.xlsx"

#### Import data into R ####

# LA data

tabname <- "Table 21"

scraped_data <- read.xlsx(filename, sheet = tabname, startRow =8) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


colnames(scraped_data)[1:12] <- c("AREACD", "AREANM", "201213", "201314",
                                  "201415", "201516", "201617", "201718", "201819", "201920", "202021", "Value")


scraped_values <- scraped_data %>% 
  select(all_of(c("AREACD", "AREANM", "Value")))

#### Add in extra LUDA variables based off titles given above ####

scraped_values['Category']=Mission 
scraped_values['Indicator']=Metric
scraped_values['Measure']="Rate per million population" 
scraped_values['Unit']="per million population" 


# No confidence interval or observation status data
scraped_values['Lower Confidence Interval (95%)'] = ""
scraped_values['Upper Confidence Interval (95%)'] = ""
scraped_values['Observation Status'] = ""
scraped_values['Period'] = "201821"


# Not always the case (use view(scraped_values) code to check) but may need to add a "Variable Name " column.
# NORMALLY A COMBINATION OF METRIC AND UNIT. 

scraped_values['Variable Name'] = "Homicide Offences (Rate per million population)"


#### Define the level of geographical granulation - country/region/LA etc. #### 

# Also define Geography variable.

scraped_geographies <- scraped_values %>% 
  mutate(Geography = case_when(
    substr(as.character(AREACD), 2, 3) == "92" ~ "Country",
    substr(as.character(AREACD), 1, 3) == "K04" ~ "Country",
    substr(as.character(AREACD), 1, 3) == "E12" ~ "Region",
    substr(as.character(AREACD), 1, 3) == "E23" ~ "Police Force Area",
    substr(as.character(AREACD), 1, 3) == "W15" ~ "Police Force Area")) # this is England only. 


# Format AREANM values to title case 

scraped_clean <- scraped_geographies %>% 
  mutate(AREANM = toTitleCase(AREANM))


#### Generate Lower and Upper Confiudence Interval Values ####

# no need for this metric.

# insert polarity value 
scraped_clean['Polarity']=-1

# should be in correct order. If not...

csv_formatted <-  scraped_clean %>%
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


csv_output <- (na.omit(csv_formatted)) # removes NAs - British Transport police


#### Export Output files ####

# SET WORKING DIRECTORY!! 

setwd("D:/Coding_Repos/LUDA-Scripts") # please note this path will be specific for your local drive

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

