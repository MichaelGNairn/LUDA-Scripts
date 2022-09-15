#### Michael Nairn Webscraping extraction for Subnational Indicator Explorer Ingestion template R Script ####

# 15th July 2022

# For future iterations, you should just have to run the code to generate an updated output.

# This script should download webscraped data and adapt it ready for upload to Subnational Indicators Explorer.


# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 7: narrowing the gap in HLE between areas, increasing HLE by five years by 2035"
Metric <- "Smoking prevalence of adults"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "Smoke" 


#### Import data from web ####

# Set Working directory to place webscraped data files into
setwd("D:/Coding_Repos/LUDA/Webscraping/Webscraped Inputs") # please note this path will be specific for your local drive


scraped_data <- "https://www.ons.gov.uk/peoplepopulationandcommunity/healthandsocialcare/healthandlifeexpectancies/datasets/smokinghabitsintheukanditsconstituentcountries"

scraped_data <- "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/healthandsocialcare/healthandlifeexpectancies/datasets/smokinghabitsintheukanditsconstituentcountries/quarter2aprtojunetoquarter4octtodec2020/smokinghabitstheukanditsconstituentcountries2020q24.xls"

filename <- "smokinghabitstheukanditsconstituentcountries2020q24.xls"
  # not comparable to prior data as telephone only

# 2011 to 2020 Q1 data here. "smokinghabitstheukanditsconstituentcountries2020q1.xls"


#### Import data into R ####

# LA data

tabname_LA <- "Table 4"

scraped_data_LAs <- read_excel(filename, sheet = tabname_LA, skip = 20) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


# regional data

tabname_region <- "Table 2"

scraped_data_regions <- read_excel(filename, sheet = tabname_region, skip = 19) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


# country data

tabname_countries <- "Table 1"

scraped_data_countries <- read_excel(filename, sheet = tabname_countries, skip = 20) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


#### Filter by sex = all, rename and select relevant columns ####

# LAs
scraped_data_LAs <- filter(scraped_data_LAs, Sex == "Persons")

scraped_values_LAs <- rename(scraped_data_LAs, AREACD = "Local Authority Code",
                             AREANM = "Local Authority Name",
                             Value = "April to December 2020",
                             'Lower Confidence Interval (95%)' = "...7",
                             'Upper Confidence Interval (95%)' = "...8")

scraped_values_LAs <- scraped_values_LAs %>%
  select(all_of(c("AREACD",
                  "AREANM",
                  "Value",
                  "Lower Confidence Interval (95%)",
                  "Upper Confidence Interval (95%)")))


# Regions
scraped_data_regions <- filter(scraped_data_regions, Sex == "Persons" 
                               & `Age group` == "All 18+")

scraped_values_regions <- rename(scraped_data_regions, AREACD = "Region code",
                             AREANM = "Region of England",
                             Value = "April to December 2020",
                             'Lower Confidence Interval (95%)' = "...6",
                             'Upper Confidence Interval (95%)' = "...7")

scraped_values_regions <- scraped_values_regions %>%
  select(all_of(c("AREACD",
                  "AREANM",
                  "Value",
                  "Lower Confidence Interval (95%)",
                  "Upper Confidence Interval (95%)")))


# Countries
scraped_data_countries <- filter(scraped_data_countries, Sex == "Persons" 
                                 & `Age group` == "All 18+")

scraped_values_countries <- rename(scraped_data_countries,
                                 AREANM = "Country",
                                 Value = "April to December 2020",
                                 'Lower Confidence Interval (95%)' = "...5",
                                 'Upper Confidence Interval (95%)' = "...6")

scraped_values_countries['AREACD']=case_when(scraped_values_countries$AREANM == "England" ~  "E92000001",
                                             scraped_values_countries$AREANM == "Wales" ~  "W92000004",
                                             scraped_values_countries$AREANM == "Scotland" ~  "S92000003",
                                             scraped_values_countries$AREANM == "Northern ireland" ~  "N92000002",
                                             scraped_values_countries$AREANM == "United kingdom" ~  "K02000001")


scraped_values_countries <- scraped_values_countries %>%
  select(all_of(c("AREACD",
                  "AREANM",
                  "Value",
                  "Lower Confidence Interval (95%)",
                  "Upper Confidence Interval (95%)")))


#### Bind LAs, Regions and Countries together ####

scraped_values <- rbind(scraped_values_LAs, scraped_values_regions, scraped_values_countries)

#### Add in extra LUDA variables based off titles given above ####

scraped_values['Category']=Mission 
scraped_values['Indicator']=Metric
scraped_values['Measure']="Percentage"
scraped_values['Unit']="%" 
scraped_values['Period']="2020"

# No Observation data
scraped_values <- scraped_values %>%
  mutate(`Observation Status` = case_when(Value == "Z" ~ "Value suppressed"))



# Not always the case (use view(scraped_values) code to check) but may need to add a "Variable Name " column.
# NORMALLY A COMBINATION OF METRIC AND UNIT. 

scraped_values['Variable Name'] = "Smoking prevalence of adults (%)"


#### Define the level of geographical granulation - country/region/LA etc. #### 

# Also define Geography variable.

scraped_geographies <- scraped_values %>% 
  mutate(Geography = case_when(
    substr(as.character(AREACD), 2, 3) == "92" ~ "Country",
    substr(as.character(AREACD), 1, 3) == "K02" ~ "Country",
    substr(as.character(AREACD), 1, 3) == "E12" ~ "Region",
    substr(as.character(AREACD), 1, 3) == "W06" ~ "Unitary Authority", #Welsh LAs
    substr(as.character(AREACD), 1, 3) == "E06" ~ "Unitary Authority", # English LAs
    substr(as.character(AREACD), 1, 3) == "S12" ~ "Council Area",  # this is Scotland only 
    substr(as.character(AREACD), 1, 3) == "N09" ~ "Local Government District", # this is NI only. 
    substr(as.character(AREACD), 1, 3) == "E07" ~ "Non-metropolitan District",
    substr(as.character(AREACD), 1, 3) == "E08" ~ "Metropolitan District",
    substr(as.character(AREACD), 1, 3) == "E09" ~ "London Borough",
    substr(as.character(AREACD), 1, 3) == "E10" ~ "County")) # this is England only. 


# Format AREANM values to title case 

scraped_clean <- scraped_geographies %>% 
  mutate(AREANM = toTitleCase(AREANM))


#### Generate Lower and Upper Confiudence Interval Values ####

# no need for this metric.

# insert polarity value 
scraped_clean['Polarity']=-1

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


# replace suppressed values (Z in this case) to N/A
csv_output$Value[csv_output$Value == "Z"] <- "NA"
csv_output$`Lower Confidence Interval (95%)`[csv_output$`Lower Confidence Interval (95%)` == "Z"] <- "NA"
csv_output$`Upper Confidence Interval (95%)`[csv_output$`Upper Confidence Interval (95%)`== "Z"] <- "NA"





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

