#### Michael Nairn Subnational Statistics Writing human readable excel file R Script ####

# 27th July 2022

# This script should import .csv data files 
  # and then export into one big excel file ready for upload to Subnational Indicators Explorer.


# remove all data and clear environment

rm(list = ls())



#### Import all meta data files #### 

setwd("D:/Coding_Repos/LUDA/Output")

metadata_files <- list.files(pattern="*.xlsx")
metadata_file_list <- lapply(metadata_files, read.delim, sep = "\t")


#### Import all csv data files #### 

setwd("D:/Coding_Repos/LUDA/Output")

# this is full time series. If want to only include most recent year of output then 
  # "../../LUDA/Output/Most Recent Year Output"


data_files <- list.files(pattern="*.csv")
data_file_list <- lapply(data_files, read.delim, sep = ",")



#### Rename Columns for Human Readable File ####

renameColumns = function(data_file_list){
  rename(data_file_list, "Area Level" = Geography,
                         "Area Code" = AREACD,
                         "Area" = AREANM,
         "Upper 95% Confidence Interval" = `Upper.Confidence.Interval..95..`,
         "Lower 95% Confidence Interval" = `Lower.Confidence.Interval..95..`)
         }

data_file_list_named = lapply(data_file_list,renameColumns)

#### Extract only necessary columns from data files ####

extractColumns = function(data_file_list_named){
  select(data_file_list_named, 
         "Area Level", 
         "Area Code", 
         "Area", 
         "Period",
         "Value",
         "Variable.Name",
         contains("Confidence"),
         "Observation.Status")
}

data_file_list_sml = lapply(data_file_list_named,extractColumns)



#### Arrange data by Area Code ####

arrangeRows = function(data_file_list_sml){
  data_file_list_sml[order(data_file_list_sml$`Area Code`),]
}

data_file_list_clean = lapply(data_file_list_sml, arrangeRows)




#### Set up working directory structure for output ####

setwd("D:/Coding_Repos/LUDA/Output/Final_Output")

# Create filename

date <- Sys.Date()

filename <- paste0(date, "_HumanReadable.xlsx")


#### Export all metadata files into excel file ####

# create workbook for file
wb <- createWorkbook()


# Add all metadata worksheets and sheet names
for(i in 1:length(metadata_file_list)) {
  addWorksheet(wb, str_sub(metadata_files[i], 1, -6))
}



# Write metadata files to new worksheets
for(i in 1:length(metadata_file_list)) {
  writeData(wb, metadata_files[i], metadata_file_list[i])
}


# Save file
saveWorkbook(wb, file = filename, overwrite = TRUE)



#### Export all data files into excel file ####


# Add all data worksheets and sheet names
  # the 1, -5 means the .csv file extension isn't added to sheet name
for(i in 1:length(data_file_list_clean)) {
  addWorksheet(wb, str_sub(data_files[i], 1, -5))
}
?addWorksheet

# Will need to pull in relevant information into top few rows. 


# Write data frames to new worksheets
  # the 1, -5 means the .csv file extension isn't added to sheet name
for(i in 1:length(data_file_list_clean)) {
  writeData(wb, str_sub(data_files[i], 1, -5), data.frame(data_file_list_clean[i]), startRow = 8, keepNA = TRUE) 
}


# Save file
saveWorkbook(wb, file = filename, overwrite = TRUE)


