library(shiny)
library(openxlsx)

source('file_utilities.r')

#allow for large excel file uploads up to 1 gb
options(shiny.maxRequestSize = 1000 * 1024^2)

# Define UI
ui <- fluidPage(
   
   # Application title
   titlePanel("File Compare"),
   
   # Sidebar
   sidebarLayout(
     sidebarPanel(
       #Import first file
       fileInput(inputId="file",
                 label="Browse for File: ",
                 accept = ".xlsx"
       ),
       numericInput(inputId = 'start_row',
          label = 'Start Row',
          value=1,
          min=1,
          max=1048576,
          step=1
        ),
       selectInput(
         inputId='sheet',
         label='Worksheet',
         choices=c(),
         selected = NULL,
         multiple = FALSE
       ),
       actionButton(
         inputId="import", 
         label="Import File"
       )
     ),
      mainPanel(
        tabsetPanel(id = 'all_files',
          tabPanel("Instructions", 
            p('Upload files to begin')
          )
        )
      )
    )
  )

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  #file data
  all_file_data <- reactiveValues(files = list(), file_count=0, file_names = list())
  file_upload_options <- observeEvent(input$file, {
      req(input$file)
      
      #get names of sheets
      sheet_list = openxlsx::getSheetNames(input$file$datapath)
      updateSelectInput(
        session, 
        inputId='sheet',
        choices = sheet_list ,
        selected = sheet_list[[1]]
        )
    }
  )
    
  file_upload <- observeEvent(input$import, {
      #Upload File
      req(input$file)
    
    
    
      #load data
      file_info <- load_file(
        name=input$file$name, 
        path=input$file$datapath,
        start_row=input$start_row,
        sheet=input$sheet
        )
      all_file_data$files <- append(all_file_data$files, file_info)
      all_file_data$file_count <- all_file_data$file_count + 1
      file_id <- paste0(all_file_data$file_count, '_', input$file$name)
      all_file_data$file_names <- append(all_file_data$file_names, file_id)
      
      
      #add tqb for file contents
      insertTab(inputId = "all_files",
                tabPanel(file_id, tableOutput(outputId=file_id)),
                target='Instructions',
                position = "after")
      
      #render to table
      output[[file_id]] <- renderTable({
        file_info
      })
      
  }

  )
}

# Run the application 
shinyApp(ui = ui, server = server)