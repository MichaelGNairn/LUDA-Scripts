#### Michael Nairn Webscraping extraction for Subnational Indicator Explorer Ingestion template R Script ####

# 15th July 2022

# For future iterations, you should just have to run the code to generate an updated output.

# This script should download webscraped data and adapt it ready for upload to Subnational Indicators Explorer.


# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 1: closing the gap in median employment and productivity"
Metric <- "Outward Foreign Direct Investment (FDI)"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "OutwardFDI" 

#### Import data from web ####

# Set Working directory to place webscraped data files into
setwd("D:/Coding_Repos/LUDA/Webscraping/Webscraped Inputs") # please note this path will be specific for your local drive


scraped_data <- "https://www.ons.gov.uk/economy/nationalaccounts/balanceofpayments/datasets/foreigndirectinvestmentinvolvingukcompaniesbyukcountryandindustrydirectionaloutward"

scraped_data <- "https://www.ons.gov.uk/file?uri=/economy/nationalaccounts/balanceofpayments/datasets/foreigndirectinvestmentinvolvingukcompaniesbyukcountryandindustrydirectionaloutward/current/subnationalfdioutwardtablesfinal.xls"

filename <- "subnationalfdioutwardtablesfinal.xls"


#### Import data into R ####

tabname_region <- "1.3 ITL1 earn"

scraped_data_region <- read_excel(filename, sheet = tabname_region, skip = 4) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


tabname_subregion <- "1.6 ITL2 earn"

scraped_data_subregion <- read_excel(filename, sheet = tabname_subregion, skip = 4) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


tabname_city <- "1.7 City region"

scraped_data_city <- read_excel(filename, sheet = tabname_city, skip = 4) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish))

# below line makes the region, subregion, and city data easier to bind. 
scraped_data_city <- cbind(a = "", scraped_data_city)
colnames(scraped_data_city)[1:3] <- c("...1", "...2", "...3")

scraped_data <- rbind(scraped_data_region, scraped_data_subregion, scraped_data_city) 


#### Filter by total net earnings, and rename and select relevant columns ####

scraped_data <- filter(scraped_data, ...3 == "Total fdi international investment position abroad at end period")
                       
scraped_data <- rename(scraped_data, AREANM = "...2")


#### Merge years into one column called "Period" ####

year_2015 <- scraped_data %>%
  rename(Value = "2015") %>%
  select(all_of(c("...1", "AREANM", "Value")))
year_2015['Period'] = "2015"

year_2016 <- scraped_data %>%
  rename(Value = "2016") %>%
  select(all_of(c("...1", "AREANM", "Value")))
year_2016['Period'] = "2016"

year_2017 <- scraped_data %>%
  rename(Value = "2017") %>%
  select(all_of(c("...1", "AREANM", "Value")))
year_2017['Period'] = "2017"

year_2018 <- scraped_data %>%
  rename(Value = "2018") %>%
  select(all_of(c("...1", "AREANM", "Value")))
year_2018['Period'] = "2018"

year_2019 <- scraped_data %>%
  rename(Value = "2019") %>%
  select(all_of(c("...1", "AREANM", "Value")))
year_2019['Period'] = "2019"

scraped_values <- rbind(year_2015, year_2016, year_2017,
                        year_2018, year_2019)


rm(list = ls(pattern = "year"))


#### Add in extra LUDA variables based off titles given above ####

scraped_values['Category']=Mission 
scraped_values['Indicator']=Metric
scraped_values['Measure']="Pounds"
scraped_values['Unit']="£ (million)" # likely a % or £. Be careful.


# No confidence interval or observation status data
scraped_values['Lower Confidence Interval (95%)'] = ""
scraped_values['Upper Confidence Interval (95%)'] = ""


scraped_values <- scraped_values %>%
  mutate(`Observation Status` = case_when(Value == ".." ~ "Data not reported"))




# Not always the case (use view(scraped_values) code to check) but may need to add a "Variable Name " column.
# NORMALLY A COMBINATION OF METRIC AND UNIT. 

scraped_values['Variable Name'] = "Outward Foreign Direct Investment (£ million)"

#### Format AREANM values to title case ####

scraped_clean <- scraped_values %>% 
  mutate(AREANM = toTitleCase(AREANM))

# remove " Region" and " Combined Authority" from AREANM??

scraped_clean$AREANM <- gsub(" Region", "", scraped_clean$AREANM)
scraped_clean$AREANM <- gsub(" Combined Authority", "", scraped_clean$AREANM)



#### Import area codes ####

setwd("D:/Coding_Repos/LUDA/Geoportal codes")

area_codes <- read.csv("geoportal_codes_ITL.csv")

area_codes$AREANM <- as.character(area_codes$AREANM)

area_codes <- area_codes %>%
  mutate(AREANM = toTitleCase(AREANM)) # Format to title case to allow joining with dataset 


# Join datasets by AREANM

scraped_codes <- scraped_clean %>%
  left_join(area_codes, by = "AREANM")



#### Define the level of geographical granulation - country/region/LA etc. #### 

# Also define Geography variable.

scraped_geographies <- scraped_codes %>% 
  mutate(Geography = case_when(str_length(scraped_codes$AREACD) == "3" ~ "ITL Level 1",
                               str_length(scraped_codes$AREACD) == "4" ~ "ITL Level 2",
                               str_length(scraped_codes$AREACD) == "5" ~ "ITL Level 3"))


#### Generate Lower and Upper Confiudence Interval Values ####

# no need for this metric.

# insert polarity value 
scraped_geographies['Polarity']=1


# should be in correct order. If not...
csv_output <-  scraped_geographies %>%
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


# replace suppressed values (blanks in this case) to N/A
csv_output$Value[csv_output$Value == ""] <- "NA"


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

