#### Michael Nairn Subnational Statistics extracting most recent period R Script ####

# 18th August 2022

# This script should import .csv data files 
  # and then export into one big csv file ready for jitter plot creation & upload to Subnational Indicators Explorer.


# remove all data and clear environment

rm(list = ls())


#### Import all csv data files #### 

setwd("D:/Coding_Repos/LUDA/Output")


data_files <- list.files(pattern="*.csv")
data_file_list <- lapply(data_files, read.delim, sep = ",")


#### Extract only most recent year of data ####

# this works fine for when period is a number (e.g. 2021 or 202021)
# However, not for when it is a factor (e.g. 2020/21)
extractMaxYear = function(data_file_list){
  filter(data_file_list, Period == max(Period))
}

data_file_list_recent = lapply(data_file_list,extractMaxYear)



#### Arrange data by Area Code ####

arrangeRows = function(data_file_list_recent){
  data_file_list_recent[order(data_file_list_recent$`AREACD`),]
}

data_file_list_clean = lapply(data_file_list_recent, arrangeRows)



#### Set up working directory structure for output ####

setwd("D:/Coding_Repos/LUDA/Output/Most Recent Year Output")


#### Export all most recent csv files ####

for(i in 1:length(data_file_list_clean)) { 
  write.csv(data_file_list_clean[i], file = paste0(data_files[i]), row.names = FALSE)
}




