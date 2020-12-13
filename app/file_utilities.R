#janitor, openxlsx
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