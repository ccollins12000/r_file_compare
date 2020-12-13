library(tidyverse)
library(openxlsx)


### File Parameters
file1_params = list(
  file_name='file1.xlsx',
  sheet=1,
  startRow=1,
  na.strings="",
  key_column='key_column',
  compare_columns=c('key_column', 'dimension_1', 'dimension_2', 'dimension_3')
)

file2_params = list(
  file_name='file2.xlsx',
  sheet=1,
  startRow=1,
  na.strings="",
  key_column='key_column',
  compare_columns=c('key_column', 'dimension_1', 'dimension_2', 'dimension_3')
)

#Read in files
file1 = read.xlsx(
  xlsxFile=file1_params$file_name,
  sheet=file1_params$sheet,
  startRow=file1_params$startRow,
  na.strings=file1_params$na.strings
)

file2 = read.xlsx(
  xlsxFile=file2_params$file_name,
  sheet=file2_params$sheet,
  startRow=file2_params$startRow,
  na.strings=file2_params$na.strings
)

#pivot data
pivot_file <- function(file, key_column, keep_columns){
  file %>%
    select(keep_columns) %>%
    gather(key = 'field', value = 'value', -one_of(file1_params$key_column))
}

file1_data <- pivot_file(file1, file1_params$key_column, file1_params$compare_columns)
file2_data <- pivot_file(file2, file2_params$key_column, file2_params$compare_columns)


#join data
join_on = c('field'='field')
join_on[file1_params$key_column] <- file2_params$key_column

combined_data <- file1_data %>% 
  full_join(file2_data, 
            by=join_on, 
            keep=TRUE, 
            suffix =c(paste0('_', file1_params$file_name),  paste0('_', file2_params$file_name)))

#compare data
combined_data$values_match <- 
  combined_data[paste0('value_', file1_params$file_name)] == combined_data[paste0('value_', file2_params$file_name)] 

