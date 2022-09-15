#### Michael Nairn Webscraping extraction for Subnational Indicator Explorer Ingestion template R Script ####

# 15th July 2022

# For future iterations, you should just have to run the code to generate an updated output.

# This script should download webscraped data and adapt it ready for upload to Subnational Indicators Explorer.


# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 4: 4G and 5G connectivity across the UK by 2030. "
Metric <- "Percentage of 4G (and 5G) coverage by at least one mobile network operator"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "4GAreaCoverage" 

#### Import data from web ####

# Set Working directory to place webscraped data files into
setwd("D:/Coding_Repos/LUDA-Scripts/Webscraping/Webscraped Inputs") # please note this path will be specific for your local drive


scraped_data <- "https://www.ofcom.org.uk/research-and-data/multi-sector-research/infrastructure-research/connected-nations-update-summer-2021"

# https://www.ofcom.org.uk/__data/assets/file/0015/224214/202105_mobile_laua_r01.zip

filename <- "202105_mobile_laua_r01.csv"


#### Import data into R ####

scraped_data <- read_csv(filename) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


#### select columns ####

scraped_values <-  scraped_data %>%
  select(all_of(c("laua",
                  "laua_name",
                  "4G_geo_out_0")))


#### Add in extra LUDA variables based off titles given above ####

scraped_values['Category']=Mission 
scraped_values['Indicator']=Metric
scraped_values['Measure']="Percentage"
scraped_values['Unit']="%" # likely a % or £. Be careful.
scraped_values['Period']="2021"

# No confidence interval or observation status data
scraped_values['Lower Confidence Interval (95%)'] = ""
scraped_values['Upper Confidence Interval (95%)'] = ""
scraped_values['Observation Status'] = ""

# Not always the case (use view(scraped_values) code to check) but may need to add a "Variable Name " column.
# NORMALLY A COMBINATION OF METRIC AND UNIT. 

scraped_values['Variable Name'] = "Percentage of 4G (and 5G) coverage by at least one mobile network operator (%)"


#### Define the level of geographical granulation - country/region/LA etc. #### 

# Also define Geography variable.

scraped_geographies <- scraped_values %>% 
  mutate(Geography = case_when(
    substr(as.character(laua), 1, 3) == "Ukx" ~ "Country", #Welsh LAs
    substr(as.character(laua), 1, 3) == "W06" ~ "Unitary Authority", #Welsh LAs
    substr(as.character(laua), 1, 3) == "E06" ~ "Unitary Authority", # English LAs
    substr(as.character(laua), 1, 3) == "S12" ~ "Council Area",  # this is Scotland only 
    substr(as.character(laua), 1, 3) == "N09" ~ "Local Government District", # this is NI only. 
    substr(as.character(laua), 1, 3) == "E07" ~ "Non-metropolitan District",
    substr(as.character(laua), 1, 3) == "E08" ~ "Metropolitan District",
    substr(as.character(laua), 1, 3) == "E09" ~ "London Borough",
    substr(as.character(laua), 1, 3) == "E10" ~ "County")) # this is England only. 



#### Rename column names for output files ####

scraped_clean <- rename(scraped_geographies, AREACD = laua,
                        AREANM = laua_name)


# Format AREANM values to title case 

scraped_clean <- scraped_clean %>% 
  mutate(AREANM = toTitleCase(AREANM))


#### Convert 4g_geo_out_0 to a has 4g. Currently without 4g connectivity ####

scraped_clean['Value'] = 100 - scraped_clean$'4G_geo_out_0'


csv_formatted <- scraped_clean %>% 
  mutate(Value = ifelse(is.na(Value), "100", Value))


#### Generate Lower and Upper Confidence Interval Values ####

# no need for this metric.

#insert polarity
csv_formatted['Polarity'] = 1


# should be in correct order. If not...

csv_output <- csv_formatted  %>%
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

# e.g. setwd("D:/Coding_Repos/LUDA-Scripts") # please note this path will be specific for your local drive

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

