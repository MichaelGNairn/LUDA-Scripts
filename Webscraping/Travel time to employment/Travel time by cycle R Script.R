#### Michael Nairn Webscraping extraction for Subnational Indicator Explorer Ingestion R Script ####

# 15th July 2022

# For future iterations, you should just have to run the code to generate an updated output.

# This script should download webscraped data and adapt it ready for upload to Subnational Indicators Explorer.


# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 3: improving public transport outside of London"
Metric <- "Average travel time in minutes to reach nearest large employment centre (500 + employees), by cycle"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "TIMEtravelWORKBike"


#### Import data from web ####

# Set Working directory to place webscraped data files into
setwd("D:/Coding_Repos/LUDA-Scripts/Webscraping/Webscraped Inputs") # please note this path will be specific for your local drive


scraped_data <- "https://www.gov.uk/government/statistical-data-sets/journey-time-statistics-data-tables-jts"




#### Import data into R ####

# Will need to import each tab. Be careful.

#### 2019 data ####

filename <- "jts0401.xlsx"
tabname <- "2019_REVISED"

scraped_data <- read.xlsx(filename, sheet = tabname, startRow = 7)


scraped_values <- scraped_data %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 



# Select columns of interest

Cyc_2019 <-  scraped_values %>%
  select(all_of(c("LA_Code",
                  "LA_Name",
                  "500EmpCyct")))

#### 2017 data ####

filename <- "jts0401.xlsx"
tabname <- "2017"

scraped_data <- read.xlsx(filename, sheet = tabname, startRow = 7)


scraped_values <- scraped_data %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 



# Select columns of interest

Cyc_2017 <-  scraped_values %>%
  select(all_of(c("LA_Code",
                  "LA_Name",
                  "500EmpCyct")))


#### 2016 data ####

filename <- "jts0401.xlsx"
tabname <- "2016"

scraped_data <- read.xlsx(filename, sheet = tabname, startRow = 7)


scraped_values <- scraped_data %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 



# Select columns of interest

Cyc_2016 <-  scraped_values %>%
  select(all_of(c("LA_Code",
                  "LA_Name",
                  "500EmpCyct")))


#### 2015 data ####

filename <- "jts0401.xlsx"
tabname <- "2015"

scraped_data <- read.xlsx(filename, sheet = tabname, startRow = 7)


scraped_values <- scraped_data %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 



# Select columns of interest

Cyc_2015 <-  scraped_values %>%
  select(all_of(c("LA_Code",
                  "LA_Name",
                  "500EmpCyct")))


#### 2014 data ####

filename <- "jts0401.xlsx"
tabname <- "2014"

scraped_data <- read.xlsx(filename, sheet = tabname, startRow = 7)


scraped_values <- scraped_data %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 



# Select columns of interest 

Cyc_2014 <-  scraped_values %>%
  select(all_of(c("LA_Code",
                  "LA_Name",
                  "500EmpCyct")))



#### Region data ####

filename <- "jts0103.xlsx"

#### 2019 ####

tabname <- "2019"
Region_2019 <- read.xlsx(filename, sheet = tabname, rows = c(8, 18:26))


# Add in necessary columns

Region_2019['LA_Code']=""

# Select and rename columns of interest

Region_2019 <-  rename(Region_2019,  LA_Name = Region,
                       `500EmpCyct` = `Places.with.500-4999.jobs`) %>%
  select(all_of(c("LA_Code",
                  "LA_Name",
                  "500EmpCyct")))


#### 2017 ####

tabname <- "2017"
Region_2017 <- read.xlsx(filename, sheet = tabname, rows = c(8, 18:26))


# Add in necessary columns

Region_2017['LA_Code']=""

# Select and rename columns of interest

Region_2017 <-  rename(Region_2017,  LA_Name = Region,
                       `500EmpCyct` = `Places.with.500-4999.jobs`) %>%
  select(all_of(c("LA_Code",
                  "LA_Name",
                  "500EmpCyct")))


#### 2016 ####

tabname <- "2016"
Region_2016 <- read.xlsx(filename, sheet = tabname, rows = c(8, 18:26))


# Add in necessary columns

Region_2016['LA_Code']=""

# Select and rename columns of interest

Region_2016 <-  rename(Region_2016,  LA_Name = Region,
                       `500EmpCyct` = `Places.with.500-4999.jobs`) %>%
  select(all_of(c("LA_Code",
                  "LA_Name",
                  "500EmpCyct")))


#### 2015 ####

tabname <- "2015"
Region_2015 <- read.xlsx(filename, sheet = tabname, rows = c(8, 18:26))


# Add in necessary columns

Region_2015['LA_Code']=""

# Select and rename columns of interest

Region_2015 <-  rename(Region_2015,  LA_Name = Region,
                       `500EmpCyct` = `Places.with.500-4999.jobs`) %>%
  select(all_of(c("LA_Code",
                  "LA_Name",
                  "500EmpCyct")))



#### 2014 ####

tabname <- "2014"
Region_2014 <- read.xlsx(filename, sheet = tabname, rows = c(8, 18:26))


