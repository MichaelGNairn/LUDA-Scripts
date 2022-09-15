#### Michael Nairn Webscraping extraction for Subnational Indicator Explorer Ingestion template R Script ####

# 25th July 2022

# For future iterations, you should just have to run the code to generate an updated output.

# This script should download webscraped data and adapt it ready for upload to Subnational Indicators Explorer.


# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 5: increasing primary school attainment, 90% of children achieving the minimum standard in England"
Metric <- "Percentage of schools rated good or outstanding by Ofsted"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "Ofsted" 


#### Import data from web ####

# Set Working directory to place webscraped data files into
setwd("D:/Coding_Repos/LUDA/Webscraping/Webscraped Inputs") # please note this path will be specific for your local drive


scraped_data <- "https://www.gov.uk/government/statistical-data-sets/monthly-management-information-ofsteds-school-inspections-outcomes"

scraped_data <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/1097015/Management_information_-_state-funded_schools_-_as_at_31_July_2022.xlsx"

filename <- "Management_information_-_state-funded_schools_-_as_at_31_July_2022.xlsx"

#### Import data into R ####

tabname <- "Table_1"

scraped_data <- read_excel(filename, sheet = tabname, skip = 4) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 

colnames(scraped_data)

#### Select relevant columns ####

scraped_values <- scraped_data %>%
  select(all_of(c("Region/Local authority...1",
                  "Outstanding %...9",
                  "Good \r\n%...10")))

#### Calculate Outstanding and good combined ####

scraped_values['Value'] = scraped_values$`Outstanding %...9` + scraped_values$`Good \r\n%...10`



# Rename area name as AREANM and format values to title case 

scraped_values <- scraped_values %>% 
  mutate(AREANM = toTitleCase(`Region/Local authority...1`))

#### Select relevant columns ####

scraped_values <- scraped_values %>%
  select(all_of(c("AREANM", "Value")))


#### Some area names are not aligned with ONS geoportal standards. ####
scraped_values$AREANM <- gsub("Bristol", "Bristol, City of", as.character(scraped_values$AREANM))
scraped_values$AREANM <- gsub("Bournemouth, Christchurch & Poole", "Bournemouth, Christchurch and Poole", as.character(scraped_values$AREANM))
scraped_values$AREANM <- gsub("Herefordshire", "Herefordshire, County of", as.character(scraped_values$AREANM))
scraped_values$AREANM <- gsub("Kingston Upon Hull", "Kingston Upon Hull, City of", as.character(scraped_values$AREANM))
scraped_values$AREANM <- gsub("Southend on Sea", "Southend-on-Sea", as.character(scraped_values$AREANM))
scraped_values$AREANM <- gsub("St Helens", "St. Helens", as.character(scraped_values$AREANM))



#### Import area codes ####

setwd("D:/Coding_Repos/LUDA/Geoportal codes")

area_codes <- read.csv("geoportal_codes.csv")

area_codes$AREANM <- as.character(area_codes$AREANM)

area_codes <- area_codes %>%
  mutate(AREANM = toTitleCase(AREANM)) # Format to title case to allow joining with dataset 


# Join datasets by AREANM

scraped_codes <- scraped_values %>%
  left_join(area_codes, by = "AREANM")



#### For August 2022 iteration this data source has some incorrect area codes for 2021/22 ####

scraped_codes$AREACD <- gsub("E10000002", "E06000060", as.character(scraped_codes$AREACD))
scraped_codes$AREACD <- gsub("E10000009", "E06000059", as.character(scraped_codes$AREACD))
scraped_codes$AREACD <- gsub("E10000010", "E06000047", as.character(scraped_codes$AREACD))
scraped_codes$AREACD <- gsub("E10000022", "E06000057", as.character(scraped_codes$AREACD))
scraped_codes$AREACD <- gsub("E10000026", "E06000051", as.character(scraped_codes$AREACD))
scraped_codes$AREACD <- gsub("E10000033", "E06000054", as.character(scraped_codes$AREACD))

scraped_codes$AREANM <- gsub("Durham", "County Durham", as.character(scraped_codes$AREANM))


#### Add in extra LUDA variables based off titles given above ####

scraped_codes['Category']=Mission 
scraped_codes['Indicator']=Metric
scraped_codes['Measure']="Percentage"
scraped_codes['Unit']="%" # likely a % or £. Be careful.


# No confidence interval or observation status data
scraped_codes['Lower Confidence Interval (95%)'] = ""
scraped_codes['Upper Confidence Interval (95%)'] = ""
scraped_codes['Observation Status'] = ""
scraped_codes['Period'] = "202122"


# Not always the case (use view(scraped_codes) code to check) but may need to add a "Variable Name " column.
# NORMALLY A COMBINATION OF METRIC AND UNIT. 

scraped_codes['Variable Name'] = "Percentage of schools rated good or outstanding by Ofsted (%)"


#### Define the level of geographical granulation - country/region/LA etc. #### 

# Also define Geography variable.

scraped_geographies <- scraped_codes %>% 
  mutate(Geography = case_when(
    substr(as.character(AREACD), 2, 3) == "92" ~ "Country",
    substr(as.character(AREACD), 1, 3) == "K04" ~ "Country",
    substr(as.character(AREACD), 1, 3) == "K02" ~ "Country",
    substr(as.character(AREACD), 1, 3) == "Ukx" ~ "Country",
    substr(as.character(AREACD), 1, 3) == "W42" ~ "City Region", # Wales
    substr(as.character(AREACD), 1, 3) == "E12" ~ "Region", # this is England only. 
    substr(as.character(AREACD), 1, 3) == "W06" ~ "Unitary Authority", #Welsh LAs
    substr(as.character(AREACD), 1, 3) == "E06" ~ "Unitary Authority", # English LAs
    substr(as.character(AREACD), 1, 3) == "S12" ~ "Council Area",  # this is Scotland only 
    substr(as.character(AREACD), 1, 3) == "N09" ~ "Local Government District", # this is NI only. 
    substr(as.character(AREACD), 1, 3) == "E07" ~ "Non-metropolitan District",
    substr(as.character(AREACD), 1, 3) == "E08" ~ "Metropolitan District",
    substr(as.character(AREACD), 1, 3) == "E09" ~ "London Borough", # this is England only. 
    substr(as.character(AREACD), 1, 3) == "E10" ~ "County", # this is England only. 
    substr(as.character(AREACD), 1, 3) == "E11" ~ "Metropolitan County",
    substr(as.character(AREACD), 1, 3) == "E13" ~ "Inner or Outer London",
    substr(as.character(AREACD), 1, 3) == "E47" ~ "Combined Authority")) # this is England only. 


#### Generate Lower and Upper Confidence Interval Values ####

# no need for this metric.

#insert polarity
scraped_geographies['Polarity'] = 1

# should be in correct order. If not...

csv_formatted <-  scraped_geographies %>%
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

# remove unwanted geography granulations
csv_output <- csv_formatted[!is.na(csv_formatted$Geography),]

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

