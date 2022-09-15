#### Michael Nairn Webscraping extraction for Subnational Indicator Explorer Ingestion template R Script ####

# 15th July 2022

# For future iterations, you should just have to run the code to generate an updated output.

# This script should download webscraped data and adapt it ready for upload to Subnational Indicators Explorer.


# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 1: closing the gap in median employment and productivity"
Metric <- "Gross Value Added (GVA) per hour worked"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "GVAperhourworked" 


#### Import data from web ####

# Set Working directory to place webscraped data files into
setwd("D:/Coding_Repos/LUDA-Scripts/Webscraping/Webscraped Inputs") # please note this path will be specific for your local drive


scraped_data_LA <- "https://www.ons.gov.uk/file?uri=/employmentandlabourmarket/peopleinwork/labourproductivity/datasets/subregionalproductivitylabourproductivityindicesbylocalauthoritydistrict/current/"

filename_LA <- "ladproductivity.xlsx"

tabname_LA <- "A3"


scraped_data_region <- "https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/labourproductivity/datasets/subregionalproductivitylabourproductivitygvaperhourworkedandgvaperfilledjobindicesbyuknuts2andnuts3subregions"

# https://www.ons.gov.uk/file?uri=/employmentandlabourmarket/peopleinwork/labourproductivity/datasets/subregionalproductivitylabourproductivitygvaperhourworkedandgvaperfilledjobindicesbyuknuts2andnuts3subregions/current/itlproductivity.xls

filename_region <- "itlproductivity.xls"

tabname_region <- "A3"



#### Import data into R ####

scraped_data_LA <- read.xlsx(filename_LA, sheet = tabname_LA, startRow = 3) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


scraped_values_LA <- scraped_data_LA[-1,] 

colnames(scraped_values_LA)[1:19] <- c("AREACD", "AREANM", "2004", "2005", "2006", "2007",
                                    "2008", "2009", "2010", "2011", "2012", "2013", "2014",
                                    "2015", "2016", "2017", "2018", "2019", "2020")


scraped_data_region <- read_excel(filename_region, sheet = tabname_region, skip = 3) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


scraped_values_region <- scraped_data_region[-1,] 

colnames(scraped_values_region)[1:20] <- c("ITL", "AREACD", "AREANM", "2004", "2005", "2006", "2007",
                                       "2008", "2009", "2010", "2011", "2012", "2013", "2014",
                                       "2015", "2016", "2017", "2018", "2019", "2020")

scraped_values_region <- scraped_values_region %>%
  select(all_of(c("AREACD", "AREANM", "2004", "2005", "2006", "2007",
                    "2008", "2009", "2010", "2011", "2012", "2013", "2014",
                    "2015", "2016", "2017", "2018", "2019", "2020")))


#### Define Period for LA ####

# must be a more elegant and robust way of doing this via a loop.

year_2004 <- scraped_values_LA %>%
  rename(Value = "2004") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2004['Period'] = "2004"

year_2005 <- scraped_values_LA %>%
  rename(Value = "2005") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2005['Period'] = "2005"

year_2006 <- scraped_values_LA %>%
  rename(Value = "2006") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2006['Period'] = "2006"

year_2007 <- scraped_values_LA %>%
  rename(Value = "2007") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2007['Period'] = "2007"

year_2008 <- scraped_values_LA %>%
  rename(Value = "2008") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2008['Period'] = "2008"

year_2009 <- scraped_values_LA %>%
  rename(Value = "2009") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2009['Period'] = "2009"

year_2010 <- scraped_values_LA %>%
  rename(Value = "2010") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2010['Period'] = "2010"

year_2011 <- scraped_values_LA %>%
  rename(Value = "2011") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2011['Period'] = "2011"

year_2012 <- scraped_values_LA %>%
  rename(Value = "2012") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2012['Period'] = "2012"

year_2013 <- scraped_values_LA %>%
  rename(Value = "2013") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2013['Period'] = "2013"

year_2014 <- scraped_values_LA %>%
  rename(Value = "2014") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2014['Period'] = "2014"

year_2015 <- scraped_values_LA %>%
  rename(Value = "2015") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2015['Period'] = "2015"

year_2016 <- scraped_values_LA %>%
  rename(Value = "2016") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2016['Period'] = "2016"

year_2017 <- scraped_values_LA %>%
  rename(Value = "2017") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2017['Period'] = "2017"

