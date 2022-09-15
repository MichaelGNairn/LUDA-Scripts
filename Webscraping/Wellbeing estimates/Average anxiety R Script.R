#### Michael Nairn Webscraping extraction for Subnational Indicator Explorer Ingestion template R Script ####

# 15th July 2022

# For future iterations, you should just have to run the code to generate an updated output.

# This script should download webscraped data and adapt it ready for upload to Subnational Indicators Explorer.


# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 8: improving well-being for every area in the UK by 2030"
Metric <- "Average anxiety ratings"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "Anxiety" 


#### Import data from web ####

# Set Working directory to place webscraped data files into
setwd("D:/Coding_Repos/LUDA-Scripts/Webscraping/Webscraped Inputs") # please note this path will be specific for your local drive


scraped_data <- "https://www.ons.gov.uk/peoplepopulationandcommunity/wellbeing/datasets/headlineestimatesofpersonalwellbeing"

scraped_data <- "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/wellbeing/datasets/headlineestimatesofpersonalwellbeing/april2020tomarch2021localauthorityupdate/headlineestimatespersonalwellbeing2020to2021.xlsx"

filename <- "headlineestimatespersonalwellbeing2020to2021.xlsx"

#### Import data into R ####

# LA data

tabname <- "Anxiety - Means"

scraped_data <- read.xlsx(filename, sheet = tabname, startRow =6) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


colnames(scraped_data)[1:13] <- c("AREACD", "AREANM", "Geographical designation", "201112", "201213", "201314",
                                  "201415", "201516", "201617", "201718", "201819", "201920", "202021")

scraped_values <- scraped_data[-1,] 


#### Define Period ####

# must be a more elegant and robust way of doing this via a loop.

year_201112 <- scraped_values %>%
  rename(Value = "201112") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_201112['Period'] = "201112"

year_201213 <- scraped_values %>%
  rename(Value = "201213") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_201213['Period'] = "201213"

year_201314 <- scraped_values %>%
  rename(Value = "201314") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_201314['Period'] = "201314"

year_201415 <- scraped_values %>%
  rename(Value = "201415") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_201415['Period'] = "201415"

year_201516 <- scraped_values %>%
  rename(Value = "201516") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_201516['Period'] = "201516"

year_201617 <- scraped_values %>%
  rename(Value = "201617") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_201617['Period'] = "201617"

year_201718 <- scraped_values %>%
  rename(Value = "201718") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_201718['Period'] = "201718"

year_201819 <- scraped_values %>%
  rename(Value = "201819") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_201819['Period'] = "201819"

year_201920 <- scraped_values %>%
  rename(Value = "201920") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_201920['Period'] = "201920"

year_202021 <- scraped_values %>%
  rename(Value = "202021") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_202021['Period'] = "202021"



scraped_values <- rbind(year_201112, year_201213, year_201314, year_201415, year_201516,
                        year_201617, year_201718, year_201819, year_201920, year_202021)


rm(list = ls(pattern = "year"))


#### Add in extra LUDA variables based off titles given above ####

scraped_values['Category']=Mission 
scraped_values['Indicator']=Metric
scraped_values['Measure']="Rating"
scraped_values['Unit']="Score out of 10" # likely a % or £. Be careful.


# No confidence interval or observation status data
scraped_values['Lower Confidence Interval (95%)'] = ""
scraped_values['Upper Confidence Interval (95%)'] = ""
scraped_values <- scraped_values %>%
  mutate(`Observation Status` = case_when(Value == "X" ~ "Value suppressed"))


# Not always the case (use view(scraped_values) code to check) but may need to add a "Variable Name " column.
# NORMALLY A COMBINATION OF METRIC AND UNIT. 

scraped_values['Variable Name'] = "Average anxiety rating (score out of 10)"


scraped_values$AREANM <- gsub("ireland2,3,4", "ireland", as.character(scraped_values$AREANM))

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


# removes notes from bottom of sheet
csv_output <- csv_formatted %>% 
  drop_na(AREANM)

# replace suppressed values (X in this case) to N/A
csv_output$Value[csv_output$Value == "X"] <- "NA"





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

