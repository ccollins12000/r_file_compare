library(shiny)
library(openxlsx)

source('load_file.r')

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
       numericInput(inputId = 'start_row',
          label = 'Start Row',
          value=1,
          min=1,
          max=1048576,
          step=1
        ),
       numericInput(inputId = 'sheet',
                    label = 'Worksheet',
                    value=1,
                    min=1,
                    max=100,
                    step=1
       ),
       fileInput(inputId="file",
         label="Browse for File: ",
         accept = ".xlsx"
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
  all_file_data <- reactiveValues(files = list(), file_count=0)

  file_tab <- observeEvent(input$file, {
      #Upload File
      req(input$file)
      
      #load data
      file_info <- load_file(
        name=input$file$name, 
        path=input$file$datapath,
        start_row=input$start_row,
        sheet_index=input$sheet
        )
      all_file_data$files <- append(all_file_data$files, file_info)
      all_file_data$file_count <- all_file_data$file_count + 1
      file_id <- paste0(all_file_data$file_count, '_', input$file$name)
      
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