year_2018 <- scraped_values_LA %>%
  rename(Value = "2018") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2018['Period'] = "2018"

year_2019 <- scraped_values_LA %>%
  rename(Value = "2019") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2019['Period'] = "2019"

year_2020 <- scraped_values_LA %>%
  rename(Value = "2020") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2020['Period'] = "2020"


scraped_values_LA <- rbind(year_2004, year_2005, year_2006, year_2007, year_2008, year_2009, year_2010,
                        year_2011, year_2012, year_2013, year_2014, year_2015, year_2016, year_2017,
                        year_2018, year_2019, year_2020)


rm(list = ls(pattern = "year"))


#### Define period for region ####

# must be a more elegant and robust way of doing this via a loop.

year_2004 <- scraped_values_region %>%
  rename(Value = "2004") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2004['Period'] = "2004"

year_2005 <- scraped_values_region %>%
  rename(Value = "2005") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2005['Period'] = "2005"

year_2006 <- scraped_values_region %>%
  rename(Value = "2006") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2006['Period'] = "2006"

year_2007 <- scraped_values_region %>%
  rename(Value = "2007") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2007['Period'] = "2007"

year_2008 <- scraped_values_region %>%
  rename(Value = "2008") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2008['Period'] = "2008"

year_2009 <- scraped_values_region %>%
  rename(Value = "2009") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2009['Period'] = "2009"

year_2010 <- scraped_values_region %>%
  rename(Value = "2010") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2010['Period'] = "2010"

year_2011 <- scraped_values_region %>%
  rename(Value = "2011") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2011['Period'] = "2011"

year_2012 <- scraped_values_region %>%
  rename(Value = "2012") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2012['Period'] = "2012"

year_2013 <- scraped_values_region %>%
  rename(Value = "2013") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2013['Period'] = "2013"

year_2014 <- scraped_values_region %>%
  rename(Value = "2014") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2014['Period'] = "2014"

year_2015 <- scraped_values_region %>%
  rename(Value = "2015") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2015['Period'] = "2015"

year_2016 <- scraped_values_region %>%
  rename(Value = "2016") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2016['Period'] = "2016"

year_2017 <- scraped_values_region %>%
  rename(Value = "2017") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2017['Period'] = "2017"

year_2018 <- scraped_values_region %>%
  rename(Value = "2018") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2018['Period'] = "2018"

year_2019 <- scraped_values_region %>%
  rename(Value = "2019") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2019['Period'] = "2019"

year_2020 <- scraped_values_region %>%
  rename(Value = "2020") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_2020['Period'] = "2020"


scraped_values_region <- rbind(year_2004, year_2005, year_2006, year_2007, year_2008, year_2009, year_2010,
                           year_2011, year_2012, year_2013, year_2014, year_2015, year_2016, year_2017,
                           year_2018, year_2019, year_2020)


rm(list = ls(pattern = "year"))


#### Combine region and LA ####

scraped_values <- rbind(scraped_values_LA, scraped_values_region)


#### Add in extra LUDA variables based off titles given above ####

scraped_values['Category']=Mission 
scraped_values['Indicator']=Metric
scraped_values['Measure']="Pounds"
scraped_values['Unit']="£" # likely a % or £. Be careful.


# No confidence interval or observation status data
scraped_values['Lower Confidence Interval (95%)'] = ""
scraped_values['Upper Confidence Interval (95%)'] = ""
scraped_values['Observation Status'] = ""

# Not always the case (use view(scraped_values) code to check) but may need to add a "Variable Name " column.
# NORMALLY A COMBINATION OF METRIC AND UNIT. 

scraped_values['Variable Name'] = "Gross Value Added (GVA) per hour worked (£)"


#### Define the level of geographical granulation - country/region/LA etc. #### 

# Also define Geography variable.

scraped_geographies <- scraped_values %>% 
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


# Format AREANM values to title case 

scraped_clean <- scraped_geographies %>% 
  mutate(AREANM = toTitleCase(AREANM))


#### Generate Lower and Upper Confiudence Interval Values ####

# no need for this metric.

#insert polarity
scraped_clean['Polarity'] = 1

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



# remove unwanted geography granulations
csv_formatted <- csv_formatted[!is.na(csv_formatted$Geography),]

# remove duplicate rows 
csv_output <- unique(csv_formatted)

# replace suppressed values (blanks in this case) to N/A
csv_output$Value[csv_output$Value == ""] <- "NA"




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

