load_file <- function(name, path) {
  ext <- tools::file_ext(name)
  switch(ext,
         xlsx = openxlsx::read.xlsx(
           xlsxFile=path,
           sheet=1,
           startRow=1,
           na.strings=""
         ),
         validate("Invalid file; Please upload a .xslx file")
  )
}