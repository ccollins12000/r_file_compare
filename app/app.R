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
       fileInput(
         inputId="file",
         label="Upload Files: ",
         accept = ".xlsx"
       )
     )
      ,
      
      mainPanel(
        tabsetPanel(id = 'all_files',
                    tabPanel("Instructions", p('Upload files to begin'))
                    )
        )
        
      )
   )

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  all_file_data <- reactiveValues(files = list(), file_count=0)
  #file1###################################
  file_tab <- observeEvent(input$file, {
      req(input$file)
      
      file_info <- load_file(input$file$name, input$file$datapath)
      all_file_data$files <- append(all_file_data$files, file_info)
      all_file_data$file_count <- all_file_data$file_count + 1
      file_id <- paste0(all_file_data$file_count, '_', input$file$name)
      
      insertTab(inputId = "all_files",
                tabPanel(file_id, tableOutput(outputId=file_id)),
                target='Instructions',
                position = "after")
      
      output[[file_id]] <- renderTable({
        file_info
      })
      
  }

  )
}

# Run the application 
shinyApp(ui = ui, server = server)