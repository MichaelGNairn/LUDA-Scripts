#### Michael Nairn Webscraping extraction for Subnational Indicator Explorer Ingestion R Script ####

# 26th July 2022

# For future iterations, you should just have to run the code to generate an updated output.

# This script should download webscraped data and adapt it ready for upload to Subnational Indicators Explorer.


# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 1: closing the gap in median employment and productivity"
Metric <- "Total value of UK exports"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "UkExports"


#### Import data from web ####

# Set Working directory to place webscraped data files into
setwd("D:/Coding_Repos/LUDA/Webscraping/Webscraped Inputs") # please note this path will be specific for your local drive


# Two types of exports to sum. Goods and services


scraped_data_goods <- "https://www.ons.gov.uk/businessindustryandtrade/internationaltrade/datasets/subnationaltradeingoods"

scraped_data_goods <- "https://www.ons.gov.uk/file?uri=/businessindustryandtrade/internationaltrade/datasets/subnationaltradeingoods/2020/subnationaltig2020.xlsx"

filename_goods <- "subnationaltig2020.xlsx"


scraped_data_services <- "https://www.ons.gov.uk/businessindustryandtrade/internationaltrade/datasets/subnationaltradeinservices"

scraped_data_services <- "https://www.ons.gov.uk/file?uri=/businessindustryandtrade/internationaltrade/datasets/subnationaltradeinservices/2020/subnationaltis202020220704.xlsx"

filename_services <- "subnationaltis202020220704.xlsx"

#### Import data into R ####

# Goods data

tabname_goods = "Summary Sheet"

scraped_data_goods <- read.xlsx(filename_goods, sheet = tabname_goods, startRow =5) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 



# Services data

tabname_services = "Summary Sheet"

scraped_data_services <- read.xlsx(filename_services, sheet = tabname_services, startRow =5) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 



#### Rename and select relevant columns ####

scraped_values_services <- rename(scraped_data_services, 
                                  ITL.code = "ITL.Code",
                                  AREANM = "Area.name",
                                  'Value - services' = "Total.-.Exports") %>%
  select(all_of(c("ITL.code", "AREANM", "Value - services")))



scraped_values_goods <- rename(scraped_data_goods, 
                                  AREANM = "Area.name",
                                  'Value - goods' = "Total.-.Exports") %>%
  select(all_of(c("ITL.code", "AREANM", "Value - goods")))


#### Join together and sum ####

# need ITL as two West Midlands, ITL1 and ITL2. 
scraped_values <- scraped_values_goods %>%
  left_join(scraped_values_services, by = c("AREANM", "ITL.code"))


# Format AREANM values to title case 

scraped_values <- scraped_values %>% 
  mutate(AREANM = toTitleCase(AREANM))


# Sum two columns to get total value of UK exports 

scraped_values$`Value - services` <- as.numeric(as.character(scraped_values$`Value - services`))
scraped_values$`Value - goods` <- as.numeric(as.character(scraped_values$`Value - goods`))

# Lots of NAs here due to not having data for one of the two variables
scraped_values['Value'] = scraped_values$`Value - goods` + scraped_values$`Value - services`


#### Add in extra LUDA variables based off titles given above ####

scraped_values['Category']=Mission 
scraped_values['Indicator']=Metric
scraped_values['Measure']="Pounds"
scraped_values['Unit']="£ million" # likely a % or £. Be careful.


# No confidence interval or observation status data
scraped_values['Lower Confidence Interval (95%)'] = ""
scraped_values['Upper Confidence Interval (95%)'] = ""
scraped_values['Period'] = "2020"


scraped_values <- scraped_values %>%
  mutate(`Observation Status` = case_when(Value == "" ~ "Data not reported"))


# Not always the case (use view(scraped_values) code to check) but may need to add a "Variable Name " column.
# NORMALLY A COMBINATION OF METRIC AND UNIT. 

scraped_values['Variable Name'] = "Total value of UK exports (£ million)"

scraped_values$AREANM <- gsub(" Cc", " CC", scraped_values$AREANM)


#### Import area codes ####

# big issue here that a lot of geography granulation is by Eurostat NUTS codes
  # https://geoportal.statistics.gov.uk/datasets/ons::nuts-level-3-january-2018-names-and-codes-in-the-united-kingdom/explore
  # This is different ot all other metrics. 

setwd("D:/Coding_Repos/LUDA/Geoportal codes")

area_codes <- read.csv("geoportal_codes_ITL.csv")

area_codes$AREANM <- as.character(area_codes$AREANM)

area_codes <- area_codes %>%
  mutate(AREANM = toTitleCase(AREANM)) # Format to title case to allow joining with dataset 


# Join datasets by AREANM

scraped_codes <- scraped_values %>%
  left_join(area_codes, by = "AREANM")



#### Define the level of geographical granulation - country/region/LA etc. #### 

# Also define Geography variable.

scraped_geographies <- scraped_codes %>% 
  mutate(Geography = case_when(str_length(scraped_codes$AREACD) == "3" ~ "ITL Level 1",
                               str_length(scraped_codes$AREACD) == "4" ~ "ITL Level 2",
                               str_length(scraped_codes$AREACD) == "5" ~ "ITL Level 3"))
    


#### Generate Lower and Upper Confidence Interval Values ####

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


# remove duplicate rows 
csv_output <- unique(csv_output)



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

