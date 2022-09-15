#### Michael Nairn Webscraping extraction for Subnational Indicator Explorer Ingestion template R Script ####

# 25th July 2022

# For future iterations, you should just have to run the code to generate an updated output.

# This script should download webscraped data and adapt it ready for upload to Subnational Indicators Explorer.


# remove all data and clear environment

rm(list = ls())


#### Title the script by its mission and metric name ####

Mission <- "Mission 10: providing renters with clear paths to ownership, with rates of first-time buyers increasing"
Metric <- "Net additions to the housing stock"

# Metric_short is the name that the sheet will be in the human readable and jitter input files
Metric_short <- "HouseAdditions" 


#### Import data from web ####

# Set Working directory to place webscraped data files into
setwd("D:/Coding_Repos/LUDA/Webscraping/Webscraped Inputs") # please note this path will be specific for your local drive


scraped_data <- "https://www.gov.uk/government/statistical-data-sets/live-tables-on-dwelling-stock-including-vacants"

scraped_data <- "https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/1035609/Live_Table_122.ods"

filename <- "Live_Table_122.csv"

#### Import data into R ####

scraped_data <- read.csv(filename, skip =3) %>% 
  mutate(across(where(is.factor), as.character)) %>% 
  mutate(across(where(is.character), str_to_sentence)) %>% 
  mutate(across(where(is.character), str_squish)) 


#### Rename columns ####

colnames(scraped_data)[4] <- "AREACD"


colnames(scraped_data)[8:27] <- c("200102", "200203", "200304", "200405", "200506", "200607", "200708",
                                  "200809", "200910", "201011", "201112", "201213", "201314", "201415",
                                  "201516", "201617", "201718", "201819", "201920", "202021")


#### Create AREANM column ####

scraped_values <- unite(scraped_data, AREANM, c(X, Met.and.Shire.County.Totals, Lower.and.Single.Tier.Authority.Data),
                        sep = "", remove = FALSE, na.rm = TRUE)


scraped_values$AREANM <- gsub("(met county)", '', scraped_values$AREANM)   
scraped_values$AREANM <- gsub(' ua', '', scraped_values$AREANM) 



#### Define Period ####

# must be a more elegant and robust way of doing this via a loop.


year_200102 <- scraped_values %>%
  rename(Value = "200102") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_200102['Period'] = "200102"

year_200203 <- scraped_values %>%
  rename(Value = "200203") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_200203['Period'] = "200203"

year_200304 <- scraped_values %>%
  rename(Value = "200304") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_200304['Period'] = "200304"

year_200405 <- scraped_values %>%
  rename(Value = "200405") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_200405['Period'] = "200405"

year_200506 <- scraped_values %>%
  rename(Value = "200506") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_200506['Period'] = "200506"

year_200607 <- scraped_values %>%
  rename(Value = "200607") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_200607['Period'] = "200607"

year_200708 <- scraped_values %>%
  rename(Value = "200708") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_200708['Period'] = "200708"

year_200809 <- scraped_values %>%
  rename(Value = "200809") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_200809['Period'] = "200809"

year_200910 <- scraped_values %>%
  rename(Value = "200910") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_200910['Period'] = "200910"

year_201011 <- scraped_values %>%
  rename(Value = "201011") %>%
  select(all_of(c("AREACD", "AREANM", "Value")))
year_201011['Period'] = "201011"

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



scraped_years <- rbind(year_200102, year_200203, year_200304, year_200405, year_200506,
                        year_200607, year_200708, year_200809, year_200910, year_201011,
                        year_201112, year_201213, year_201314, year_201415, year_201516,
                        year_201617, year_201718, year_201819, year_201920, year_202021)


rm(list = ls(pattern = "year_"))


#### Remove blank rows - legacy of input file ####

scraped_values <- scraped_years %>%
  na_if("") %>%
  na.omit


#### Add in extra LUDA variables based off titles given above ####

scraped_values['Category']=Mission 
scraped_values['Indicator']=Metric
scraped_values['Measure']="Number"
scraped_values['Unit']="Number" # likely a % or £. Be careful.


# No confidence interval or observation status data
scraped_values['Lower Confidence Interval (95%)'] = ""
scraped_values['Upper Confidence Interval (95%)'] = ""

scraped_values <- scraped_values %>%
  mutate(`Observation Status` = case_when(Value == ".." ~ "Data not reported"))




# Not always the case (use view(scraped_values) code to check) but may need to add a "Variable Name " column.
# NORMALLY A COMBINATION OF METRIC AND UNIT. 

scraped_values['Variable Name'] = "Net additions to the housing stock (number)"


#### Define the level of geographical granulation - country/region/LA etc. #### 

# Also define Geography variable.

scraped_geographies <- scraped_values %>% 
  mutate(Geography = case_when(
    substr(as.character(AREACD), 1, 3) == "E92" ~ "Country",
    substr(as.character(AREACD), 1, 3) == "K04" ~ "Country",
    substr(as.character(AREACD), 1, 3) == "E12" ~ "Region", # this is England only. 
    substr(as.character(AREACD), 1, 3) == "W06" ~ "Unitary Authority", #Welsh LAs
    substr(as.character(AREACD), 1, 3) == "E06" ~ "Unitary Authority", # English LAs
    substr(as.character(AREACD), 1, 3) == "S12" ~ "Council Area",  # this is Scotland only 
    substr(as.character(AREACD), 1, 3) == "N09" ~ "Local Government District", # this is NI only. 
    substr(as.character(AREACD), 1, 3) == "E07" ~ "Non-metropolitan District",
    substr(as.character(AREACD), 1, 3) == "E08" ~ "Metropolitan District",
    substr(as.character(AREACD), 1, 3) == "E09" ~ "London Borough", # this is England only. 
    substr(as.character(AREACD), 1, 3) == "E10" ~ "County", # this is England only. 
    substr(as.character(AREACD), 1, 3) == "E11" ~ "Metropolitan County")) # this is England only. 




# Format AREANM values to title case 

scraped_clean <- scraped_geographies %>% 
  mutate(AREANM = toTitleCase(AREANM))


#### Generate Lower and Upper Confiudence Interval Values ####

# no need for this metric.


#insert polarity
scraped_clean['Polarity'] = 1

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



# replace suppressed values (.. in this case) to N/A
csv_output$Value[csv_output$Value == ".."] <- "NA"



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

