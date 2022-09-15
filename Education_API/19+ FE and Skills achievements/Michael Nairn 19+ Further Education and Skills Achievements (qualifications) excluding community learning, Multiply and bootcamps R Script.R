#### Michael Nairn Webscraping extraction for Subnational Indicator Explorer R Script ####

# 25th July 2022

# For future iterations, you should just have to run the code to generate an updated output.

# This script should download webscraped data and adapt it ready for upload to Subnational Indicators Explorer.


# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 6: increasing high-quality skills training in every area in the UK."
Metric <- "19+ Further Education and Skills Achievements (qualifications) excluding community learning, Multiply and bootcamps"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "FESkillsAchievements"


#### Import data from web ####

# Set Working directory to place webscraped data files into
setwd("D:/Coding_Repos/LUDA/Webscraping/Webscraped Inputs") # please note this path will be specific for your local drive


scraped_data_LA <- "https://content.explore-education-statistics.service.gov.uk/api/releases/bd108e73-078e-4f0e-9faa-c1a0cb6b7135/files/a90cd3d0-6741-45ed-ac38-08d9d771ae37"

# The above link is an API, but does not go to "latest data" so may need updating in the future.
  # Check here: 

# "https://explore-education-statistics.service.gov.uk/find-statistics/further-education-and-skills"
  # Explore data and files > All supporting files > List supporting files > FE and skills (FES) learner achievements (excluding Community Learning) by local authority

filename_LA <- "FESexclCLachievementsLA.csv"


scraped_data_England <- "https://content.explore-education-statistics.service.gov.uk/api/releases/bd108e73-078e-4f0e-9faa-c1a0cb6b7135/files/5d8bf00a-e3f2-43a6-ac37-08d9d771ae37"
# The above link is an API, but does not go to "latest data" so may need updating in the future.
  # Check here: 

# "https://explore-education-statistics.service.gov.uk/find-statistics/further-education-and-skills"
  # Explore data and files > All supporting files > List supporting files > FE and skills (FES) learner achievements (excluding Community Learning)

filename_England <- "FES excl CL achievements.csv"



#### Import data into R ####

scraped_data_LA <- read.csv(filename_LA) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


scraped_data_England <- read.csv(filename_England) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 



#### Rename and select relevant columns ####

scraped_values_LA <- rename(scraped_data_LA, Period = "time_period",
                                             AREACD = "new_la_code",
                                             AREANM = "la_name",
                                             Value = "fes_excluding_cl_ach") %>%
  select(all_of(c("Period",
                  "AREACD",
                  "AREANM",
                  "Value")))


scraped_values_England <- rename(scraped_data_England, Period = "time_period",
                            AREACD = "country_code",
                            AREANM = "country_name",
                            Value = "fes_excluding_cl_ach") %>%
  select(all_of(c("Period",
                  "AREACD",
                  "AREANM",
                  "Value")))


#### bind together LAs and Country data ####

scraped_values <- rbind(scraped_values_England, scraped_values_LA)

#### Add in extra LUDA variables based off titles given above ####

scraped_values['Category']=Mission 
scraped_values['Indicator']=Metric
scraped_values['Measure']="Number"
scraped_values['Unit']="Number" # likely a % or £. Be careful.


# No confidence interval or observation status data
scraped_values['Lower Confidence Interval (95%)'] = ""
scraped_values['Upper Confidence Interval (95%)'] = ""
scraped_values['Observation Status'] = ""


# Not always the case (use view(scraped_values) code to check) but may need to add a "Variable Name " column.
# NORMALLY A COMBINATION OF METRIC AND UNIT. 

scraped_values['Variable Name'] = "19+ Further Education and Skills Achievements (qualifications) excluding community learning, Multiply and bootcamps"



#### For August 2022 iteration this data source has an incorrect area code for Buckinghamshire in 2020/21 ####

scraped_values$AREACD <- gsub("E10000002", "E06000060", as.character(scraped_values$AREACD))


#### Define the level of geographical granulation - country/region/LA etc. #### 

# Also define Geography variable.

scraped_geographies <- scraped_values %>% 
  mutate(Geography = case_when(
    substr(as.character(AREACD), 1, 3) == "E92" ~ "Country",
    substr(as.character(AREACD), 1, 3) == "E12" ~ "Region", 
    AREACD == "Z" ~ "Region",
    substr(as.character(AREACD), 1, 3) == "E13" ~ "Region", 
    substr(as.character(AREACD), 1, 3) == "W06" ~ "Unitary Authority", #Welsh LAs
    substr(as.character(AREACD), 1, 3) == "E06" ~ "Unitary Authority", # English LAs
    substr(as.character(AREACD), 1, 3) == "S12" ~ "Council Area",  # this is Scotland only 
    substr(as.character(AREACD), 1, 3) == "N09" ~ "Local Government District", # this is NI only. 
    substr(as.character(AREACD), 1, 3) == "E07" ~ "Non-metropolitan District",
    substr(as.character(AREACD), 1, 3) == "E08" ~ "Metropolitan District",
    substr(as.character(AREACD), 1, 3) == "E09" ~ "London Borough", # this is England only. 
    substr(as.character(AREACD), 1, 3) == "E10" ~ "County", # this is England only. 
    substr(as.character(AREACD), 1, 3) == "E11" ~ "Metropolitan County")) # this is England only. 



#### Rename column names for output files ####

# not necessary for this metric

# Format AREANM values to title case 

scraped_clean <- scraped_geographies %>% 
  mutate(AREANM = toTitleCase(AREANM))


#### Generate Lower and Upper Confidence Interval Values ####

# no need for this metric.


# insert polarity value 
scraped_clean['Polarity']=1


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


# csv_formatted <- (na.omit(csv_formatted)) # removes NAs - especially if CIs



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