# Add in necessary columns

Region_2014['LA_Code']=""

# Select and rename columns of interest

Region_2014 <-  rename(Region_2014,  LA_Name = Region,
                       `500EmpCyct` = `Places.with.500-4999.jobs`) %>%
  select(all_of(c("LA_Code",
                  "LA_Name",
                  "500EmpCyct")))




#### Add in period column to LA and regional dataframes ####

Cyc_2019['Period']=2019 
Cyc_2017['Period']=2017 
Cyc_2016['Period']=2016 
Cyc_2015['Period']=2015 
Cyc_2014['Period']=2014 
Region_2019['Period']=2019 
Region_2017['Period']=2017 
Region_2016['Period']=2016 
Region_2015['Period']=2015 
Region_2014['Period']=2014 


#### England data ####

filename <- "jts0101.xlsx"
England <- read.xlsx(filename, rows = 8:25)


England <- England %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


# filter to only include cycle data

England_cycle <- filter(England, Mode == "Cycle")


# Add in necessary columns

England_cycle['LA_Name']="England"
England_cycle['LA_Code']="E92000001"
England_cycle['Year'] = c("2014", "2015", "2016", "2017", "2019")


# Select and rename columns of interest

England_cycle <-  rename(England_cycle,  `500EmpCyct` = `Places.with.500-4999.jobs`,
                   Period = Year) %>%
  select(all_of(c("LA_Code",
                  "LA_Name",
                  "500EmpCyct",
                  "Period")))



#### Combine dataframes ####

scraped_values <- rbind(England_cycle, Region_2019, Region_2017, Region_2016, Region_2015, Region_2014, 
                        Cyc_2019, Cyc_2017, Cyc_2016, Cyc_2015, Cyc_2014)



#### Add in extra LUDA variables based off titles given above ####

scraped_values['Category']=Mission 
scraped_values['Indicator']=Metric
scraped_values['Measure']="Minutes"
scraped_values['Unit']="Minutes" # likely a % or £. Be careful.


# No confidence interval or observation status data
scraped_values['Lower Confidence Interval (95%)'] = ""
scraped_values['Upper Confidence Interval (95%)'] = ""
scraped_values['Observation Status'] = ""

# Not always the case (use view(scraped_values) code to check) but may need to add a "Variable Name " column.
# NORMALLY A COMBINATION OF METRIC AND UNIT. 

scraped_values['Variable Name'] = "Average travel time in minutes to reach nearest large employment centre (500 + employees), by car (minutes)"


#### Rename column names for output files ####

scraped_clean <- rename(scraped_values, AREACD = LA_Code,
                        AREANM = LA_Name,
                        Value = `500EmpCyct`)

# Format AREANM values to title case 

scraped_clean <- scraped_clean %>% 
  mutate(AREANM = toTitleCase(AREANM))


#### Add in area codes for regions ####

setwd("D:/Coding_Repos/LUDA-Scripts")

area_codes <- read.csv("region_codes_MN.csv")

area_codes$AREANM <- as.character(area_codes$AREANM)

area_codes <- area_codes %>%
  mutate(AREANM = toTitleCase(AREANM)) # Format to title case to allow joining with dataset 


# Join datasets by AREANM

scraped_areas <- scraped_clean %>%
  left_join(area_codes, by = "AREANM")



scraped_codes <- unite(scraped_areas, AREACD, c(AREACD.x, AREACD.y), 
                       sep = "", remove=FALSE, na.rm = TRUE)



#### Define the level of geographical granulation - country/region/LA etc. #### 

# Also define Geography variable.

scraped_geographies <- scraped_codes %>% 
  mutate(Geography = case_when(
    substr(as.character(AREACD), 1, 3) == "E92" ~ "Country",
    substr(as.character(AREACD), 1, 3) == "E12" ~ "Region", 
    substr(as.character(AREACD), 1, 3) == "W06" ~ "Unitary Authority", #Welsh LAs
    substr(as.character(AREACD), 1, 3) == "E06" ~ "Unitary Authority", # English LAs
    substr(as.character(AREACD), 1, 3) == "S12" ~ "Council Area",  # this is Scotland only 
    substr(as.character(AREACD), 1, 3) == "N09" ~ "Local Government District", # this is NI only. 
    substr(as.character(AREACD), 1, 3) == "E07" ~ "Non-metropolitan District",
    substr(as.character(AREACD), 1, 3) == "E08" ~ "Metropolitan District",
    substr(as.character(AREACD), 1, 3) == "E09" ~ "London Borough", # this is England only. 
    substr(as.character(AREACD), 1, 3) == "E10" ~ "County", # this is England only. 
    substr(as.character(AREACD), 1, 3) == "E11" ~ "Metropolitan County",
    substr(as.character(AREACD), 1, 3) == "E13" ~ "Inner or Outer London")) # this is England only. 



#### Generate Lower and Upper Confiudence Interval Values ####

# no need for this metric.

# insert polarity value 
scraped_geographies['Polarity']=-1

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

