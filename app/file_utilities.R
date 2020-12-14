#janitor, openxlsx
library(tidyverse)
load_file <- function(name, path, sheet=1, start_row=1) {
  ext <- tools::file_ext(name)
  janitor::clean_names(switch(ext,
         xlsx = openxlsx::read.xlsx(
             xlsxFile=path,
             sheet=sheet,
             startRow=start_row,
             na.strings="",
             fillMergedCells = TRUE
           ),
         validate("Invalid file; Please upload a .xslx file")
  ), case = 'snake')
}

pivot_file <- function(file, key_column, keep_columns){
  file %>%
    select(keep_columns) %>%
    gather(key = 'field', value = 'value', -one_of(key_column))
}

get_common_columns <- function(data_frame_list){
  column_names = list()
  for(index in 1:length(data_frame_list)){
    column_names[[index]] <- names(data_frame_list[[index]])
  }
  Reduce(intersect, column_names)
}

join_data <- function(datasets, dataset_names, join_vector){
  
  combined_data = datasets[[1]]
  
  for(index in 2:length(datasets)){
    combined_data <- combined_data %>% 
      full_join(datasets[[index]], 
                by=join_vector, 
                #suffix not working on more than one join
                suffix =c(paste0('_', dataset_names[[index-1]]),  paste0('_', dataset_names[[index]])))
  }
  combined_data
}